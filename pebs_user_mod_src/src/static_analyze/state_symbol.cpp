#include "state_symbol.h"

#include <asm-generic/errno.h>
#include <symengine/add.h>
#include <symengine/basic.h>
#include <symengine/dict.h>
#include <symengine/expression.h>
#include <symengine/functions.h>
#include <symengine/integer.h>
#include <symengine/logic.h>
#include <symengine/mp_class.h>
#include <symengine/mul.h>
#include <symengine/pow.h>
#include <symengine/symengine_rcp.h>


#include <cstdint>
#include <memory>
#include <sstream>
#include <string>
#include <vector>


state_symbol state_symbol::operator+(const state_symbol &right) {
  auto max_size = this->_symbol_size > right._symbol_size ? this->_symbol_size
                                                          : right._symbol_size;
  auto this_symbol = this->_single_symbol;
  auto right_symbol = right._single_symbol;
  char num_num = 0;
  if (this->is_num()) {
    ++num_num;
    auto num = this->to_int();
    if (num == 0 && this->_symbol_size == max_size) {
      return state_symbol(right);
    }
    this_symbol = SymEngine::integer(num);
  }
  if (right.is_num()) {
    ++num_num;
    auto num = right.to_int();
    if (num == 0 && right._symbol_size == max_size) {
      return state_symbol(*this);
    }
    right_symbol = SymEngine::integer(num);
  }
  state_symbol res = state_symbol();
  if (num_num == 2) {
    res._single_symbol = SymEngine::integer(this->to_int() + right.to_int());
  } else {
    res._single_symbol = SymEngine::add(this_symbol, right_symbol);
  }
  res._str = res._single_symbol->__str__();
  res._symbol_size = max_size;
  // 获取res的taine符号
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right._taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right._taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right._mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  if (this->_can_up_taine_level || right._can_up_taine_level) {
    res.set_can_up_taine_lv_true();
  }
  if (this->_taine2_with_mul_or_left_shift ||
      right._taine2_with_mul_or_left_shift) {
    res._taine2_with_mul_or_left_shift = true;
  }
  return res;
}
state_symbol state_symbol::op_add(state_symbol::ptr right) {
  auto max_size = this->_symbol_size > right->_symbol_size
                      ? this->_symbol_size
                      : right->_symbol_size;
  auto this_symbol = this->_single_symbol;
  auto right_symbol = right->_single_symbol;
  char num_num = 0;
  if (this->is_num()) {
    ++num_num;
    auto num = this->to_int();
    if (num == 0 && this->_symbol_size == max_size) {
      return state_symbol(right);
    }
    this_symbol = SymEngine::integer(num);
  }
  if (right->is_num()) {
    ++num_num;
    auto num = right->to_int();
    if (num == 0 && right->_symbol_size == max_size) {
      return state_symbol(*this);
    }
    right_symbol = SymEngine::integer(num);
  }
  state_symbol res = state_symbol();
  if (num_num == 2) {
    res._single_symbol = SymEngine::integer(this->to_int() + right->to_int());
  } else {
    res._single_symbol = SymEngine::add(this_symbol, right_symbol);
  }
  res._str = res._single_symbol->__str__();
  res._symbol_size = max_size;
  // 获取res的taine符号
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right->_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right->_taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right->_mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  if (this->_can_up_taine_level || right->_can_up_taine_level) {
    res.set_can_up_taine_lv_true();
  }
  if (this->_taine2_with_mul_or_left_shift ||
      right->_taine2_with_mul_or_left_shift) {
    res._taine2_with_mul_or_left_shift = true;
  }
  return res;
}
state_symbol state_symbol::op_add(const state_symbol &right) {
  auto max_size = this->_symbol_size > right._symbol_size ? this->_symbol_size
                                                          : right._symbol_size;
  auto this_symbol = this->_single_symbol;
  auto right_symbol = right._single_symbol;
  char num_num = 0;
  if (this->is_num()) {
    ++num_num;
    auto num = this->to_int();
    if (num == 0 && this->_symbol_size == max_size) {
      return state_symbol(right);
    }
    this_symbol = SymEngine::integer(num);
  }
  if (right.is_num()) {
    ++num_num;
    auto num = right.to_int();
    if (num == 0 && right._symbol_size == max_size) {
      return state_symbol(*this);
    }
    right_symbol = SymEngine::integer(num);
  }
  state_symbol res = state_symbol();
  if (num_num == 2) {
    res._single_symbol = SymEngine::integer(this->to_int() + right.to_int());
  } else {
    res._single_symbol = SymEngine::add(this_symbol, right_symbol);
  }
  res._str = res._single_symbol->__str__();
  res._symbol_size = max_size;
  // 获取res的taine符号
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right._taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right._taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right._mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  if (this->_can_up_taine_level || right._can_up_taine_level) {
    res.set_can_up_taine_lv_true();
  }
  if (this->_taine2_with_mul_or_left_shift ||
      right._taine2_with_mul_or_left_shift) {
    res._taine2_with_mul_or_left_shift = true;
  }
  return res;
}
state_symbol state_symbol::operator-(const state_symbol &right) {
  auto max_size = this->_symbol_size > right._symbol_size ? this->_symbol_size
                                                          : right._symbol_size;
  auto this_symbol = this->_single_symbol;
  auto right_symbol = right._single_symbol;
  if (this->is_num()) {
    auto num = this->to_int();
    // if (num == 0) {
    //   return state_symbol(right);
    // }
    this_symbol = SymEngine::integer(num);
  }
  if (right.is_num()) {
    auto num = right.to_int();
    if (num == 0 && this->_symbol_size == max_size) {
      return state_symbol(*this);
    }
    right_symbol = SymEngine::integer(num);
  }
  state_symbol res = state_symbol();
  res._single_symbol = SymEngine::sub(this_symbol, right_symbol);
  res._str = res._single_symbol->__str__();
  res._symbol_size = max_size;
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right._taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right._taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right._mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  if (this->_can_up_taine_level || right._can_up_taine_level) {
    res.set_can_up_taine_lv_true();
  }
  if (this->_taine2_with_mul_or_left_shift ||
      right._taine2_with_mul_or_left_shift) {
    res._taine2_with_mul_or_left_shift = true;
  }
  return res;
}
state_symbol state_symbol::op_sub(state_symbol::ptr right) {
  auto max_size = this->_symbol_size > right->_symbol_size
                      ? this->_symbol_size
                      : right->_symbol_size;
  auto this_symbol = this->_single_symbol;
  auto right_symbol = right->_single_symbol;
  if (this->is_num()) {
    auto num = this->to_int();
    // if (num == 0) {
    //   return state_symbol(right);
    // }
    if (right->is_num()) {
      auto right_num = right->to_int();
      if (num > right_num) {
        return state_symbol(num - right_num, max_size);
      }
    }
    this_symbol = SymEngine::integer(num);
  }
  if (right->is_num()) {
    auto num = right->to_int();
    if (num == 0 && this->_symbol_size == max_size) {
      return state_symbol(*this);
    }
    right_symbol = SymEngine::integer(num);
  }
  state_symbol res = state_symbol();
  res._single_symbol = SymEngine::sub(this_symbol, right_symbol);
  res._str = res._single_symbol->__str__();
  res._symbol_size = max_size;
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right->_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right->_taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right->_mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  if (this->_can_up_taine_level || right->_can_up_taine_level) {
    res.set_can_up_taine_lv_true();
  }
  if (this->_taine2_with_mul_or_left_shift ||
      right->_taine2_with_mul_or_left_shift) {
    res._taine2_with_mul_or_left_shift = true;
  }
  return res;
}
state_symbol state_symbol::op_sub(const state_symbol &right) {
  auto max_size = this->_symbol_size > right._symbol_size ? this->_symbol_size
                                                          : right._symbol_size;
  auto this_symbol = this->_single_symbol;
  auto right_symbol = right._single_symbol;
  if (this->is_num()) {
    auto num = this->to_int();
    if (right.is_num()) {
      auto right_num = right.to_int();
      if (num > right_num) {
        return state_symbol(num - right_num, max_size);
      }
    }
    this_symbol = SymEngine::integer(num);
  }
  if (right.is_num()) {
    auto num = right.to_int();
    if (num == 0 && this->_symbol_size == max_size) {
      return state_symbol(*this);
    }

    right_symbol = SymEngine::integer(num);
  }
  state_symbol res = state_symbol();
  res._single_symbol = SymEngine::sub(this_symbol, right_symbol);
  res._str = res._single_symbol->__str__();
  res._symbol_size = max_size;
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right._taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right._taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right._mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  if (this->_can_up_taine_level || right._can_up_taine_level) {
    res.set_can_up_taine_lv_true();
  }
  if (this->_taine2_with_mul_or_left_shift ||
      right._taine2_with_mul_or_left_shift) {
    res._taine2_with_mul_or_left_shift = true;
  }
  return res;
}
state_symbol state_symbol::operator*(const state_symbol &right) {
  auto max_size = this->_symbol_size > right._symbol_size ? this->_symbol_size
                                                          : right._symbol_size;
  auto this_symbol = this->_single_symbol;
  auto right_symbol = right._single_symbol;
  if (this->is_num()) {
    auto num = this->to_int();
    if (num == 1 && right._symbol_size == max_size) {
      return state_symbol(right);
    }
    this_symbol = SymEngine::integer(num);
  }
  if (right.is_num()) {
    auto num = right.to_int();
    if (num == 1 && this->_symbol_size == max_size) {
      return state_symbol(*this);
    }
    right_symbol = SymEngine::integer(num);
  }
  state_symbol res = state_symbol();
  res._single_symbol = SymEngine::mul(this_symbol, right_symbol);
  res._str = res._single_symbol->__str__();
  res._symbol_size = max_size;
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right._taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right._taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right._mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  if (this->_can_up_taine_level || right._can_up_taine_level) {
    res.set_can_up_taine_lv_true();
  }
  return res;
}
state_symbol state_symbol::op_mul(state_symbol::ptr right) {
  auto max_size = this->_symbol_size > right->_symbol_size
                      ? this->_symbol_size
                      : right->_symbol_size;
  auto this_symbol = this->_single_symbol;
  auto right_symbol = right->_single_symbol;
  if (this->is_num()) {
    auto num = this->to_int();
    if (num == 1 && right->_symbol_size == max_size) {
      return state_symbol(right);
    }
    this_symbol = SymEngine::integer(num);
  }
  if (right->is_num()) {
    auto num = right->to_int();
    if (num == 1 && this->_symbol_size == max_size) {
      return state_symbol(*this);
    }
    right_symbol = SymEngine::integer(num);
  }
  state_symbol res = state_symbol();
  res._single_symbol = SymEngine::mul(this_symbol, right_symbol);
  res._str = res._single_symbol->__str__();
  res._symbol_size = max_size;
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right->_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right->_taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right->_mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  if (this->_can_up_taine_level || right->_can_up_taine_level) {
    res.set_can_up_taine_lv_true();
  }
  return res;
}
state_symbol state_symbol::op_mul(const state_symbol &right) {
  auto max_size = this->_symbol_size > right._symbol_size ? this->_symbol_size
                                                          : right._symbol_size;
  auto this_symbol = this->_single_symbol;
  auto right_symbol = right._single_symbol;
  if (this->is_num()) {
    auto num = this->to_int();
    if (num == 1 && right._symbol_size == max_size) {
      return state_symbol(right);
    }
    this_symbol = SymEngine::integer(num);
  }
  if (right.is_num()) {
    auto num = right.to_int();
    if (num == 1 && this->_symbol_size == max_size) {
      return state_symbol(*this);
    }
    right_symbol = SymEngine::integer(num);
  }
  state_symbol res = state_symbol();
  res._single_symbol = SymEngine::mul(this_symbol, right_symbol);
  res._str = res._single_symbol->__str__();
  res._symbol_size = max_size;
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right._taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right._taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right._mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  if (this->_can_up_taine_level || right._can_up_taine_level) {
    res.set_can_up_taine_lv_true();
  }
  return res;
}
state_symbol state_symbol::operator/(const state_symbol &right) {
  auto this_symbol = this->_single_symbol;
  auto right_symbol = right._single_symbol;
  if (this->is_num()) {
    this_symbol = SymEngine::integer(this->to_int());
  }
  if (right.is_num()) {
    right_symbol = SymEngine::integer(right.to_int());
  }
  auto res_sym_symbol = SymEngine::div(this_symbol, right_symbol);
  state_symbol res = state_symbol(res_sym_symbol, _symbol_size);
  res._symbol_size = this->_symbol_size > right._symbol_size
                         ? this->_symbol_size
                         : right._symbol_size;
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right._taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right._taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right._mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  if (this->_can_up_taine_level || right._can_up_taine_level) {
    res.set_can_up_taine_lv_true();
  }
  return res;
}
state_symbol state_symbol::op_div(state_symbol::ptr right) {
  auto this_symbol = this->_single_symbol;
  auto right_symbol = right->_single_symbol;
  if (this->is_num()) {
    this_symbol = SymEngine::integer(this->to_int());
  }
  if (right->is_num()) {
    right_symbol = SymEngine::integer(right->to_int());
  }
  auto res_sym_symbol = SymEngine::div(this_symbol, right_symbol);
  state_symbol res = state_symbol(res_sym_symbol, _symbol_size);
  res._symbol_size = this->_symbol_size > right->_symbol_size
                         ? this->_symbol_size
                         : right->_symbol_size;
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right->_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right->_taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right->_mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  if (this->_can_up_taine_level || right->_can_up_taine_level) {
    res.set_can_up_taine_lv_true();
  }
  return res;
}
state_symbol state_symbol::op_div(const state_symbol &right) {
  auto this_symbol = this->_single_symbol;
  auto right_symbol = right._single_symbol;
  if (this->is_num()) {
    this_symbol = SymEngine::integer(this->to_int());
  }
  if (right.is_num()) {
    right_symbol = SymEngine::integer(right.to_int());
  }
  auto res_sym_symbol = SymEngine::div(this_symbol, right_symbol);
  state_symbol res = state_symbol(res_sym_symbol, _symbol_size);
  res._symbol_size = this->_symbol_size > right._symbol_size
                         ? this->_symbol_size
                         : right._symbol_size;
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right._taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right._taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right._mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  if (this->_can_up_taine_level || right._can_up_taine_level) {
    res.set_can_up_taine_lv_true();
  }
  return res;
}
state_symbol state_symbol::op_and(const state_symbol &right) {
  //都是数字的情况下可以直接计算

  short symbol_size = this->_symbol_size > right._symbol_size
                          ? this->_symbol_size
                          : right._symbol_size;

  if (this->is_num() && right.is_num()) {
    uint64_t left_num = this->to_int();
    uint64_t right_num = right.to_int();
    return state_symbol(left_num & right_num, symbol_size);
  }
  if (right.is_num()) {
    //和全0与会变成全0,这种情况下会将原值覆盖
    uint64_t num = right.to_int();
    if (num == 0) {
      return state_symbol(0, symbol_size);
    }
  }
  if (this->is_num()) {
    //和全0与会变成全0,这种情况下会将原值覆盖
    uint64_t num = this->to_int();
    if (num == 0) {
      return state_symbol(0, symbol_size);
    }
  }
  //其中一个都是符号并且无法被覆盖的情况下

  // state_symbol res =
  //     state_symbol(this->to_string() + "_with_and", _symbol_size,
  //                  std::make_shared<symbol_tree>(new_root_node(
  //                      symbol_node::op_type::AND,
  //                      std::make_shared<symbol_node>(right._single_symbol))));
  std::stringstream stream;
  stream << this->to_string() << "_and_" << right.to_string() << "-";
  state_symbol res = state_symbol(stream.str(), _symbol_size);

  res._symbol_size = symbol_size;
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right._taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right._taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right._mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  if (this->_can_up_taine_level || right._can_up_taine_level) {
    res.set_can_up_taine_lv_true();
  }
  return res;
}
state_symbol state_symbol::op_and(state_symbol::ptr right) {
  //都是数字的情况下可以直接计算

  short symbol_size = this->_symbol_size > right->_symbol_size
                          ? this->_symbol_size
                          : right->_symbol_size;

  if (this->is_num() && right->is_num()) {
    uint64_t left_num = this->to_int();
    uint64_t right_num = right->to_int();
    return state_symbol(left_num & right_num, symbol_size);
  }
  if (right->is_num()) {
    //和全0与会变成全0,这种情况下会将原值覆盖
    uint64_t num = right->to_int();
    if (num == 0) {
      return state_symbol(0, symbol_size);
    }
  }
  if (this->is_num()) {
    //和全0与会变成全0,这种情况下会将原值覆盖
    uint64_t num = this->to_int();
    if (num == 0) {
      return state_symbol(0, symbol_size);
    }
  }
  //其中一个都是符号并且无法被覆盖的情况下

  // state_symbol res =
  //     state_symbol(this->to_string() + "_with_and", _symbol_size,
  //                  std::make_shared<symbol_tree>(new_root_node(
  //                      symbol_node::op_type::AND,
  //                      std::make_shared<symbol_node>(right._single_symbol))));
  std::stringstream stream;
  stream << this->to_string() << "_and_" << right->to_string() << "-";
  state_symbol res = state_symbol(stream.str(), _symbol_size);

  res._symbol_size = symbol_size;
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right->_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right->_taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right->_mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  if (this->_can_up_taine_level || right->_can_up_taine_level) {
    res.set_can_up_taine_lv_true();
  }
  if (this->_taine2_with_mul_or_left_shift ||
      right->_taine2_with_mul_or_left_shift) {
    res._taine2_with_mul_or_left_shift = true;
  }
  return res;
}
state_symbol state_symbol::op_or(const state_symbol &right) {
  //都是数字的情况下可以直接计算
  short symbol_size = this->_symbol_size > right._symbol_size
                          ? this->_symbol_size
                          : right._symbol_size;
  if (this->is_num() && right.is_num()) {
    uint64_t left_num = this->to_int();
    uint64_t right_num = right.to_int();
    return state_symbol(left_num | right_num, symbol_size);
  }
  uint64_t mask;
  if (_symbol_size == 8) {
    mask = 0xffffffffffffffff;
  } else {
    mask = ~(0xffffffffffffffff << (symbol_size * 8));
  }
  if (right.is_num() && right.to_int() == mask) {
    //和全1或会变成全1,这种情况下会将原值覆盖
    return state_symbol(mask, symbol_size);
  }
  if (this->is_num() && this->to_int() == mask) {
    //和全1或会变成全1,这种情况下会将原值覆盖
    return state_symbol(mask, symbol_size);
  }
  //其中一个都是符号并且无法被覆盖的情况下
  // state_symbol res =
  //     state_symbol(this->to_string() + "_with_and", _symbol_size,
  //                  std::make_shared<symbol_tree>(new_root_node(
  //                      symbol_node::op_type::OR,
  //                      std::make_shared<symbol_node>(right._single_symbol))));
  state_symbol res = state_symbol(
      this->to_string() + "_and_" + right.to_string(), _symbol_size);
  res._symbol_size = symbol_size;
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right._taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right._taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right._mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  if (this->_can_up_taine_level || right._can_up_taine_level) {
    res.set_can_up_taine_lv_true();
  }
  return res;
}
state_symbol state_symbol::op_or(state_symbol::ptr &right) {
  //都是数字的情况下可以直接计算
  short symbol_size = this->_symbol_size > right->_symbol_size
                          ? this->_symbol_size
                          : right->_symbol_size;
  if (this->is_num() && right->is_num()) {
    uint64_t left_num = this->to_int();
    uint64_t right_num = right->to_int();
    return state_symbol(left_num | right_num, symbol_size);
  }
  uint64_t mask;
  if (_symbol_size == 8) {
    mask = 0xffffffffffffffff;
  } else {
    mask = ~(0xffffffffffffffff << (symbol_size * 8));
  }
  if (right->is_num() && right->to_int() == mask) {
    //和全1或会变成全1,这种情况下会将原值覆盖
    return state_symbol(mask, symbol_size);
  }
  if (this->is_num() && this->to_int() == mask) {
    //和全1或会变成全1,这种情况下会将原值覆盖
    return state_symbol(mask, symbol_size);
  }
  //其中一个都是符号并且无法被覆盖的情况下
  // state_symbol res =
  //     state_symbol(this->to_string() + "_with_and", _symbol_size,
  //                  std::make_shared<symbol_tree>(new_root_node(
  //                      symbol_node::op_type::OR,
  //                      std::make_shared<symbol_node>(right._single_symbol))));
  state_symbol res = state_symbol(
      this->to_string() + "_or_" + right->to_string(), _symbol_size);
  res._symbol_size = symbol_size;
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right->_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right->_taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right->_mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  if (this->_can_up_taine_level || right->_can_up_taine_level) {
    res.set_can_up_taine_lv_true();
  }
  return res;
}
state_symbol state_symbol::op_not() {
  if (this->is_num()) {
    uint64_t left_num = this->to_int();
    return state_symbol(~left_num, _symbol_size);
  }

  // state_symbol res = state_symbol(
  //     this->to_string() + "_with_and", _symbol_size,
  //     std::make_shared<symbol_tree>(new_root_node(symbol_node::op_type::NOT)));
  state_symbol res = state_symbol(this->to_string() + "_not_", _symbol_size);
  res._symbol_size = this->_symbol_size;
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  if (this->_can_up_taine_level) {
    res.set_can_up_taine_lv_true();
  }
  return res;
}
state_symbol state_symbol::op_xor(const state_symbol &right) {
  //都是数字的情况下可以直接计算
  short symbol_size = this->_symbol_size > right._symbol_size
                          ? this->_symbol_size
                          : right._symbol_size;
  if (this->is_num() && right.is_num()) {
    uint64_t left_num = this->to_int();
    uint64_t right_num = right.to_int();
    return state_symbol(left_num ^ right_num, symbol_size);
  }
  if (this->to_string() == right.to_string()) {
    state_symbol res = state_symbol(0, _symbol_size);
    return res;
  } else {
    state_symbol res = state_symbol(
        this->to_string() + "_and_" + right.to_string(), _symbol_size);
    res._symbol_size = symbol_size;
    res.init_symbol_str();
    for (auto symbol_str : res._contain_symbol) {
      if (right._taine_effect_symbol_map.count(symbol_str)) {
        res._taine_effect_symbol_map[symbol_str] =
            right._taine_effect_symbol_map.at(symbol_str);
      } else if (_taine_effect_symbol_map.count(symbol_str)) {
        res._taine_effect_symbol_map[symbol_str] =
            _taine_effect_symbol_map.at(symbol_str);
      }
    }
    res.init_symbol_taine();
    {
      if (!res.is_num()) {
        switch (res._symbol_size) {
          case 8: {
            // 设置eax ax ah al
            // xh
            res._size_xh_symbol = std::make_shared<state_symbol>(
                res._str + "xh", 1, res._taine_effect_vector);
            // xl
            res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            // xx
            {
              res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
              res._size_xl_symbol->_taine_effect_vector =
                  res._taine_effect_vector;
              res._size_xl_symbol->_taine_effect_symbol_map =
                  res._taine_effect_symbol_map;
              res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
              res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
            }
            // exx
            {
              res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
              res._size_xl_symbol->_taine_effect_vector =
                  res._taine_effect_vector;
              res._size_xl_symbol->_taine_effect_symbol_map =
                  res._taine_effect_symbol_map;
              res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
              res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
              res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
            }
            break;
          }
          case 4: {
            // 设置ax ah al
            // xh
            res._size_xh_symbol = std::make_shared<state_symbol>(
                res._str + "xh", 1, res._taine_effect_vector);
            // xl
            res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            // xx
            {
              res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
              res._size_xl_symbol->_taine_effect_vector =
                  res._taine_effect_vector;
              res._size_xl_symbol->_taine_effect_symbol_map =
                  res._taine_effect_symbol_map;
              res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
              res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
            }
            break;
          }
          case 2: {
            // 设置ah al
            // xh
            res._size_xh_symbol = std::make_shared<state_symbol>(
                res._str + "xh", 1, res._taine_effect_vector);
            // xl
            res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            break;
          } break;
        }
      }
    }
    if (this->_mem_effect || right._mem_effect) {
      res.set_symbol_mem_effect_true();
    }
    if (this->_can_up_taine_level || right._can_up_taine_level) {
      res.set_can_up_taine_lv_true();
    }
    return res;
  }
}
state_symbol state_symbol::op_xor(state_symbol::ptr &right) {
  //都是数字的情况下可以直接计算
  short symbol_size = this->_symbol_size > right->_symbol_size
                          ? this->_symbol_size
                          : right->_symbol_size;
  if (this->is_num() && right->is_num()) {
    uint64_t left_num = this->to_int();
    uint64_t right_num = right->to_int();
    return state_symbol(left_num ^ right_num, symbol_size);
  }
  if (this->to_string() == right->to_string()) {
    state_symbol res = state_symbol(0, _symbol_size);
    return res;
  } else {
    state_symbol res = state_symbol(
        this->to_string() + "_and_" + right->to_string(), _symbol_size);
    res._symbol_size = symbol_size;
    res.init_symbol_str();
    for (auto symbol_str : res._contain_symbol) {
      if (right->_taine_effect_symbol_map.count(symbol_str)) {
        res._taine_effect_symbol_map[symbol_str] =
            right->_taine_effect_symbol_map.at(symbol_str);
      } else if (_taine_effect_symbol_map.count(symbol_str)) {
        res._taine_effect_symbol_map[symbol_str] =
            _taine_effect_symbol_map.at(symbol_str);
      }
    }
    res.init_symbol_taine();
    {
      if (!res.is_num()) {
        switch (res._symbol_size) {
          case 8: {
            // 设置eax ax ah al
            // xh
            res._size_xh_symbol = std::make_shared<state_symbol>(
                res._str + "xh", 1, res._taine_effect_vector);
            // xl
            res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            // xx
            {
              res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
              res._size_xl_symbol->_taine_effect_vector =
                  res._taine_effect_vector;
              res._size_xl_symbol->_taine_effect_symbol_map =
                  res._taine_effect_symbol_map;
              res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
              res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
            }
            // exx
            {
              res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
              res._size_xl_symbol->_taine_effect_vector =
                  res._taine_effect_vector;
              res._size_xl_symbol->_taine_effect_symbol_map =
                  res._taine_effect_symbol_map;
              res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
              res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
              res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
            }
            break;
          }
          case 4: {
            // 设置ax ah al
            // xh
            res._size_xh_symbol = std::make_shared<state_symbol>(
                res._str + "xh", 1, res._taine_effect_vector);
            // xl
            res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            // xx
            {
              res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
              res._size_xl_symbol->_taine_effect_vector =
                  res._taine_effect_vector;
              res._size_xl_symbol->_taine_effect_symbol_map =
                  res._taine_effect_symbol_map;
              res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
              res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
            }
            break;
          }
          case 2: {
            // 设置ah al
            // xh
            res._size_xh_symbol = std::make_shared<state_symbol>(
                res._str + "xh", 1, res._taine_effect_vector);
            // xl
            res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            break;
          } break;
        }
      }
    }
    if (this->_mem_effect || right->_mem_effect) {
      res.set_symbol_mem_effect_true();
    }
    if (this->_can_up_taine_level || right->_can_up_taine_level) {
      res.set_can_up_taine_lv_true();
    }
    return res;
  }
}
state_symbol state_symbol::op_left_shift(const state_symbol &right) {
  if (this->is_num() && right.is_num()) {
    uint64_t left_num = this->to_int();
    uint64_t right_num = right.to_int();
    return state_symbol(left_num << right_num, _symbol_size);
  }

  state_symbol res =
      state_symbol(this->to_string() + "_left_shift_", _symbol_size);
  res._symbol_size = this->_symbol_size;
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right._taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right._taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right._mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  return res;
}
state_symbol state_symbol::op_left_shift(state_symbol::ptr &right) {
  if (this->is_num() && right->is_num()) {
    uint64_t left_num = this->to_int();
    uint64_t right_num = right->to_int();
    return state_symbol(left_num << right_num, _symbol_size);
  }

  state_symbol res =
      state_symbol(this->to_string() + "_left_shift_", _symbol_size);
  res._symbol_size = this->_symbol_size;
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right->_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right->_taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_xl_symbol->_taine_effect_vector =
                res._taine_effect_vector;
            res._size_xl_symbol->_taine_effect_symbol_map =
                res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right->_mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  return res;
}
state_symbol state_symbol::op_right_shift(const state_symbol &right) {
  if (this->is_num() && right.is_num()) {
    uint64_t left_num = this->to_int();
    uint64_t right_num = right.to_int();
    return state_symbol(left_num << right_num, _symbol_size);
  }

  state_symbol res =
      state_symbol(this->to_string() + "_right_shift_", _symbol_size);
  res._symbol_size = this->_symbol_size;
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right._taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right._taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            // res._size_xl_symbol->_taine_effect_vector =
            //     res._taine_effect_vector;
            // res._size_xl_symbol->_taine_effect_symbol_map =
            //     res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            // res._size_xl_symbol->_taine_effect_vector =
            //     res._taine_effect_vector;
            // res._size_xl_symbol->_taine_effect_symbol_map =
            //     res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right._mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  return res;
}
state_symbol state_symbol::op_right_shift(state_symbol::ptr &right) {
  if (this->is_num() && right->is_num()) {
    uint64_t left_num = this->to_int();
    uint64_t right_num = right->to_int();
    return state_symbol(left_num << right_num, _symbol_size);
  }

  state_symbol res =
      state_symbol(this->to_string() + "_right_shift_", _symbol_size);
  res._symbol_size = this->_symbol_size;
  res.init_symbol_str();
  for (auto symbol_str : res._contain_symbol) {
    if (right->_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          right->_taine_effect_symbol_map.at(symbol_str);
    } else if (_taine_effect_symbol_map.count(symbol_str)) {
      res._taine_effect_symbol_map[symbol_str] =
          _taine_effect_symbol_map.at(symbol_str);
    }
  }
  res.init_symbol_taine();
  {
    if (!res.is_num()) {
      switch (res._symbol_size) {
        case 8: {
          // 设置eax ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            // res._size_xl_symbol->_taine_effect_vector =
            //     res._taine_effect_vector;
            // res._size_xl_symbol->_taine_effect_symbol_map =
            //     res._taine_effect_symbol_map;
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          // exx
          {
            res._size_32_symbol = std::make_shared<state_symbol>(res, 4);
            // res._size_xl_symbol->_taine_effect_vector =
            //     res._taine_effect_vector;
            // res._size_xl_symbol->_taine_effect_symbol_map =
            //     res._taine_effect_symbol_map;
            res._size_32_symbol->_size_16_symbol = res._size_16_symbol;
            res._size_32_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_32_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 4: {
          // 设置ax ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          // xx
          {
            res._size_16_symbol = std::make_shared<state_symbol>(res, 2);
            res._size_16_symbol->_size_xh_symbol = res._size_xh_symbol;
            res._size_16_symbol->_size_xl_symbol = res._size_xl_symbol;
          }
          break;
        }
        case 2: {
          // 设置ah al
          // xh
          res._size_xh_symbol = std::make_shared<state_symbol>(
              res._str + "xh", 1, res._taine_effect_vector);
          // xl
          res._size_xl_symbol = std::make_shared<state_symbol>(res, 1);
          res._size_xl_symbol->_taine_effect_vector = res._taine_effect_vector;
          res._size_xl_symbol->_taine_effect_symbol_map =
              res._taine_effect_symbol_map;
          break;
        } break;
      }
    }
  }
  if (this->_mem_effect || right->_mem_effect) {
    res.set_symbol_mem_effect_true();
  }
  return res;
}
