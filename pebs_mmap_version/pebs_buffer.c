/*
 * @Date: 2023-06-08 09:20:16
 * @LastEditors: liuchang chang.liu@zhejianglab.com
 * @LastEditTime: 2023-07-12 17:46:18
 * @FilePath: /pebs/src/pebs_buffer.c
 */
#include "pebs_buffer.h"

#include <linux/cpumask.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/slab.h>
#include <linux/vmalloc.h>

#include "pebs_pub.h"
#include "pebs_taine_tool.h"

// 一个pid的字节数（64位的long long int），start_addr &
// end_addr的字节数（64位的long long int）1024-pid的个数（2的指数）
// #define RING_BUFFER_ITEM_SINGLE_SIZE_BYTES 24
// 在加上两个地址的寄存器信息 还需要144字节 总共24+144*2=312 字节
// #define RING_BUFFER_ITEM_SINGLE_SIZE_BYTES 312
// 需要在加上一些信息， 一个时间，一个距离在加上16个字节
#define RING_BUFFER_ITEM_SINGLE_SIZE_BYTES 328

// 一个环形缓存区ITEM的字节数，一个环的大小为1024个
// 1024会崩溃换用512
#define RING_BUFFER_ITEM_SINGLE_SIZE_NUM 512
#define RING_BUFFER_ITEM_TOTAL_SIZE_BYTES \
  (RING_BUFFER_ITEM_SINGLE_SIZE_BYTES * RING_BUFFER_ITEM_SINGLE_SIZE_NUM)

typedef struct buffer_item {
  // item的内存基址
  uint64_t* buffer_item_base;

  // 读指针index，指向最近一次读取的位置
  int64_t read_index;

  // 写指针index，指向可写入的位置
  int64_t write_index;

} buffer_item_t;

typedef struct ring_buffers {
  // buffer的内存基址指针
  uint32_t* buffer_base;

  // ring_buffer的个数
  uint32_t item_size;

  // 结构体数组（最多支持100个核）
  buffer_item_t items[100];
} ring_buffers_t;

ring_buffers_t buffers;

#define PER_CPU_ANALYZE_RING_BUFFER_SIZE 64
#define PER_CPU_SINGLE_ANALYZE_BUFFER_SIZE 256
typedef struct single_analyze_buffer {
  // 32位cache miss addr 32位branch miss addr
  uint64_t info;
  // 出现的次数
  uint32_t num;
} single_analyze_buffer_t;
typedef struct per_cpu_buffer {
  // 进程的pid
  uint32_t pid;

  uint32_t index;
  // 进程中cachemiss branchmiss的信息
  single_analyze_buffer_t analyze_buffer[PER_CPU_SINGLE_ANALYZE_BUFFER_SIZE];
} per_cpu_buffer_t;
typedef struct analyze_ring_buffer {
  // 缓冲区的基址
  per_cpu_buffer_t* buffer_base;
  uint32_t item_size;
  // 指针指向基址的某一个位置
  per_cpu_buffer_t* ring_buffer[100];
  int per_cpu_buffer_index[100];
} analyze_ring_buffer_t;

analyze_ring_buffer_t analyze_res_ring_buffer;

// cat /proc/sys/kernel/pid_max
// #define MAX_PID_SIZE 4194304
/**
 * @brief 分配ring buffer空间
 *
 */
int alloc_ring_buffer(void) {
  // 可用的cpu核数
  uint32_t num;
  short index;
  num = num_online_cpus();
  buffers.buffer_base = NULL;
  if (num > 100) {
    // printk(KERN_ERR "ring buffer max size is 100....");
    return 0;
  }
  //分配去重用的空间
  if (analyze_res_ring_buffer.buffer_base == NULL) {
    analyze_res_ring_buffer.buffer_base = vmalloc(
        sizeof(per_cpu_buffer_t) * num * PER_CPU_ANALYZE_RING_BUFFER_SIZE);
    if (analyze_res_ring_buffer.buffer_base == NULL) {
      return 0;
    }
    memset(analyze_res_ring_buffer.buffer_base, 0,
           sizeof(per_cpu_buffer_t) * num * PER_CPU_ANALYZE_RING_BUFFER_SIZE);
    analyze_res_ring_buffer.item_size = num;
    index = 0;
    for (; index < num; ++index) {
      analyze_res_ring_buffer.ring_buffer[index] =
          analyze_res_ring_buffer.buffer_base +
          index * PER_CPU_ANALYZE_RING_BUFFER_SIZE;
      analyze_res_ring_buffer.per_cpu_buffer_index[index] = 0;
    }
  }

  // 分配连续的内存空间
  buffers.buffer_base =
      (uint32_t*)kmalloc(num * RING_BUFFER_ITEM_TOTAL_SIZE_BYTES, GFP_KERNEL);

  if (buffers.buffer_base == NULL) {
    vfree(analyze_res_ring_buffer.buffer_base);
    analyze_res_ring_buffer.buffer_base = NULL;
    return 0;
  }

  buffers.item_size = num;

  index = 0;
  for (; index < num; index++) {
    buffers.items[index].read_index = -1;
    buffers.items[index].write_index = 0;
    // 因为buffers.buffer_base
    // 指针是32为int，所以在执行加法时，需要除以字节数（4）
    buffers.items[index].buffer_item_base =
        (uint64_t*)(buffers.buffer_base +
                    (index * RING_BUFFER_ITEM_TOTAL_SIZE_BYTES / 4));
  }
  return 1;
}

/**
 * 释放buffer ring空间
 */
void free_ring_buffer(void) {
  short index;
  buffers.item_size = 0;
  if (buffers.buffer_base != NULL) {
    kfree((void*)buffers.buffer_base);
    buffers.buffer_base = NULL;
  }

  if (analyze_res_ring_buffer.buffer_base != NULL) {
    vfree(analyze_res_ring_buffer.buffer_base);
    analyze_res_ring_buffer.buffer_base = NULL;
  }

  // 重置数据
  index = 0;
  for (; index < 100; index++) {
    buffer_item_t item = buffers.items[index];
    item.read_index = -1;
    item.write_index = 0;
    item.buffer_item_base = NULL;
  }
}

/**
 * 将pid写入到内存区域中
 */
void write_ring_buffer(unsigned int pid, unsigned long long int start_addr,
                       unsigned long long int end_addr,
                       register_info_t* start_info, register_info_t* end_info,
                       unsigned int time, unsigned int distance, char flag) {
  // printk(KERN_INFO "begin to write\n");

  // 禁止套圈
  int cpu_id = get_cpu();
  buffer_item_t item = buffers.items[cpu_id];
  //进行去重操作
  {
    //先搜寻pid
    int need_to_insert = 0;
    int cpu_index = 0;
    int pid_index;
    int find = 0;
    int insert_id;
    //循环每个cpu
    for (; cpu_index < analyze_res_ring_buffer.item_size; ++cpu_index) {
      pid_index = 0;
      //循环每个cpu管辖的区域
      for (; pid_index < PER_CPU_ANALYZE_RING_BUFFER_SIZE; ++pid_index) {
        per_cpu_buffer_t* pid_buffer =
            analyze_res_ring_buffer.ring_buffer[cpu_index] + pid_index;
        // linux pid递增
        if (pid_buffer->pid == 0) {
          break;
        }
        //找到pid的情况下
        if (pid_buffer->pid == pid) {
          single_analyze_buffer_t* tmp;
          int index_2;
          uint32_t min_num;
          find = 1;
          //继续搜索地址
          tmp = pid_buffer->analyze_buffer;
          index_2 = 0;
          insert_id = -1;
          min_num = tmp[0].num;
          for (; index_2 < PER_CPU_SINGLE_ANALYZE_BUFFER_SIZE; ++index_2) {
            uint32_t num;
            uint64_t info;
            num = tmp[index_2].num;
            info = tmp[index_2].info;
            if (num == 0) {
              insert_id = index_2;
              break;
            }
            if ((((info & 0xffffffff00000000LL) >> 32) ==
                 (start_addr & 0xffffffffll)) &&
                ((info & 0xffffffffLL) == (end_addr & 0xffffffffLL))) {
              tmp->num += 1;
              insert_id = -1;
              break;
            }
            if (num < min_num) {
              min_num = num;
              insert_id = index_2;
            }
          }
          //需要插入数据
          if (insert_id != -1) {
            // 判断当前缓冲区有没有多余的空间
            if (((item.write_index + 1) % RING_BUFFER_ITEM_SINGLE_SIZE_NUM) ==
                item.read_index) {
              // printk(KERN_INFO "%d buffer overwrite", cpu_id);
              return;
            }
            need_to_insert = 1;
            tmp[insert_id].num = 1;
            tmp[insert_id].info =
                ((start_addr & 0xffffffffLL) << 32) + (end_addr & 0xffffffffLL);
          }
          break;
        }
      }
      if (find > 0) {
        break;
      }
    }
    //没有找到pid的情况下
    if (find == 0) {
      per_cpu_buffer_t* tmp;
      // 判断当前缓冲区有没有多余的空间
      if (((item.write_index + 1) % RING_BUFFER_ITEM_SINGLE_SIZE_NUM) ==
          item.read_index) {
        // printk(KERN_INFO "%d buffer overwrite", cpu_id);
        return;
      }
      need_to_insert = 1;
      tmp = analyze_res_ring_buffer.ring_buffer[cpu_id] +
            analyze_res_ring_buffer.per_cpu_buffer_index[cpu_id];
      tmp->pid = pid;
      analyze_res_ring_buffer.per_cpu_buffer_index[cpu_id] =
          (analyze_res_ring_buffer.per_cpu_buffer_index[cpu_id] + 1) %
          PER_CPU_ANALYZE_RING_BUFFER_SIZE;
      tmp->analyze_buffer[0].num = 1;
      tmp->analyze_buffer[0].info =
          ((start_addr & 0xffffffffLL) << 32) + (end_addr & 0xffffffffLL);
      tmp->index = 1;
    }
    if (need_to_insert == 0) {
      return;
    }
  }
  // 写入值
  {
    if (flag > 0) {
      printk(KERN_INFO "spec insert\n");
    }
    uint64_t* cur_p;
    cur_p = item.buffer_item_base +
            (item.write_index * RING_BUFFER_ITEM_SINGLE_SIZE_BYTES / 8);
    *(cur_p) = ((uint64_t)pid);
    *(cur_p + 1) = start_addr;
    *(cur_p + 2) = end_addr;

    memcpy(cur_p + 3, start_info, sizeof(uint64_t) * 18);
    memcpy(cur_p + 21, end_info, sizeof(uint64_t) * 18);
    *(cur_p + 39) = ((uint64_t)time);
    *(cur_p + 40) = ((uint64_t)distance);

    buffers.items[cpu_id].write_index =
        (item.write_index + 1) & (RING_BUFFER_ITEM_SINGLE_SIZE_NUM - 1);
  }
}
// int find_ring_buffer(unsigned int pid, unsigned long long int start_addr,
//                      unsigned long long int end_addr) {
//   //
//   int cpu_id = get_cpu();
//   buffer_item_t item = buffers.items[cpu_id];
//   // 无元素可读
//   if (item.read_index == (item.write_index - 1)) {
//     // printk(KERN_INFO "no data\n");
//     return -1;
//   }
//   int index = item.read_index;
//   while (index != (item.write_index - 1)) {

//   }
// }

/**
 * 读取指定ring_buffer_id的一个元素，如果无元素可读，则返回-1
 */
unsigned char read_ring_buffer(unsigned int ring_buffer_id, unsigned int* pid,
                               unsigned long long int* start_addr,
                               unsigned long long int* end_addr,
                               register_info_t* start_info,
                               register_info_t* end_info, unsigned int* time,
                               unsigned int* distance) {
  buffer_item_t item;
  uint64_t* cur_p;
  if (ring_buffer_id > (buffers.item_size - 1)) {
    // printk(KERN_INFO "ring_buffer_id err\n");
    return -1;
  }

  item = buffers.items[ring_buffer_id];
  // 无元素可读
  if (((item.read_index + 1) & (RING_BUFFER_ITEM_SINGLE_SIZE_NUM - 1)) ==
      item.write_index) {
    // printk(KERN_INFO "no data\n");
    return -1;
  }

  item.read_index =
      (item.read_index + 1) & (RING_BUFFER_ITEM_SINGLE_SIZE_NUM - 1);
  cur_p = item.buffer_item_base +
          item.read_index * RING_BUFFER_ITEM_SINGLE_SIZE_BYTES / 8;
  *(pid) = (uint32_t)(*(cur_p));
  *(start_addr) = *(cur_p + 1);
  *(end_addr) = *(cur_p + 2);

  memcpy(start_info, cur_p + 3, sizeof(uint64_t) * 18);
  memcpy(end_info, cur_p + 21, sizeof(uint64_t) * 18);
  *(time) = (uint32_t)(*(cur_p + 39));
  *(distance) = (uint32_t)(*(cur_p + 40));

  buffers.items[ring_buffer_id].read_index = item.read_index;

  return 0;
}
void print_buffer_data(unsigned int ring_buffer_id) {
  buffer_item_t item;
  if (ring_buffer_id > (buffers.item_size - 1)) {
    return;
  }

  item = buffers.items[ring_buffer_id];
  // 无元素可读
  if (item.read_index == (item.write_index - 1)) {
    return;
  }
}