#include "pebs_init.h"

#include "pebs_buffer.h"
#include "pebs_message_send.h"
#include "pebs_taine.h"
#include "pebs_taine_tool.h"

// typedef struct single_analyze_buffer {
//   uint64_t info;
//   uint32_t num;
// } single_analyze_buffer_t;

// single_analyze_buffer_t *analyze_res_buffer = NULL;
// #define SINGLE_BUFFER_SIZE 256

// 引入外部定义钩子

extern void (*pebs_handler)(void);

// pebs记录的大小---64个字节按照basic_info(32) + mem_info(32)计算
// 208是再加上GPRS后的大小
static uint32_t pebs_record_size = 208;

// 定义CPU本地变量，指向ds struct区域的指针
static DEFINE_PER_CPU(debug_store_t *, cpu_ds_p);

static DEFINE_PER_CPU(uint64_t, cpu_old_ds);

// 线程
static struct task_struct *analyze_pthread = NULL;
static char analyze_pthread_need_to_stop = 0;

// static char error = 0;

// 缓存区记录总数
// static atomic_t total = ATOMIC_INIT(0);

EXPORT_SYMBOL_GPL(pebs_record_handler);

/**
 * @brief 校验是否有其他程序使用PMU
 *
 * @return true
 * @return false
 */
static bool check(void) {
  uint64_t val;

  // 1. 校验是否有其他程序使用PMU
  rdmsrl(MSR_PERFEVTSEL0, val);
  if (((val >> 22) & 0x1) == 1) {
    printk(KERN_INFO "cpu-%d:Someone else using perf counter 0\n", get_cpu());
    return false;
  }

  val = (uint64_t)0;
  rdmsrl(MSR_PERFEVTSEL1, val);
  if (((val >> 22) & 0x1) == 1) {
    printk(KERN_INFO "cpu-%d:Someone else using perf counter 1\n", get_cpu());
    return false;
  }

  return true;
}
/**
 * @brief 返回指定的branch miss事件编码
 *
 * @return uint64_t
 */
static uint64_t cal_branch_miss_ctrl_val(int is_pcore) {
  uint64_t ctrl_val = 0x00;

  // 设置事件类型
  ctrl_val |= (0x000000FF & BRANCH_MISS_EVENT_TYPE);

  // 设置事件掩码
  if (is_pcore) {
    ctrl_val |= (0x0000FF00 & (BRANCH_MISS_UMASK_PCORE << 8));
  } else {
    ctrl_val |= (0x0000FF00 & (BRANCH_MISS_UMASK_ECORE << 8));
  }
  // ctrl_val |= (0x0000FF00 & (BRANCH_MISS_UMASK_PCORE << 8));

  // 设置开启用户态监控模式
  ctrl_val |= (1 << 16);

  // 设置监控边缘触发事件
  ctrl_val |= (1 << 18);

  // 设置性能计数器为生效状态
  ctrl_val |= (1 << 22);

  // ADEPTIVE record
  ctrl_val |= (((uint64_t)1) << 34);

  return ctrl_val;
}

/**
 * @brief 返回指定的cache miss事件编码
 *
 * @return uint64_t
 */
static uint64_t cal_cache_miss_ctrl_val(int is_pcore) {
  uint64_t ctrl_val = 0x00;

  // 设置事件类型
  ctrl_val |= (0x000000FF & CACHE_MISS_EVENT_TYPE);

  // 设置事件掩码
  if (is_pcore) {
    ctrl_val |= (0x0000FF00 & (CACHE_MISS_UMASK_PCORE << 8));
  } else {
    ctrl_val |= (0x0000FF00 & (CACHE_MISS_UMASK_ECORE << 8));
  }
  // ctrl_val |= (0x0000FF00 & (CACHE_MISS_UMASK_PCORE << 8));

  // 设置开启用户态监控模式
  ctrl_val |= (1 << 16);

  // 设置监控边缘触发事件
  ctrl_val |= (1 << 18);

  // 设置性能计数器为生效状态
  ctrl_val |= (1 << 22);

  // ADEPTIVE record
  ctrl_val |= (((uint64_t)1) << 34);

  return ctrl_val;
}

// static void print_ds_info(void) {
//   debug_store_t *ds_p = __this_cpu_read(cpu_ds_p);
//   if (ds_p != NULL) {
//     printk(KERN_INFO
//            "cpu-%d:debug_store info: "
//            "pebs_base=%llx,pebs_index=%llx,pebs_max=%llx,pebs_thresh=%llx,pebs_"
//            "counter_0=%llx,pebs_counter_1=%llx\n",
//            get_cpu(), ds_p->pebs_base, ds_p->pebs_index, ds_p->pebs_max,
//            ds_p->pebs_thresh, ds_p->pebs_counter_reset[0],
//            ds_p->pebs_counter_reset[1]);
//   } else {
//     printk(KERN_ERR "cpu-%d:ds_p is NULL.\n", get_cpu());
//   }
// }

// static void print_msr_info(void) {
//   printk(KERN_INFO "cpu-%d:---------------msr info-------------\n",
//   get_cpu()); uint64_t val; rdmsrl(MSR_PERFEVTSEL0, val); printk(KERN_INFO
//   "cpu-%d:MSR_PERFEVTSEL0(%llx)=%llx\n", get_cpu(),
//          MSR_PERFEVTSEL0, val);

//   rdmsrl(MSR_PERFEVTSEL1, val);
//   printk(KERN_INFO "cpu-%d:MSR_PERFEVTSEL1(%llx)=%llx\n", get_cpu(),
//          MSR_PERFEVTSEL1, val);

//   rdmsrl(MSR_PEBS_ENABLE, val);
//   printk(KERN_INFO "cpu-%d:MSR_PEBS_ENABLE(%llx)=%llx\n", get_cpu(),
//          MSR_PEBS_ENABLE, val);

//   rdmsrl(MSR_GP_COUNT_PMC0, val);
//   printk(KERN_INFO "cpu-%d:MSR_GP_COUNT_PMC0(%llx)=%llx\n", get_cpu(),
//          MSR_GP_COUNT_PMC0, val);

//   rdmsrl(MSR_GP_COUNT_PMC1, val);
//   printk(KERN_INFO "cpu-%d:MSR_GP_COUNT_PMC1(%llx)=%llx\n", get_cpu(),
//          MSR_GP_COUNT_PMC1, val);

//   rdmsrl(MSR_DS_AREA, val);
//   printk(KERN_INFO "cpu-%d:MSR_DS_AREA(%llx)=%llx\n", get_cpu(), MSR_DS_AREA,
//          val);

//   rdmsrl(MSR_PERF_CAPABILITIES, val);
//   printk(KERN_INFO "cpu-%d:MSR_PERF_CAPABILITIES(%llx)=%llx\n", get_cpu(),
//          MSR_PERF_CAPABILITIES, val);

//   rdmsrl(MSR_PEBS_DATA_CFG, val);
//   printk(KERN_INFO "cpu-%d:MSR_PEBS_DATA_CFG(%llx)=%llx\n", get_cpu(),
//          MSR_PEBS_DATA_CFG, val);

//   printk(KERN_INFO "cpu-%d:---------------msr info-------------\n",
//   get_cpu());
// }

// static void print_pebs_buffer_records(void) {
//   debug_store_t *ds_p = __this_cpu_read(cpu_ds_p);
//   if (ds_p != NULL) {
//     uint64_t cur_addr = ds_p->pebs_base;
//     uint64_t end_addr = ds_p->pebs_index;
//     // printk(KERN_INFO "cpu-%d:PEBS record info: start_addr=%llx,
//     // end_addr=%llx\n",get_cpu(),cur_addr,end_addr);

//     uint64_t *cur_p = cur_addr;
//     // basic_info 和 mem_info各占32个字节，因此一条记录是64个字节
//     uint64_t total_rec_count = (end_addr - cur_addr) / pebs_record_size;
//     // printk(KERN_INFO "cpu-%d:pebs buffer record
//     // count:%lld\n",get_cpu(),total_rec_count);

//     uint64_t i = 0;
//     uint64_t count = total_rec_count * 8;
//     while (i < count) {
//       uint64_t val = *(cur_p + i);
//       if ((val & 0xff) == 0xd5 || (val & 0xff) == 0xe1) {
//         // 输出record的值（按照8字节一条数据的方式）
//         // printk(KERN_INFO "cpu-%d:address:%llx,PEBS record
//         // value:%llx(target)\n",get_cpu(),(cur_p+i),*(cur_p+i));
//       } else {
//         //    printk(KERN_INFO "cpu-%d:address:%llx,PEBS record
//         //    value:%llx\n",get_cpu(),(cur_p+i),*(cur_p+i));
//       }

//       i++;
//     }
//   }
// }

/**
 * @brief 设置ds_buffer内存区域
 *
 * @return true
 * @return false
 */
static bool set_ds_buffer(void) {
  // 申请DS结构体内存,GFP_KERNEL表示内核内存空间分配模式
  debug_store_t *ds_p = kmalloc(sizeof(debug_store_t), GFP_KERNEL);
  uint64_t pebs_max_num;
  if (ds_p != NULL) {
    // printk(KERN_INFO "cpu-%d:debug_store kmalloc success.
    // address=%llx\n",get_cpu(),ds_p);
  } else {
    // printk(KERN_ERR "cpu-%d:debug_store kmalloc failed.",get_cpu());
    return false;
  }
  memset(ds_p, 0, sizeof(debug_store_t));

  // 申请PEBS record buffer区域内存
  ds_p->pebs_base = (uint64_t)kmalloc(PEBS_BUFFER_SIZE_BYTE, GFP_KERNEL);
  if (ds_p->pebs_base != 0) {
    // printk(KERN_INFO "cpu-%d:pebs buffer kmalloc success.
    // address=%llx\n",get_cpu(),ds_p->pebs_base);
  } else {
    // printk(KERN_ERR "cpu-%d:pebs buffer kmalloc failed.",get_cpu());
    return false;
  }
  memset((void *)ds_p->pebs_base, 0, PEBS_BUFFER_SIZE_BYTE);

  // 设置DS的其他值
  pebs_max_num = PEBS_BUFFER_SIZE_BYTE / pebs_record_size;
  ds_p->pebs_index = ds_p->pebs_base;
  ds_p->pebs_max = ds_p->pebs_base + (pebs_max_num - 1) * pebs_record_size;

  // 触发PEBS Buffer 中断的阀值
  // ds_p->pebs_thresh = ds_p->pebs_base + (pebs_max_num - pebs_max_num/10) *
  // pebs_record_size ;
  ds_p->pebs_thresh = ds_p->pebs_max;

  ds_p->pebs_counter_reset[0] = -(int64_t)PERIOD;
  ds_p->pebs_counter_reset[1] = -(int64_t)PERIOD;

  // 写入到本地CPU变量中
  __this_cpu_write(cpu_ds_p, ds_p);

  // print_ds_info();

  return true;
}

/**
 * @brief 初始化pebs寄存器
 *
 * @param arg
 */
static void pebs_mod_init_each_cpu(void *arg) {
  char cpu_id = get_cpu();
  unsigned int eax, ebx, ecx, edx;
  // unsigned int model;
  uint64_t old_ds;
  debug_store_t *ds_p;
  printk(KERN_INFO "cpu-%d:*************PEBS module load start!*************\n",
         cpu_id);

  // 校验 并做一些计算全局变量操作
  if (check() == false) {
    return;
  }

  // 申请和设置DS buffer区域相关信息
  ds_p = __this_cpu_read(cpu_ds_p);
  if (ds_p == NULL) {
    if (set_ds_buffer() == false) {
      return;
    }
  }

  //将Buffer首地址设置到IA32_DS_AREA寄存器中。
  rdmsrl(MSR_DS_AREA, old_ds);
  //将旧值暂存
  __this_cpu_write(cpu_old_ds, old_ds);
  wrmsrl(MSR_DS_AREA, (uint64_t)__this_cpu_read(cpu_ds_p));

  //设置PEBS record关注的信息
  // 只关注basic和memory，basic_info默认开启，memory_info控制位为最低位
  // 新增关注GPRS，控制位为倒数第二位
  wrmsrl(MSR_PEBS_DATA_CFG, (uint64_t)3);

  // 先禁用PMU功能（对应MSR_PERFEVTSEL0&1的计数器Enable字段设置为0）
  wrmsrl(MSR_PERF_GLOBAL_CTRL, 0);

  cpuid(2, &eax, &ebx, &ecx, &edx);
  if (ebx != 0) {
    uint64_t cache_miss_val;
    uint64_t branch_miss_val;
    //当前是pcore
    // 设置关注的事件类型
    cache_miss_val = cal_cache_miss_ctrl_val(1);
    // printk(KERN_INFO "cpu-%d:cache_miss MSR_PERFEVTSEL0
    // val=%llx\n",get_cpu(), cache_miss_val);
    wrmsrl(MSR_PERFEVTSEL0, cache_miss_val);

    branch_miss_val = cal_branch_miss_ctrl_val(1);
    // printk(KERN_INFO "cpu-%d:branch_miss MSR_PERFEVTSEL1
    // val=%llx\n",get_cpu(), branch_miss_val);
    wrmsrl(MSR_PERFEVTSEL1, branch_miss_val);
  } else {
    //当前是ecore
    // 设置关注的事件类型
    uint64_t cache_miss_val;
    uint64_t branch_miss_val;
    cache_miss_val = cal_cache_miss_ctrl_val(0);
    // printk(KERN_INFO "cpu-%d:cache_miss MSR_PERFEVTSEL0
    // val=%llx\n",get_cpu(), cache_miss_val);
    wrmsrl(MSR_PERFEVTSEL0, cache_miss_val);

    branch_miss_val = cal_branch_miss_ctrl_val(0);
    // printk(KERN_INFO "cpu-%d:branch_miss MSR_PERFEVTSEL1
    // val=%llx\n",get_cpu(), branch_miss_val);
    wrmsrl(MSR_PERFEVTSEL1, branch_miss_val);
  }
  // model = (eax >> 4) & 0xF;
  // printk(KERN_INFO "CPUID Model 值: %u\n", model);
  // unsigned long long msr_value;
  // rdmsrl(MSR_IA32_MISC_ENABLE, msr_value);
  // // Alder Lake架构中，P-core的第21位为1，E-core的第22位为1
  // if (msr_value & (1ULL << 21)) {
  //   printk(KERN_INFO "CPU %d: P-core detected \n", cpu_id);
  // } else if (msr_value & (1ULL << 22)) {
  //   printk(KERN_INFO "CPU %d: E-core detected \n", cpu_id);
  // } else {
  //   printk(KERN_INFO "CPU %d: Unknown core type \n", cpu_id);
  // }

  // 设置PMC0、PMC1计数器的初始值
  wrmsrl(MSR_GP_COUNT_PMC0, -(int64_t)PERIOD);
  wrmsrl(MSR_GP_COUNT_PMC1, -(int64_t)PERIOD);

  // 启用PEBS功能（开启PMC0&PMC1的PEBS能力）
  wrmsrl(MSR_PEBS_ENABLE, 0x03);

  // 启用PMU功能（对应MSR_PERFEVTSEL0&1的计数器Enable字段设置为1）
  wrmsrl(MSR_PERF_GLOBAL_CTRL, 0x03);

  // print_msr_info();

  // printk(KERN_INFO "cpu-%d:*************PEBS module load
  // success!*************\n",get_cpu());
}

/**
 * @brief 重置pebs
 *
 */
static void pebs_reset(void) {
  wrmsrl(MSR_PERF_GLOBAL_CTRL, (uint64_t)0);
  wrmsrl(MSR_PEBS_ENABLE, (uint64_t)0);
  wrmsrl(MSR_PERFEVTSEL0, (uint64_t)0);
  wrmsrl(MSR_PERFEVTSEL1, (uint64_t)0);
  wrmsrl(MSR_GP_COUNT_PMC0, (uint64_t)0);
  wrmsrl(MSR_GP_COUNT_PMC1, (uint64_t)0);
  wrmsrl(MSR_PEBS_DATA_CFG, (uint64_t)0);
  wrmsrl(MSR_DS_AREA, __this_cpu_read(cpu_old_ds));

  // print_msr_info();
}

static void pebs_mod_exit_each_cpu(void *arg) {
  uint64_t val_addr;
  debug_store_t *ds_p;
  rdmsrl(MSR_DS_AREA, val_addr);

  // 重置各种MSR值
  pebs_reset();

  // 释放为DS申请的内核内存空间
  ds_p = __this_cpu_read(cpu_ds_p);
  if (ds_p != NULL) {
    if ((void *)ds_p->pebs_base != NULL) {
      kfree((void *)ds_p->pebs_base);
    }
    kfree(ds_p);
    ds_p = NULL;
    __this_cpu_write(cpu_ds_p, ds_p);
  }
}

/**
 * @brief 初始化pebs模块
 *
 * @return int
 */
int pebs_mod_init(void) {
  // 对每一个CPU进行初始化设置
  analyze_pthread_need_to_stop = 0;
  on_each_cpu(pebs_mod_init_each_cpu, NULL, 1);

  // 申请一片公共的内存区域用于存放筛选后的数据
  if (alloc_ring_buffer()) {
    if (alloc_taine_analyze_list()) {
      //内存分配成功则设置内核钩子处理函数
      printk(KERN_INFO "alloc memory succ");
      pebs_handler = pebs_record_handler;
      analyze_pthread = kthread_run(thread_analyze_func, NULL, "pebs_thread");
    } else {
      printk(KERN_ERR "conot alloc memory");
      free_ring_buffer();
    }
  } else {
    printk(KERN_ERR "conot alloc memory");
    return 0;
  }
  if (IS_ERR(analyze_pthread)) {
    printk(KERN_ERR "create pebs_thread failed!\n");
    return 0;
  }

  return 1;
}
/**
 * @brief 离开pebs模块
 *
 */
void pebs_mod_exit(void) {
  // printk(KERN_INFO "cpu-%d: system has %d processor(s).\n", get_cpu(),
  // num_online_cpus());
  int i, num;
  pebs_handler = NULL;

  // 在所有CPU核心上按照核心顺序执行退出逻辑
  i = 0;
  num = num_online_cpus();
  for (; i < num; i++) {
    smp_call_function_single(i, pebs_mod_exit_each_cpu, NULL, 1);
  }
  msleep(1000);
  analyze_pthread_need_to_stop = 1;
  if (analyze_pthread != NULL && analyze_pthread->__state != TASK_DEAD) {
    // 认为线程是活跃的
    kthread_stop(analyze_pthread);
    analyze_pthread = NULL;
  }

  // printk(KERN_INFO "begin to  free_ring_buffer.\n");
  // 释放用于存放筛选后数据的环形缓冲区
  free_ring_buffer();
  free_taine_analyze_list();
  // if (analyze_res_buffer != NULL) {
  //   vfree(analyze_res_buffer);
  // }
}

// static void print_pebs_record_single(uint64_t *address_p) {
//   unsigned short count = 26;
//   unsigned short i = 0;
//   for (; i < count; i++) {
//     // printk(KERN_INFO "cpu-%d:address:%llx,pebs valid record
//     // value:%llx\n",get_cpu(),(address_p+i),*(address_p+i));
//   }
//   // printk(KERN_INFO "--------------------------------");
// }

// 钩子函数，每次进程切换时执行
void pebs_record_handler(void) {
  struct task_struct *current_pid;
  debug_store_t *ds_p;
  uint64_t start_addr;
  uint64_t pebs_index;
  uint64_t *cur_p_2;
  uint64_t *cur_p_1;

  // 此操作耗时长
  // wrmsrl(MSR_PERF_GLOBAL_CTRL, 0);
  // 获取当前CPU进程信息
  current_pid = current;

  ds_p = __this_cpu_read(cpu_ds_p);

  start_addr = ds_p->pebs_base;

  pebs_index = ds_p->pebs_index;

  cur_p_2 =
      (uint64_t *)(pebs_index - pebs_record_size);  // branch_miss事件记录指针

  cur_p_1 = (uint64_t *)(pebs_index -
                         2 * pebs_record_size);  // cache_miss事件记录指针

  while ((uint64_t)cur_p_2 > start_addr && (uint64_t)cur_p_1 >= start_addr) {
    uint64_t mem_addr_2 = *(cur_p_2 + 1);
    uint64_t count_type_2 = *(cur_p_2 + 2);
    uint64_t tsp_2 = *(cur_p_2 + 3);

    if (count_type_2 != BRANCH_MISS_EVENT_ENUM) {
      cur_p_2 = cur_p_2 - pebs_record_size / 8;
      continue;
    }

    // 只往回找
    cur_p_1 = cur_p_2 - pebs_record_size / 8;

    while ((uint64_t)cur_p_1 >= start_addr) {
      uint64_t mem_addr_1 = *(cur_p_1 + 1);
      uint64_t count_type_1 = *(cur_p_1 + 2);
      uint64_t tsp_1 = *(cur_p_1 + 3);
      uint32_t mem_addr_sub;
      uint32_t time;
      if (count_type_1 != CACHE_MISS_EVENT_ENUM) {
        break;
      }
      if (mem_addr_2 < mem_addr_1) {
        cur_p_1 = cur_p_1 - pebs_record_size / 8;
        continue;
      }
      mem_addr_sub = (mem_addr_2 - mem_addr_1);
      if (mem_addr_sub > 16) {
        cur_p_1 = cur_p_1 - pebs_record_size / 8;
        continue;
      }

      // //判断时间戳是否在300个cycle内，如果不在直接结束内层循环。
      time = tsp_2 - tsp_1;
      if (time > 300) {
        break;
      }
      // 准备写入数据
      {
        // uint32_t cpu_id = get_cpu();
        // 将pid写入到共享内存中
        char test = 0;
        // if (current_pid->comm[0] == 's' && current_pid->comm[1] == 'p'&&current_pid->comm[2]=='e') {
        //   test = 1;
        // }

        write_ring_buffer(current_pid->pid, *(cur_p_1 + 1), *(cur_p_2 + 1),
                          (register_info_t *)(cur_p_1 + 8),
                          (register_info_t *)(cur_p_2 + 8), time, mem_addr_sub,
                          test);
      }
      cur_p_1 = cur_p_1 - pebs_record_size / 8;
      // break;
    }
    cur_p_2 = cur_p_2 - pebs_record_size / 8;
  }
  // 重置index以及计数器的值
  ds_p->pebs_index = ds_p->pebs_base;
  ds_p->pebs_counter_reset[0] = -(int64_t)PERIOD;
  ds_p->pebs_counter_reset[1] = -(int64_t)PERIOD;

  // 这些操作耗时长
  // 启用PMU功能（对应MSR_PERFEVTSEL0&1的计数器Enable字段设置为1）
  // wrmsrl(MSR_PEBS_ENABLE, 0x03);
  // wrmsrl(MSR_PERF_GLOBAL_CTRL, 0x03);
}
// 分析暂存数据的内核进程
int thread_analyze_func(void *arg) {
  printk(KERN_INFO "cpu-%d:kthread start.\n", get_cpu());
  while (!kthread_should_stop()) {
    uint32_t count = 0;
    short sleep_count = 0;

    // 读取内存区域，并执行进程的kill操作
    uint32_t num = num_online_cpus();
    uint32_t index = 0;
    for (; index < num; index++) {
      uint32_t pid;
      uint64_t start_addr;
      uint64_t end_addr;
      register_info_t start_info;
      register_info_t end_info;
      uint32_t time;
      uint32_t distance;

      while (analyze_pthread_need_to_stop == 0 &&
             read_ring_buffer(index, &pid, &start_addr, &end_addr, &start_info,
                              &end_info, &time, &distance) == 0) {
        // 判断进程是否活跃，如果是活跃的就进入下一步污点分析
        struct pid *kpid;
        // rcu_read_lock();
        kpid = find_vpid((int32_t)pid);
        if (kpid != NULL) {
          struct task_struct *task = pid_task(kpid, PIDTYPE_PID);
          if (task != NULL) {
            if (pid_alive(task) == 1 && task->mm != NULL) {
              // if (task->comm[0] == 's' && task->comm[1] == 'p' &&
              //     task->comm[2] == 'e') {
              //   printk(KERN_INFO "read exec file name %s  index = %d\n",
              //          task->comm, index);
              // }
              // 共享内存不满的情况下
              if (judge_message_struct_full() == 0) {
                // if (task->comm[0] == 's') {
                //   printk(KERN_INFO "read exec file name %s  index = %d\n",
                //          task->comm, index);
                // }
                if (insert_and_search_analyze_list(pid, start_addr, end_addr) ==
                    0) {
                  pebs_taine_analyze(task, start_addr, end_addr, &start_info,
                                     &end_info, pid);
                }
              }
            }
          }
        }
        // rcu_read_unlock();
        count++;
        if (sleep_count > 0) {
          sleep_count = 3;
        }
      }
    }

    if (count == 0) {
      if (sleep_count < 10) {
        sleep_count++;
      }

      // 休眠，让出CPU
      msleep(THREAD_SLEEP_MILL_SECONDS * sleep_count);
    }
  }

  printk(KERN_INFO "cpu-%d:kthread stop.\n", get_cpu());

  return 0;
}