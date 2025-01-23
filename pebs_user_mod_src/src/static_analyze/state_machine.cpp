#include "state_machine.h"

#include <asm-generic/errno.h>
#include <capstone/x86.h>
#include <symengine/dict.h>
#include <symengine/symengine_rcp.h>

#include <cstdint>
#include <cstdlib>
#include <ctime>
#include <memory>
#include <string>

#include "abstract_addr.h"
#include "conf.h"
#include "state_symbol.h"

abstract_addr::ptr generate_abstract_addr_tool::get_abstract_addr(
    std::string str, short size) {
  abstract_addr::ptr tmp;
  if (!_string_map.count(str)) {
    tmp = std::make_shared<abstract_addr>(str, size);
    _string_map[str] = tmp;
  } else {
    tmp = _string_map[str];
  }
  return tmp;
}
abstract_addr::ptr generate_abstract_addr_tool::get_abstract_addr(
    u_int64_t addr, short size) {
  abstract_addr::ptr tmp;
  if (!_addr_map.count(addr)) {
    tmp = std::make_shared<abstract_addr>(addr, size);
    _addr_map[addr] = tmp;
  } else {
    tmp = _addr_map[addr];
  }
  return tmp;
}
abstract_addr::ptr generate_abstract_addr_tool::get_abstract_addr(x86_reg reg,
                                                                  short size) {
  abstract_addr::ptr res = nullptr;
  if (!_reg_map.count(reg)) {
    if (reg_size_map.count(reg)) {
      res = std::make_shared<abstract_addr>(reg, reg_size_map[reg]);
    } else {
      res = std::make_shared<abstract_addr>(reg, 8);
    }
    _reg_map[reg] = res;
  }
  res = _reg_map[reg];
  return res;
}
abstract_addr::ptr generate_abstract_addr_tool::get_abstract_addr(
    state_symbol::ptr symbol, short size) {
  if (symbol->is_num()) {
    return get_abstract_addr(symbol->to_int(), size);
  } else {
    return get_abstract_addr(symbol->to_string(), size);
  }
}
abstract_addr::ptr generate_abstract_addr_tool::get_abstract_addr(
    state_symbol symbol, short size) {
  if (symbol.is_num()) {
    return get_abstract_addr(symbol.to_int(), size);
  } else {
    return get_abstract_addr(symbol.to_string(), size);
  }
}
abstract_addr::ptr generate_abstract_addr_tool::get_abstract_addr(
    x86_op_mem mem, state_machine::ptr state, short size) {
  state_symbol::ptr base_symbol_ptr = nullptr;
  state_symbol::ptr index_symbol_ptr = nullptr;
  //获取base对应的symbol
  bool base_effect = false;
  if (mem.base == X86_REG_INVALID) {
    base_symbol_ptr = std::make_shared<state_symbol>(0, size);
  } else {
    base_effect = true;
    abstract_addr::ptr mem_addr = get_abstract_addr(mem.base, size);

    base_symbol_ptr = state->get_symbol_from_addr(mem_addr);
    if (base_symbol_ptr == nullptr) {
      short size = 8;
      if (reg_size_map.count(mem.base)) {
        size = reg_size_map[mem.base];
      }
      base_symbol_ptr = state->generate_symbol_for_addr(
          mem_addr, get_symbol_str(_random, _dist), {}, size);
    }
  }
  state_symbol::ptr addr_symbol;
  if (mem.index != X86_REG_INVALID) {
    //获取index对应的symbol
    bool index_effect = false;
    index_effect = true;
    index_symbol_ptr =
        state->get_symbol_from_addr(get_abstract_addr(mem.index, size));
    if (index_symbol_ptr == nullptr) {
      short size = 8;
      if (reg_size_map.count(mem.base)) {
        size = reg_size_map[mem.base];
      }
      index_symbol_ptr = state->generate_symbol_for_addr(
          get_abstract_addr(mem.index, size), get_symbol_str(_random, _dist),
          {}, size);
    }

    //计算出应该访问的地址的symbol
    state_symbol::ptr disp;
    if (mem.disp < 0) {
      auto tmp = state_symbol(-mem.disp);
      disp = std::make_shared<state_symbol>(state_symbol(0) - tmp, 8);
    } else {
      disp = std::make_shared<state_symbol>(mem.disp, 8);
    }
    bool can_up_taine = false;
    //判断是否是一个数组访问
    {
      int num = 0;
      if (base_effect) {
        ++num;
      }
      if (index_effect && (mem.scale != 0)) {
        ++num;
      }
      if (num == 2) {
        // base和index是来源不同的污点
        if (!base_symbol_ptr->judge_taine_same(index_symbol_ptr) &&
            base_symbol_ptr->get_symbol_mem_effect() &&
            index_symbol_ptr->get_symbol_mem_effect()) {
          can_up_taine = true;
        }
        //两个中有一个是污点另一个是比较大的数
        int num = 0;
        if ((base_symbol_ptr->is_num() &&
             base_symbol_ptr->to_int() > 0xfffff) &&
            (mem.base != X86_REG_RSP && mem.base != X86_REG_ESP)) {
          ++num;
        }
        if ((index_symbol_ptr->is_num() &&
             index_symbol_ptr->to_int() > 0xfffff) &&
            (mem.base != X86_REG_RSP && mem.base != X86_REG_ESP)) {
          ++num;
        }
        if (num == 1 && (base_symbol_ptr->_taine != taine_enum::not_a_tine ||
                         index_symbol_ptr->_taine != taine_enum::not_a_tine)) {
          can_up_taine = true;
        }
      }
    }

    auto tmp_addr_symbol =
        base_symbol_ptr
            ->op_add(index_symbol_ptr->op_mul(state_symbol(mem.scale)))
            .op_add(disp);
    addr_symbol = std::make_shared<state_symbol>(tmp_addr_symbol);
    if (can_up_taine) {
      addr_symbol->set_can_up_taine_lv_true();
    }
  } else {
    state_symbol::ptr disp;
    if (mem.disp < 0) {
      auto tmp = state_symbol(-mem.disp);
      disp = std::make_shared<state_symbol>(state_symbol(0) - tmp, 8);
    } else {
      disp = std::make_shared<state_symbol>(mem.disp, 8);
    }
    bool can_up_taine = false;
    //判断是否是一个数组访问
    {
      int num = 0;
      if (base_effect && base_symbol_ptr->_taine != taine_enum::not_a_tine&&mem.disp>0xffff) {
        can_up_taine = true;
      }
    }
    auto tmp_addr_symbol = base_symbol_ptr->op_add(disp);
    addr_symbol = std::make_shared<state_symbol>(tmp_addr_symbol);
    if (can_up_taine) {
      addr_symbol->set_can_up_taine_lv_true();
    }
  }

  //为这个符号地址生成一个抽象地址
  abstract_addr::ptr res = get_abstract_addr(*addr_symbol, size);

  //将污点传递给抽象地址
  res->_taine = addr_symbol->_taine;
  res->_can_up_taine_lv = addr_symbol->get_can_up_taine_lv();
  
  if (res->_taine == taine_enum::taine2 && res->_can_up_taine_lv &&
      !addr_symbol->_taine2_with_mul_or_left_shift) {
    res->_can_up_taine_lv = false;
  }

  if (addr_symbol->is_num()) {
    uint64_t addr_num = addr_symbol->to_int();
    if (!_addr_map.contains(addr_num)) {
      _addr_map[addr_num] = std::make_shared<abstract_addr>(addr_num, size);
    }
    res = _addr_map[addr_num];

  } else {
    std::string addr_str = addr_symbol->to_string();
    if (!_string_map.contains(addr_str)) {
      _string_map[addr_str] = std::make_shared<abstract_addr>(addr_str, size);
    }
    res = _string_map[addr_str];
  }
  res->_size = size;

  return res;
}

abstract_flags::ptr generate_abstract_addr_tool::get_abstract_flag(
    rflags flag) {
  abstract_flags::ptr tmp;

  if (!_flag_map.count(flag)) {
    tmp = std::make_shared<abstract_flags>(flag);
    _flag_map[flag] = tmp;
  } else {
    tmp = _flag_map[flag];
  }
  return tmp;
}

state_symbol::ptr state_machine::get_symbol_from_addr(abstract_addr::ptr addr) {
  if (_addr_symbol_map.count(addr)) {
    return _addr_symbol_map[addr];
  } else {
    return nullptr;
  }
}

state_symbol::ptr state_machine::generate_symbol_for_addr(
    abstract_addr::ptr addr, std::string symbol_name,
    std::vector<std::string> taine_vector) {
  auto tmp =
      std::make_shared<state_symbol>(symbol_name, addr->_size, taine_vector);
  // 设置下面的可拆分寄存器
  switch (addr->_size) {
    case 8: {
      // 设置eax ax ah al
      // xh
      tmp->_size_xh_symbol = std::make_shared<state_symbol>(
          tmp->to_string() + "xh", 1, taine_vector);
      // xl
      tmp->_size_xl_symbol = std::make_shared<state_symbol>(tmp, 1);
      // xx
      {
        tmp->_size_16_symbol = std::make_shared<state_symbol>(tmp, 2);
        tmp->_size_16_symbol->_size_xh_symbol = tmp->_size_xh_symbol;
        tmp->_size_16_symbol->_size_xl_symbol = tmp->_size_xl_symbol;
      }
      // exx
      {
        tmp->_size_32_symbol = std::make_shared<state_symbol>(tmp, 4);
        tmp->_size_32_symbol->_size_16_symbol = tmp->_size_16_symbol;
        tmp->_size_32_symbol->_size_xh_symbol = tmp->_size_xh_symbol;
        tmp->_size_32_symbol->_size_xl_symbol = tmp->_size_xl_symbol;
      }
      break;
    }
    case 4: {
      // 设置ax ah al
      // xh
      tmp->_size_xh_symbol = std::make_shared<state_symbol>(
          tmp->to_string() + "xh", 1, taine_vector);
      // xl
      tmp->_size_xl_symbol = std::make_shared<state_symbol>(tmp, 1);
      // xx
      {
        tmp->_size_16_symbol = std::make_shared<state_symbol>(tmp, 2);
        tmp->_size_16_symbol->_size_xh_symbol = tmp->_size_xh_symbol;
        tmp->_size_16_symbol->_size_xl_symbol = tmp->_size_xl_symbol;
      }
      break;
    }
    case 2: {
      // xh
      tmp->_size_xh_symbol = std::make_shared<state_symbol>(
          tmp->to_string() + "xh", 1, taine_vector);
      // xl
      tmp->_size_xl_symbol = std::make_shared<state_symbol>(tmp, 1);
      break;
    } break;
  }
  _addr_symbol_map[addr] = tmp;
  return tmp;
}
state_symbol::ptr state_machine::generate_symbol_for_addr(
    abstract_addr::ptr addr, std::string symbol_name,
    std::vector<std::string> taine_vector, short size) {
  auto tmp = std::make_shared<state_symbol>(symbol_name, size, taine_vector);
  // 设置下面的可拆分寄存器
  switch (addr->_size) {
    case 8: {
      // 设置eax ax ah al
      // xh
      tmp->_size_xh_symbol = std::make_shared<state_symbol>(
          tmp->to_string() + "xh", 1, taine_vector);
      // xl
      tmp->_size_xl_symbol = std::make_shared<state_symbol>(tmp, 1);
      {
        tmp->_size_16_symbol = std::make_shared<state_symbol>(tmp, 2);
        tmp->_size_16_symbol->_size_xh_symbol = tmp->_size_xh_symbol;
        tmp->_size_16_symbol->_size_xl_symbol = tmp->_size_xl_symbol;
      }
      {
        tmp->_size_32_symbol = std::make_shared<state_symbol>(tmp, 4);
        tmp->_size_32_symbol->_size_16_symbol = tmp->_size_16_symbol;
        tmp->_size_32_symbol->_size_xh_symbol = tmp->_size_xh_symbol;
        tmp->_size_32_symbol->_size_xl_symbol = tmp->_size_xl_symbol;
      }
      break;
    }
    case 4: {
      // 设置ax ah al
      tmp->_size_xh_symbol =
          std::make_shared<state_symbol>(symbol_name + "xh", 1, taine_vector);
      tmp->_size_xl_symbol =
          std::make_shared<state_symbol>(symbol_name + "xl", 1, taine_vector);
      {
        tmp->_size_16_symbol = std::make_shared<state_symbol>(tmp, 2);
        tmp->_size_16_symbol->_size_xh_symbol = tmp->_size_xh_symbol;
        tmp->_size_16_symbol->_size_xl_symbol = tmp->_size_xl_symbol;
      }
      break;
    }
    case 2: {
      // 设置ah al
      tmp->_size_xh_symbol =
          std::make_shared<state_symbol>(symbol_name + "xh", 1, taine_vector);
      tmp->_size_xl_symbol =
          std::make_shared<state_symbol>(symbol_name + "xl", 1, taine_vector);
      break;
    } break;
  }
  _addr_symbol_map[addr] = tmp;
  return tmp;
}

state_symbol::ptr state_machine::generate_symbol_for_addr(
    abstract_addr::ptr addr, std::string symbol_name, short size) {
  auto tmp = std::make_shared<state_symbol>(symbol_name, size);
  _addr_symbol_map[addr] = tmp;
  return tmp;
}
state_symbol::ptr state_machine::generate_symbol_for_addr(
    abstract_addr::ptr addr, std::string symbol_name) {
  auto tmp = std::make_shared<state_symbol>(symbol_name, addr->_size);
  _addr_symbol_map[addr] = tmp;
  return tmp;
}

state_symbol::ptr state_machine::generate_symbol_for_addr(
    abstract_addr::ptr addr, uint64_t number, short size) {
  auto tmp = std::make_shared<state_symbol>(number, size);
  _addr_symbol_map[addr] = tmp;
  return tmp;
}

state_symbol::ptr state_machine::generate_symbol_for_addr(
    abstract_addr::ptr addr, uint64_t number) {
  auto tmp = std::make_shared<state_symbol>(number, addr->_size);
  _addr_symbol_map[addr] = tmp;
  return tmp;
}

void state_machine::set_symbol_for_addr(abstract_addr::ptr addr,
                                        std::string sym, short size) {
  _addr_symbol_map[addr] = std::make_shared<state_symbol>(sym, size);
}

void state_machine::set_symbol_for_addr(abstract_addr::ptr addr, uint64_t num,
                                        short size) {
  _addr_symbol_map[addr] = std::make_shared<state_symbol>(num, size);
}

void state_machine::set_symbol_for_addr(abstract_addr::ptr addr,
                                        state_symbol::ptr symbol) {
  _addr_symbol_map[addr] = symbol;
}

x86_reg generate_abstract_addr_tool::merge_reg(x86_reg reg) {
  if (reg == X86_REG_EAX || reg == X86_REG_AX || reg == X86_REG_AH ||
      reg == X86_REG_AL) {
    return X86_REG_RAX;
  } else if (reg == X86_REG_EBX || reg == X86_REG_BX || reg == X86_REG_BH ||
             reg == X86_REG_BL) {
    return X86_REG_RBX;
  } else if (reg == X86_REG_ECX || reg == X86_REG_CX || reg == X86_REG_CH ||
             reg == X86_REG_CL) {
    return X86_REG_RCX;
  } else if (reg == X86_REG_EDX || reg == X86_REG_DX || reg == X86_REG_DH ||
             reg == X86_REG_DL) {
    return X86_REG_RDX;
  } else {
    return reg;
  }
}
void state_machine::clear_all_symbol() {
  _addr_symbol_map.clear();
  _flag_symbol_map.clear();
  _cache_miss_symbol_vector.clear();
}