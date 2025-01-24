#include "pebs_message_send.h"

#include <asm-generic/errno-base.h>
#include <asm/io.h>
#include <asm/uaccess.h>
#include <linux/cdev.h>
#include <linux/fs.h>
#include <linux/io.h>
#include <linux/kthread.h>
#include <linux/mm.h>
#include <linux/module.h>
#include <linux/netlink.h>
#include <linux/slab.h>
#include <linux/uaccess.h>
#include <linux/vmalloc.h>
#include <net/sock.h>

#include "conf.h"
#include "pebs_init.h"
#include "pebs_taine.h"

struct pebs_message_send_chre_dev {
  // 
  char *dev_name;
  // 
  int major;
  // 
  int minor;
  // 
  struct file_operations fops;
  // 
  struct mem_dev mem_devp;
  // 
  struct class *device_class;
  // 
  struct device *device;

  struct cdev cdev;
};
struct pebs_message_send_chre_dev this_dev;

struct pebs_netlink_info {
  // sock
  struct sock *nl_sk;
  // pid
  uint32_t usermod_pid;
  // 
  int is_start;
  struct netlink_kernel_cfg cfg;
};
struct pebs_netlink_info this_netlink;

message_struct_t this_dev_messgae_struct;
/**
 * @brief 
 *
 * @param inode
 * @param filp
 * @return int
 */
int mem_open(struct inode *inode, struct file *filp) {
  printk(KERN_INFO "open_dev\n");
  filp->private_data = &this_dev.mem_devp;
  return 0;
}
/**
 * @brief 
 *
 * @param inode
 * @param filp
 * @return int
 */
int mem_release(struct inode *inode, struct file *filp) {
  printk(KERN_INFO "release_dev\n");
  return 0;
}
/**
 * @brief mmap
 *
 * @param filp
 * @param vma
 * @return int
 */
static int memdev_mmap(struct file *filp, struct vm_area_struct *vma) {
  // 
  struct mem_dev *dev = filp->private_data;

  unsigned long pfn;
  size_t size = vma->vm_end - vma->vm_start;
  unsigned long offset = 0;
  printk(KERN_INFO "mmap_dev\n");
  if (size > MEMDEV_SIZE) {
    return -EINVAL;
  }
  vma->vm_flags |= VM_IO;
  while (size > 0) {
    pfn = vmalloc_to_pfn(dev->data + offset);
    if (remap_pfn_range(vma, vma->vm_start + offset, pfn, PAGE_SIZE,
                        vma->vm_page_prot)) {
      return -EAGAIN;
    }
    size -= PAGE_SIZE;
    offset += PAGE_SIZE;
  }

  return 0;
}
//
static int __init pebs_module_init(void) {
  int result;

  printk(KERN_INFO "init\n");
  // 
  {
    this_dev.dev_name = DEVICE_NAME;
    this_dev.major = MEMDEV_MAJOR;
    this_dev.fops.owner = THIS_MODULE;
    this_dev.fops.open = mem_open;
    this_dev.fops.release = mem_release;
    this_dev.fops.mmap = memdev_mmap;
  }
  // 
  this_dev.mem_devp.size = MEMDEV_SIZE;
  if (this_dev.mem_devp.data == NULL) {
    this_dev.mem_devp.data = vmalloc(MEMDEV_SIZE);
    if (this_dev.mem_devp.data == NULL) {
      printk(KERN_INFO "fail to alloc device mem\n");
      return 0;
    }
    this_dev_messgae_struct.write_index = (uint32_t *)(this_dev.mem_devp.data);
    this_dev_messgae_struct.read_index =
        (uint32_t *)(this_dev.mem_devp.data + 4);
    this_dev_messgae_struct.data = this_dev.mem_devp.data + 8;
    *this_dev_messgae_struct.write_index = 1;
    *this_dev_messgae_struct.read_index = 0;
  }
  //
  this_dev.major = register_chrdev(0, this_dev.dev_name, &this_dev.fops);
  if (this_dev.major < 0) {
    printk(KERN_INFO "alloc deveive fail\n");
    goto free_mem;
  }
  // 
  this_dev.device_class = class_create(THIS_MODULE, DEVICE_CLASS);
  if (IS_ERR(this_dev.device_class)) {
    printk(KERN_INFO "fail to create dev class\n");
    goto unregister_dev;
  }
  // 
  this_dev.device = device_create(this_dev.device_class, NULL,
                                  MKDEV(this_dev.major, 0), NULL, DEVICE_NAME);
  if (IS_ERR(this_dev.device)) {
    printk(KERN_INFO "fail to create dev\n");
    goto destory_class;
  }

  //netlink 
  {
    this_netlink.is_start = 0;
    this_netlink.nl_sk = NULL;
    this_netlink.usermod_pid = -1;
    this_netlink.cfg.input = recv_callback;
  }
  this_netlink.nl_sk =
      netlink_kernel_create(&init_net, NETLINK_TEST, &this_netlink.cfg);
  if (!this_netlink.nl_sk) {
    printk(KERN_ERR "net_link: connot create netlink socket\n");
    goto device_destroy;
  }
  printk(KERN_INFO "pebs_netlink_and_dev_init_secc\n");
  // {
  //   char test[SINGLE_MESSAGE_BY_MMAP_SIZE];
  //   send_msg_by_mmap(test);
  //   send_msg_by_mmap(test);
  // }

  return 0;

device_destroy:
  device_destroy(this_dev.device_class, MKDEV(this_dev.major, 0));
destory_class:
  class_destroy(this_dev.device_class);
unregister_dev:
  // 
  unregister_chrdev(this_dev.major, this_dev.dev_name);
free_mem:
  // 
  if (this_dev.mem_devp.data != NULL) {
    vfree(this_dev.mem_devp.data);
  }
  return result;
}

static void __exit pebs_module_exit(void) {
  // netlink
  printk(KERN_INFO "exit\n");

  device_destroy(this_dev.device_class, MKDEV(this_dev.major, 0));

  class_destroy(this_dev.device_class);

  unregister_chrdev(this_dev.major, this_dev.dev_name);

  // 
  if (this_dev.mem_devp.data != NULL) {
    vfree(this_dev.mem_devp.data);
  }
  // netlink
  if (this_netlink.nl_sk != NULL) {
    sock_release(this_netlink.nl_sk->sk_socket);
    this_netlink.nl_sk = NULL;
  }
  this_netlink.usermod_pid = -1;
}

void recv_callback(struct sk_buff *skb) {
  struct nlmsghdr *nlh = NULL;
  void *data = NULL;
  int i = 0;

  if (skb->len >= nlmsg_total_size(0)) {
    nlh = nlmsg_hdr(skb);
    this_netlink.usermod_pid = nlh->nlmsg_pid;
    // 
    data = NLMSG_DATA(nlh);
    if (data) {
      // printk("kernel receive data %c\n", *((char *)data));
      if (*((char *)data) == 'r') {
        // todo rpebs
        // char mess_ini = "begin";
        // send_msg_by_netlink(mess_init, 16);
        printk("kernel begin to init pebs");
        if (this_netlink.is_start != 0) {
          return;
        }
        *this_dev_messgae_struct.write_index = 1;
        *this_dev_messgae_struct.read_index = 0;
        pebs_mod_init();
        this_netlink.is_start = 1;

      } else if (*((char *)data) == 's') {
        // todo spebs
        if (this_netlink.is_start != 0) {
          char mess_exit[8] = "exit";
          printk("kernel begin to send exit");
          pebs_mod_exit();
          send_msg_by_netlink(mess_exit, 8);
          this_netlink.is_start = 0;
        }
      } else if (*((char *)data) == 'g') {
        u64 thread_id;
        u32 target_thread_pid;
        u64 start_addr;
        // todo g
        // printk("kernel begin to get data from mem");
        thread_id = *((uint64_t *)(data + 8));
        target_thread_pid = *((uint32_t *)(data + 16));
        start_addr = *((uint64_t *)(data + 24));
        // printk(KERN_INFO "thread_id = %llx\n", thread_id);
        // printk(KERN_INFO "target_thread_pid = %x\n", target_thread_pid);
        // printk(KERN_INFO "start_addr = %llx\n", start_addr);
        read_data(target_thread_pid, thread_id, start_addr);
      } else if (*((char *)data) == 't') {
        // todo 
        char data_with_information[382];
        data_with_information[0] = 0;
        data_with_information[1] = 30;
        data_with_information[2] = 0;
        *((u32 *)(data_with_information + 4)) = 33333;

        *((u64 *)(data_with_information + 8)) = 50;

        *((u64 *)(data_with_information + 16)) = 0;
        for (; i < 18; ++i) {
          *((u64 *)(data_with_information + MEAASGE_INFO + i * 8)) = 66666 + i;
        }
        send_msg_by_mmap(data_with_information);

      } else {
      }
    }
  }
}

int send_msg_by_netlink(const char *pbuf, uint16_t len) {
  struct sk_buff *nl_skb;
  struct nlmsghdr *nlh;
  int ret;

  //sk_buffer
  nl_skb = nlmsg_new(len, GFP_ATOMIC);
  if (!nl_skb) {
    printk("nlmsg_new error\n");
    return -1;
  }
  //netlink
  nlh = nlmsg_put(nl_skb, 0, 0, 0, len, 0);
  if (nlh == NULL) {
    printk("netlink header error\n");
    nlmsg_free(nl_skb);
    return -1;
  }
  //
  memcpy(nlmsg_data(nlh), pbuf, len);

  //
  ret = netlink_unicast(this_netlink.nl_sk, nl_skb, this_netlink.usermod_pid,
                        MSG_DONTWAIT);

  return ret;
}
int send_msg_by_mmap(const char *pbuf) {
  //
  int message_num_max = MAX_MESSAGE_NUM_SIZE;
  int message_size = SINGLE_MESSAGE_BY_MMAP_SIZE;
  // 
  if ((*this_dev_messgae_struct.write_index + 1) % message_num_max ==
      *this_dev_messgae_struct.read_index) {
    printk(KERN_INFO "this_dev_mesage_is_full");
    return 0;
  }
  memcpy(this_dev_messgae_struct.data +
             *this_dev_messgae_struct.write_index * message_size,
         pbuf, message_size);
  *this_dev_messgae_struct.write_index =
      (*this_dev_messgae_struct.write_index + 1) % message_num_max;
  // printk(KERN_INFO "write_index = %d read_index =%d\n",
  //        *this_dev_messgae_struct.write_index,
  //        *this_dev_messgae_struct.read_index);
  return 1;
}
int judge_message_struct_full(void) {
  int message_num_max = MAX_MESSAGE_NUM_SIZE;
  // 
  if ((*this_dev_messgae_struct.write_index + 1) % message_num_max ==
      *this_dev_messgae_struct.read_index) {
    printk(KERN_INFO "this_dev_mesage_is_full");
    return 1;
  }
  return 0;
}

module_init(pebs_module_init);
module_exit(pebs_module_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Your Name");
MODULE_DESCRIPTION("A simple character device driver with mmap support");