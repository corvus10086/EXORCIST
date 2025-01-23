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

// 

extern void (*pebs_handler)(void);

// pebs---64basic_info(32) + mem_info(32)
// 208GPRS
static uint32_t pebs_record_size = 208;

// CPU，ds struct
static DEFINE_PER_CPU(debug_store_t *, cpu_ds_p);

static DEFINE_PER_CPU(uint64_t, cpu_old_ds);

// 
static struct task_struct *analyze_pthread = NULL;
static char analyze_pthread_need_to_stop = 0;

// static char error = 0;

// 
// static atomic_t total = ATOMIC_INIT(0);

EXPORT_SYMBOL_GPL(pebs_record_handler);

/**
 * @brief PMU
 *
 * @return true
 * @return false
 */
static bool check(void) {
  uint64_t val;

  // 1. PMU
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
 * @brief branch miss
 *
 * @return uint64_t
 */
static uint64_t cal_branch_miss_ctrl_val(int is_pcore) {
  uint64_t ctrl_val = 0x00;

  // 
  ctrl_val |= (0x000000FF & BRANCH_MISS_EVENT_TYPE);

  // 
  if (is_pcore) {
    ctrl_val |= (0x0000FF00 & (BRANCH_MISS_UMASK_PCORE << 8));
  } else {
    ctrl_val |= (0x0000FF00 & (BRANCH_MISS_UMASK_ECORE << 8));
  }
  // ctrl_val |= (0x0000FF00 & (BRANCH_MISS_UMASK_PCORE << 8));

  // 
  ctrl_val |= (1 << 16);

  // 
  ctrl_val |= (1 << 18);

  // 
  ctrl_val |= (1 << 22);

  // ADEPTIVE record
  ctrl_val |= (((uint64_t)1) << 34);

  return ctrl_val;
}

/**
 * @brief cache miss
 *
 * @return uint64_t
 */
static uint64_t cal_cache_miss_ctrl_val(int is_pcore) {
  uint64_t ctrl_val = 0x00;

  // 
  ctrl_val |= (0x000000FF & CACHE_MISS_EVENT_TYPE);

  // 
  if (is_pcore) {
    ctrl_val |= (0x0000FF00 & (CACHE_MISS_UMASK_PCORE << 8));
  } else {
    ctrl_val |= (0x0000FF00 & (CACHE_MISS_UMASK_ECORE << 8));
  }
  // ctrl_val |= (0x0000FF00 & (CACHE_MISS_UMASK_PCORE << 8));

  // 
  ctrl_val |= (1 << 16);

  // 
  ctrl_val |= (1 << 18);

  // 
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
//     // basic_info  mem_info32，64
//     uint64_t total_rec_count = (end_addr - cur_addr) / pebs_record_size;
//     // printk(KERN_INFO "cpu-%d:pebs buffer record
//     // count:%lld\n",get_cpu(),total_rec_count);

//     uint64_t i = 0;
//     uint64_t count = total_rec_count * 8;
//     while (i < count) {
//       uint64_t val = *(cur_p + i);
//       if ((val & 0xff) == 0xd5 || (val & 0xff) == 0xe1) {
//         // record（8）
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
 * @brief ds_buffer
 *
 * @return true
 * @return false
 */
static bool set_ds_buffer(void) {
  // DS,GFP_KERNEL
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

  // PEBS record buffer
  ds_p->pebs_base = (uint64_t)kmalloc(PEBS_BUFFER_SIZE_BYTE, GFP_KERNEL);
  if (ds_p->pebs_base != 0) {
    // printk(KERN_INFO "cpu-%d:pebs buffer kmalloc success.
    // address=%llx\n",get_cpu(),ds_p->pebs_base);
  } else {
    // printk(KERN_ERR "cpu-%d:pebs buffer kmalloc failed.",get_cpu());
    return false;
  }
  memset((void *)ds_p->pebs_base, 0, PEBS_BUFFER_SIZE_BYTE);

  // DS
  pebs_max_num = PEBS_BUFFER_SIZE_BYTE / pebs_record_size;
  ds_p->pebs_index = ds_p->pebs_base;
  ds_p->pebs_max = ds_p->pebs_base + (pebs_max_num - 1) * pebs_record_size;

  // PEBS Buffer 
  // ds_p->pebs_thresh = ds_p->pebs_base + (pebs_max_num - pebs_max_num/10) *
  // pebs_record_size ;
  ds_p->pebs_thresh = ds_p->pebs_max;

  ds_p->pebs_counter_reset[0] = -(int64_t)PERIOD;
  ds_p->pebs_counter_reset[1] = -(int64_t)PERIOD;

  // CPU
  __this_cpu_write(cpu_ds_p, ds_p);

  // print_ds_info();

  return true;
}

/**
 * @brief pebs
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

  //  
  if (check() == false) {
    return;
  }

  // DS buffer
  ds_p = __this_cpu_read(cpu_ds_p);
  if (ds_p == NULL) {
    if (set_ds_buffer() == false) {
      return;
    }
  }

  //BufferIA32_DS_AREA。
  rdmsrl(MSR_DS_AREA, old_ds);
  //
  __this_cpu_write(cpu_old_ds, old_ds);
  wrmsrl(MSR_DS_AREA, (uint64_t)__this_cpu_read(cpu_ds_p));

  //PEBS record
  // basicmemory，basic_info，memory_info
  // GPRS，
  wrmsrl(MSR_PEBS_DATA_CFG, (uint64_t)3);

  // PMU（MSR_PERFEVTSEL0&1Enable0）
  wrmsrl(MSR_PERF_GLOBAL_CTRL, 0);

  cpuid(2, &eax, &ebx, &ecx, &edx);
  if (ebx != 0) {
    uint64_t cache_miss_val;
    uint64_t branch_miss_val;
    //pcore
    // 
    cache_miss_val = cal_cache_miss_ctrl_val(1);
    // printk(KERN_INFO "cpu-%d:cache_miss MSR_PERFEVTSEL0
    // val=%llx\n",get_cpu(), cache_miss_val);
    wrmsrl(MSR_PERFEVTSEL0, cache_miss_val);

    branch_miss_val = cal_branch_miss_ctrl_val(1);
    // printk(KERN_INFO "cpu-%d:branch_miss MSR_PERFEVTSEL1
    // val=%llx\n",get_cpu(), branch_miss_val);
    wrmsrl(MSR_PERFEVTSEL1, branch_miss_val);
  } else {
    //ecore
    // 
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
  // printk(KERN_INFO "CPUID Model : %u\n", model);
  // unsigned long long msr_value;
  // rdmsrl(MSR_IA32_MISC_ENABLE, msr_value);
  // // Alder Lake，P-core211，E-core221
  // if (msr_value & (1ULL << 21)) {
  //   printk(KERN_INFO "CPU %d: P-core detected \n", cpu_id);
  // } else if (msr_value & (1ULL << 22)) {
  //   printk(KERN_INFO "CPU %d: E-core detected \n", cpu_id);
  // } else {
  //   printk(KERN_INFO "CPU %d: Unknown core type \n", cpu_id);
  // }

  // PMC0、PMC1
  wrmsrl(MSR_GP_COUNT_PMC0, -(int64_t)PERIOD);
  wrmsrl(MSR_GP_COUNT_PMC1, -(int64_t)PERIOD);

  // PEBS（PMC0&PMC1PEBS）
  wrmsrl(MSR_PEBS_ENABLE, 0x03);

  // PMU（MSR_PERFEVTSEL0&1Enable1）
  wrmsrl(MSR_PERF_GLOBAL_CTRL, 0x03);

  // print_msr_info();

  // printk(KERN_INFO "cpu-%d:*************PEBS module load
  // success!*************\n",get_cpu());
}

/**
 * @brief pebs
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

  // MSR
  pebs_reset();

  // DS
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
 * @brief pebs
 *
 * @return int
 */
int pebs_mod_init(void) {
  // CPU
  analyze_pthread_need_to_stop = 0;
  on_each_cpu(pebs_mod_init_each_cpu, NULL, 1);

  // 
  if (alloc_ring_buffer()) {
    if (alloc_taine_analyze_list()) {
      //
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
 * @brief pebs
 *
 */
void pebs_mod_exit(void) {
  // printk(KERN_INFO "cpu-%d: system has %d processor(s).\n", get_cpu(),
  // num_online_cpus());
  int i, num;
  pebs_handler = NULL;

  // CPU
  i = 0;
  num = num_online_cpus();
  for (; i < num; i++) {
    smp_call_function_single(i, pebs_mod_exit_each_cpu, NULL, 1);
  }
  msleep(1000);
  analyze_pthread_need_to_stop = 1;
  if (analyze_pthread != NULL && analyze_pthread->__state != TASK_DEAD) {
    // 
    kthread_stop(analyze_pthread);
    analyze_pthread = NULL;
  }

  // printk(KERN_INFO "begin to  free_ring_buffer.\n");
  // 
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

// ，
void pebs_record_handler(void) {
  struct task_struct *current_pid;
  debug_store_t *ds_p;
  uint64_t start_addr;
  uint64_t pebs_index;
  uint64_t *cur_p_2;
  uint64_t *cur_p_1;

  // 
  // wrmsrl(MSR_PERF_GLOBAL_CTRL, 0);
  // CPU
  current_pid = current;

  ds_p = __this_cpu_read(cpu_ds_p);

  start_addr = ds_p->pebs_base;

  pebs_index = ds_p->pebs_index;

  cur_p_2 =
      (uint64_t *)(pebs_index - pebs_record_size);  // branch_miss

  cur_p_1 = (uint64_t *)(pebs_index -
                         2 * pebs_record_size);  // cache_miss

  while ((uint64_t)cur_p_2 > start_addr && (uint64_t)cur_p_1 >= start_addr) {
    uint64_t mem_addr_2 = *(cur_p_2 + 1);
    uint64_t count_type_2 = *(cur_p_2 + 2);
    uint64_t tsp_2 = *(cur_p_2 + 3);

    if (count_type_2 != BRANCH_MISS_EVENT_ENUM) {
      cur_p_2 = cur_p_2 - pebs_record_size / 8;
      continue;
    }

    // 
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

      // //300cycle，。
      time = tsp_2 - tsp_1;
      if (time > 300) {
        break;
      }
      // 
      {
        // uint32_t cpu_id = get_cpu();
        // pid
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
  // index
  ds_p->pebs_index = ds_p->pebs_base;
  ds_p->pebs_counter_reset[0] = -(int64_t)PERIOD;
  ds_p->pebs_counter_reset[1] = -(int64_t)PERIOD;

  // 
  // PMU（MSR_PERFEVTSEL0&1Enable1）
  // wrmsrl(MSR_PEBS_ENABLE, 0x03);
  // wrmsrl(MSR_PERF_GLOBAL_CTRL, 0x03);
}
// 
int thread_analyze_func(void *arg) {
  printk(KERN_INFO "cpu-%d:kthread start.\n", get_cpu());
  while (!kthread_should_stop()) {
    uint32_t count = 0;
    short sleep_count = 0;

    // ，kill
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
        // ，
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
              // 
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

      // ，CPU
      msleep(THREAD_SLEEP_MILL_SECONDS * sleep_count);
    }
  }

  printk(KERN_INFO "cpu-%d:kthread stop.\n", get_cpu());

  return 0;
}