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


#define RING_BUFFER_ITEM_SINGLE_SIZE_BYTES 312
// 
// #define RING_BUFFER_ITEM_SINGLE_SIZE_BYTES 328

// 
// 
#define RING_BUFFER_ITEM_SINGLE_SIZE_NUM 512
#define RING_BUFFER_ITEM_TOTAL_SIZE_BYTES \
  (RING_BUFFER_ITEM_SINGLE_SIZE_BYTES * RING_BUFFER_ITEM_SINGLE_SIZE_NUM)

typedef struct buffer_item {
  // 
  uint64_t* buffer_item_base;

  // 
  int64_t read_index;

  // 
  int64_t write_index;

} buffer_item_t;

typedef struct ring_buffers {
  // 
  uint32_t* buffer_base;

  // 
  uint32_t item_size;

  // 
  buffer_item_t items[100];
} ring_buffers_t;

ring_buffers_t buffers;

#define PER_CPU_ANALYZE_RING_BUFFER_SIZE 64
#define PER_CPU_SINGLE_ANALYZE_BUFFER_SIZE 256
typedef struct single_analyze_buffer {
  // 
  uint64_t info;
  // 
  uint32_t num;
  uint32_t eflag;
} single_analyze_buffer_t;
typedef struct per_cpu_buffer {
  // 
  uint32_t pid;
  
  uint32_t index;
  // 
  single_analyze_buffer_t analyze_buffer[PER_CPU_SINGLE_ANALYZE_BUFFER_SIZE];
} per_cpu_buffer_t;
typedef struct analyze_ring_buffer {
  // 
  per_cpu_buffer_t* buffer_base;
  uint32_t item_size;
  // 
  per_cpu_buffer_t* ring_buffer[100];
  int per_cpu_buffer_index[100];
} analyze_ring_buffer_t;

analyze_ring_buffer_t analyze_res_ring_buffer;

// cat /proc/sys/kernel/pid_max
// #define MAX_PID_SIZE 4194304
/**
 * @brief 
 *
 */
int alloc_ring_buffer(void) {
  // 
  uint32_t num;
  short index;
  num = num_online_cpus();
  buffers.buffer_base = NULL;
  if (num > 100) {
    // printk(KERN_ERR "ring buffer max size is 100....");
    return 0;
  }
  //
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

  // 
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
    // 
    // 
    buffers.items[index].buffer_item_base =
        (uint64_t*)(buffers.buffer_base +
                    (index * RING_BUFFER_ITEM_TOTAL_SIZE_BYTES / 4));
  }
  return 1;
}

/**
 * 
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

  // 
  index = 0;
  for (; index < 100; index++) {
    buffer_item_t item = buffers.items[index];
    item.read_index = -1;
    item.write_index = 0;
    item.buffer_item_base = NULL;
  }
}


void write_ring_buffer(int cpu_id, unsigned int pid, unsigned long long int start_addr,
                       unsigned long long int end_addr,
                       register_info_t* start_info, register_info_t* end_info,
                       char is_find) {
  // printk(KERN_INFO "begin to write\n");

  // 
  buffer_item_t item = buffers.items[cpu_id];
  //
  {
    //
    int need_to_insert = 0;
    int cpu_index = 0;
    int pid_index;
    int find = 0;
    int insert_id;
    //
    for (; cpu_index < analyze_res_ring_buffer.item_size; ++cpu_index) {
      pid_index = 0;
      //
      for (; pid_index < PER_CPU_ANALYZE_RING_BUFFER_SIZE; ++pid_index) {
        per_cpu_buffer_t* pid_buffer =
            analyze_res_ring_buffer.ring_buffer[cpu_index] + pid_index;
        // 
        if (pid_buffer->pid == 0) {
          break;
        }
        //
        if (pid_buffer->pid == pid) {
          single_analyze_buffer_t* tmp;
          int index_2;
          uint32_t min_num;
          find = 1;
          //
          tmp = pid_buffer->analyze_buffer;
          index_2 = 0;
          insert_id = -1;
          min_num = tmp[0].num;
          for (; index_2 < PER_CPU_SINGLE_ANALYZE_BUFFER_SIZE; ++index_2) {
            uint32_t num;
            uint32_t eflag;
            uint64_t info;

            num = tmp[index_2].num;
            info = tmp[index_2].info;

            if (num == 0) {
              insert_id = index_2;
              break;
            }
            if ((((info & 0xffffffff00000000LL) >> 32) ==
                 (start_addr & 0xffffffffll)) &&
                ((info & 0xffffffffLL) == (end_addr & 0xffffffffLL)) &&
                ((eflag) == (end_info->RFLAGS & 0xffffffffLL))) {
              tmp->num += 1;
              insert_id = -1;
              break;
            }
            if (num < min_num) {
              min_num = num;
              insert_id = index_2;
            }
          }
          //
          if (insert_id != -1) {
            // 
            if (((item.write_index + 1) % RING_BUFFER_ITEM_SINGLE_SIZE_NUM) ==
                item.read_index) {
              if(is_find){
// printk(KERN_INFO "%d buffer overwrite", cpu_id);
              }
              
              return;
            }
            need_to_insert = 1;
            tmp[insert_id].num = 1;
            tmp[insert_id].eflag = end_info->RFLAGS & 0xffffffffLL;
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
    //
    if (find == 0) {
      per_cpu_buffer_t* tmp;
      // 
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
      tmp->analyze_buffer[0].eflag = end_info->RFLAGS & 0xffffffffLL;
      tmp->analyze_buffer[0].info =
          ((start_addr & 0xffffffffLL) << 32) + (end_addr & 0xffffffffLL);

      tmp->index = 1;
    }
    if (need_to_insert == 0) {
      return;
    }
  }
  
  {

    uint64_t* cur_p;
    cur_p = item.buffer_item_base +
            (item.write_index * RING_BUFFER_ITEM_SINGLE_SIZE_BYTES / 8);
    *(cur_p) = ((uint64_t)pid);
    *(cur_p + 1) = start_addr;
    *(cur_p + 2) = end_addr;

    memcpy(cur_p + 3, start_info, sizeof(uint64_t) * 18);
    memcpy(cur_p + 21, end_info, sizeof(uint64_t) * 18);

    buffers.items[cpu_id].write_index =
        (item.write_index + 1) & (RING_BUFFER_ITEM_SINGLE_SIZE_NUM - 1);
  }
}

/**
 * 
 */
unsigned char read_ring_buffer(unsigned int ring_buffer_id, unsigned int* pid,
                               unsigned long long int* start_addr,
                               unsigned long long int* end_addr,
                               register_info_t* start_info,
                               register_info_t* end_info) {
  buffer_item_t item;
  uint64_t* cur_p;
  if (ring_buffer_id > (buffers.item_size - 1)) {
    // printk(KERN_INFO "ring_buffer_id err\n");
    return -1;
  }

  item = buffers.items[ring_buffer_id];
  // 
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

  buffers.items[ring_buffer_id].read_index = item.read_index;

  return 0;
}
void print_buffer_data(unsigned int ring_buffer_id) {
  buffer_item_t item;
  if (ring_buffer_id > (buffers.item_size - 1)) {
    return;
  }

  item = buffers.items[ring_buffer_id];
  //
  if (item.read_index == (item.write_index - 1)) {
    return;
  }
}
