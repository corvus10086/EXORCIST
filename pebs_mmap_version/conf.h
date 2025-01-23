#ifndef PEBS_CONF
#define PEBS_CONF
#include "pebs_pub.h"

#define MAX_PROCESS_COUNT 10
#define MAX_PAYLOAD 1024
#define MAX_PID_COUNT MAX_PROCESS_COUNT
#define MAX_REC_DATA_LEN 1024

#define STATIC_PEROID 1024 * 500
#define MSG_COUNT 10000
#define NETLINK_TEST 30
#define JUDGE_RET_STEP_SIZE 5

#define DEVICE_NAME "pebs_test_device"
#define DEVICE_CLASS "pebs_test_class"
#define MEMDEV_MAJOR 0
#define MEMDEV_NR_DEVS 1
#define MEMDEV_SIZE (1024 * 1024 * 4 * 6)

// 向后读取的字节数
#define OVER_FOOT_SIZE 200
// 向前读取的字节数
#define OVER_HEAD_SIZE 20
// 传递消息的前缀大小
// 第0个字节描述消息类型
// 第1个字节表示branch miss addr与cache miss_addr的插值
// 2表示是否是一个ret类型
// 3保留
// 4-7个字节表示pid
// 8-15个字节表示cache miss addr
// 16-23表示ret的addr
// 24-39表示进程的可执行文件名称
// 40-43表示指令可能开始地址相对与start_addr的偏移
#define MEAASGE_INFO (8 * 3 + 16 + 4)
#define PREFIX_SIZE (MEAASGE_INFO + sizeof(register_info_t))
// cache_miss与branch_miss插值的最大值
#define CACHE_BRANCHE_ADDR_ADDR_SUB_ADDR_MAX 16
// 通过mmap传递消息的总大小
#define SINGLE_MESSAGE_BY_MMAP_SIZE                                          \
  (PREFIX_SIZE + CACHE_BRANCHE_ADDR_ADDR_SUB_ADDR_MAX + 6 + OVER_FOOT_SIZE + \
   OVER_HEAD_SIZE)
#define MAX_MESSAGE_NUM_SIZE ((MEMDEV_SIZE - 8) / SINGLE_MESSAGE_BY_MMAP_SIZE)

#endif