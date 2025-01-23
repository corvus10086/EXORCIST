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
   * @brief init tool
   *
   * @return true 
   * @return false 
   */
  bool init();
  // 
  void destory();
  std::string read_data();

  ~share_mem_tool() { destory(); }

 private:
  int _fd;
  char *_data;
};

#endif