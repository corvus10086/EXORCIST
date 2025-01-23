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

// 
#define OVER_FOOT_SIZE 200
// 
#define OVER_HEAD_SIZE 20
// 
// 0
// 1branch miss addrcache miss_addr
// 2ret
// 3
// 4-7pid
// 8-15cache miss addr
// 16-23retaddr
// 24-39
// 40-43start_addr
#define MEAASGE_INFO (8 * 3 + 16 + 4)
#define PREFIX_SIZE (MEAASGE_INFO + sizeof(register_info_t))
// cache_missbranch_miss
#define CACHE_BRANCHE_ADDR_ADDR_SUB_ADDR_MAX 16
// mmap
#define SINGLE_MESSAGE_BY_MMAP_SIZE                                          \
  (PREFIX_SIZE + CACHE_BRANCHE_ADDR_ADDR_SUB_ADDR_MAX + 6 + OVER_FOOT_SIZE + \
   OVER_HEAD_SIZE)
#define MAX_MESSAGE_NUM_SIZE ((MEMDEV_SIZE - 8) / SINGLE_MESSAGE_BY_MMAP_SIZE)

#endif