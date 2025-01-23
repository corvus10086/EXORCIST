#ifndef PEBS_MESSAGE_SEND
#define PEBS_MESSAGE_SEND

#include <linux/netlink.h>

#include "conf.h"

struct mem_dev {
  char *data;
  unsigned long size;
};
//用于描述设备data的数据结构
typedef struct message_struct {
  uint32_t *read_index;
  uint32_t *write_index;
  char *data;
} message_struct_t;


static void pebs_module_exit(void);
static int pebs_module_init(void);
/**
 * @brief 接受数据后的回调函数
 *
 * @param skb
 */
void recv_callback(struct sk_buff *skb);

int send_msg_by_mmap(const char *pbuf);
int send_msg_by_netlink(const char *pbuf, uint16_t len);
int judge_message_struct_full(void);

#endif