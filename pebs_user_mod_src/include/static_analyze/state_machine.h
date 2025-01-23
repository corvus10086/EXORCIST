#ifndef STATE_MACHINE
#define STATE_MACHINE
#include <capstone/x86.h>

#include <cstdint>
#include <map>
#include <memory>
#include <random>
#include <set>
#include <string>
#include <variant>
#include <vector>

#include "conf.h"
#include "state_symbol.h"
#include "static_analyze/abstract_addr.h"

class state_machine {
 public:
  typedef std::shared_ptr<state_machine> ptr;

  /**
   * @brief 一个构造函数
   *
   */
  state_machine(std::default_random_engine& random,
                std::uniform_int_distribution<int>& dist)
      : _random(random), _dist(dist) {}
  // 从一个抽象地址获取符号，没有相应符号时返回空符号
  state_symbol::ptr get_symbol_from_addr(abstract_addr::ptr);
  // 根据字符类型为一个抽象地址生成符号
  state_symbol::ptr generate_symbol_for_addr(abstract_addr::ptr, std::string,
                                             short size);
  // 根据字符类型为一个抽象地址生成符号
  state_symbol::ptr generate_symbol_for_addr(abstract_addr::ptr, std::string);
  // 根据一个字符串和一个污点字符串容器为地址生成一个符号
  state_symbol::ptr generate_symbol_for_addr(abstract_addr::ptr, std::string,
                                             std::vector<std::string>);
  // 根据一个字符串和一个污点字符串容器为地址生成一个符号
  state_symbol::ptr generate_symbol_for_addr(abstract_addr::ptr, std::string,
                                             std::vector<std::string>, short);
  // 根据数字类型为一个抽象地址生成符号
  state_symbol::ptr generate_symbol_for_addr(abstract_addr::ptr, uint64_t,
                                             short size);
  // 根据数字类型为一个抽象地址生成符号
  state_symbol::ptr generate_symbol_for_addr(abstract_addr::ptr, uint64_t);

  // 给一个抽象地址设置一个字符串符号
  void set_symbol_for_addr(abstract_addr::ptr, std::string, short size);
  // 给一个抽象地址设置一个数字符号
  void set_symbol_for_addr(abstract_addr::ptr, uint64_t, short size);
  /**
   * @brief 给一个抽象地址设置一个抽象符号
   *
   */
  void set_symbol_for_addr(abstract_addr::ptr, state_symbol::ptr);
  // 清除当前状态机中的全部污点
  void clear_all_symbol();
  // 对一个状态机进行浅拷贝
  state_machine::ptr shallow_copy() {
    state_machine::ptr res = std::make_shared<state_machine>(_random, _dist);
    res->_addr_symbol_map = _addr_symbol_map;
    res->_flag_symbol_map = _flag_symbol_map;
    return res;
  }
  // 在状态机中寻找可能与symbol中污点有关的地址和符号映射
  std::map<abstract_addr::ptr, state_symbol::ptr> find_addr_contain_taine(
      state_symbol::ptr symbol) {
    std::map<abstract_addr::ptr, state_symbol::ptr> res = {};
    for (auto iter : _addr_symbol_map) {
      if (iter.second != nullptr &&
          (iter.second->get_symbol_size() == symbol->get_symbol_size()) &&
          iter.second->judge_taine_str_effect(symbol->get_taine_str())) {
        res[iter.first] = iter.second;
      }
    }
    return res;
  }
  // 在状态机中寻找可能与symbol中污点有关的地址和符号映射 不包含另一个符号的影响
  std::map<abstract_addr::ptr, state_symbol::ptr>
  find_addr_contain_taine_without_in(state_symbol::ptr symbol,
                                     state_symbol::ptr with_out_symbol) {
    std::map<abstract_addr::ptr, state_symbol::ptr> res = {};
    for (auto iter : _addr_symbol_map) {
      if (iter.second != nullptr &&
          (iter.second->get_symbol_size() == symbol->get_symbol_size()) &&
          iter.second->judge_taine_str_effect(symbol->get_taine_str()) &&
          (!iter.second->judge_symbol_str_same(
              with_out_symbol->_contain_symbol))) {
        res[iter.first] = iter.second;
      }
    }
    return res;
  }
  // 在状态机中寻找可能与symbol中污点有关的地址和符号映射
  std::map<abstract_addr::ptr, state_symbol::ptr> find_addr_contain_taine(
      std::vector<std::string> taine_str_vec) {
    std::map<abstract_addr::ptr, state_symbol::ptr> res = {};
    for (auto iter : _addr_symbol_map) {
      if (iter.second != nullptr &&
          iter.second->judge_taine_str_effect(taine_str_vec)) {
        res[iter.first] = iter.second;
      }
    }
    return res;
  }
  std::map<abstract_addr::ptr, state_symbol::ptr> find_addr_contain_symbol(
      std::vector<std::string> symbol_str_vec, short sym_size, short deep = 5) {
    std::map<abstract_addr::ptr, state_symbol::ptr> res = {};
    for (auto iter : _addr_symbol_map) {
      if (iter.second != nullptr &&
          (iter.second->get_symbol_size() == sym_size) &&
          iter.second->judge_symbol_str_effect(symbol_str_vec)) {
        res[iter.first] = iter.second;
        // 如果找到的结果是一个字符地址就继续找这个字符地址的相关数据
        if (iter.first->get_addr_string() != "" && deep > 0) {
          auto tmp = find_addr_contain_symbol(
              iter.first->get_symbol_str_vector(), iter.first->_size, --deep);
          res.insert(tmp.begin(), tmp.end());
        }
      }
    }
    return res;
  }
  std::map<abstract_addr::ptr, state_symbol::ptr> find_addr_symbol_same(
      std::unordered_set<std::string> symbol_str_set, short sym_size) {
    std::map<abstract_addr::ptr, state_symbol::ptr> res = {};
    for (auto iter : _addr_symbol_map) {
      if (iter.second != nullptr &&
          (iter.second->get_symbol_size() == sym_size) &&
          iter.second->judge_symbol_str_same(symbol_str_set)) {
        res[iter.first] = iter.second;
      }
    }
    return res;
  }

  // 随机数生成器
  std::default_random_engine& _random;
  // 当前进程的随机数范围限制
  std::uniform_int_distribution<int>& _dist;

  // 地址符号映射
  std::map<abstract_addr::ptr, state_symbol::ptr> _addr_symbol_map;
  // 标志位符号映射
  std::map<abstract_flags::ptr, state_symbol::ptr> _flag_symbol_map;
  std::vector<state_symbol::ptr> _cache_miss_symbol_vector = {};
};
class generate_abstract_addr_tool {
 public:
  typedef std::shared_ptr<generate_abstract_addr_tool> ptr;
  /**
   * @brief 构造函数
   *
   * @param random 随机数生成器
   */
  generate_abstract_addr_tool(std::default_random_engine& random,
                              std::uniform_int_distribution<int>& dist)
      : _random(random), _dist(dist) {}
  /**
   * @brief 从一个字符串获取抽象地址
   *
   * @param size
   * @return abstract_addr::ptr
   */
  abstract_addr::ptr get_abstract_addr(std::string, short size);
  /**
   * @brief 从一个整数地址获取抽象地址
   *
   * @param addr
   * @param size
   * @return abstract_addr::ptr
   */
  abstract_addr::ptr get_abstract_addr(u_int64_t, short size);
  /**
   * @brief 从一个寄存器类型获取抽象地址
   *
   * @param size
   * @return abstract_addr::ptr
   */
  abstract_addr::ptr get_abstract_addr(x86_reg, short size);
  /**
   * @brief 从一个内存地址获取抽象地址,
   * 从内存获取地址的时候设置此地址的污点等级，
   * 等到对此地址操作时具体在确定此地址对应符号的污点等级
   *
   * @param size
   * @return abstract_addr::ptr
   */
  abstract_addr::ptr get_abstract_addr(x86_op_mem, state_machine::ptr, short);
  /**
   * @brief 从一个符号获取抽象地址
   *
   * @param symbol
   * @param size
   * @return abstract_addr::ptr
   */
  abstract_addr::ptr get_abstract_addr(state_symbol::ptr symbol, short size);
  abstract_addr::ptr get_abstract_addr(state_symbol symbol, short size);
  /**
   * @brief 将可拆分的寄存器进行合并处理
   *
   * @return x86_reg
   */
  x86_reg merge_reg(x86_reg);
  /**
   * @brief
   * 对生成抽象地址的工具进行浅拷贝，由于地址和符号不会改变，改变的只是对应关系，所以无需深拷贝
   *
   * @return generate_abstract_addr_tool::ptr
   */
  generate_abstract_addr_tool::ptr shallow_copy() {
    generate_abstract_addr_tool::ptr res =
        std::make_shared<generate_abstract_addr_tool>(_random, _dist);
    res->_addr_map = _addr_map;
    res->_reg_map = _reg_map;
    res->_string_map = _string_map;
    res->_flag_map = _flag_map;
    return res;
  }
  /**
   * @brief 获取一个抽象符号 根据rflags
   *
   * @param flag
   * @return abstract_flags::ptr
   */
  abstract_flags::ptr get_abstract_flag(rflags flag);
  void clear_addr() {
    _addr_map.clear();
    _reg_map.clear();
    _string_map.clear();
  }
  void set_addr(std::vector<abstract_addr::ptr> addr_vector) {
    for (auto iter : addr_vector) {
      if (iter->get_reg() != X86_REG_INVALID) {
        _reg_map[iter->get_reg()] = iter;
      } else if (iter->is_string()) {
        _string_map[iter->get_addr_string()] = iter;
      } else {
        _addr_map[iter->_get_addr_num()] = iter;
      }
    }
  }
  // { return _flag_map[flag]; }

 private:
  std::default_random_engine& _random;
  // 当前进程的随机数范围限制
  std::uniform_int_distribution<int>& _dist;
  /**
   * @brief 数字地址和抽象地址的映射
   *
   */
  std::map<u_int64_t, abstract_addr::ptr> _addr_map;
  /**
   * @brief 字符地址和抽象地址的映射
   *
   */
  std::map<std::string, abstract_addr::ptr> _string_map;
  /**
   * @brief 寄存器地址和抽象地址的映射
   *
   */
  std::map<x86_reg, abstract_addr::ptr> _reg_map;
  /**
   * @brief 标志位和抽象地址的映射
   *
   */
  std::map<rflags, abstract_flags::ptr> _flag_map = {
      {rflags::of, std::make_shared<abstract_flags>(rflags::of)},
      {rflags::sf, std::make_shared<abstract_flags>(rflags::sf)},
      {rflags::zf, std::make_shared<abstract_flags>(rflags::zf)},
      {rflags::pf, std::make_shared<abstract_flags>(rflags::pf)},
      {rflags::cf, std::make_shared<abstract_flags>(rflags::df)},
      {rflags::df, std::make_shared<abstract_flags>(rflags::df)},
      {rflags::af, std::make_shared<abstract_flags>(rflags::af)},
  };
};
#endif