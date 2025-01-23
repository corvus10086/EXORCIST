#ifndef STATIC_ANALYZE_TOOLS
#define STATIC_ANALYZE_TOOLS

#include <sys/types.h>

#include <memory>

#include "conf.h"
#include "full_diasm_info.h"
#include "static_analyze/instruction_analyze_tool.h"
#include "static_analyze/state_machine.h"
/**
 * @brief 
 */
class static_analyze_tools {
 public:
  typedef std::shared_ptr<static_analyze_tools> ptr;
  /**
   * @brief
   * @param diasm_info
   */
  static_analyze_tools(full_diasm_info::ptr diasm_info,
                       std::uniform_int_distribution<int> &dist)
      : _diasm_info_ptr(diasm_info), _dist(dist) {
    // 
    _instruction_analyze_tool_ptr =
        std::make_shared<instruction_analyze_tool>(_dist);
  }
  /**
   * @brief 
   *
   * @param other
   */
  static_analyze_tools(const static_analyze_tools &other) : _dist(other._dist) {
    // 
    _diasm_info_ptr = other._diasm_info_ptr;
    // 
    _instruction_analyze_tool_ptr =
        other._instruction_analyze_tool_ptr->shallow_copy();
    //
    _deep = other._deep + 1;
  }
  //
  std::pair<std::pair<diasm_code_tool::ptr, int>, analyze_result> analyze();

  int _deep = 0;

 private:
  full_diasm_info::ptr _diasm_info_ptr;
  std::uniform_int_distribution<int> &_dist;
  /**
   * @brief 
   *
   */
  instruction_analyze_tool::ptr _instruction_analyze_tool_ptr;
  /**
   * @brief 
   *
   * @param addr
   * @return cs_insn*
   */
  std::pair<short, diasm_code_tool::ptr> find_single_instruction_by_addr(
      uint64_t addr);
  /**
   * @brief
   * 
   *
   * @param step 
   * @param exec 
   * @param error_path 
   * @param deep 
   * @param exec_mode 
   * @return std::pair<std::pair<diasm_code_tool::ptr, int>, analyze_result>
   */
  std::pair<std::pair<diasm_code_tool::ptr, int>, analyze_result>
  static_analyze(
      short step, std::pair<short, diasm_code_tool::ptr>, char exec,
      bool error_path, char exec_mode, char deep, short cmp_index,
      std::map<abstract_addr::ptr, state_symbol::ptr> &analyze_addr_taine_map);
  // 
  char analyze_start_info();
};

/**
   * @brief
   * 
   *
   *@param step 
   *@param exec_mode 

   * @return analyze_result
   */

#endif