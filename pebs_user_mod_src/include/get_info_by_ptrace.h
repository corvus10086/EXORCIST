#ifndef GET_INFO_BY_PTRACE
#define GET_INFO_BY_PTRACE

#include <cstdint>
#include <string>
class get_info_by_ptrace {
 public:
  /**
   * @brief 
   *
   * @param pid
   * @param addr
   */
  get_info_by_ptrace(uint32_t pid, uint64_t addr) : _pid(pid), _addr(addr) {}
  std::pair<uint32_t, std::string> get_info();

 private:
  uint32_t _pid;
  uint64_t _addr;
};

#endif