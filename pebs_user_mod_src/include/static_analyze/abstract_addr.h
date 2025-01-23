#ifndef ABSTRACT_ADDR
#define ABSTRACT_ADDR

/**
 * @brief 一个代表抽象地址的类
 */
#include <capstone/x86.h>
#include <sys/types.h>

#include <cstddef>
#include <cstdint>
#include <map>
#include <memory>
#include <regex>
#include <string>
#include <vector>

#include "conf.h"
class abstract_addr {
 public:
  typedef std::shared_ptr<abstract_addr> ptr;

  abstract_addr(x86_reg reg) : _register(reg), _size(8) {}

  abstract_addr(std::string str) : _addr_string(str), _size(8) {}

  abstract_addr(x86_reg reg, short size) : _register(reg), _size(size) {}

  abstract_addr(std::string str, short size) : _addr_string(str), _size(size) {}

  abstract_addr(uint64_t num) : _addr_num(num), _size(8) {}

  abstract_addr(uint64_t num, short size) : _addr_num(num), _size(size) {}

  abstract_addr(const abstract_addr &other)
      : _register(other._register),
        _addr_string(other._addr_string),
        _size(other._size) {}

  abstract_addr(const abstract_addr::ptr other)
      : _register(other->_register),
        _addr_string(other->_addr_string),
        _size(other->_size) {}
  /**
   * @brief 标识此地址中的符号大小
   *
   */
  short _size;
  /**
   * @brief 标记这是一个未知地址
   *
   */
  taine_enum _taine = taine_enum::not_a_tine;
  bool _can_up_taine_lv = false;
  bool is_register() { return _register == X86_REG_INVALID ? false : true; }
  bool is_string() { return _addr_string == "" ? false : true; }
  bool is_num() { return _addr_num == -1 ? false : true; }
  x86_reg get_reg() { return _register; }
  std::string get_addr_string() { return _addr_string; }
  uint64_t _get_addr_num(){return _addr_num;}

  // 获取字符串地址中的符号来源
  std::vector<std::string> get_symbol_str_vector() {
    if (_addr_string == "") {
      return {""};
    }
    std::vector<std::string> res;
    std::regex pattern("#symbol[0-9]{6}#");
    std::smatch match_result;
    std::string::const_iterator iterStart = _addr_string.begin();
    std::string::const_iterator iterEnd = _addr_string.end();
    while (std::regex_search(iterStart, iterEnd, match_result, pattern)) {
      // 记录从符号中找到的符号
      res.push_back(match_result[0]);
      iterStart = match_result[0].second;
    }
    return res;
  }

 private:
  x86_reg _register = X86_REG_INVALID;
  std::string _addr_string = "";
  uint64_t _addr_num = -1;
};

class abstract_flags {
 public:
  typedef std::shared_ptr<abstract_flags> ptr;

  abstract_flags(rflags rflag) : _rflag(rflag) {}
  abstract_flags(const abstract_flags &other) : _rflag(other._rflag) {}
  abstract_flags(const abstract_flags::ptr other) : _rflag(other->_rflag) {}

 private:
  rflags _rflag;
};

#endif