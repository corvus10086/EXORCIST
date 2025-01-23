#ifndef SHARE_MEM_TOOL
#define SHARE_MEM_TOOL
#include <fcntl.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

#include <iostream>
#include <memory>

#include "conf.h"
class share_mem_tool {
 public:
  typedef std::shared_ptr<share_mem_tool> ptr;
  /**
   * @brief 初始化工具
   *
   * @return true 成功
   * @return false 失败
   */
  bool init();
  // 销毁
  void destory();
  std::string read_data();

  ~share_mem_tool() { destory(); }

 private:
  int _fd;
  char *_data;
};

#endif