#ifndef PEBS_INIT
#define PEBS_INIT

#include <asm/current.h>
#include <linux/cpumask.h>
#include <linux/delay.h>
#include <linux/init.h>
#include <linux/jiffies.h>
#include <linux/kernel.h>
#include <linux/kthread.h>
#include <linux/ktime.h>
#include <linux/module.h>
#include <linux/netlink.h>
#include <linux/pid.h>
#include <linux/sched.h>
#include <linux/smp.h>
#include <linux/string.h>
#include <linux/types.h>

#include "pebs_pub.h"
#include "pebs_buffer.h"

// 配置PEBS能力启用的寄存器地址
#define MSR_PEBS_ENABLE 0x3f1

// 配置关注事件类型的寄存器地址
#define MSR_PERFEVTSEL0 0x186
#define MSR_PERFEVTSEL1 0x187

// 通用计数器地址
#define MSR_GP_COUNT_PMC0 0xc1
#define MSR_GP_COUNT_PMC1 0xc2

// 固定计数器地址
#define MSR_FIXED_CTR0 0x309
#define MSR_FIXED_CTR1 0x30A
#define MSR_FIXED_CTR2 0x30B
#define MSR_FIXED_CTR3 0x30C

// 控制固定计数器是否启用的寄存器地址
#define MSR_FIXED_CTR_CTRL 0x38D

// cache miss的事件类型编码\掩码
#define CACHE_MISS_EVENT_TYPE 0xD1
#define CACHE_MISS_UMASK_PCORE 0x08
//L3 miss
#define CACHE_MISS_UMASK_ECORE 0x80

// cache miss事件 PEBS事件记录内存地址最后两位的值\事件类型
#define CACHE_MISS_MEM_ADDR_LOW_2_BIT_VAL 0x01d5
#define CACHE_MISS_EVENT_ENUM 0x01

// branch miss的事件类型编码\掩码
#define BRANCH_MISS_EVENT_TYPE 0xC5
#define BRANCH_MISS_UMASK_PCORE 0x01
#define BRANCH_MISS_UMASK_ECORE 0xFE
//#define BRANCH_MISS_UMASK 0x04

// branch miss的事件 PEBS事件记录内存地址最后两位的值\事件类型
#define BRANCH_MISS_MEM_ADDR_LOW_2_BIT_VAL 0x01e1
#define BRANCH_MISS_EVENT_ENUM 2

// 批量设置&查询计数器（通用 or 固定）状态
#define MSR_PERF_GLOBAL_STATUS 0x38E
#define MSR_PERF_GLOBAL_CTRL 0x38F
#define MSR_PERF_GLOBAL_OVF_CTRL 0x390

// 存放ds缓存区首地址的寄存器地址
#define MSR_DS_AREA 0x600

// 配置PEBS每条Record记录的格式的寄存器地址
// #define MSR_PEBS_DATA_CFG 0x3F2

// 配置PEBS Record记录位数的寄存器地址
#define MSR_PERF_CAPABILITIES 0x345

// 整个PEBS Record Buffer区域的最大值:4M，单位为字节
#define PEBS_BUFFER_SIZE_BYTE 4 * 1024 * 1024

// 计数器的reset值，也是一个计数周期的值。每个周期完成后，会记录一条PEBS 记录。
#define PERIOD 100

// 线程休眠的毫秒数
#define THREAD_SLEEP_MILL_SECONDS 1

// DS结构体
typedef struct pebs_debug_store {
  uint64_t bts_base;
  uint64_t bts_index;
  uint64_t bts_max;
  uint64_t bts_thresh;

  uint64_t pebs_base;
  uint64_t pebs_index;
  uint64_t pebs_max;
  uint64_t pebs_thresh;
  int64_t pebs_counter_reset[4];

  uint64_t reserved;
} debug_store_t;

void pebs_record_handler(void);
void  pebs_mod_exit(void);
int pebs_mod_init(void);
int thread_analyze_func(void *arg);
#endif