#ifndef FULL_DIASM_INFO
#define FULL_DIASM_INFO

#include <capstone/capstone.h>
#include <sys/types.h>

#include <boost/archive/text_iarchive.hpp>
#include <boost/archive/text_oarchive.hpp>
#include <boost/serialization/map.hpp>
#include <boost/serialization/serialization.hpp>
#include <boost/serialization/shared_ptr.hpp>
#include <boost/serialization/string.hpp>
#include <boost/serialization/vector.hpp>
#include <cstdint>
#include <map>
#include <memory>
#include <sstream>
#include <vector>

#include "async_analyze_code_tool.h"
#include "conf.h"
#include "diasm_code_tool.h"
#include "netlink_tool.h"

// #define PREFIX_SIZE ((64 * 4) / 8 + sizeof(register_info_t))
#define OVER_READ_SIZE 50

class full_diasm_info {
 public:
  typedef std::shared_ptr<full_diasm_info> ptr;
  /**
   * @brief
   *
   * @param code_info
   * @param _thread_code_map
   * @param thread_id
   * @param _netlink_tool_ptr
   * @return true
   * @return false
   */
  bool get_full_diasm_code(
      std::string code_info,
      std::map<std::uint64_t,
               async_analyze_code_tool::thread_recv_data_struct::ptr>
          &_thread_code_map,
      boost::mutex &thread_code_map_mutex, unsigned long thread_id,
      netlink_tool::ptr _netlink_tool_ptr);
  // 
  full_diasm_info(const full_diasm_info &other) {
    _ret_addr = other._ret_addr;
    _branch_miss_addr = other._branch_miss_addr;
    _branch_miss_register_info = other._branch_miss_register_info;
    _cache_miss_addr = other._cache_miss_addr;
    _target_thread_pid = other._target_thread_pid;
    _diasm_code_ptr_vector = other._diasm_code_ptr_vector;
  }
  std::stringstream get_branch_miss_addr_reg_info_str();
  full_diasm_info() {}
  // 
  std::stringstream get_diasm_string_stream();
  // 
  const register_info &get_branch_miss_register_info() {
    return _branch_miss_register_info;
  }
  // 
  const std::vector<diasm_code_tool::ptr> &get_diasm_info() {
    return _diasm_code_ptr_vector;
  }
  uint64_t get_branch_miss_addr() { return _branch_miss_addr; }
  uint64_t get_cache_miss_addr() { return _cache_miss_addr; }
  uint32_t get_target_pid() { return _target_thread_pid; }
  uint64_t get_ret_addr() { return _ret_addr; }
  std::string get_exec_file_name() { return _exec_file_name; }
  void reset_ret_addr() { _ret_addr = 0; }
  std::map<uint64_t, bool> get_judge_addr_is_mem_map() {
    return _judge_addr_is_mem_map;
  }
  bool get_is_32() { return _is_32; }

  /**
   * @brief 
   *
   * @param code_info
   * @return true 
   * @return false 
   */
  bool analyze_recy_data(const std::string &code_info);
  uint32_t get_start_offset() { return _start_offset; }
  std::string get_over_head_info() { return _over_head_info; }
  uint64_t get_virtual_start_addr() { return _virtual_start_addr; }

  //
  void set_branch_miss_addr(uint64_t addr) { _branch_miss_addr = addr; }
  void set_cache_miss_addr(uint64_t addr) { _cache_miss_addr = addr; }
  void set_branch_miss_register_info(register_info_t &info) {
    _branch_miss_register_info = info;
  }
  void set_ret_addr(uint64_t addr) { _ret_addr = addr; }
  void set_diasm_code_ptr_vector(std::vector<diasm_code_tool::ptr> info) {
    _diasm_code_ptr_vector = info;
  }
  void set_start_offset(uint32_t offset) { _start_offset = offset; }
  void set_over_head_info(std::string info) { _over_head_info = info; }
  void set_virtual_start_addr(uint64_t addr) { _virtual_start_addr = addr; }
  std::map<uint64_t, bool> _judge_addr_is_mem_map;

 private:
  // 
  uint64_t _ret_addr = 0;
  // 
  bool _is_32 = false;
  // 
  uint64_t _branch_miss_addr;
  // 
  uint64_t _cache_miss_addr;
  // 
  uint64_t _virtual_start_addr;
  // 
  register_info_t _branch_miss_register_info;
  // 
  uint32_t _target_thread_pid;
  // 
  uint32_t _start_offset;
  // 
  std::string _exec_file_name;
  // 
  std::string _over_head_info;
  // 
  // 
  std::vector<diasm_code_tool::ptr> _diasm_code_ptr_vector;
  //

  /**
   * @brief 
   *
   */
  void get_ret_info(
      std::map<std::uint64_t,
               async_analyze_code_tool::thread_recv_data_struct::ptr>
          &thread_code_map,
      unsigned long thread_id, netlink_tool::ptr netlink_tool_ptr);
  /**
   * @brief 
   *
   */
  void get_jmp_info(
      diasm_code_tool::ptr main_code_info_ptr,
      std::map<std::uint64_t,
               async_analyze_code_tool::thread_recv_data_struct::ptr>
          &_thread_code_map,
      boost::mutex &thread_code_map_mutex, unsigned long thread_id,
      netlink_tool::ptr _netlink_tool_ptr);

  /**
   * @brief 
   *
   */
  friend class boost::serialization::access;
  template <class Archive>
  void serialize(Archive &ar, const unsigned int version) {
    ar &_ret_addr;
    ar &_branch_miss_addr;
    ar &_cache_miss_addr;
    ar &_virtual_start_addr;
    ar &_branch_miss_register_info;
    ar &_target_thread_pid;
    ar &_start_offset;
    ar &_exec_file_name;
    ar &_over_head_info;
    ar &_diasm_code_ptr_vector;
    ar &_is_32;
    // ar &_judge_addr_is_mem_map;
  }
};

#endif