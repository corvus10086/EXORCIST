#ifndef NETLINK_TOOL
#define NETLINK_TOOL
#include <linux/netlink.h>
#include <sys/socket.h>
#include <sys/types.h>

#include <cstdint>
#include <iostream>
#include <memory>
#include <string>

#include "conf.h"

class netlink_tool {
 public:
  typedef std::shared_ptr<netlink_tool> ptr;
  /**
   * @brief 构造函数
   */
  netlink_tool(u_int32_t pid) : _pid(pid) { init_netlink(); };

  /**
   * @brief 析沟函数
   */
  ~netlink_tool();

  std::string recieve_message();

  void send_message(std::string message);

  void destory();
  /**
   * @brief 判断当前netlink tool是否生效
   *
   * @return true
   * @return false
   */
  bool effective() { return _sock_fd > 0; }

 private:
  uint32_t _pid = -1;
  int32_t _sock_fd = -1;
  std::string _message;
  struct sockaddr_nl _src_addr, _dst_addr;
  // struct nlmsghdr *_nlh_send;
  struct nlmsghdr *_nlh_recv;
  void init_netlink();
};

#endif