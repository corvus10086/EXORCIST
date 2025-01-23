#ifndef STATE_SYMBOL
#define STATE_SYMBOL
#include <symengine/add.h>
#include <symengine/basic-inl.h>
#include <symengine/basic.h>
#include <symengine/expression.h>
#include <symengine/printers.h>
#include <symengine/symbol.h>
#include <symengine/symengine_config.h>
#include <symengine/symengine_rcp.h>

#include <cstddef>
#include <cstdint>
#include <map>
#include <memory>
#include <regex>
#include <sstream>
#include <string>
#include <unordered_set>
#include <vector>

#include "conf.h"

/**
 * @brief 符号机中的抽象符号类
 *
 */
class state_symbol {
 public:
  // 智能指针
  typedef std::shared_ptr<state_symbol> ptr;
  state_symbol() {}
  // 从无符号整数构建
  state_symbol(uint64_t value)
      : _single_symbol(SymEngine::integer(value)),
        _symbol_size(8),
        _str(std::to_string(value)) {}
  state_symbol(uint64_t value, short size)
      : _single_symbol(SymEngine::integer(value)),
        _symbol_size(size),
        _str(std::to_string(value)) {}

  // 从字符串构建一个符号
  state_symbol(std::string symbol)
      : _single_symbol(SymEngine::symbol(symbol)),
        _symbol_size(8),
        _str(symbol) {}
  state_symbol(std::string symbol, short size)
      : _single_symbol(SymEngine::symbol(symbol)),
        _symbol_size(size),
        _str(symbol) {}
  state_symbol(std::string symbol, short size,
               std::vector<std::string> taine_effect_vector)
      : _single_symbol(SymEngine::symbol(symbol)),
        _symbol_size(size),
        _str(symbol),
        _taine_effect_vector(taine_effect_vector) {
    init_symbol_str();
    _taine_effect_symbol_map[symbol] = taine_effect_vector;
    {
      char taine3 = 0, taine2 = 0, taine1 = 0;
      for (auto taine_str : _taine_effect_symbol_map.at(symbol)) {
        // 记录从记录中找到的污点字符串
        if (taine_str[12] == '1') {
          ++taine1;
        } else if (taine_str[12] == '2') {
          ++taine2;
        } else if (taine_str[12] == '3') {
          ++taine3;
        }
      }
      if (taine3 > 0) {
        _taine = taine_enum::taine3;
      } else if (taine2 > 0) {
        _taine = taine_enum::taine2;
      } else if (taine1 > 0) {
        _taine = taine_enum::taine1;
      } else {
        _taine = taine_enum::not_a_tine;
      }
    }
  }
  state_symbol(std::string symbols, short size,
               std::map<std::string, std::vector<std::string>> symbol_taine_map)
      : _single_symbol(SymEngine::symbol(symbols)),
        _symbol_size(size),
        _str(symbols),
        _taine_effect_symbol_map(symbol_taine_map) {
    init_symbol_str();
    init_symbol_taine();
  }

  // 从原始符号构建抽象符号类
  state_symbol(SymEngine::RCP<const SymEngine::Basic> single_symbol)
      : _single_symbol(single_symbol), _symbol_size(8) {
    std::stringstream stream;
    stream << *single_symbol;
    _str = stream.str();
  }

  state_symbol(SymEngine::RCP<const SymEngine::Basic> single_symbol, short size)
      : _single_symbol(single_symbol), _symbol_size(size) {
    std::stringstream stream;
    stream << *single_symbol;
    _str = stream.str();
  }

  state_symbol(SymEngine::RCP<const SymEngine::Basic> single_symbol, short size,
               taine_enum taine)
      : _single_symbol(single_symbol), _symbol_size(size), _taine(taine) {
    std::stringstream stream;
    stream << *single_symbol;
    _str = stream.str();
  }

  // 拷贝构造函数
  state_symbol(const state_symbol &other)
      : _symbol_size(other._symbol_size),
        _mem_effect(other._mem_effect),
        _single_symbol(other._single_symbol),
        _can_up_taine_level(other._can_up_taine_level),
        _taine2_with_mul_or_left_shift(other._taine2_with_mul_or_left_shift),
        _taine(other._taine),
        _str(other._str),
        _is_flag(other._is_flag),
        _taine_effect_vector(other._taine_effect_vector),
        _taine_effect_symbol_map(other._taine_effect_symbol_map),
        _contain_symbol(other._contain_symbol),
        _size_64_symbol(other._size_64_symbol),
        _size_32_symbol(other._size_32_symbol),
        _size_16_symbol(other._size_16_symbol),
        _size_xh_symbol(other._size_xh_symbol),
        _size_xl_symbol(other._size_xl_symbol) {}

  // 不同大小的拷贝时仅复制映射，字符串，基本符号表示
  state_symbol(const state_symbol &other, short size)
      : _symbol_size(size),
        _mem_effect(other._mem_effect),
        _single_symbol(other._single_symbol),
        _can_up_taine_level(other._can_up_taine_level),
        _taine2_with_mul_or_left_shift(other._taine2_with_mul_or_left_shift),
        _str(other._str),
        _taine(other._taine),
        _taine_effect_vector(other._taine_effect_vector),
        _taine_effect_symbol_map(other._taine_effect_symbol_map),
        _contain_symbol(other._contain_symbol),
        _is_flag(other._is_flag) {
    if (size == other._symbol_size) {
      _size_64_symbol = other._size_64_symbol;
      _size_32_symbol = other._size_32_symbol;
      _size_16_symbol = other._size_16_symbol;
      _size_xh_symbol = other._size_xh_symbol;
      _size_xl_symbol = other._size_xl_symbol;
    }
  }
  state_symbol &operator=(const state_symbol &other) {
    if (this != &other) {
      _symbol_size = other._symbol_size;
      _mem_effect = other._mem_effect;
      _single_symbol = other._single_symbol;
      _can_up_taine_level = other._can_up_taine_level;
      _taine2_with_mul_or_left_shift = other._taine2_with_mul_or_left_shift;
      _str = other._str;
      _taine = other._taine;
      _is_flag = other._is_flag;
      _taine_effect_vector = other._taine_effect_vector;
      _taine_effect_symbol_map = other._taine_effect_symbol_map;
      _contain_symbol = other._contain_symbol;
      _size_64_symbol = other._size_64_symbol;
      _size_32_symbol = other._size_32_symbol;
      _size_16_symbol = other._size_16_symbol;
      _size_xh_symbol = other._size_xh_symbol;
      _size_xl_symbol = other._size_xl_symbol;
    }
    return *this;
  }

  state_symbol(state_symbol::ptr other)
      : _symbol_size(other->_symbol_size),
        _mem_effect(other->_mem_effect),
        _single_symbol(other->_single_symbol),
        _can_up_taine_level(other->_can_up_taine_level),
        _taine2_with_mul_or_left_shift(other->_taine2_with_mul_or_left_shift),
        _str(other->_str),
        _taine(other->_taine),
        _is_flag(other->_is_flag),
        _taine_effect_vector(other->_taine_effect_vector),
        _taine_effect_symbol_map(other->_taine_effect_symbol_map),
        _contain_symbol(other->_contain_symbol),
        _size_64_symbol(other->_size_64_symbol),
        _size_32_symbol(other->_size_32_symbol),
        _size_16_symbol(other->_size_16_symbol),
        _size_xh_symbol(other->_size_xh_symbol),
        _size_xl_symbol(other->_size_xl_symbol) {}

  state_symbol(state_symbol::ptr other, short size)
      : _symbol_size(size),
        _mem_effect(other->_mem_effect),
        _single_symbol(other->_single_symbol),
        _can_up_taine_level(other->_can_up_taine_level),
        _taine2_with_mul_or_left_shift(other->_taine2_with_mul_or_left_shift),
        _is_flag(other->_is_flag),
        _taine(other->_taine),
        _taine_effect_vector(other->_taine_effect_vector),
        _taine_effect_symbol_map(other->_taine_effect_symbol_map),
        _contain_symbol(other->_contain_symbol),
        _str(other->_str) {
    if (size == other->_symbol_size) {
      _size_64_symbol = other->_size_64_symbol;
      _size_32_symbol = other->_size_32_symbol;
      _size_16_symbol = other->_size_16_symbol;
      _size_xh_symbol = other->_size_xh_symbol;
      _size_xl_symbol = other->_size_xl_symbol;
    }
  }

  // 设置

  // 初始化抽象符号所包含的符号
  void init_symbol_str() {
    // 记录符号的字符串表示
    this->to_string();
    std::regex pattern("#symbol[0-9]{6}#");
    std::smatch match_result;
    std::string::const_iterator iterStart = _str.begin();
    std::string::const_iterator iterEnd = _str.end();

    while (std::regex_search(iterStart, iterEnd, match_result, pattern)) {
      // 记录从符号中找到的符号
      _contain_symbol.insert(match_result[0]);
      iterStart = match_result[0].second;
    }
  }
  // 在设置符号的taine_symbol_map后设置符号的污点等级
  void init_symbol_taine() {
    char taine3 = 0, taine2 = 0, taine1 = 0;
    for (auto symbol : _contain_symbol) {
      if (_taine_effect_symbol_map.count(symbol)) {
        for (auto taine_str : _taine_effect_symbol_map.at(symbol)) {
          // 记录从记录中找到的污点字符串
          _taine_effect_vector.push_back(taine_str);
          if (taine_str[12] == '1') {
            ++taine1;
          } else if (taine_str[12] == '2') {
            ++taine2;
          } else if (taine_str[12] == '3') {
            ++taine3;
          }
        }
      }
      if (_size_64_symbol != nullptr) {
        if (_size_64_symbol->_taine_effect_symbol_map.count(symbol)) {
          for (auto taine_str : _taine_effect_symbol_map.at(symbol)) {
            // 记录从记录中找到的污点字符串
            _taine_effect_vector.push_back(taine_str);
            if (taine_str[12] == '1') {
              ++taine1;
            } else if (taine_str[12] == '2') {
              ++taine2;
            } else if (taine_str[12] == '3') {
              ++taine3;
            }
          }
        }
      }
      if (_size_32_symbol != nullptr) {
        if (_size_32_symbol->_taine_effect_symbol_map.count(symbol)) {
          for (auto taine_str : _taine_effect_symbol_map.at(symbol)) {
            // 记录从记录中找到的污点字符串
            _taine_effect_vector.push_back(taine_str);
            if (taine_str[12] == '1') {
              ++taine1;
            } else if (taine_str[12] == '2') {
              ++taine2;
            } else if (taine_str[12] == '3') {
              ++taine3;
            }
          }
        }
      }
      if (_size_16_symbol != nullptr) {
        if (_size_16_symbol->_taine_effect_symbol_map.count(symbol)) {
          for (auto taine_str : _taine_effect_symbol_map.at(symbol)) {
            // 记录从记录中找到的污点字符串
            _taine_effect_vector.push_back(taine_str);
            if (taine_str[12] == '1') {
              ++taine1;
            } else if (taine_str[12] == '2') {
              ++taine2;
            } else if (taine_str[12] == '3') {
              ++taine3;
            }
          }
        }
      }
      if (_size_xh_symbol != nullptr) {
        if (_size_xh_symbol->_taine_effect_symbol_map.count(symbol)) {
          for (auto taine_str : _taine_effect_symbol_map.at(symbol)) {
            // 记录从记录中找到的污点字符串
            _taine_effect_vector.push_back(taine_str);
            if (taine_str[12] == '1') {
              ++taine1;
            } else if (taine_str[12] == '2') {
              ++taine2;
            } else if (taine_str[12] == '3') {
              ++taine3;
            }
          }
        }
      }
      if (_size_xl_symbol != nullptr) {
        if (_size_xl_symbol->_taine_effect_symbol_map.count(symbol)) {
          for (auto taine_str : _taine_effect_symbol_map.at(symbol)) {
            // 记录从记录中找到的污点字符串
            _taine_effect_vector.push_back(taine_str);
            if (taine_str[12] == '1') {
              ++taine1;
            } else if (taine_str[12] == '2') {
              ++taine2;
            } else if (taine_str[12] == '3') {
              ++taine3;
            }
          }
        }
      }
    }
    if (taine3 > 0) {
      _taine = taine_enum::taine3;
    } else if (taine2 > 0) {
      _taine = taine_enum::taine2;
    } else if (taine1 > 0) {
      _taine = taine_enum::taine1;
    } else {
      _taine = taine_enum::not_a_tine;
    }
  }
  // 判断两个抽象符号包含的符号所关联的最大污点是否相同
  bool judge_taine_same(const state_symbol &other) {
    // if (_taine == taine_enum::not_a_tine ||
    //     other._taine == taine_enum::not_a_tine) {
    //   return false;
    // }
    if (this->_taine != other._taine) {
      return false;
    } else {
      for (auto iter : _taine_effect_vector) {
        for (auto other_iter : other._taine_effect_vector) {
          if (iter == other_iter && judge_taine_by_str(iter) == _taine) {
            return true;
          }
        }
      }
    }
    return false;
  }
  bool judge_taine_same(const std::vector<state_symbol::ptr> &other_vector) {
    for (state_symbol::ptr iter : other_vector) {
      if (judge_taine_same(iter)) {
        return true;
      }
    }
    return false;
  }
  // 判断是否受到影响
  bool judge_taine_effect(const state_symbol &other) {
    if (this->_taine != other._taine) {
      return false;
    } else {
      for (auto iter : _taine_effect_vector) {
        for (auto other_iter : other._taine_effect_vector) {
          if (iter == other_iter) {
            return true;
          }
        }
      }
    }
    return false;
  }
  bool judge_taine_effect(const std::vector<state_symbol::ptr> &other_vector) {
    for (state_symbol::ptr iter : other_vector) {
      if (judge_taine_effect(iter)) {
        return true;
      }
    }
    return false;
  }
  bool judge_taine_effect(state_symbol::ptr other) {
    if (this->_taine != other->_taine) {
      return false;
    } else {
      for (auto iter : _taine_effect_vector) {
        for (auto other_iter : other->_taine_effect_vector) {
          if (iter == other_iter) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // 判断两个抽象符号包含的符号所关联的最大污点是否相同
  bool judge_taine_same(state_symbol::ptr other) {
    // if (_taine == taine_enum::not_a_tine ||
    //     other->_taine == taine_enum::not_a_tine) {
    //   return false;
    // }
    if (this->_taine != other->_taine) {
      return false;
    } else {
      for (auto iter : _taine_effect_vector) {
        for (auto other_iter : other->_taine_effect_vector) {
          if (iter == other_iter && judge_taine_by_str(iter) == _taine) {
            return true;
          }
        }
      }
    }
    return false;
  }

  taine_enum judge_taine_by_str(std::string taine_str) {
    std::regex pattern("#taine[0-9]{6}[0-3]#");
    std::smatch match_result;
    std::string::const_iterator iterStart = taine_str.begin();
    std::string::const_iterator iterEnd = taine_str.end();
    std::regex_search(iterStart, iterEnd, match_result, pattern);
    auto test = match_result[0];
    taine_enum res = taine_enum::not_a_tine;
    switch (test.str()[12]) {
      case '0': {
        res = taine_enum::not_a_tine;
        break;
      }
      case '1': {
        res = taine_enum::taine1;
        break;
      }
      case '2': {
        res = taine_enum::taine2;
        break;
      }
      case '3': {
        res = taine_enum::taine3;
        break;
      }
    }
    return res;
  }

  bool judge_taine_str_effect(std::string taine_str) {
    for (auto iter_taine_str : _taine_effect_vector) {
      if (iter_taine_str == taine_str) {
        return true;
      }
    }
    return false;
  }
  bool judge_taine_str_effect(std::vector<std::string> taine_str_vec) {
    for (auto taine_str : taine_str_vec) {
      if (judge_taine_str_effect(taine_str)) {
        return true;
      }
    }
    return false;
  }
  bool judge_symbol_str_effect(std::string symbol_str) {
    for (auto iter : _contain_symbol) {
      if (iter == symbol_str) {
        return true;
      }
    }
    return false;
  }
  bool judge_symbol_str_effect(std::vector<std::string> symbol_str_vec) {
    for (auto iter : symbol_str_vec) {
      if (judge_symbol_str_effect(iter)) {
        return true;
      }
    }
    return false;
  }
  bool judge_symbol_str_same(std::unordered_set<std::string> symbol_str_set) {
    if (symbol_str_set.size() != _contain_symbol.size()) {
      return false;
    }
    for (auto iter : symbol_str_set) {
      if (!judge_symbol_str_effect(iter)) {
        return false;
      }
    }
    return true;
  }

  //返回全部影响该符号的污点字符串
  std::vector<std::string> &get_taine_str() { return _taine_effect_vector; }

  //返回污点字符串
  std::vector<std::string> get_taine_str(
      std::vector<std::string> symbol_vector) const {
    std::vector<std::string> taine_vector;
    for (auto symbol : symbol_vector) {
      if (_taine_effect_symbol_map.count(symbol)) {
        taine_vector.insert(taine_vector.end(),
                            _taine_effect_symbol_map.at(symbol).begin(),
                            _taine_effect_symbol_map.at(symbol).end());
      }
      if (_size_64_symbol != nullptr) {
        if (_size_64_symbol->_taine_effect_symbol_map.count(symbol)) {
          taine_vector.insert(taine_vector.end(),
                              _taine_effect_symbol_map.at(symbol).begin(),
                              _taine_effect_symbol_map.at(symbol).end());
        }
      }
      if (_size_32_symbol != nullptr) {
        if (_size_32_symbol->_taine_effect_symbol_map.count(symbol)) {
          taine_vector.insert(taine_vector.end(),
                              _taine_effect_symbol_map.at(symbol).begin(),
                              _taine_effect_symbol_map.at(symbol).end());
        }
      }
      if (_size_xh_symbol != nullptr) {
        if (_size_xh_symbol->_taine_effect_symbol_map.count(symbol)) {
          taine_vector.insert(taine_vector.end(),
                              _taine_effect_symbol_map.at(symbol).begin(),
                              _taine_effect_symbol_map.at(symbol).end());
        }
      }
      if (_size_xl_symbol != nullptr) {
        if (_size_xl_symbol->_taine_effect_symbol_map.count(symbol)) {
          taine_vector.insert(taine_vector.end(),
                              _taine_effect_symbol_map.at(symbol).begin(),
                              _taine_effect_symbol_map.at(symbol).end());
        }
      }
    }
    return taine_vector;
  }

  // 将符号转化为字符串
  const std::string to_string() const {
    if (_str == "") {
      std::stringstream stream;
      stream << *(this->_single_symbol);
      return stream.str();
    }
    return _str;
  }
  // 将具体值的符号转换为数字
  uint64_t to_int() const {
    std::stringstream strIn;
    strIn << this->to_string();
    long long q1;
    strIn >> q1;
    return q1;
  }
  //判断符号是否是数字
  bool is_num() const {
    std::regex reg("^[+-]?\\d+");  // 匹配一个或多个数字
    std::string tmp = this->to_string();
    return regex_match(tmp, reg);
  }

  //符号的运算
  state_symbol operator+(const state_symbol &right);
  state_symbol op_add(state_symbol::ptr right);
  state_symbol op_add(const state_symbol &right);
  state_symbol operator-(const state_symbol &right);
  state_symbol op_sub(state_symbol::ptr right);
  state_symbol op_sub(const state_symbol &right);
  state_symbol operator*(const state_symbol &right);
  state_symbol op_mul(state_symbol::ptr right);
  state_symbol op_mul(const state_symbol &right);
  state_symbol operator/(const state_symbol &right);
  state_symbol op_div(state_symbol::ptr right);
  state_symbol op_div(const state_symbol &right);

  state_symbol op_and(const state_symbol &right);
  state_symbol op_and(state_symbol::ptr right);
  state_symbol op_or(const state_symbol &right);
  state_symbol op_or(state_symbol::ptr &right);
  state_symbol op_not();
  state_symbol op_xor(const state_symbol &right);
  state_symbol op_xor(state_symbol::ptr &right);
  state_symbol op_left_shift(const state_symbol &right);
  state_symbol op_left_shift(state_symbol::ptr &right);
  state_symbol op_right_shift(const state_symbol &right);
  state_symbol op_right_shift(state_symbol::ptr &right);

  short get_symbol_size() { return _symbol_size; }
  void set_symbol_size(short size) { _symbol_size = size; }
  bool get_can_up_taine_lv() { return _can_up_taine_level; }
  void set_can_up_taine_lv_true() {
    _can_up_taine_level = true;
    if (_size_xh_symbol != nullptr) {
      _size_xh_symbol->_can_up_taine_level = true;
    }
    if (_size_xl_symbol != nullptr) {
      _size_xl_symbol->_can_up_taine_level = true;
    }
    switch (_symbol_size) {
      case 8: {
        if (_size_16_symbol != nullptr) {
          _size_16_symbol->_can_up_taine_level = true;
        }
        if (_size_32_symbol != nullptr) {
          _size_32_symbol->_can_up_taine_level = true;
        }
        break;
      }
      case 4: {
        if (_size_16_symbol != nullptr) {
          _size_16_symbol->_can_up_taine_level = true;
        }
        break;
      }
    }
  }
  bool get_symbol_mem_effect() { return _mem_effect; }
  void set_symbol_mem_effect_true() {
    _mem_effect = true;
    if (_size_xh_symbol != nullptr) {
      _size_xh_symbol->_mem_effect = true;
    }
    if (_size_xl_symbol != nullptr) {
      _size_xl_symbol->_mem_effect = true;
    }
    switch (_symbol_size) {
      case 8: {
        if (_size_16_symbol != nullptr) {
          _size_16_symbol->_mem_effect = true;
        }
        if (_size_32_symbol != nullptr) {
          _size_32_symbol->_mem_effect = true;
        }
        break;
      }
      case 4: {
        if (_size_16_symbol != nullptr) {
          _size_16_symbol->_mem_effect = true;
        }
        break;
      }
    }
  }
  // 当前符号和内存有关系
  bool _mem_effect = false;
  // 标志符号污点是否能够晋升的标识
  bool _can_up_taine_level = false;
  // taine2经过乘法或者左移操作进行放大
  bool _taine2_with_mul_or_left_shift = false;

  std::vector<std::string> _taine_effect_vector;
  // 一个存放污点字符串与符号关联的映射
  // 这个属性用于污点的追踪，将符号与影响其的污点绑定
  std::map<std::string, std::vector<std::string>> _taine_effect_symbol_map;
  // 这个属性用于存放抽象符号中包含的符号（由于抽象符号一经确定不会更改，所以这个也不会更改
  std::unordered_set<std::string> _contain_symbol;
  // 被覆盖时原本的64位寄存器所代表的符号
  state_symbol::ptr _size_64_symbol = nullptr;
  // eax所代表的符号
  state_symbol::ptr _size_32_symbol = nullptr;
  // ax所代表的符号
  state_symbol::ptr _size_16_symbol = nullptr;
  // ah所代表的符号
  state_symbol::ptr _size_xh_symbol = nullptr;
  // al所代表的符号
  state_symbol::ptr _size_xl_symbol = nullptr;
  // 该符号的最大污点等级
  taine_enum _taine = taine_enum::not_a_tine;
  // 是否是一个标志位
  bool _is_flag = false;

 private:
  // 符号的位数
  short _symbol_size;
  // 具体符号 可拆分寄存器时这个表示64位寄存器的符号
  SymEngine::RCP<const SymEngine::Basic> _single_symbol = SymEngine::null;

  // 符号的字符串表示
  std::string _str = "";
};

#endif