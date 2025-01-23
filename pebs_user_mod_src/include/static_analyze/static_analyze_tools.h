#ifndef STATIC_ANALYZE_TOOLS
#define STATIC_ANALYZE_TOOLS

#include <sys/types.h>

#include <memory>

#include "conf.h"
#include "full_diasm_info.h"
#include "static_analyze/instruction_analyze_tool.h"
#include "static_analyze/state_machine.h"
/**
 * @brief 静态分析工具类
 *
 */
class static_analyze_tools {
 public:
  typedef std::shared_ptr<static_analyze_tools> ptr;
  /**
   * @brief 构造函数 需要传入一个full_diasm_info类型的数据
   * 在函数中初始化分析指令的工具instruction_analyze_tool
   * 然后通过instruction_analyze_tool来初始化状态机
   *
   * @param diasm_info
   */
  static_analyze_tools(full_diasm_info::ptr diasm_info,
                       std::uniform_int_distribution<int> &dist)
      : _diasm_info_ptr(diasm_info), _dist(dist) {
    // 初始化分析指令的工具
    _instruction_analyze_tool_ptr =
        std::make_shared<instruction_analyze_tool>(_dist);
  }
  /**
   * @brief 拷贝构造函数
   *
   * @param other
   */
  static_analyze_tools(const static_analyze_tools &other) : _dist(other._dist) {
    // 复制反汇编消息的指针
    _diasm_info_ptr = other._diasm_info_ptr;
    // 复制分析工具的指针
    _instruction_analyze_tool_ptr =
        other._instruction_analyze_tool_ptr->shallow_copy();
    // 分析的套嵌深度
    _deep = other._deep + 1;
  }
  // 静态分析工具的接口
  std::pair<std::pair<diasm_code_tool::ptr, int>, analyze_result> analyze();

  int _deep = 0;

 private:
  full_diasm_info::ptr _diasm_info_ptr;
  std::uniform_int_distribution<int> &_dist;
  /**
   * @brief 对指令进行分析的工具
   *
   */
  instruction_analyze_tool::ptr _instruction_analyze_tool_ptr;
  /**
   * @brief 根据一个地址获取当前的指令
   *
   * @param addr
   * @return cs_insn*
   */
  std::pair<short, diasm_code_tool::ptr> find_single_instruction_by_addr(
      uint64_t addr);
  /**
   * @brief
   * 对diasm_info中的数据进行静态分析，首先初始化状态机，然后单步执行指令，单步执行的指令数量有最大限制，最后判断是否存在攻击
   *
   * @param step 已分析的指令数量
   * @param exec 在未知控制流的时候是否进行跳转 0分析 1跳转 2不跳转
   * @param error_path 是否需要错误执行
   * @param deep 深度
   * @param exec_mode 执行模式 0分析模式 ，1有初始污点的模式 ，2无初始污点的模式
   * @return std::pair<std::pair<diasm_code_tool::ptr, int>, analyze_result>
   */
  std::pair<std::pair<diasm_code_tool::ptr, int>, analyze_result>
  static_analyze(
      short step, std::pair<short, diasm_code_tool::ptr>, char exec,
      bool error_path, char exec_mode, char deep, short cmp_index,
      std::map<abstract_addr::ptr, state_symbol::ptr> &analyze_addr_taine_map);
  // 这里先分析branch miss触发的
  char analyze_start_info();
};

/**
   * @brief
   * 对diasm_info中的数据进行静态分析，首先初始化状态机，然后单步执行指令，
   * 单步执行的指令数量有最大限制，最后判断是否存在攻击
   *
   *@param step 已分析的指令数量
   *@param exec_mode 表示指令执行的模式 0 jcc正常执行 1 jcc错误执行 2 痕迹追踪

   * @return analyze_result
   */

#endif