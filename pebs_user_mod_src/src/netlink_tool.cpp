#include "netlink_tool.h"

#include <asm-generic/errno-base.h>
#include <asm-generic/errno.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#include <cstddef>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <new>
#include <stdexcept>
#include <string>
#include <type_traits>
/**
 * @brief 对socket进行初始化
 *
 */
void netlink_tool::init_netlink() {
  std::cout << "init\n";
  //初始化用于接受数据的缓存区
  _nlh_recv = (struct nlmsghdr *)malloc(NLMSG_SPACE(MAX_PAYLOAD));
  if (_nlh_recv == nullptr) {
    std::cout << "con't alloc mem\n";
    return;
  }
  //初始化套接字
  _sock_fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_TEST);
  if (_sock_fd < 0) {
    std::cout << "con't open socket\n";
    return;
  }
  // // 查看套接字模式
  // int flags = fcntl(_sock_fd, F_GETFL, 0);
  // if (flags < 0) {
  //   std::cout << "Failed to get socket flags\n";
  //   close(_sock_fd);
  //   _sock_fd = -1;
  //   return;
  // } else {
  //   if (flags & O_NONBLOCK) {
  //     // 套接字处于非阻塞模式
  //     printf("Socket is in non-blocking mode.\n");
  //   } else {
  //     // 套接字处于阻塞模式
  //     printf("Socket is in blocking mode.\n");
  //   }
  // }
  // // 设置非阻塞模式
  // if (fcntl(_sock_fd, F_SETFL, flags | O_NONBLOCK) < 0) {
  //   std::cout << "Failed to set non-blocking mode\n";
  //   close(_sock_fd);
  //   _sock_fd = -1;
  //   return;
  // }
  // // 查看套接字模式
  // flags = fcntl(_sock_fd, F_GETFL, 0);
  // if (flags == -1) {
  //   std::cout << "Failed to get socket flags\n";
  //   close(_sock_fd);
  //   _sock_fd = -1;
  //   return;
  // } else {
  //   if (flags & O_NONBLOCK) {
  //     // 套接字处于非阻塞模式
  //     printf("Socket is in non-blocking mode.\n");
  //   } else {
  //     // 套接字处于阻塞模式
  //     printf("Socket is in blocking mode.\n");
  //   }
  // }

  // 将套接字与pid绑定
  memset(&_src_addr, 0, sizeof(struct sockaddr_nl));
  _src_addr.nl_family = AF_NETLINK;
  _src_addr.nl_pid = _pid;
  if (bind(_sock_fd, (struct sockaddr *)&_src_addr,
           sizeof(struct sockaddr_nl)) != 0) {
    std::cout << "con't bind\n";
    close(_sock_fd);
    _sock_fd = -1;
    return;
  }

  memset(&_dst_addr, 0, sizeof(struct sockaddr_nl));
  _dst_addr.nl_family = AF_NETLINK;
  _dst_addr.nl_pid = 0;
  _dst_addr.nl_groups = 0;
}

void netlink_tool::destory() {
  if (_sock_fd >= 0) {
    close(_sock_fd);
    _sock_fd = -1;
  }
  if (_nlh_recv != nullptr) {
    free(_nlh_recv);
    _nlh_recv = nullptr;
  }
  std::cout << "destory netlink\n";
}

/**
 * @brief 析构函数
 *
 */
netlink_tool::~netlink_tool() { destory(); }
/**
 * @brief 向内核发送消息
 *
 * @param message
 */
void netlink_tool::send_message(std::string message) {
  if (_sock_fd < 0) {
    throw std::runtime_error("_sock_fd init fail");
  }
  struct nlmsghdr *nlh = (struct nlmsghdr *)malloc(NLMSG_SPACE(MSG_SIZE));
  if (!nlh) {
    std::cout << "malloc error\n";
    return;
  }
  memset(nlh, 0, NLMSG_SPACE(MSG_SIZE));
  nlh->nlmsg_len = NLMSG_SPACE(MSG_SIZE);
  nlh->nlmsg_pid = _pid;
  nlh->nlmsg_flags = 0;
  if (message.length() > NLMSG_SPACE(MSG_SIZE)) {
    throw std::runtime_error("message too long");
  }
  memcpy(NLMSG_DATA(nlh), message.c_str(), message.size());
  if (sendto(_sock_fd, nlh, nlh->nlmsg_len, 0, (struct sockaddr *)&_dst_addr,
             sizeof(struct sockaddr_nl)) < 0) {
    std::cout << "send error\n";
  }
  free(nlh);
}

/**接受内核传递的消息*/
std::string netlink_tool::recieve_message() {
  if (_sock_fd < 0) {
    throw std::runtime_error("_sock_fd init fail");
  }
  struct sockaddr_nl src_addr;
  socklen_t addrlen = sizeof(struct sockaddr_nl);
  memset(&src_addr, 0, addrlen);

  if (recvfrom(_sock_fd, _nlh_recv, NLMSG_SPACE(MAX_PAYLOAD), 0,
               (struct sockaddr *)&src_addr, (socklen_t *)&addrlen) < 0) {
    throw std::runtime_error("recv message fail");
    // //非阻塞模式下没有数据返回空字符串
    // if (errno == EAGAIN || errno == EWOULDBLOCK) {
    //   return std::string("");
    // }
    // //接受数据出现了错误
    // else {
    //   throw std::runtime_error("recv message fail");
    // }
  }
  int32_t len = _nlh_recv->nlmsg_len - NLMSG_SPACE(0);
  return std::string((char *)NLMSG_DATA(_nlh_recv), len);
}