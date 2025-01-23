#include "instruction_analyze_tool.h"

#include <bits/types/struct_tm.h>
#include <capstone/capstone.h>
#include <capstone/x86.h>
#include <math.h>
#include <sys/types.h>

#include <boost/asio/buffered_read_stream.hpp>
#include <cmath>
#include <cstdint>
#include <map>
#include <memory>
#include <string>
#include <utility>
#include <vector>

#include "abstract_addr.h"
#include "conf.h"
#include "state_machine.h"
#include "state_symbol.h"

std::pair<uint64_t, uint64_t> multiply_and_get_parts(uint64_t x, uint64_t y) {
  unsigned long long int a = x >> 32, b = x & 0xffffffffLL;
  unsigned long long int c = y >> 32, d = y & 0xffffffffLL;
  unsigned long long int ac = a * c;
  unsigned long long int bc = b * c;
  unsigned long long int ad = a * d;
  unsigned long long int bd = b * d;
  unsigned long long int mid34 =
      (bd >> 32) + (bc & 0xffffffffLL) + (ad & 0xffffffffLL);
  uint64_t high_part = ac + (bc >> 32) + (ad >> 32) + (mid34 >> 32);
  uint64_t low_part = (mid34 << 32) | (bd & 0xffffffffLL);
  return std::make_pair(high_part, low_part);
}

char get_1_num(uint64_t num) {
  char res = 0;
  uint64_t mask = 0x1LL;
  for (int i = 0; i < 64; ++i) {
    if (num == 0) {
      break;
    }
    if ((num & mask) == 1) {
      ++res;
    }
    num = num >> 1;
  }
  return res;
}

bool judge_sign(uint64_t number, char size) {
  switch (size) {
    case 8: {
      if (number >> 63) {
        return true;
      }
      return false;
    }
    case 4: {
      if ((number & 0xffffffffLL) >> 31) {
        return true;
      }
      return false;
    }
    case 2: {
      if ((number & 0xffffLL) >> 15) {
        return true;
      }
      return false;
    }
    case 1: {
      if ((number & 0xffLL) >> 7) {
        return true;
      }
      return false;
    }
  }
  return false;
}

/**
 * @brief 用于分析操作数的函数，将获取内存获得地址的污点传回符号 需要修改
 *
 * @param op
 * @param addr
 * @param symbol
 * @param read
 * @param control_leak_model
 * @param exec_mode 执行模式 0分析模式 ，1有初始污点的模式 ，2无初始污点的模式
 * @return char 标识 0寄存器 1立即数 2内存 3发现攻击 4无效指令
 */
char instruction_analyze_tool::analyze_operator(
    const cs_x86_op &op, abstract_addr::ptr &addr, state_symbol::ptr &symbol,
    bool read, bool control_leak_model, char exec_mode) {
  char source_type = 0;
  if (read) {  //源操作数
    switch (op.type) {
      //无效的操作数时
      case X86_OP_INVALID: {
        return 4;
      }
      //寄存器操作数
      case X86_OP_REG: {
        source_type = 0;
        addr = _generatr_abstract_addr_tool_ptr->get_abstract_addr(op.reg,
                                                                   op.size);
        symbol = _state_machine_ptr->get_symbol_from_addr(addr);
        if (symbol == nullptr) {
          std::vector<std::string> taine_vector = {};
          symbol = _state_machine_ptr->generate_symbol_for_addr(
              addr, get_symbol_str(_random, _dist), taine_vector);
        }  // 取出一个已知的值
        else {
          // 取出的值的大小与要获取的大小不同时
          if (symbol->get_symbol_size() < op.size && !symbol->is_num()) {
            switch (op.size) {
              case 8: {
                // xh
                if (symbol->_size_xh_symbol == nullptr) {
                  symbol->_size_xh_symbol =
                      std::make_shared<state_symbol>(0, 1);
                }
                // xl
                if (symbol->_size_xl_symbol == nullptr) {
                  symbol->_size_xl_symbol =
                      std::make_shared<state_symbol>(0, 1);
                }
                // 16
                if (symbol->_size_16_symbol == nullptr) {
                  symbol->_size_16_symbol =
                      std::make_shared<state_symbol>(symbol, 16);
                  symbol->_size_16_symbol->_size_xh_symbol =
                      symbol->_size_xh_symbol;
                  symbol->_size_16_symbol->_size_xl_symbol =
                      symbol->_size_xl_symbol;
                }
                // 32
                if (symbol->_size_32_symbol == nullptr) {
                  symbol->_size_32_symbol =
                      std::make_shared<state_symbol>(symbol, 32);
                  symbol->_size_32_symbol->_size_16_symbol =
                      symbol->_size_16_symbol;
                  symbol->_size_32_symbol->_size_xh_symbol =
                      symbol->_size_xh_symbol;
                  symbol->_size_32_symbol->_size_xl_symbol =
                      symbol->_size_xl_symbol;
                }
                break;
              }
              case 4: {
                // xh
                if (symbol->_size_xh_symbol == nullptr) {
                  symbol->_size_xh_symbol =
                      std::make_shared<state_symbol>(0, 1);
                }
                // xl
                if (symbol->_size_xl_symbol == nullptr) {
                  symbol->_size_xl_symbol =
                      std::make_shared<state_symbol>(0, 1);
                }
                // 16
                if (symbol->_size_16_symbol == nullptr) {
                  symbol->_size_16_symbol =
                      std::make_shared<state_symbol>(symbol, 16);
                  symbol->_size_16_symbol->_size_xh_symbol =
                      symbol->_size_xh_symbol;
                  symbol->_size_16_symbol->_size_xl_symbol =
                      symbol->_size_xl_symbol;
                }
                break;
              }
              case 2: {
                // xh
                if (symbol->_size_xh_symbol == nullptr) {
                  symbol->_size_xh_symbol =
                      std::make_shared<state_symbol>(0, 1);
                }
                // xl
                if (symbol->_size_xl_symbol == nullptr) {
                  symbol->_size_xl_symbol =
                      std::make_shared<state_symbol>(0, 1);
                }
                break;
              } break;
            }
          }
          symbol->set_symbol_size(op.size);
        }
        break;
      }
      //立即数操作数
      case X86_OP_IMM: {
        source_type = 1;
        addr = nullptr;
        symbol = std::make_shared<state_symbol>(op.imm, op.size);
        break;
      }
      //内存操作数
      case X86_OP_MEM: {
        source_type = 2;
        addr = _generatr_abstract_addr_tool_ptr->get_abstract_addr(
            op.mem, _state_machine_ptr, op.size);
        symbol = _state_machine_ptr->get_symbol_from_addr(addr);
        taine_enum taine = addr->_taine;
        // 表示从内存中取出一个未知的值
        if (symbol == nullptr) {
          // 进行污点的提升，在分析模式下不进行污点的提升
          if (addr->_can_up_taine_lv && op.size == 1 && exec_mode != 0 &&
              taine != taine_enum::not_a_tine) {
            taine = add_taine_level(addr->_taine);
          }
          // 仅在无初始污点的模式下生成taine1的污点
          if (taine == taine_enum::not_a_tine && exec_mode == 2 &&
              op.size > 2) {
            taine = taine_enum::taine1;
          }
          if (taine == taine_enum::taine3) {
            return 3;
          }
          if (control_leak_model && taine == taine_enum::taine2) {
            return 3;
          }
          std::vector<std::string> taine_vector = {
              get_taine_string(taine, _random, _dist)};
          symbol = _state_machine_ptr->generate_symbol_for_addr(
              addr, get_symbol_str(_random, _dist), taine_vector, addr->_size);
          symbol->set_symbol_mem_effect_true();
        }
        // 取出一个已知的值
        else {
          // 取出的值的大小与要获取的大小不同时
          if (symbol->get_symbol_size() < op.size && !symbol->is_num()) {
            switch (op.size) {
              case 8: {
                // xh
                if (symbol->_size_xh_symbol == nullptr) {
                  symbol->_size_xh_symbol =
                      std::make_shared<state_symbol>(0, 1);
                }
                // xl
                if (symbol->_size_xl_symbol == nullptr) {
                  symbol->_size_xl_symbol =
                      std::make_shared<state_symbol>(0, 1);
                }
                // 16
                if (symbol->_size_16_symbol == nullptr) {
                  symbol->_size_16_symbol =
                      std::make_shared<state_symbol>(symbol, 16);
                  symbol->_size_16_symbol->_size_xh_symbol =
                      symbol->_size_xh_symbol;
                  symbol->_size_16_symbol->_size_xl_symbol =
                      symbol->_size_xl_symbol;
                }
                // 32
                if (symbol->_size_32_symbol == nullptr) {
                  symbol->_size_32_symbol =
                      std::make_shared<state_symbol>(symbol, 32);
                  symbol->_size_32_symbol->_size_16_symbol =
                      symbol->_size_16_symbol;
                  symbol->_size_32_symbol->_size_xh_symbol =
                      symbol->_size_xh_symbol;
                  symbol->_size_32_symbol->_size_xl_symbol =
                      symbol->_size_xl_symbol;
                }
                break;
              }
              case 4: {
                // xh
                if (symbol->_size_xh_symbol == nullptr) {
                  symbol->_size_xh_symbol =
                      std::make_shared<state_symbol>(0, 1);
                }
                // xl
                if (symbol->_size_xl_symbol == nullptr) {
                  symbol->_size_xl_symbol =
                      std::make_shared<state_symbol>(0, 1);
                }
                // 16
                if (symbol->_size_16_symbol == nullptr) {
                  symbol->_size_16_symbol =
                      std::make_shared<state_symbol>(symbol, 16);
                  symbol->_size_16_symbol->_size_xh_symbol =
                      symbol->_size_xh_symbol;
                  symbol->_size_16_symbol->_size_xl_symbol =
                      symbol->_size_xl_symbol;
                }
                break;
              }
              case 2: {
                // xh
                if (symbol->_size_xh_symbol == nullptr) {
                  symbol->_size_xh_symbol =
                      std::make_shared<state_symbol>(0, 1);
                }
                // xl
                if (symbol->_size_xl_symbol == nullptr) {
                  symbol->_size_xl_symbol =
                      std::make_shared<state_symbol>(0, 1);
                }
                break;
              } break;
            }
          }
          symbol->set_symbol_size(op.size);
        }

        break;
      }
    }
  } else {  //目标操作数
    switch (op.type) {
      case X86_OP_INVALID: {
        return 4;
      }
      case X86_OP_REG: {
        addr = _generatr_abstract_addr_tool_ptr->get_abstract_addr(op.reg,
                                                                   op.size);
        break;
      }
      case X86_OP_IMM: {
        return 4;
      }
      case X86_OP_MEM: {
        addr = _generatr_abstract_addr_tool_ptr->get_abstract_addr(
            op.mem, _state_machine_ptr, op.size);

        taine_enum taine;
        if (addr->_can_up_taine_lv && op.size == 1) {
          taine = add_taine_level(addr->_taine);
        }

        if (taine == taine_enum::taine3) {
          return 3;
        }
        break;
      }
    }
  }
  return source_type;
}

void instruction_analyze_tool::set_target_symbol(abstract_addr::ptr target_addr,
                                                 state_symbol::ptr symbol,
                                                 bool is_set_init_taine) {
  switch (target_addr->get_reg()) {
    case X86_REG_RAX: {
      // symbol为数字时
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RAX, 8)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_EAX, 4)] =
            std::make_shared<state_symbol>(num & 0x00000000ffffffffLL, 4);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_AX, 2)] =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_AH, 1)] =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_AL, 1)] =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
      }
      // symbol不为数字的时候
      else {
        // rax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RAX, 8)] =
            symbol;
        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_EAX, 4)] =
            symbol->_size_32_symbol;
        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_AX, 2)] =
            symbol->_size_16_symbol;
        // ah
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_AH, 1)] =
            symbol->_size_xh_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_AL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_RCX: {
      // symbol为数字时
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RCX, 8)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_ECX, 4)] =
            std::make_shared<state_symbol>(num & 0x00000000ffffffffLL, 4);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_CX, 2)] =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_CH, 1)] =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_CL, 1)] =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
      }
      // symbol不为数字的时候
      else {
        // rax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RCX, 8)] =
            symbol;
        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_ECX, 4)] =
            symbol->_size_32_symbol;

        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_CX, 2)] =
            symbol->_size_16_symbol;

        // ah
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_CH, 1)] =
            symbol->_size_xh_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_CL, 1)] =
            symbol->_size_xl_symbol;
      }

      break;
    }
    case X86_REG_RDX: {
      // symbol为数字时
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RDX, 8)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_EDX, 4)] =
            std::make_shared<state_symbol>(num & 0x00000000ffffffffLL, 4);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DX, 2)] =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DH, 1)] =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DL, 1)] =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
      }
      // symbol不为数字的时候
      else {
        // rax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RDX, 8)] =
            symbol;
        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_EDX, 4)] =
            symbol->_size_32_symbol;

        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DX, 2)] =
            symbol->_size_16_symbol;

        // ah
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DH, 1)] =
            symbol->_size_xh_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DL, 1)] =
            symbol->_size_xl_symbol;
      }

      break;
    }
    case X86_REG_RBX: {
      // symbol为数字时
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RBX, 8)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_EBX, 4)] =
            std::make_shared<state_symbol>(num & 0x00000000ffffffffLL, 4);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BX, 2)] =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BH, 1)] =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BL, 1)] =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
      }
      // symbol不为数字的时候
      else {
        // rax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RBX, 8)] =
            symbol;
        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_EBX, 4)] =
            symbol->_size_32_symbol;

        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BX, 2)] =
            symbol->_size_16_symbol;
        // ah
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BH, 1)] =
            symbol->_size_xh_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BL, 1)] =
            symbol->_size_xl_symbol;
      }

      break;
    }
    case X86_REG_RSI: {
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RSI, 8)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_ESI, 4)] =
            std::make_shared<state_symbol>(num & 0x00000000ffffffffLL, 4);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SI, 2)] =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SIL, 1)] =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
      } else {
        // rsi
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RSI, 8)] =
            symbol;
        // esi
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_ESI, 4)] =
            symbol->_size_32_symbol;
        // si
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SI, 2)] =
            symbol->_size_16_symbol;
        // sil
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SIL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_RDI: {
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RDI, 8)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_EDI, 4)] =
            std::make_shared<state_symbol>(num & 0x00000000ffffffffLL, 4);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DI, 2)] =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DIL, 1)] =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
      } else {
        // rdi
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RDI, 8)] =
            symbol;
        // edi
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_EDI, 4)] =
            symbol->_size_32_symbol;
        // di
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DI, 2)] =
            symbol->_size_16_symbol;
        // dil
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DIL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_RSP: {
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RSP, 8)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_ESP, 4)] =
            std::make_shared<state_symbol>(num & 0x00000000ffffffffLL, 4);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SP, 2)] =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SPL, 1)] =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
      } else {
        // rsp
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RSP, 8)] =
            symbol;
        // esp
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_ESP, 4)] =
            symbol->_size_32_symbol;
        // sp
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SP, 2)] =
            symbol->_size_16_symbol;
        // spl
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SPL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_RBP: {
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RBP, 8)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_EBP, 4)] =
            std::make_shared<state_symbol>(num & 0x00000000ffffffffLL, 4);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BP, 2)] =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BPL, 1)] =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
      } else {
        // rbp
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RBP, 8)] =
            symbol;
        // ebp
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_EBP, 4)] =
            symbol->_size_32_symbol;
        // bp
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BP, 2)] =
            symbol->_size_16_symbol;
        // bpl
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BPL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R8: {
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R8, 8)] = symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R8D, 4)] =
            std::make_shared<state_symbol>(num & 0x00000000ffffffffLL, 4);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R8W, 2)] =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R8B, 1)] =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
      } else {
        // r8
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R8, 8)] = symbol;
        // r8d
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R8D, 4)] =
            symbol->_size_32_symbol;
        // r8w
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R8W, 2)] =
            symbol->_size_16_symbol;
        // r8b
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R8B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R9: {
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R9, 8)] = symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R9D, 4)] =
            std::make_shared<state_symbol>(num & 0x00000000ffffffffLL, 4);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R9W, 2)] =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R9B, 1)] =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
      } else {
        // r8

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R9, 8)] = symbol;
        // r8d
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R9D, 4)] =
            symbol->_size_32_symbol;
        // r8w
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R9W, 2)] =
            symbol->_size_16_symbol;
        // r8b
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R9B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R10: {
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R10, 8)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R10D, 4)] =
            std::make_shared<state_symbol>(num & 0x00000000ffffffffLL, 4);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R10W, 2)] =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R10B, 1)] =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
      } else {
        // r8

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R10, 8)] =
            symbol;
        // r8d
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R10D, 4)] =
            symbol->_size_32_symbol;
        // r8w
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R10W, 2)] =
            symbol->_size_16_symbol;
        // r8b
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R10B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R11: {
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R11, 8)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R11D, 4)] =
            std::make_shared<state_symbol>(num & 0x00000000ffffffffLL, 4);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R11W, 2)] =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R11B, 1)] =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
      } else {
        // r8

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R11, 8)] =
            symbol;
        // r8d
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R11D, 4)] =
            symbol->_size_32_symbol;
        // r8w
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R11W, 2)] =
            symbol->_size_16_symbol;
        // r8b
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R11B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R12: {
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R12, 8)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R12D, 4)] =
            std::make_shared<state_symbol>(num & 0x00000000ffffffffLL, 4);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R12W, 2)] =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R12B, 1)] =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
      } else {
        // r8

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R12, 8)] =
            symbol;
        // r8d
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R12D, 4)] =
            symbol->_size_32_symbol;
        // r8w
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R12W, 2)] =
            symbol->_size_16_symbol;
        // r8b
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R12B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R13: {
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R13, 8)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R13D, 4)] =
            std::make_shared<state_symbol>(num & 0x00000000ffffffffLL, 4);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R13W, 2)] =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R13B, 1)] =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
      } else {
        // r8

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R13, 8)] =
            symbol;
        // r8d
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R13D, 4)] =
            symbol->_size_32_symbol;
        // r8w
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R13W, 2)] =
            symbol->_size_16_symbol;
        // r8b
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R13B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R14: {
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R14, 8)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R14D, 4)] =
            std::make_shared<state_symbol>(num & 0x00000000ffffffffLL, 4);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R14W, 2)] =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R14B, 1)] =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
      } else {
        // r8

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R14, 8)] =
            symbol;
        // r8d
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R14D, 4)] =
            symbol->_size_32_symbol;
        // r8w
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R14W, 2)] =
            symbol->_size_16_symbol;
        // r8b
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R14B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R15: {
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R15, 8)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R15D, 4)] =
            std::make_shared<state_symbol>(num & 0x00000000ffffffffLL, 4);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R15W, 2)] =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R15B, 1)] =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
      } else {
        // r8

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R15, 8)] =
            symbol;
        // r8d
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R15D, 4)] =
            symbol->_size_32_symbol;
        // r8w
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R15W, 2)] =
            symbol->_size_16_symbol;
        // r8b
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R15B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_EAX: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RAX,
                                                                  8));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_16_size =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);

        // 设置rax寄存器
        // rax是数字的时候
        if (size_8_symbol->is_num()) {
          uint64_t size_8_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RAX, 8)] =
              std::make_shared<state_symbol>(
                  (size_8_num & 0xffffffff00000000LL) |
                      (num & 0x00000000ffffffffLL),
                  8);
        }
        // symbol是数字 rax不是数字
        else {
          // 使用原本的污点信息新建一个符号
          std::vector<std::string> new_taine_vector = {};
          // // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          // 设置
          {
            new_size_8_symbol->_size_32_symbol = symbol;
            new_size_8_symbol->_size_16_symbol = symbol_16_size;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          // 设置rax
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RAX, 8)] =
              new_size_8_symbol;
        }
        // 设置eax ax ah al寄存器
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EAX, 4)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_AX, 2)] =
              symbol_16_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_AH, 1)] =
              symbol_xh_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_AL, 1)] =
              symbol_xl_size;
        }
      } else {
        // rax不确定但symbol为符号的时候
        std::shared_ptr<state_symbol> tmp_symbol;
        // 生成新符号的污点信息
        std::vector<std::string> new_size_8_taine_str = symbol->get_taine_str();
        // if (size_8_symbol->_size_64_symbol == nullptr) {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_taine_effect_vector.end());
        // } else {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
        // }
        distinct_taine_str(new_size_8_taine_str);
        tmp_symbol = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
        // 重建新符号的各可拆分寄存器
        {
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   tmp_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   tmp_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          // }
          tmp_symbol->_size_32_symbol = symbol;
          tmp_symbol->_size_16_symbol = symbol->_size_16_symbol;
          tmp_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
          tmp_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
        }

        if (symbol->get_can_up_taine_lv()) {
          tmp_symbol->_can_up_taine_level = true;
        }
        if (symbol->get_symbol_mem_effect()) {
          tmp_symbol->_mem_effect = true;
        }
        if (symbol->_taine2_with_mul_or_left_shift) {
          tmp_symbol->_taine2_with_mul_or_left_shift = true;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RAX, 8)] =
            tmp_symbol;

        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_EAX, 4)] =
            symbol;
        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_AX, 2)] =
            symbol->_size_16_symbol;
        // ah
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_AH, 1)] =
            symbol->_size_xh_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_AL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_ECX: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RCX,
                                                                  8));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_16_size =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);

        // 设置rax寄存器
        // rax是数字的时候
        if (size_8_symbol->is_num()) {
          uint64_t size_8_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RCX, 8)] =
              std::make_shared<state_symbol>(
                  (size_8_num & 0xffffffff00000000LL) +
                      (num & 0x00000000ffffffffLL),
                  8);
        }
        // symbol是数字 rax不是数字
        else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector = {};
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          // 设置
          {
            new_size_8_symbol->_size_32_symbol = symbol;
            new_size_8_symbol->_size_16_symbol = symbol_16_size;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          // 设置rax
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RCX, 8)] =
              new_size_8_symbol;
        }
        // 设置eax ax ah al寄存器
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ECX, 4)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_CX, 2)] =
              symbol_16_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_CH, 1)] =
              symbol_xh_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_CL, 1)] =
              symbol_xl_size;
        }
      } else {
        // rax不确定但symbol为符号的时候
        std::shared_ptr<state_symbol> tmp_symbol;
        // 生成新符号的污点信息
        std::vector<std::string> new_size_8_taine_str =
            symbol->_taine_effect_vector;
        // if (size_8_symbol->_size_64_symbol == nullptr) {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_taine_effect_vector.end());
        // } else {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
        // }
        distinct_taine_str(new_size_8_taine_str);
        tmp_symbol = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
        // 重建新符号的各可拆分寄存器
        {
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   tmp_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   tmp_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          // }
          tmp_symbol->_size_32_symbol = symbol;
          tmp_symbol->_size_16_symbol = symbol->_size_16_symbol;
          tmp_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
          tmp_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
        }
        if (symbol->get_can_up_taine_lv()) {
          tmp_symbol->_can_up_taine_level = true;
        }
        if (symbol->get_symbol_mem_effect()) {
          tmp_symbol->_mem_effect = true;
        }
        if (symbol->_taine2_with_mul_or_left_shift) {
          tmp_symbol->_taine2_with_mul_or_left_shift = true;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RCX, 8)] =
            tmp_symbol;

        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_ECX, 4)] =
            symbol;
        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_CX, 2)] =
            symbol->_size_16_symbol;
        // ah
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_CH, 1)] =
            symbol->_size_xh_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_CL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_EDX: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RDX,
                                                                  8));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_16_size =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);

        // 设置rax寄存器
        // rax是数字的时候
        if (size_8_symbol->is_num()) {
          uint64_t size_8_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDX, 8)] =
              std::make_shared<state_symbol>(
                  (size_8_num & 0xffffffff00000000LL) +
                      (num & 0x00000000ffffffffLL),
                  8);
        }
        // symbol是数字 rax不是数字
        else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector = {};
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          // 设置
          {
            new_size_8_symbol->_size_32_symbol = symbol;
            new_size_8_symbol->_size_16_symbol = symbol_16_size;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          // 设置rax
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDX, 8)] =
              new_size_8_symbol;
        }
        // 设置eax ax ah al寄存器
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EDX, 4)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DX, 2)] =
              symbol_16_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DH, 1)] =
              symbol_xh_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DL, 1)] =
              symbol_xl_size;
        }
      } else {
        // rax不确定但symbol为符号的时候
        std::shared_ptr<state_symbol> tmp_symbol;
        // 生成新符号的污点信息
        std::vector<std::string> new_size_8_taine_str =
            symbol->_taine_effect_vector;
        // if (size_8_symbol->_size_64_symbol == nullptr) {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_taine_effect_vector.end());
        // } else {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
        // }
        distinct_taine_str(new_size_8_taine_str);
        tmp_symbol = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
        // 重建新符号的各可拆分寄存器
        {
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   tmp_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   tmp_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          // }
          tmp_symbol->_size_32_symbol = symbol;
          tmp_symbol->_size_16_symbol = symbol->_size_16_symbol;
          tmp_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
          tmp_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
        }
        if (symbol->get_can_up_taine_lv()) {
          tmp_symbol->_can_up_taine_level = true;
        }
        if (symbol->get_symbol_mem_effect()) {
          tmp_symbol->_mem_effect = true;
        }
        if (symbol->_taine2_with_mul_or_left_shift) {
          tmp_symbol->_taine2_with_mul_or_left_shift = true;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RDX, 8)] =
            tmp_symbol;

        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_EDX, 4)] =
            symbol;
        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DX, 2)] =
            symbol->_size_16_symbol;
        // ah
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DH, 1)] =
            symbol->_size_xh_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_EBX: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RBX,
                                                                  8));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_16_size =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);

        // 设置rax寄存器
        // rax是数字的时候
        if (size_8_symbol->is_num()) {
          uint64_t size_8_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBX, 8)] =
              std::make_shared<state_symbol>(
                  (size_8_num & 0xffffffff00000000LL) +
                      (num & 0x00000000ffffffffLL),
                  8);
        }
        // symbol是数字 rax不是数字
        else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector = {};
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          // 设置
          {
            new_size_8_symbol->_size_32_symbol = symbol;
            new_size_8_symbol->_size_16_symbol = symbol_16_size;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          // 设置rax
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBX, 8)] =
              new_size_8_symbol;
        }
        // 设置eax ax ah al寄存器
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EBX, 4)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BX, 2)] =
              symbol_16_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BH, 1)] =
              symbol_xh_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BL, 1)] =
              symbol_xl_size;
        }
      } else {
        // rax不确定但symbol为符号的时候
        std::shared_ptr<state_symbol> tmp_symbol;
        // 生成新符号的污点信息
        std::vector<std::string> new_size_8_taine_str =
            symbol->_taine_effect_vector;
        // if (size_8_symbol->_size_64_symbol == nullptr) {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_taine_effect_vector.end());
        // } else {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
        // }
        distinct_taine_str(new_size_8_taine_str);
        tmp_symbol = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
        // 重建新符号的各可拆分寄存器
        {
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   tmp_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   tmp_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          // }
          tmp_symbol->_size_32_symbol = symbol;
          tmp_symbol->_size_16_symbol = symbol->_size_16_symbol;
          tmp_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
          tmp_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
        }

        if (symbol->get_can_up_taine_lv()) {
          tmp_symbol->_can_up_taine_level = true;
        }
        if (symbol->get_symbol_mem_effect()) {
          tmp_symbol->_mem_effect = true;
        }
        if (symbol->_taine2_with_mul_or_left_shift) {
          tmp_symbol->_taine2_with_mul_or_left_shift = true;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RBX, 8)] =
            tmp_symbol;

        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_EBX, 4)] =
            symbol;
        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BX, 2)] =
            symbol->_size_16_symbol;
        // ah
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BH, 1)] =
            symbol->_size_xh_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_ESI: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RSI,
                                                                  8));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_16_size =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);

        // 设置rax寄存器
        // rax是数字的时候
        if (size_8_symbol->is_num()) {
          uint64_t size_8_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RSI, 8)] =
              std::make_shared<state_symbol>(
                  (size_8_num & 0xffffffff00000000LL) +
                      (num & 0x00000000ffffffffLL),
                  8);
        }
        // symbol是数字 rax不是数字
        else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector = {};
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          // 设置
          {
            new_size_8_symbol->_size_32_symbol = symbol;
            new_size_8_symbol->_size_16_symbol = symbol_16_size;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          // 设置rax
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RSI, 8)] =
              new_size_8_symbol;
        }
        // 设置eax ax ah al寄存器
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ESI, 4)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_SI, 2)] =
              symbol_16_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_SIL, 1)] =
              symbol_xl_size;
        }
      } else {
        // rax不确定但symbol为符号的时候
        std::shared_ptr<state_symbol> tmp_symbol;
        // 生成新符号的污点信息
        std::vector<std::string> new_size_8_taine_str =
            symbol->_taine_effect_vector;
        // if (size_8_symbol->_size_64_symbol == nullptr) {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_taine_effect_vector.end());
        // } else {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
        // }
        distinct_taine_str(new_size_8_taine_str);
        tmp_symbol = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
        // 重建新符号的各可拆分寄存器
        {
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   tmp_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   tmp_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          // }
          tmp_symbol->_size_32_symbol = symbol;
          tmp_symbol->_size_16_symbol = symbol->_size_16_symbol;
          tmp_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
          tmp_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
        }

        if (symbol->get_can_up_taine_lv()) {
          tmp_symbol->_can_up_taine_level = true;
        }
        if (symbol->get_symbol_mem_effect()) {
          tmp_symbol->_mem_effect = true;
        }
        if (symbol->_taine2_with_mul_or_left_shift) {
          tmp_symbol->_taine2_with_mul_or_left_shift = true;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RSI, 8)] =
            tmp_symbol;

        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_ESI, 4)] =
            symbol;
        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SI, 2)] =
            symbol->_size_16_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SIL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_EDI: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RDI,
                                                                  8));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_16_size =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);

        // 设置rax寄存器
        // rax是数字的时候
        if (size_8_symbol->is_num()) {
          uint64_t size_8_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDI, 8)] =
              std::make_shared<state_symbol>(
                  (size_8_num & 0xffffffff00000000LL) +
                      (num & 0x00000000ffffffffLL),
                  8);
        }
        // symbol是数字 rax不是数字
        else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector = {};
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 设置
          {
            new_size_8_symbol->_size_32_symbol = symbol;
            new_size_8_symbol->_size_16_symbol = symbol_16_size;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          // 设置rax
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDI, 8)] =
              new_size_8_symbol;
        }
        // 设置eax ax ah al寄存器
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EDI, 4)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DI, 2)] =
              symbol_16_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DIL, 1)] =
              symbol_xl_size;
        }
      } else {
        // rax不确定但symbol为符号的时候
        std::shared_ptr<state_symbol> tmp_symbol;
        // 生成新符号的污点信息
        std::vector<std::string> new_size_8_taine_str =
            symbol->_taine_effect_vector;
        // if (size_8_symbol->_size_64_symbol == nullptr) {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_taine_effect_vector.end());
        // } else {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
        // }
        distinct_taine_str(new_size_8_taine_str);
        tmp_symbol = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
        // 重建新符号的各可拆分寄存器
        {
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   tmp_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   tmp_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          // }
          tmp_symbol->_size_32_symbol = symbol;
          tmp_symbol->_size_16_symbol = symbol->_size_16_symbol;
          tmp_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
          tmp_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
        }
        if (symbol->get_can_up_taine_lv()) {
          tmp_symbol->_can_up_taine_level = true;
        }
        if (symbol->get_symbol_mem_effect()) {
          tmp_symbol->_mem_effect = true;
        }
        if (symbol->_taine2_with_mul_or_left_shift) {
          tmp_symbol->_taine2_with_mul_or_left_shift = true;
        }
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RDI, 8)] =
            tmp_symbol;

        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_EDI, 4)] =
            symbol;
        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DI, 2)] =
            symbol->_size_16_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DIL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_EBP: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RBP,
                                                                  8));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_16_size =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);

        // 设置rax寄存器
        // rax是数字的时候
        if (size_8_symbol->is_num()) {
          uint64_t size_8_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBP, 8)] =
              std::make_shared<state_symbol>(
                  (size_8_num & 0xffffffff00000000LL) +
                      (num & 0x00000000ffffffffLL),
                  8);
        }
        // symbol是数字 rax不是数字
        else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector = {};
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          // 设置
          {
            new_size_8_symbol->_size_32_symbol = symbol;
            new_size_8_symbol->_size_16_symbol = symbol_16_size;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          // 设置rax
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBP, 8)] =
              new_size_8_symbol;
        }
        // 设置eax ax ah al寄存器
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EBP, 4)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BP, 2)] =
              symbol_16_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BPL, 1)] =
              symbol_xl_size;
        }
      } else {
        // rax不确定但symbol为符号的时候
        std::shared_ptr<state_symbol> tmp_symbol;
        // 生成新符号的污点信息
        std::vector<std::string> new_size_8_taine_str =
            symbol->_taine_effect_vector;
        // if (size_8_symbol->_size_64_symbol == nullptr) {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_taine_effect_vector.end());
        // } else {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
        // }
        distinct_taine_str(new_size_8_taine_str);
        tmp_symbol = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
        // 重建新符号的各可拆分寄存器
        {
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   tmp_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   tmp_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          // }
          tmp_symbol->_size_32_symbol = symbol;
          tmp_symbol->_size_16_symbol = symbol->_size_16_symbol;
          tmp_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
          tmp_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
        }
        if (symbol->get_can_up_taine_lv()) {
          tmp_symbol->_can_up_taine_level = true;
        }
        if (symbol->get_symbol_mem_effect()) {
          tmp_symbol->_mem_effect = true;
        }
        if (symbol->_taine2_with_mul_or_left_shift) {
          tmp_symbol->_taine2_with_mul_or_left_shift = true;
        }
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RBP, 8)] =
            tmp_symbol;

        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_EBP, 4)] =
            symbol;
        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BP, 2)] =
            symbol->_size_16_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BPL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_ESP: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RSP,
                                                                  8));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_16_size =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);

        // 设置rax寄存器
        // rax是数字的时候
        if (size_8_symbol->is_num()) {
          uint64_t size_8_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RSP, 8)] =
              std::make_shared<state_symbol>(
                  (size_8_num & 0xffffffff00000000LL) +
                      (num & 0x00000000ffffffffLL),
                  8);
        }
        // symbol是数字 rax不是数字
        else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector = {};
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          // 设置
          {
            new_size_8_symbol->_size_32_symbol = symbol;
            new_size_8_symbol->_size_32_symbol->set_symbol_size(4);
            new_size_8_symbol->_size_16_symbol = symbol_16_size;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          // 设置rax
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RSP, 8)] =
              new_size_8_symbol;
        }
        // 设置eax ax ah al寄存器
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ESP, 4)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_SP, 2)] =
              symbol_16_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_SPL, 1)] =
              symbol_xl_size;
        }
      } else {
        // rax不确定但symbol为符号的时候
        std::shared_ptr<state_symbol> tmp_symbol;
        // 生成新符号的污点信息
        std::vector<std::string> new_size_8_taine_str =
            symbol->_taine_effect_vector;
        // if (size_8_symbol->_size_64_symbol == nullptr) {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_taine_effect_vector.end());
        // } else {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
        // }
        distinct_taine_str(new_size_8_taine_str);
        tmp_symbol = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
        // 重建新符号的各可拆分寄存器
        {
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   tmp_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   tmp_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          // }
          tmp_symbol->_size_32_symbol = symbol;
          tmp_symbol->_size_16_symbol = symbol->_size_16_symbol;
          tmp_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
          tmp_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
        }
        if (symbol->get_can_up_taine_lv()) {
          tmp_symbol->_can_up_taine_level = true;
        }
        if (symbol->get_symbol_mem_effect()) {
          tmp_symbol->_mem_effect = true;
        }
        if (symbol->_taine2_with_mul_or_left_shift) {
          tmp_symbol->_taine2_with_mul_or_left_shift = true;
        }
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_RSP, 8)] =
            tmp_symbol;

        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_ESP, 4)] =
            symbol;
        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SP, 2)] =
            symbol->_size_16_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SPL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R8D: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R8,
                                                                  8));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_16_size =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);

        // 设置rax寄存器
        // rax是数字的时候
        if (size_8_symbol->is_num()) {
          uint64_t size_8_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8, 8)] =
              std::make_shared<state_symbol>(
                  (size_8_num & 0xffffffff00000000LL) +
                      (num & 0x00000000ffffffffLL),
                  8);
        }
        // symbol是数字 rax不是数字
        else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          // 设置
          {
            new_size_8_symbol->_size_32_symbol = symbol;
            new_size_8_symbol->_size_16_symbol = symbol_16_size;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          // 设置rax
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8, 8)] =
              new_size_8_symbol;
        }
        // 设置eax ax ah al寄存器
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8D, 4)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8W, 2)] =
              symbol_16_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8B, 1)] =
              symbol_xl_size;
        }
      } else {
        // rax不确定但symbol为符号的时候
        std::shared_ptr<state_symbol> tmp_symbol;
        // 生成新符号的污点信息
        std::vector<std::string> new_size_8_taine_str =
            symbol->_taine_effect_vector;
        // if (size_8_symbol->_size_64_symbol == nullptr) {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_taine_effect_vector.end());
        // } else {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
        // }
        distinct_taine_str(new_size_8_taine_str);
        tmp_symbol = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
        // 重建新符号的各可拆分寄存器
        {
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   tmp_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   tmp_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          // }
          tmp_symbol->_size_32_symbol = symbol;
          tmp_symbol->_size_16_symbol = symbol->_size_16_symbol;
          tmp_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
          tmp_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
        }
        if (symbol->get_can_up_taine_lv()) {
          tmp_symbol->_can_up_taine_level = true;
        }
        if (symbol->get_symbol_mem_effect()) {
          tmp_symbol->_mem_effect = true;
        }
        if (symbol->_taine2_with_mul_or_left_shift) {
          tmp_symbol->_taine2_with_mul_or_left_shift = true;
        }
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R8, 8)] =
            tmp_symbol;

        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R8D, 4)] =
            symbol;
        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R8W, 2)] =
            symbol->_size_16_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R8B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R9D: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R9,
                                                                  8));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_16_size =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);

        // 设置rax寄存器
        // rax是数字的时候
        if (size_8_symbol->is_num()) {
          uint64_t size_8_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9, 8)] =
              std::make_shared<state_symbol>(
                  (size_8_num & 0xffffffff00000000LL) +
                      (num & 0x00000000ffffffffLL),
                  8);
        }
        // symbol是数字 rax不是数字
        else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          // 设置
          {
            new_size_8_symbol->_size_32_symbol = symbol;
            new_size_8_symbol->_size_32_symbol->set_symbol_size(4);
            new_size_8_symbol->_size_16_symbol = symbol_16_size;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          // 设置rax
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9, 8)] =
              new_size_8_symbol;
        }
        // 设置eax ax ah al寄存器
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9D, 4)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9W, 2)] =
              symbol_16_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9B, 1)] =
              symbol_xl_size;
        }
      } else {
        // rax不确定但symbol为符号的时候
        std::shared_ptr<state_symbol> tmp_symbol;
        // 生成新符号的污点信息
        std::vector<std::string> new_size_8_taine_str =
            symbol->_taine_effect_vector;
        // if (size_8_symbol->_size_64_symbol == nullptr) {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_taine_effect_vector.end());
        // } else {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
        // }
        distinct_taine_str(new_size_8_taine_str);
        tmp_symbol = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
        // 重建新符号的各可拆分寄存器
        {
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   tmp_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   tmp_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          // }
          tmp_symbol->_size_32_symbol = symbol;
          tmp_symbol->_size_16_symbol = symbol->_size_16_symbol;
          tmp_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
          tmp_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
        }
        if (symbol->get_can_up_taine_lv()) {
          tmp_symbol->_can_up_taine_level = true;
        }
        if (symbol->get_symbol_mem_effect()) {
          tmp_symbol->_mem_effect = true;
        }
        if (symbol->_taine2_with_mul_or_left_shift) {
          tmp_symbol->_taine2_with_mul_or_left_shift = true;
        }
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R9, 8)] =
            tmp_symbol;

        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R9D, 4)] =
            symbol;
        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R9W, 2)] =
            symbol->_size_16_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R9B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R10D: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R10,
                                                                  8));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_16_size =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);

        // 设置rax寄存器
        // rax是数字的时候
        if (size_8_symbol->is_num()) {
          uint64_t size_8_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10, 8)] =
              std::make_shared<state_symbol>(
                  (size_8_num & 0xffffffff00000000LL) +
                      (num & 0x00000000ffffffffLL),
                  8);
        }
        // symbol是数字 rax不是数字
        else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          // 设置
          {
            new_size_8_symbol->_size_32_symbol = symbol;
            new_size_8_symbol->_size_32_symbol->set_symbol_size(4);
            new_size_8_symbol->_size_16_symbol = symbol_16_size;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          // 设置rax
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10, 8)] =
              new_size_8_symbol;
        }
        // 设置eax ax ah al寄存器
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10D, 4)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10W, 2)] =
              symbol_16_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10B, 1)] =
              symbol_xl_size;
        }
      } else {
        // rax不确定但symbol为符号的时候
        std::shared_ptr<state_symbol> tmp_symbol;
        // 生成新符号的污点信息
        std::vector<std::string> new_size_8_taine_str =
            symbol->_taine_effect_vector;
        // if (size_8_symbol->_size_64_symbol == nullptr) {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_taine_effect_vector.end());
        // } else {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
        // }
        distinct_taine_str(new_size_8_taine_str);
        tmp_symbol = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
        // 重建新符号的各可拆分寄存器
        {
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   tmp_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   tmp_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          // }
          tmp_symbol->_size_32_symbol = symbol;
          tmp_symbol->_size_16_symbol = symbol->_size_16_symbol;
          tmp_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
          tmp_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
        }
        if (symbol->get_can_up_taine_lv()) {
          tmp_symbol->_can_up_taine_level = true;
        }
        if (symbol->get_symbol_mem_effect()) {
          tmp_symbol->_mem_effect = true;
        }
        if (symbol->_taine2_with_mul_or_left_shift) {
          tmp_symbol->_taine2_with_mul_or_left_shift = true;
        }
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R10, 8)] =
            tmp_symbol;

        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R10D, 4)] =
            symbol;
        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R10W, 2)] =
            symbol->_size_16_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R10B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R11D: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R11,
                                                                  8));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_16_size =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);

        // 设置rax寄存器
        // rax是数字的时候
        if (size_8_symbol->is_num()) {
          uint64_t size_8_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11, 8)] =
              std::make_shared<state_symbol>(
                  (size_8_num & 0xffffffff00000000LL) +
                      (num & 0x00000000ffffffffLL),
                  8);
        }
        // symbol是数字 rax不是数字
        else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          // 设置
          {
            new_size_8_symbol->_size_32_symbol = symbol;
            new_size_8_symbol->_size_32_symbol->set_symbol_size(4);
            new_size_8_symbol->_size_16_symbol = symbol_16_size;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          // 设置rax
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11, 8)] =
              new_size_8_symbol;
        }
        // 设置eax ax ah al寄存器
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11D, 4)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11W, 2)] =
              symbol_16_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11B, 1)] =
              symbol_xl_size;
        }
      } else {
        // rax不确定但symbol为符号的时候
        std::shared_ptr<state_symbol> tmp_symbol;
        // 生成新符号的污点信息
        std::vector<std::string> new_size_8_taine_str =
            symbol->_taine_effect_vector;
        // if (size_8_symbol->_size_64_symbol == nullptr) {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_taine_effect_vector.end());
        // } else {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
        // }
        distinct_taine_str(new_size_8_taine_str);
        tmp_symbol = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
        // 重建新符号的各可拆分寄存器
        {
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   tmp_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   tmp_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          // }
          tmp_symbol->_size_32_symbol = symbol;
          tmp_symbol->_size_16_symbol = symbol->_size_16_symbol;
          tmp_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
          tmp_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
        }
        if (symbol->get_can_up_taine_lv()) {
          tmp_symbol->_can_up_taine_level = true;
        }
        if (symbol->get_symbol_mem_effect()) {
          tmp_symbol->_mem_effect = true;
        }
        if (symbol->_taine2_with_mul_or_left_shift) {
          tmp_symbol->_taine2_with_mul_or_left_shift = true;
        }
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R11, 8)] =
            tmp_symbol;

        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R11D, 4)] =
            symbol;
        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R11W, 2)] =
            symbol->_size_16_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R11B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R12D: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R12,
                                                                  8));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_16_size =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);

        // 设置rax寄存器
        // rax是数字的时候
        if (size_8_symbol->is_num()) {
          uint64_t size_8_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12, 8)] =
              std::make_shared<state_symbol>(
                  (size_8_num & 0xffffffff00000000LL) +
                      (num & 0x00000000ffffffffLL),
                  8);
        }
        // symbol是数字 rax不是数字
        else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          // 设置
          {
            new_size_8_symbol->_size_32_symbol = symbol;
            new_size_8_symbol->_size_32_symbol->set_symbol_size(4);
            new_size_8_symbol->_size_16_symbol = symbol_16_size;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          // 设置rax
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12, 8)] =
              new_size_8_symbol;
        }
        // 设置eax ax ah al寄存器
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12D, 4)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12W, 2)] =
              symbol_16_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12B, 1)] =
              symbol_xl_size;
        }
      } else {
        // rax不确定但symbol为符号的时候
        std::shared_ptr<state_symbol> tmp_symbol;
        // 生成新符号的污点信息
        std::vector<std::string> new_size_8_taine_str =
            symbol->_taine_effect_vector;
        // if (size_8_symbol->_size_64_symbol == nullptr) {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_taine_effect_vector.end());
        // } else {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
        // }
        distinct_taine_str(new_size_8_taine_str);
        tmp_symbol = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
        // 重建新符号的各可拆分寄存器
        {
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   tmp_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   tmp_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          // }
          tmp_symbol->_size_32_symbol = symbol;
          tmp_symbol->_size_16_symbol = symbol->_size_16_symbol;
          tmp_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
          tmp_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
        }
        if (symbol->get_can_up_taine_lv()) {
          tmp_symbol->_can_up_taine_level = true;
        }
        if (symbol->get_symbol_mem_effect()) {
          tmp_symbol->_mem_effect = true;
        }
        if (symbol->_taine2_with_mul_or_left_shift) {
          tmp_symbol->_taine2_with_mul_or_left_shift = true;
        }
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R12, 8)] =
            tmp_symbol;

        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R12D, 4)] =
            symbol;
        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R12W, 2)] =
            symbol->_size_16_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R12B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R13D: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R13,
                                                                  8));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_16_size =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);

        // 设置rax寄存器
        // rax是数字的时候
        if (size_8_symbol->is_num()) {
          uint64_t size_8_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13, 8)] =
              std::make_shared<state_symbol>(
                  (size_8_num & 0xffffffff00000000LL) +
                      (num & 0x00000000ffffffffLL),
                  8);
        }
        // symbol是数字 rax不是数字
        else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          // 设置
          {
            new_size_8_symbol->_size_32_symbol = symbol;
            new_size_8_symbol->_size_32_symbol->set_symbol_size(4);
            new_size_8_symbol->_size_16_symbol = symbol_16_size;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          // 设置rax
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13, 8)] =
              new_size_8_symbol;
        }
        // 设置eax ax ah al寄存器
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13D, 4)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13W, 2)] =
              symbol_16_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13B, 1)] =
              symbol_xl_size;
        }
      } else {
        // rax不确定但symbol为符号的时候
        std::shared_ptr<state_symbol> tmp_symbol;
        // 生成新符号的污点信息
        std::vector<std::string> new_size_8_taine_str =
            symbol->_taine_effect_vector;
        // if (size_8_symbol->_size_64_symbol == nullptr) {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_taine_effect_vector.end());
        // } else {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
        // }
        distinct_taine_str(new_size_8_taine_str);
        tmp_symbol = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
        // 重建新符号的各可拆分寄存器
        {
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   tmp_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   tmp_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          // }
          tmp_symbol->_size_32_symbol = symbol;
          tmp_symbol->_size_16_symbol = symbol->_size_16_symbol;
          tmp_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
          tmp_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
        }
        if (symbol->get_can_up_taine_lv()) {
          tmp_symbol->_can_up_taine_level = true;
        }
        if (symbol->get_symbol_mem_effect()) {
          tmp_symbol->_mem_effect = true;
        }
        if (symbol->_taine2_with_mul_or_left_shift) {
          tmp_symbol->_taine2_with_mul_or_left_shift = true;
        }
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R13, 8)] =
            tmp_symbol;

        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R13D, 4)] =
            symbol;
        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R13W, 2)] =
            symbol->_size_16_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R13B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R14D: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R14,
                                                                  8));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_16_size =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);

        // 设置rax寄存器
        // rax是数字的时候
        if (size_8_symbol->is_num()) {
          uint64_t size_8_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14, 8)] =
              std::make_shared<state_symbol>(
                  (size_8_num & 0xffffffff00000000LL) +
                      (num & 0x00000000ffffffffLL),
                  8);
        }
        // symbol是数字 rax不是数字
        else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          // 设置
          {
            new_size_8_symbol->_size_32_symbol = symbol;
            new_size_8_symbol->_size_32_symbol->set_symbol_size(4);
            new_size_8_symbol->_size_16_symbol = symbol_16_size;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          // 设置rax
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14, 8)] =
              new_size_8_symbol;
        }
        // 设置eax ax ah al寄存器
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14D, 4)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14W, 2)] =
              symbol_16_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14B, 1)] =
              symbol_xl_size;
        }
      } else {
        // rax不确定但symbol为符号的时候
        std::shared_ptr<state_symbol> tmp_symbol;
        // 生成新符号的污点信息
        std::vector<std::string> new_size_8_taine_str =
            symbol->_taine_effect_vector;
        // if (size_8_symbol->_size_64_symbol == nullptr) {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_taine_effect_vector.end());
        // } else {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
        // }
        distinct_taine_str(new_size_8_taine_str);
        tmp_symbol = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
        // 重建新符号的各可拆分寄存器
        {
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   tmp_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   tmp_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          // }
          tmp_symbol->_size_32_symbol = symbol;
          tmp_symbol->_size_16_symbol = symbol->_size_16_symbol;
          tmp_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
          tmp_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
        }
        if (symbol->get_can_up_taine_lv()) {
          tmp_symbol->_can_up_taine_level = true;
        }
        if (symbol->get_symbol_mem_effect()) {
          tmp_symbol->_mem_effect = true;
        }
        if (symbol->_taine2_with_mul_or_left_shift) {
          tmp_symbol->_taine2_with_mul_or_left_shift = true;
        }
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R14, 8)] =
            tmp_symbol;

        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R14D, 4)] =
            symbol;
        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R14W, 2)] =
            symbol->_size_16_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R14B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R15D: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R15,
                                                                  8));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_16_size =
            std::make_shared<state_symbol>(num & 0x000000000000ffffLL, 2);
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);

        // 设置rax寄存器
        // rax是数字的时候
        if (size_8_symbol->is_num()) {
          uint64_t size_8_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15, 8)] =
              std::make_shared<state_symbol>(
                  (size_8_num & 0xffffffff00000000LL) +
                      (num & 0x00000000ffffffffLL),
                  8);
        }
        // symbol是数字 rax不是数字
        else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          // 设置
          {
            new_size_8_symbol->_size_32_symbol = symbol;
            new_size_8_symbol->_size_16_symbol = symbol_16_size;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          // 设置rax
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15, 8)] =
              new_size_8_symbol;
        }
        // 设置eax ax ah al寄存器
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15D, 4)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15W, 2)] =
              symbol_16_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15B, 1)] =
              symbol_xl_size;
        }
      } else {
        // rax不确定但symbol为符号的时候
        std::shared_ptr<state_symbol> tmp_symbol;
        // 生成新符号的污点信息
        std::vector<std::string> new_size_8_taine_str =
            symbol->_taine_effect_vector;
        // if (size_8_symbol->_size_64_symbol == nullptr) {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_taine_effect_vector.end());
        // } else {
        //   new_size_8_taine_str.insert(
        //       new_size_8_taine_str.end(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
        //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
        // }
        distinct_taine_str(new_size_8_taine_str);
        tmp_symbol = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
        // 重建新符号的各可拆分寄存器
        {
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   tmp_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   tmp_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          // }
          tmp_symbol->_size_32_symbol = symbol;
          tmp_symbol->_size_16_symbol = symbol->_size_16_symbol;
          tmp_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
          tmp_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
        }
        if (symbol->get_can_up_taine_lv()) {
          tmp_symbol->_can_up_taine_level = true;
        }
        if (symbol->get_symbol_mem_effect()) {
          tmp_symbol->_mem_effect = true;
        }
        if (symbol->_taine2_with_mul_or_left_shift) {
          tmp_symbol->_taine2_with_mul_or_left_shift = true;
        }
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R15, 8)] =
            tmp_symbol;

        // eax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R15D, 4)] =
            symbol;
        // ax
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R15W, 2)] =
            symbol->_size_16_symbol;
        // al
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R15B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_AX: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RAX,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EAX,
                                                                  4));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
        //设置相关寄存器
        state_symbol::ptr new_size_4_symbol;
        if (size_4_symbol->is_num()) {
          uint64_t size_4_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EAX, 4)] =
              std::make_shared<state_symbol>(
                  (size_4_num & 0x00000000ffff0000LL) +
                      (num & 0x000000000000ffffLL),
                  4);
        }
        // eax是一个符号，symbol是数字
        else {
          std::vector<std::string> new_taine_vector;
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_4_symbol->get_taine_str().begin(),
          //                           size_4_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().begin(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
          // } else {
          //   new_size_4_symbol->_size_32_symbol =
          //   size_4_symbol->_size_32_symbol;
          // }
          {
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_4_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EAX, 4)] =
              new_size_4_symbol;
        }

        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RAX, 8)] =
              std::make_shared<state_symbol>((rax_num & 0xffffffffffff0000LL) +
                                                 (num & 0x000000000000ffffLL),
                                             8);
        } else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RAX, 8)] =
              new_size_8_symbol;
        }
        //
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_AX, 2)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_AH, 1)] =
              symbol_xh_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_AL, 1)] =
              symbol_xl_size;
        }

      } else {
        // 先生成eax
        std::shared_ptr<state_symbol> new_size_4_symbol;
        std::shared_ptr<state_symbol> new_size_8_symbol;
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            // if (size_4_symbol->_size_32_symbol == nullptr) {
            //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
            // } else {
            //   new_size_4_symbol->_size_32_symbol =
            //       size_4_symbol->_size_32_symbol;
            // }
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EAX, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            // if (size_8_symbol->_size_64_symbol == nullptr) {
            //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
            // } else {
            //   new_size_8_symbol->_size_64_symbol =
            //       size_8_symbol->_size_64_symbol;
            // }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol->_size_16_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RAX, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_AX, 2)] = symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_AH, 1)] =
            symbol->_size_xh_symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_AL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_CX: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RCX,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_ECX,
                                                                  4));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
        //设置相关寄存器
        state_symbol::ptr new_size_4_symbol;
        if (size_4_symbol->is_num()) {
          uint64_t size_4_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ECX, 4)] =
              std::make_shared<state_symbol>(
                  (size_4_num & 0x00000000ffff0000LL) +
                      (num & 0x000000000000ffffLL),
                  4);
        }
        // eax是一个符号，symbol是数字
        else {
          std::vector<std::string> new_taine_vector;
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_4_symbol->get_taine_str().begin(),
          //                           size_4_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().begin(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
          // } else {
          //   new_size_4_symbol->_size_32_symbol =
          //   size_4_symbol->_size_32_symbol;
          // }
          {
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_4_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ECX, 4)] =
              new_size_4_symbol;
        }

        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RCX, 8)] =
              std::make_shared<state_symbol>((rax_num & 0xffffffffffff0000LL) +
                                                 (num & 0x000000000000ffffLL),
                                             8);
        } else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RCX, 8)] =
              new_size_8_symbol;
        }
        //
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_CX, 2)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_CH, 1)] =
              symbol_xh_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_CL, 1)] =
              symbol_xl_size;
        }

      } else {
        // 先生成eax
        std::shared_ptr<state_symbol> new_size_4_symbol;
        std::shared_ptr<state_symbol> new_size_8_symbol;
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            // if (size_4_symbol->_size_32_symbol == nullptr) {
            //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
            // } else {
            //   new_size_4_symbol->_size_32_symbol =
            //       size_4_symbol->_size_32_symbol;
            // }
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ECX, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            // if (size_8_symbol->_size_64_symbol == nullptr) {
            //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
            // } else {
            //   new_size_8_symbol->_size_64_symbol =
            //       size_8_symbol->_size_64_symbol;
            // }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol->_size_16_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RCX, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_CX, 2)] = symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_CH, 1)] =
            symbol->_size_xh_symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_CL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_DX: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RDX,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EDX,
                                                                  4));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
        //设置相关寄存器
        state_symbol::ptr new_size_4_symbol;
        if (size_4_symbol->is_num()) {
          uint64_t size_4_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EDX, 4)] =
              std::make_shared<state_symbol>(
                  (size_4_num & 0x00000000ffff0000LL) +
                      (num & 0x000000000000ffffLL),
                  4);
        }
        // eax是一个符号，symbol是数字
        else {
          std::vector<std::string> new_taine_vector;
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_4_symbol->get_taine_str().begin(),
          //                           size_4_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().begin(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
          // } else {
          //   new_size_4_symbol->_size_32_symbol =
          //   size_4_symbol->_size_32_symbol;
          // }
          {
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_4_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EDX, 4)] =
              new_size_4_symbol;
        }

        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDX, 8)] =
              std::make_shared<state_symbol>((rax_num & 0xffffffffffff0000LL) +
                                                 (num & 0x000000000000ffffLL),
                                             8);
        } else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDX, 8)] =
              new_size_8_symbol;
        }
        //
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DX, 2)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DH, 1)] =
              symbol_xh_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DL, 1)] =
              symbol_xl_size;
        }

      } else {
        // 先生成eax
        std::shared_ptr<state_symbol> new_size_4_symbol;
        std::shared_ptr<state_symbol> new_size_8_symbol;
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            // if (size_4_symbol->_size_32_symbol == nullptr) {
            //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
            // } else {
            //   new_size_4_symbol->_size_32_symbol =
            //       size_4_symbol->_size_32_symbol;
            // }
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EDX, 4)] =
              new_size_4_symbol;
        }

        {
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            // if (size_8_symbol->_size_64_symbol == nullptr) {
            //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
            // } else {
            //   new_size_8_symbol->_size_64_symbol =
            //       size_8_symbol->_size_64_symbol;
            // }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol->_size_16_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDX, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DX, 2)] = symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DH, 1)] =
            symbol->_size_xh_symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_BX: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RBX,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EBX,
                                                                  4));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
        //设置相关寄存器
        state_symbol::ptr new_size_4_symbol;
        if (size_4_symbol->is_num()) {
          uint64_t size_4_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EBX, 4)] =
              std::make_shared<state_symbol>(
                  (size_4_num & 0x00000000ffff0000LL) +
                      (num & 0x000000000000ffffLL),
                  4);
        }
        // eax是一个符号，symbol是数字
        else {
          std::vector<std::string> new_taine_vector;
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_4_symbol->get_taine_str().begin(),
          //                           size_4_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().begin(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
          // } else {
          //   new_size_4_symbol->_size_32_symbol =
          //   size_4_symbol->_size_32_symbol;
          // }
          {
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_4_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EBX, 4)] =
              new_size_4_symbol;
        }

        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBX, 8)] =
              std::make_shared<state_symbol>((rax_num & 0xffffffffffff0000LL) +
                                                 (num & 0x000000000000ffffLL),
                                             8);
        } else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBX, 8)] =
              new_size_8_symbol;
        }
        //
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BX, 2)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BH, 1)] =
              symbol_xh_size;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BL, 1)] =
              symbol_xl_size;
        }

      } else {
        // 先生成eax
        std::shared_ptr<state_symbol> new_size_4_symbol;
        std::shared_ptr<state_symbol> new_size_8_symbol;
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            // if (size_4_symbol->_size_32_symbol == nullptr) {
            //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
            // } else {
            //   new_size_4_symbol->_size_32_symbol =
            //       size_4_symbol->_size_32_symbol;
            // }
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EBX, 4)] =
              new_size_4_symbol;
        }

        {
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            // if (size_8_symbol->_size_64_symbol == nullptr) {
            //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
            // } else {
            //   new_size_8_symbol->_size_64_symbol =
            //       size_8_symbol->_size_64_symbol;
            // }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol->_size_16_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBX, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BX, 2)] = symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BH, 1)] =
            symbol->_size_xh_symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_SI: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RSI,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_ESI,
                                                                  4));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
        //设置相关寄存器
        state_symbol::ptr new_size_4_symbol;
        if (size_4_symbol->is_num()) {
          uint64_t size_4_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ESI, 4)] =
              std::make_shared<state_symbol>(
                  (size_4_num & 0x00000000ffff0000LL) +
                      (num & 0x000000000000ffffLL),
                  4);
        }
        // eax是一个符号，symbol是数字
        else {
          std::vector<std::string> new_taine_vector;
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_4_symbol->get_taine_str().begin(),
          //                           size_4_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().begin(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
          // } else {
          //   new_size_4_symbol->_size_32_symbol =
          //   size_4_symbol->_size_32_symbol;
          // }
          {
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_4_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ESI, 4)] =
              new_size_4_symbol;
        }

        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RSI, 8)] =
              std::make_shared<state_symbol>((rax_num & 0xffffffffffff0000LL) +
                                                 (num & 0x000000000000ffffLL),
                                             8);
        } else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RSI, 8)] =
              new_size_8_symbol;
        }
        //
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_SI, 2)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_SIL, 1)] =
              symbol_xl_size;
        }

      } else {
        // 先生成eax
        std::shared_ptr<state_symbol> new_size_4_symbol;
        std::shared_ptr<state_symbol> new_size_8_symbol;
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            // if (size_4_symbol->_size_32_symbol == nullptr) {
            //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
            // } else {
            //   new_size_4_symbol->_size_32_symbol =
            //       size_4_symbol->_size_32_symbol;
            // }
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ESI, 4)] =
              new_size_4_symbol;
        }

        {
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            // if (size_8_symbol->_size_64_symbol == nullptr) {
            //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
            // } else {
            //   new_size_8_symbol->_size_64_symbol =
            //       size_8_symbol->_size_64_symbol;
            // }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol->_size_16_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RSI, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SI, 2)] = symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SIL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_DI: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RDI,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EDI,
                                                                  4));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
        //设置相关寄存器
        state_symbol::ptr new_size_4_symbol;
        if (size_4_symbol->is_num()) {
          uint64_t size_4_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EDI, 4)] =
              std::make_shared<state_symbol>(
                  (size_4_num & 0x00000000ffff0000LL) +
                      (num & 0x000000000000ffffLL),
                  4);
        }
        // eax是一个符号，symbol是数字
        else {
          std::vector<std::string> new_taine_vector;
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_4_symbol->get_taine_str().begin(),
          //                           size_4_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().begin(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
          // } else {
          //   new_size_4_symbol->_size_32_symbol =
          //   size_4_symbol->_size_32_symbol;
          // }
          {
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_4_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EDI, 4)] =
              new_size_4_symbol;
        }

        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDI, 8)] =
              std::make_shared<state_symbol>((rax_num & 0xffffffffffff0000LL) +
                                                 (num & 0x000000000000ffffLL),
                                             8);
        } else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDI, 8)] =
              new_size_8_symbol;
        }
        //
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DI, 2)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DIL, 1)] =
              symbol_xl_size;
        }

      } else {
        // 先生成eax
        std::shared_ptr<state_symbol> new_size_4_symbol;
        std::shared_ptr<state_symbol> new_size_8_symbol;
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            // if (size_4_symbol->_size_32_symbol == nullptr) {
            //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
            // } else {
            //   new_size_4_symbol->_size_32_symbol =
            //       size_4_symbol->_size_32_symbol;
            // }
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EDI, 4)] =
              new_size_4_symbol;
        }

        {
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            // if (size_8_symbol->_size_64_symbol == nullptr) {
            //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
            // } else {
            //   new_size_8_symbol->_size_64_symbol =
            //       size_8_symbol->_size_64_symbol;
            // }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol->_size_16_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDI, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DI, 2)] = symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DIL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_SP: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RSP,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_ESP,
                                                                  4));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
        //设置相关寄存器
        state_symbol::ptr new_size_4_symbol;
        if (size_4_symbol->is_num()) {
          uint64_t size_4_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ESP, 4)] =
              std::make_shared<state_symbol>(
                  (size_4_num & 0x00000000ffff0000LL) +
                      (num & 0x000000000000ffffLL),
                  4);
        }
        // eax是一个符号，symbol是数字
        else {
          std::vector<std::string> new_taine_vector;
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_4_symbol->get_taine_str().begin(),
          //                           size_4_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().begin(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
          // } else {
          //   new_size_4_symbol->_size_32_symbol =
          //   size_4_symbol->_size_32_symbol;
          // }
          {
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_4_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ESP, 4)] =
              new_size_4_symbol;
        }

        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RSP, 8)] =
              std::make_shared<state_symbol>((rax_num & 0xffffffffffff0000LL) +
                                                 (num & 0x000000000000ffffLL),
                                             8);
        } else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RSP, 8)] =
              new_size_8_symbol;
        }
        //
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_SP, 2)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_SPL, 1)] =
              symbol_xl_size;
        }

      } else {
        // 先生成eax
        std::shared_ptr<state_symbol> new_size_4_symbol;
        std::shared_ptr<state_symbol> new_size_8_symbol;
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            // if (size_4_symbol->_size_32_symbol == nullptr) {
            //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
            // } else {
            //   new_size_4_symbol->_size_32_symbol =
            //       size_4_symbol->_size_32_symbol;
            // }
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ESP, 4)] =
              new_size_4_symbol;
        }

        {
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            // if (size_8_symbol->_size_64_symbol == nullptr) {
            //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
            // } else {
            //   new_size_8_symbol->_size_64_symbol =
            //       size_8_symbol->_size_64_symbol;
            // }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol->_size_16_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RSP, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SP, 2)] = symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SPL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_BP: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RBP,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EBP,
                                                                  4));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
        //设置相关寄存器
        state_symbol::ptr new_size_4_symbol;
        if (size_4_symbol->is_num()) {
          uint64_t size_4_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EBP, 4)] =
              std::make_shared<state_symbol>(
                  (size_4_num & 0x00000000ffff0000LL) +
                      (num & 0x000000000000ffffLL),
                  4);
        }
        // eax是一个符号，symbol是数字
        else {
          std::vector<std::string> new_taine_vector;
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_4_symbol->get_taine_str().begin(),
          //                           size_4_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().begin(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
          // } else {
          //   new_size_4_symbol->_size_32_symbol =
          //   size_4_symbol->_size_32_symbol;
          // }
          {
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_4_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EBP, 4)] =
              new_size_4_symbol;
        }

        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBP, 8)] =
              std::make_shared<state_symbol>((rax_num & 0xffffffffffff0000LL) +
                                                 (num & 0x000000000000ffffLL),
                                             8);
        } else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBP, 8)] =
              new_size_8_symbol;
        }
        //
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BP, 2)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BPL, 1)] =
              symbol_xl_size;
        }

      } else {
        // 先生成eax
        std::shared_ptr<state_symbol> new_size_4_symbol;
        std::shared_ptr<state_symbol> new_size_8_symbol;
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            // if (size_4_symbol->_size_32_symbol == nullptr) {
            //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
            // } else {
            //   new_size_4_symbol->_size_32_symbol =
            //       size_4_symbol->_size_32_symbol;
            // }
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EBP, 4)] =
              new_size_4_symbol;
        }

        {
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            // if (size_8_symbol->_size_64_symbol == nullptr) {
            //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
            // } else {
            //   new_size_8_symbol->_size_64_symbol =
            //       size_8_symbol->_size_64_symbol;
            // }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol->_size_16_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBP, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BP, 2)] = symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BPL, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R8W: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R8,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R8D,
                                                                  4));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
        //设置相关寄存器
        state_symbol::ptr new_size_4_symbol;
        if (size_4_symbol->is_num()) {
          uint64_t size_4_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8D, 4)] =
              std::make_shared<state_symbol>(
                  (size_4_num & 0x00000000ffff0000LL) +
                      (num & 0x000000000000ffffLL),
                  4);
        }
        // eax是一个符号，symbol是数字
        else {
          std::vector<std::string> new_taine_vector;
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_4_symbol->get_taine_str().begin(),
          //                           size_4_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().begin(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
          // } else {
          //   new_size_4_symbol->_size_32_symbol =
          //   size_4_symbol->_size_32_symbol;
          // }
          {
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_4_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8D, 4)] =
              new_size_4_symbol;
        }

        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8, 8)] =
              std::make_shared<state_symbol>((rax_num & 0xffffffffffff0000LL) +
                                                 (num & 0x000000000000ffffLL),
                                             8);
        } else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8, 8)] =
              new_size_8_symbol;
        }
        //
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8W, 2)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8B, 1)] =
              symbol_xl_size;
        }

      } else {
        // 先生成eax
        std::shared_ptr<state_symbol> new_size_4_symbol;
        std::shared_ptr<state_symbol> new_size_8_symbol;
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            // if (size_4_symbol->_size_32_symbol == nullptr) {
            //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
            // } else {
            //   new_size_4_symbol->_size_32_symbol =
            //       size_4_symbol->_size_32_symbol;
            // }
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8D, 4)] =
              new_size_4_symbol;
        }

        {
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            // if (size_8_symbol->_size_64_symbol == nullptr) {
            //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
            // } else {
            //   new_size_8_symbol->_size_64_symbol =
            //       size_8_symbol->_size_64_symbol;
            // }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol->_size_16_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R8W, 2)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R8B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R9W: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R9,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R9D,
                                                                  4));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
        //设置相关寄存器
        state_symbol::ptr new_size_4_symbol;
        if (size_4_symbol->is_num()) {
          uint64_t size_4_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9D, 4)] =
              std::make_shared<state_symbol>(
                  (size_4_num & 0x00000000ffff0000LL) +
                      (num & 0x000000000000ffffLL),
                  4);
        }
        // eax是一个符号，symbol是数字
        else {
          std::vector<std::string> new_taine_vector;
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_4_symbol->get_taine_str().begin(),
          //                           size_4_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().begin(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
          // } else {
          //   new_size_4_symbol->_size_32_symbol =
          //   size_4_symbol->_size_32_symbol;
          // }
          {
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_4_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9D, 4)] =
              new_size_4_symbol;
        }

        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9, 8)] =
              std::make_shared<state_symbol>((rax_num & 0xffffffffffff0000LL) +
                                                 (num & 0x000000000000ffffLL),
                                             8);
        } else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9, 8)] =
              new_size_8_symbol;
        }
        //
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9W, 2)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9B, 1)] =
              symbol_xl_size;
        }

      } else {
        // 先生成eax
        std::shared_ptr<state_symbol> new_size_4_symbol;
        std::shared_ptr<state_symbol> new_size_8_symbol;
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            // if (size_4_symbol->_size_32_symbol == nullptr) {
            //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
            // } else {
            //   new_size_4_symbol->_size_32_symbol =
            //       size_4_symbol->_size_32_symbol;
            // }
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9D, 4)] =
              new_size_4_symbol;
        }

        {
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            // if (size_8_symbol->_size_64_symbol == nullptr) {
            //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
            // } else {
            //   new_size_8_symbol->_size_64_symbol =
            //       size_8_symbol->_size_64_symbol;
            // }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol->_size_16_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R9W, 2)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R9B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R10W: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R10,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R10D,
                                                                  4));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
        //设置相关寄存器
        state_symbol::ptr new_size_4_symbol;
        if (size_4_symbol->is_num()) {
          uint64_t size_4_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10D, 4)] =
              std::make_shared<state_symbol>(
                  (size_4_num & 0x00000000ffff0000LL) +
                      (num & 0x000000000000ffffLL),
                  4);
        }
        // eax是一个符号，symbol是数字
        else {
          std::vector<std::string> new_taine_vector;
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_4_symbol->get_taine_str().begin(),
          //                           size_4_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().begin(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
          // } else {
          //   new_size_4_symbol->_size_32_symbol =
          //   size_4_symbol->_size_32_symbol;
          // }
          {
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_4_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10D, 4)] =
              new_size_4_symbol;
        }

        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10, 8)] =
              std::make_shared<state_symbol>((rax_num & 0xffffffffffff0000LL) +
                                                 (num & 0x000000000000ffffLL),
                                             8);
        } else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10, 8)] =
              new_size_8_symbol;
        }
        //
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10W, 2)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10B, 1)] =
              symbol_xl_size;
        }

      } else {
        // 先生成eax
        std::shared_ptr<state_symbol> new_size_4_symbol;
        std::shared_ptr<state_symbol> new_size_8_symbol;
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            // if (size_4_symbol->_size_32_symbol == nullptr) {
            //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
            // } else {
            //   new_size_4_symbol->_size_32_symbol =
            //       size_4_symbol->_size_32_symbol;
            // }
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10D, 4)] =
              new_size_4_symbol;
        }

        {
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            // if (size_8_symbol->_size_64_symbol == nullptr) {
            //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
            // } else {
            //   new_size_8_symbol->_size_64_symbol =
            //       size_8_symbol->_size_64_symbol;
            // }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol->_size_16_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R10W, 2)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R10B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R11W: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R11,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R11D,
                                                                  4));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
        //设置相关寄存器
        state_symbol::ptr new_size_4_symbol;
        if (size_4_symbol->is_num()) {
          uint64_t size_4_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11D, 4)] =
              std::make_shared<state_symbol>(
                  (size_4_num & 0x00000000ffff0000LL) +
                      (num & 0x000000000000ffffLL),
                  4);
        }
        // eax是一个符号，symbol是数字
        else {
          std::vector<std::string> new_taine_vector;
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_4_symbol->get_taine_str().begin(),
          //                           size_4_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().begin(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
          // } else {
          //   new_size_4_symbol->_size_32_symbol =
          //   size_4_symbol->_size_32_symbol;
          // }
          {
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_4_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11D, 4)] =
              new_size_4_symbol;
        }

        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11, 8)] =
              std::make_shared<state_symbol>((rax_num & 0xffffffffffff0000LL) +
                                                 (num & 0x000000000000ffffLL),
                                             8);
        } else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11, 8)] =
              new_size_8_symbol;
        }
        //
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11W, 2)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11B, 1)] =
              symbol_xl_size;
        }

      } else {
        // 先生成eax
        std::shared_ptr<state_symbol> new_size_4_symbol;
        std::shared_ptr<state_symbol> new_size_8_symbol;
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            // if (size_4_symbol->_size_32_symbol == nullptr) {
            //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
            // } else {
            //   new_size_4_symbol->_size_32_symbol =
            //       size_4_symbol->_size_32_symbol;
            // }
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11D, 4)] =
              new_size_4_symbol;
        }

        {
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            // if (size_8_symbol->_size_64_symbol == nullptr) {
            //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
            // } else {
            //   new_size_8_symbol->_size_64_symbol =
            //       size_8_symbol->_size_64_symbol;
            // }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol->_size_16_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R11W, 2)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R11B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R12W: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R12,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R12D,
                                                                  4));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
        //设置相关寄存器
        state_symbol::ptr new_size_4_symbol;
        if (size_4_symbol->is_num()) {
          uint64_t size_4_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12D, 4)] =
              std::make_shared<state_symbol>(
                  (size_4_num & 0x00000000ffff0000LL) +
                      (num & 0x000000000000ffffLL),
                  4);
        }
        // eax是一个符号，symbol是数字
        else {
          std::vector<std::string> new_taine_vector;
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_4_symbol->get_taine_str().begin(),
          //                           size_4_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().begin(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
          // } else {
          //   new_size_4_symbol->_size_32_symbol =
          //   size_4_symbol->_size_32_symbol;
          // }
          {
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_4_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12D, 4)] =
              new_size_4_symbol;
        }

        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12, 8)] =
              std::make_shared<state_symbol>((rax_num & 0xffffffffffff0000LL) +
                                                 (num & 0x000000000000ffffLL),
                                             8);
        } else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12, 8)] =
              new_size_8_symbol;
        }
        //
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12W, 2)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12B, 1)] =
              symbol_xl_size;
        }

      } else {
        // 先生成eax
        std::shared_ptr<state_symbol> new_size_4_symbol;
        std::shared_ptr<state_symbol> new_size_8_symbol;
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            // if (size_4_symbol->_size_32_symbol == nullptr) {
            //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
            // } else {
            //   new_size_4_symbol->_size_32_symbol =
            //       size_4_symbol->_size_32_symbol;
            // }
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12D, 4)] =
              new_size_4_symbol;
        }

        {
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            // if (size_8_symbol->_size_64_symbol == nullptr) {
            //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
            // } else {
            //   new_size_8_symbol->_size_64_symbol =
            //       size_8_symbol->_size_64_symbol;
            // }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol->_size_16_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R12W, 2)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R12B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R13W: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R13,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R13D,
                                                                  4));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
        //设置相关寄存器
        state_symbol::ptr new_size_4_symbol;
        if (size_4_symbol->is_num()) {
          uint64_t size_4_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13D, 4)] =
              std::make_shared<state_symbol>(
                  (size_4_num & 0x00000000ffff0000LL) +
                      (num & 0x000000000000ffffLL),
                  4);
        }
        // eax是一个符号，symbol是数字
        else {
          std::vector<std::string> new_taine_vector;
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_4_symbol->get_taine_str().begin(),
          //                           size_4_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().begin(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
          // } else {
          //   new_size_4_symbol->_size_32_symbol =
          //   size_4_symbol->_size_32_symbol;
          // }
          {
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_4_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13D, 4)] =
              new_size_4_symbol;
        }

        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13, 8)] =
              std::make_shared<state_symbol>((rax_num & 0xffffffffffff0000LL) +
                                                 (num & 0x000000000000ffffLL),
                                             8);
        } else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13, 8)] =
              new_size_8_symbol;
        }
        //
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13W, 2)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13B, 1)] =
              symbol_xl_size;
        }

      } else {
        // 先生成eax
        std::shared_ptr<state_symbol> new_size_4_symbol;
        std::shared_ptr<state_symbol> new_size_8_symbol;
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            // if (size_4_symbol->_size_32_symbol == nullptr) {
            //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
            // } else {
            //   new_size_4_symbol->_size_32_symbol =
            //       size_4_symbol->_size_32_symbol;
            // }
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13D, 4)] =
              new_size_4_symbol;
        }

        {
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            // if (size_8_symbol->_size_64_symbol == nullptr) {
            //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
            // } else {
            //   new_size_8_symbol->_size_64_symbol =
            //       size_8_symbol->_size_64_symbol;
            // }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol->_size_16_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R13W, 2)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R13B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R14W: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R14,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R14D,
                                                                  4));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
        //设置相关寄存器
        state_symbol::ptr new_size_4_symbol;
        if (size_4_symbol->is_num()) {
          uint64_t size_4_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14D, 4)] =
              std::make_shared<state_symbol>(
                  (size_4_num & 0x00000000ffff0000LL) +
                      (num & 0x000000000000ffffLL),
                  4);
        }
        // eax是一个符号，symbol是数字
        else {
          std::vector<std::string> new_taine_vector;
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_4_symbol->get_taine_str().begin(),
          //                           size_4_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().begin(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
          // } else {
          //   new_size_4_symbol->_size_32_symbol =
          //   size_4_symbol->_size_32_symbol;
          // }
          {
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_4_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14D, 4)] =
              new_size_4_symbol;
        }

        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14, 8)] =
              std::make_shared<state_symbol>((rax_num & 0xffffffffffff0000LL) +
                                                 (num & 0x000000000000ffffLL),
                                             8);
        } else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14, 8)] =
              new_size_8_symbol;
        }
        //
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14W, 2)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14B, 1)] =
              symbol_xl_size;
        }

      } else {
        // 先生成eax
        std::shared_ptr<state_symbol> new_size_4_symbol;
        std::shared_ptr<state_symbol> new_size_8_symbol;
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            // if (size_4_symbol->_size_32_symbol == nullptr) {
            //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
            // } else {
            //   new_size_4_symbol->_size_32_symbol =
            //       size_4_symbol->_size_32_symbol;
            // }
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14D, 4)] =
              new_size_4_symbol;
        }

        {
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            // if (size_8_symbol->_size_64_symbol == nullptr) {
            //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
            // } else {
            //   new_size_8_symbol->_size_64_symbol =
            //       size_8_symbol->_size_64_symbol;
            // }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol->_size_16_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R14W, 2)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R14B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_R15W: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R15,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R15D,
                                                                  4));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        std::shared_ptr<state_symbol> symbol_xh_size =
            std::make_shared<state_symbol>((num & 0x000000000000ff00LL) >> 8,
                                           1);
        std::shared_ptr<state_symbol> symbol_xl_size =
            std::make_shared<state_symbol>(num & 0x00000000000000ffLL, 1);
        //设置相关寄存器
        state_symbol::ptr new_size_4_symbol;
        if (size_4_symbol->is_num()) {
          uint64_t size_4_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15D, 4)] =
              std::make_shared<state_symbol>(
                  (size_4_num & 0x00000000ffff0000LL) +
                      (num & 0x000000000000ffffLL),
                  4);
        }
        // eax是一个符号，symbol是数字
        else {
          std::vector<std::string> new_taine_vector;
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_4_symbol->get_taine_str().begin(),
          //                           size_4_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().begin(),
          //       size_4_symbol->_size_32_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
          // } else {
          //   new_size_4_symbol->_size_32_symbol =
          //   size_4_symbol->_size_32_symbol;
          // }
          {
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_4_symbol->_size_xl_symbol = symbol_xl_size;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15D, 4)] =
              new_size_4_symbol;
        }

        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15, 8)] =
              std::make_shared<state_symbol>((rax_num & 0xffffffffffff0000LL) +
                                                 (num & 0x000000000000ffffLL),
                                             8);
        } else {
          // 使用原本的污点信息新建一个符号,
          std::vector<std::string> new_taine_vector;
          // 原rax没有被覆盖
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_taine_vector.insert(new_taine_vector.end(),
          //                           size_8_symbol->get_taine_str().begin(),
          //                           size_8_symbol->get_taine_str().end());
          // } else {
          //   new_taine_vector.insert(
          //       new_taine_vector.end(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().begin(),
          //       size_8_symbol->_size_64_symbol->get_taine_str().end());
          // }
          distinct_taine_str(new_taine_vector);
          state_symbol::ptr new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_taine_vector);

          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
          // } else {
          //   new_size_8_symbol->_size_64_symbol =
          //   size_8_symbol->_size_64_symbol;
          // }
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol;
            new_size_8_symbol->_size_xh_symbol = symbol_xh_size;
            new_size_8_symbol->_size_xl_symbol = symbol_xl_size;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15, 8)] =
              new_size_8_symbol;
        }
        //
        {
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15W, 2)] =
              symbol;
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15B, 1)] =
              symbol_xl_size;
        }

      } else {
        // 先生成eax
        std::shared_ptr<state_symbol> new_size_4_symbol;
        std::shared_ptr<state_symbol> new_size_8_symbol;
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          // if (size_4_symbol->_size_32_symbol == nullptr) {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_4_taine_str.insert(
          //       new_size_4_taine_str.end(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
          //       size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            // if (size_4_symbol->_size_32_symbol == nullptr) {
            //   new_size_4_symbol->_size_32_symbol = size_4_symbol;
            // } else {
            //   new_size_4_symbol->_size_32_symbol =
            //       size_4_symbol->_size_32_symbol;
            // }
            new_size_4_symbol->_size_16_symbol = symbol;
            new_size_4_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15D, 4)] =
              new_size_4_symbol;
        }

        {
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          // if (size_8_symbol->_size_64_symbol == nullptr) {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_taine_effect_vector.end());
          // } else {
          //   new_size_8_taine_str.insert(
          //       new_size_8_taine_str.end(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
          //       size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          // }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            // if (size_8_symbol->_size_64_symbol == nullptr) {
            //   new_size_8_symbol->_size_64_symbol = size_8_symbol;
            // } else {
            //   new_size_8_symbol->_size_64_symbol =
            //       size_8_symbol->_size_64_symbol;
            // }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = symbol->_size_16_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol->_size_xl_symbol;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R15W, 2)] =
            symbol;
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R15B, 1)] =
            symbol->_size_xl_symbol;
      }
      break;
    }
    case X86_REG_AH: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RAX,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EAX,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AX,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_AX, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = symbol;
            new_size_2_symbol->_size_xl_symbol = size_2_symbol->_size_xl_symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_AX, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EAX, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = symbol;
            new_size_4_symbol->_size_xl_symbol = size_4_symbol->_size_xl_symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EAX, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RAX, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol;
            new_size_8_symbol->_size_xl_symbol = size_8_symbol->_size_xl_symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RAX, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_AH, 1)] = symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = symbol;
            new_size_2_symbol->_size_xl_symbol = size_2_symbol->_size_xl_symbol;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_AX, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = symbol;
            new_size_4_symbol->_size_xl_symbol = size_4_symbol->_size_xl_symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EAX, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol;
            new_size_8_symbol->_size_xl_symbol = size_8_symbol->_size_xl_symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RAX, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_AH, 1)] = symbol;
      }
      break;
    }
    case X86_REG_CH: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RCX,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_ECX,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_CX,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_CX, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = symbol;
            new_size_2_symbol->_size_xl_symbol = size_2_symbol->_size_xl_symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_CX, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ECX, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = symbol;
            new_size_4_symbol->_size_xl_symbol = size_4_symbol->_size_xl_symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ECX, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RCX, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol;
            new_size_8_symbol->_size_xl_symbol = size_8_symbol->_size_xl_symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RCX, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_CH, 1)] = symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = symbol;
            new_size_2_symbol->_size_xl_symbol = size_2_symbol->_size_xl_symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_CX, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = symbol;
            new_size_4_symbol->_size_xl_symbol = size_4_symbol->_size_xl_symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ECX, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol;
            new_size_8_symbol->_size_xl_symbol = size_8_symbol->_size_xl_symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RCX, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_CH, 1)] = symbol;
      }
      break;
    }
    case X86_REG_DH: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RDX,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EDX,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DX,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DX, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = symbol;
            new_size_2_symbol->_size_xl_symbol = size_2_symbol->_size_xl_symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DX, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EDX, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = symbol;
            new_size_4_symbol->_size_xl_symbol = size_4_symbol->_size_xl_symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EDX, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDX, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol;
            new_size_8_symbol->_size_xl_symbol = size_8_symbol->_size_xl_symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDX, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DH, 1)] = symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = symbol;
            new_size_2_symbol->_size_xl_symbol = size_2_symbol->_size_xl_symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DX, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = symbol;
            new_size_4_symbol->_size_xl_symbol = size_4_symbol->_size_xl_symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EDX, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol;
            new_size_8_symbol->_size_xl_symbol = size_8_symbol->_size_xl_symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDX, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DH, 1)] = symbol;
      }
      break;
    }
    case X86_REG_BH: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RBX,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EBX,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_BX,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BX, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = symbol;
            new_size_2_symbol->_size_xl_symbol = size_2_symbol->_size_xl_symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BX, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EBX, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = symbol;
            new_size_4_symbol->_size_xl_symbol = size_4_symbol->_size_xl_symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EBX, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBX, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol;
            new_size_8_symbol->_size_xl_symbol = size_8_symbol->_size_xl_symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBX, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BH, 1)] = symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = symbol;
            new_size_2_symbol->_size_xl_symbol = size_2_symbol->_size_xl_symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BX, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = symbol;
            new_size_4_symbol->_size_xl_symbol = size_4_symbol->_size_xl_symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EBX, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = symbol;
            new_size_8_symbol->_size_xl_symbol = size_8_symbol->_size_xl_symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBX, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BH, 1)] = symbol;
      }
      break;
    }
    case X86_REG_AL: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RAX,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EAX,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AX,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_AX, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_AX, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EAX, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EAX, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RAX, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RAX, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_AL, 1)] = symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_2_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_2_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_AX, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EAX, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RAX, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_AL, 1)] = symbol;
      }
      break;
    }
    case X86_REG_CL: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RCX,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_ECX,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_CX,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_CX, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_CX, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ECX, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ECX, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RCX, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RCX, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_CL, 1)] = symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_2_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_2_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_CX, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ECX, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RCX, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_CL, 1)] = symbol;
      }
      break;
    }
    case X86_REG_DL: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RDX,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EDX,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DX,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DX, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DX, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EDX, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EDX, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDX, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDX, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DL, 1)] = symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_2_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_2_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DX, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EDX, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDX, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DL, 1)] = symbol;
      }
      break;
    }
    case X86_REG_BL: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RBX,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EBX,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_BX,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BX, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BX, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EBX, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EBX, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBX, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBX, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BL, 1)] = symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_2_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_2_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BX, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EBX, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBX, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BL, 1)] = symbol;
      }
      break;
    }
    case X86_REG_SIL: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RSI,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_ESI,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_SI,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_SI, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_SI, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ESI, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ESI, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RSI, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RSI, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SIL, 1)] =
            symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_2_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_2_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_SI, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ESI, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RSI, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SIL, 1)] =
            symbol;
      }
      break;
    }
    case X86_REG_DIL: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RDI,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EDI,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DI,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DI, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DI, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EDI, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EDI, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDI, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDI, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DIL, 1)] =
            symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_2_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_2_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_DI, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EDI, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RDI, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_DIL, 1)] =
            symbol;
      }
      break;
    }
    case X86_REG_SPL: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RSP,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_ESP,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_SP,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_SP, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_SP, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ESP, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ESP, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RSP, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RSP, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SPL, 1)] =
            symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_2_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_2_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_SP, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_ESP, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RSP, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_SPL, 1)] =
            symbol;
      }
      break;
    }
    case X86_REG_BPL: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RBP,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EBP,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_BP,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BP, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BP, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EBP, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EBP, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBP, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBP, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BPL, 1)] =
            symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_2_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_2_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_BP, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_EBP, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RBP, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_BPL, 1)] =
            symbol;
      }
      break;
    }
    case X86_REG_R8B: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R8,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R8D,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R8W,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8W, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8W, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8D, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8D, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R8B, 1)] =
            symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_2_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_2_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8W, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8D, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R8, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R8B, 1)] =
            symbol;
      }
      break;
    }
    case X86_REG_R9B: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R9,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R9D,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R9W,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9W, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9W, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9D, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9D, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R9B, 1)] =
            symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_2_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_2_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9W, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9D, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R9, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R9B, 1)] =
            symbol;
      }
      break;
    }
    case X86_REG_R10B: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R10,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R10D,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R10W,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10W, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10W, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10D, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10D, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R10B, 1)] =
            symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_2_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_2_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10W, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10D, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R10, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R10B, 1)] =
            symbol;
      }
      break;
    }
    case X86_REG_R11B: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R11,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R11D,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R11W,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11W, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11W, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11D, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11D, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R11B, 1)] =
            symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_2_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_2_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11W, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11D, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R11, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R11B, 1)] =
            symbol;
      }
      break;
    }
    case X86_REG_R12B: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R12,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R12D,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R12W,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12W, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12W, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12D, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12D, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R12B, 1)] =
            symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_2_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_2_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12W, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12D, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R12, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R12B, 1)] =
            symbol;
      }
      break;
    }
    case X86_REG_R13B: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R13,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R13D,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R13W,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13W, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13W, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13D, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13D, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R13B, 1)] =
            symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_2_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_2_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13W, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13D, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R13, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R13B, 1)] =
            symbol;
      }
      break;
    }
    case X86_REG_R14B: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R14,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R14D,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R14W,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14W, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14W, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14D, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14D, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R14B, 1)] =
            symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_2_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_2_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14W, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14D, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R14, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R14B, 1)] =
            symbol;
      }
      break;
    }
    case X86_REG_R15B: {
      //获取源rax的符号
      state_symbol::ptr size_8_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R15,
                                                                  8));
      state_symbol::ptr size_4_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R15D,
                                                                  4));
      state_symbol::ptr size_2_symbol =
          _state_machine_ptr->get_symbol_from_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R15W,
                                                                  2));
      if (symbol->is_num()) {
        uint64_t num = symbol->to_int();
        // 设置相关寄存器
        // ax
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        if (size_2_symbol->is_num()) {
          uint64_t ax_num = size_2_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15W, 2)] =
              std::make_shared<state_symbol>(
                  (ax_num & 0x00000000000000ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  2);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_2_symbol->get_taine_str().begin(),
                                    size_2_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_2_symbol->_size_16_symbol->get_taine_str().begin(),
                size_2_symbol->_size_16_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_taine_vector);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15W, 2)];
        }
        // eax
        if (size_4_symbol->is_num()) {
          uint64_t eax_num = size_4_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15D, 4)] =
              std::make_shared<state_symbol>(
                  (eax_num & 0x00000000ffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  4);
        } else {
          std::vector<std::string> new_taine_vector;
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_taine_vector.insert(new_taine_vector.end(),
                                    size_4_symbol->get_taine_str().begin(),
                                    size_4_symbol->get_taine_str().end());
          } else {
            new_taine_vector.insert(
                new_taine_vector.end(),
                size_4_symbol->_size_32_symbol->get_taine_str().begin(),
                size_4_symbol->_size_32_symbol->get_taine_str().end());
          }
          distinct_taine_str(new_taine_vector);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_taine_vector);
          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_symbol->_size_32_symbol = size_4_symbol;
          } else {
            new_size_4_symbol->_size_32_symbol = size_4_symbol->_size_32_symbol;
          }
          {
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15D, 4)] =
              new_size_4_symbol;
        }
        // rax
        if (size_8_symbol->is_num()) {
          uint64_t rax_num = size_8_symbol->to_int();
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15, 8)] =
              std::make_shared<state_symbol>(
                  (rax_num & 0xffffffffffff00ffLL) +
                      ((num & 0x00000000000000ffLL) << 8),
                  8);
        } else {
          state_symbol::ptr new_size_8_symbol;
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_symbol->_size_64_symbol = size_8_symbol;
          } else {
            new_size_8_symbol->_size_64_symbol = size_8_symbol->_size_64_symbol;
          }
          // 重建新符号的各可拆分寄存器
          {
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }

          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15, 8)] =
              new_size_8_symbol;
        }

        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R15B, 1)] =
            symbol;
      } else {
        state_symbol::ptr new_size_4_symbol;
        state_symbol::ptr new_size_2_symbol;
        // ax
        {
          std::vector<std::string> new_size_2_taine_str =
              symbol->_taine_effect_vector;
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_taine_effect_vector.end());
          } else {
            new_size_2_taine_str.insert(
                new_size_2_taine_str.end(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.begin(),
                size_2_symbol->_size_16_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_2_taine_str);
          new_size_2_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 2, new_size_2_taine_str);
          if (size_2_symbol->_size_16_symbol == nullptr) {
            new_size_2_symbol->_size_16_symbol = size_2_symbol;
          } else {
            new_size_2_symbol->_size_16_symbol = size_2_symbol->_size_16_symbol;
          }
          {
            new_size_2_symbol->_size_xh_symbol = size_2_symbol->_size_xh_symbol;
            new_size_2_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_2_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_2_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_2_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15W, 2)] =
              new_size_2_symbol;
        }
        // eax
        {
          std::vector<std::string> new_size_4_taine_str =
              symbol->_taine_effect_vector;

          if (size_4_symbol->_size_32_symbol == nullptr) {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_taine_effect_vector.end());
          } else {
            new_size_4_taine_str.insert(
                new_size_4_taine_str.end(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.begin(),
                size_4_symbol->_size_32_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_4_taine_str);
          new_size_4_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 4, new_size_4_taine_str);
          {
            if (size_4_symbol->_size_32_symbol == nullptr) {
              new_size_4_symbol->_size_32_symbol = size_4_symbol;
            } else {
              new_size_4_symbol->_size_32_symbol =
                  size_4_symbol->_size_32_symbol;
            }
            new_size_4_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_4_symbol->_size_xh_symbol = size_4_symbol->_size_xh_symbol;
            new_size_4_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_4_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_4_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_4_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15D, 4)] =
              new_size_4_symbol;
        }
        // rax
        {
          state_symbol::ptr new_size_8_symbol;
          // 生成新符号的污点信息
          std::vector<std::string> new_size_8_taine_str =
              symbol->_taine_effect_vector;
          if (size_8_symbol->_size_64_symbol == nullptr) {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_taine_effect_vector.end());
          } else {
            new_size_8_taine_str.insert(
                new_size_8_taine_str.end(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.begin(),
                size_8_symbol->_size_64_symbol->_taine_effect_vector.end());
          }
          distinct_taine_str(new_size_8_taine_str);
          new_size_8_symbol = std::make_shared<state_symbol>(
              get_symbol_str(_random, _dist), 8, new_size_8_taine_str);
          // 重建新符号的各可拆分寄存器
          {
            if (size_8_symbol->_size_64_symbol == nullptr) {
              new_size_8_symbol->_size_64_symbol = size_8_symbol;
            } else {
              new_size_8_symbol->_size_64_symbol =
                  size_8_symbol->_size_64_symbol;
            }
            new_size_8_symbol->_size_32_symbol = new_size_4_symbol;
            new_size_8_symbol->_size_16_symbol = new_size_2_symbol;
            new_size_8_symbol->_size_xh_symbol = size_8_symbol->_size_xh_symbol;
            new_size_8_symbol->_size_xl_symbol = symbol;
          }
          if (symbol->get_symbol_mem_effect()) {
            new_size_8_symbol->_mem_effect = true;
          }
          if (symbol->get_can_up_taine_lv()) {
            new_size_8_symbol->_can_up_taine_level = true;
          }
          if (symbol->_taine2_with_mul_or_left_shift) {
            new_size_8_symbol->_taine2_with_mul_or_left_shift = true;
          }
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_R15, 8)] =
              new_size_8_symbol;
        }
        //
        _state_machine_ptr
            ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                   ->get_abstract_addr(X86_REG_R15B, 1)] =
            symbol;
      }
      break;
    }
    default: {
      _state_machine_ptr->_addr_symbol_map[target_addr] = symbol;
      break;
    }
  }
}

std::pair<uint64_t, analyze_result>
instruction_analyze_tool::analyze_instruction(
    const cs_insn &insn, char exec, bool error_path, bool control_leak_state,
    char exec_mode, bool is_cmp_location, bool is_cache_miss_location,
    std::map<abstract_addr::ptr, state_symbol::ptr> &analyze_addr_taine_map,
    bool is_32) {
  // lock前缀
  if (insn.detail->x86.prefix[0] == X86_PREFIX_LOCK) {
    return std::make_pair(-1, analyze_result::NO_ATTACT);
  }
  //提前获取flag的地址
  abstract_flags::ptr cf, zf, sf, of, pf, af, df;
  {
    cf = _generatr_abstract_addr_tool_ptr->get_abstract_flag(rflags::cf);
    zf = _generatr_abstract_addr_tool_ptr->get_abstract_flag(rflags::zf);
    sf = _generatr_abstract_addr_tool_ptr->get_abstract_flag(rflags::sf);
    of = _generatr_abstract_addr_tool_ptr->get_abstract_flag(rflags::of);
    pf = _generatr_abstract_addr_tool_ptr->get_abstract_flag(rflags::pf);
    af = _generatr_abstract_addr_tool_ptr->get_abstract_flag(rflags::af);
    df = _generatr_abstract_addr_tool_ptr->get_abstract_flag(rflags::df);
  }

  //更新rip寄存器
  u_int64_t rip;
  {
    rip = insn.address;
    set_target_symbol(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RIP, 8),
        std::make_shared<state_symbol>(rip, 8));
  }

  std::string key = insn.mnemonic;
  if (!instruction_type::type_str_map.count(key)) {
    return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
  }
  if (exec_mode != 0 && is_cache_miss_location) {
    return std::make_pair(0, analyze_result::NO_ATTACT);
  }
  instruction_type::type type = instruction_type::type_str_map.at(key);
  switch (type) {
    case instruction_type::type::movs: {
      //分析源操作数
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::movsb: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::movsw: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::mov: {
      //分析源操作数
      //源操作数的抽象地址
      abstract_addr::ptr source_addr = nullptr;
      //源操作数的抽象地址对应的符号
      state_symbol::ptr source_symbol = nullptr;
      char source_type =
          analyze_operator(insn.detail->x86.operands[1], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      //对取得的结果进行处理
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      //分析目标操作数
      abstract_addr::ptr target_addr = nullptr;
      state_symbol::ptr target_symbol = nullptr;
      char target_type =
          analyze_operator(insn.detail->x86.operands[0], target_addr,
                           target_symbol, false, control_leak_state, exec_mode);
      if (target_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (target_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      // cache miss 的情况下记录cache miss产生的污点符号
      if (exec_mode == 0 && is_cache_miss_location) {
        _state_machine_ptr->_cache_miss_symbol_vector.push_back(source_symbol);
      }
      //设置目标操作数的符号
      set_target_symbol(target_addr, source_symbol);
      break;
    }
    case instruction_type::type::movsxd: {
      //分析源操作数
      //源操作数的抽象地址
      abstract_addr::ptr source_addr = nullptr;
      //源操作数的抽象地址对应的符号
      state_symbol::ptr source_symbol = nullptr;
      uint64_t source_num;
      char source_type =
          analyze_operator(insn.detail->x86.operands[1], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      if (source_symbol->is_num()) {
        source_num = source_symbol->to_int();
        source_num &= 0xffffffffLL;
        if (source_num >> 31 > 0) {
          source_num |= 0xffffffff00000000LL;
        }
        source_symbol = std::make_shared<state_symbol>(source_num, 8);
      }
      // 源操作数是一个符号
      else {
        state_symbol::ptr old_source_symbol = source_symbol;
        source_symbol = std::make_shared<state_symbol>(old_source_symbol);
        source_symbol->set_symbol_size(8);
        source_symbol->_size_32_symbol = old_source_symbol;
      }
      //分析目标操作数
      abstract_addr::ptr target_addr = nullptr;
      state_symbol::ptr target_symbol = nullptr;
      char target_type =
          analyze_operator(insn.detail->x86.operands[0], target_addr,
                           target_symbol, false, control_leak_state, exec_mode);
      if (target_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (target_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      // branch miss 的情况下记录branchs miss产生的污点符号
      if (exec_mode == 0 && is_cache_miss_location) {
        _state_machine_ptr->_cache_miss_symbol_vector.push_back(source_symbol);
      }
      //设置目标操作数的符号
      set_target_symbol(target_addr, source_symbol);
      break;
    }
    case instruction_type::type::movzx: {
      //分析源操作数
      //源操作数的抽象地址
      abstract_addr::ptr source_addr = nullptr;
      //源操作数的抽象地址对应的符号
      state_symbol::ptr source_symbol = nullptr;
      char source_type =
          analyze_operator(insn.detail->x86.operands[1], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      //分析目标操作数
      abstract_addr::ptr target_addr = nullptr;
      state_symbol::ptr target_symbol = nullptr;
      char target_type =
          analyze_operator(insn.detail->x86.operands[0], target_addr,
                           target_symbol, false, control_leak_state, exec_mode);
      if (!source_symbol->is_num()) {
        // 目标操作数的大小
        switch (insn.detail->x86.operands[0].size) {
          case 8: {
            // 32 >> 64
            if (source_symbol->get_symbol_size() == 4) {
              state_symbol::ptr old_source_symbol = source_symbol;
              source_symbol = std::make_shared<state_symbol>(old_source_symbol);
              source_symbol->set_symbol_size(8);
              source_symbol->_size_32_symbol = old_source_symbol;
            }
            // 16 >> 64
            else if (source_symbol->get_symbol_size() == 2) {
              state_symbol::ptr old_source_symbol = source_symbol;
              source_symbol = std::make_shared<state_symbol>(old_source_symbol);
              source_symbol->set_symbol_size(8);
              source_symbol->_size_16_symbol = old_source_symbol;

              source_symbol->_size_32_symbol =
                  std::make_shared<state_symbol>(old_source_symbol);
              source_symbol->_size_32_symbol->set_symbol_size(4);
              source_symbol->_size_32_symbol->_size_16_symbol =
                  old_source_symbol;
            }
            // 8 >> 64
            else if (source_symbol->get_symbol_size() == 1) {
              state_symbol::ptr old_source_symbol = source_symbol;
              // 新的符号
              source_symbol = std::make_shared<state_symbol>(old_source_symbol);
              source_symbol->set_symbol_size(8);
              // xl xh
              source_symbol->_size_xl_symbol = old_source_symbol;
              source_symbol->_size_xh_symbol =
                  std::make_shared<state_symbol>(0, 1);
              // xx
              source_symbol->_size_16_symbol =
                  std::make_shared<state_symbol>(old_source_symbol);
              source_symbol->_size_16_symbol->set_symbol_size(2);
              source_symbol->_size_16_symbol->_size_xh_symbol =
                  source_symbol->_size_xh_symbol;
              source_symbol->_size_16_symbol->_size_xl_symbol =
                  source_symbol->_size_xl_symbol;
              // exx
              source_symbol->_size_32_symbol =
                  std::make_shared<state_symbol>(old_source_symbol);
              source_symbol->_size_32_symbol->set_symbol_size(4);
              source_symbol->_size_32_symbol->_size_16_symbol =
                  source_symbol->_size_16_symbol;
              source_symbol->_size_32_symbol->_size_xh_symbol =
                  source_symbol->_size_xh_symbol;
              source_symbol->_size_32_symbol->_size_xl_symbol =
                  source_symbol->_size_xl_symbol;
            }
            break;
          }
          case 4: {
            if (source_symbol->get_symbol_size() == 2) {
              state_symbol::ptr old_source_symbol = source_symbol;
              source_symbol = std::make_shared<state_symbol>(old_source_symbol);
              source_symbol->set_symbol_size(4);
              source_symbol->_size_16_symbol = old_source_symbol;
            } else if (source_symbol->get_symbol_size() == 1) {
              state_symbol::ptr old_source_symbol = source_symbol;
              // 新的符号
              source_symbol = std::make_shared<state_symbol>(old_source_symbol);
              source_symbol->set_symbol_size(4);
              // xl xh
              source_symbol->_size_xl_symbol = old_source_symbol;
              source_symbol->_size_xh_symbol =
                  std::make_shared<state_symbol>(0, 1);
              // xx
              source_symbol->_size_16_symbol =
                  std::make_shared<state_symbol>(old_source_symbol);
              source_symbol->_size_16_symbol->set_symbol_size(2);
              source_symbol->_size_16_symbol->_size_xh_symbol =
                  source_symbol->_size_xh_symbol;
              source_symbol->_size_16_symbol->_size_xl_symbol =
                  source_symbol->_size_xl_symbol;
            }
            break;
          }
          case 2: {
            state_symbol::ptr old_source_symbol = source_symbol;
            source_symbol = std::make_shared<state_symbol>(old_source_symbol);
            source_symbol->set_symbol_size(2);
            source_symbol->_size_xh_symbol =
                std::make_shared<state_symbol>(0, 1);
            break;
          } break;
        }
      }
      source_symbol->set_symbol_size(insn.detail->x86.operands[0].size);
      if (target_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (target_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      // branch miss 的情况下记录branchs miss产生的污点符号
      if (exec_mode == 0 && is_cache_miss_location) {
        _state_machine_ptr->_cache_miss_symbol_vector.push_back(source_symbol);
      }
      //设置目标操作数的符号
      set_target_symbol(target_addr, source_symbol);
      break;
    }
    case instruction_type::type::movzbl: {
      //分析源操作数
      //源操作数的抽象地址
      abstract_addr::ptr source_addr = nullptr;
      //源操作数的抽象地址对应的符号
      state_symbol::ptr source_symbol = nullptr;
      char source_type =
          analyze_operator(insn.detail->x86.operands[1], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      //分析目标操作数
      abstract_addr::ptr target_addr = nullptr;
      state_symbol::ptr target_symbol = nullptr;
      char target_type =
          analyze_operator(insn.detail->x86.operands[0], target_addr,
                           target_symbol, false, control_leak_state, exec_mode);

      if (target_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (target_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      //设置目标操作数的符号
      {
        if (!source_symbol->is_num()) {
          state_symbol::ptr old_source_symbol = source_symbol;
          // 新的符号
          source_symbol = std::make_shared<state_symbol>(old_source_symbol);

          // xl xh
          source_symbol->_size_xl_symbol = old_source_symbol;
          source_symbol->_size_xh_symbol = std::make_shared<state_symbol>(0, 1);
          // xx
          source_symbol->_size_16_symbol =
              std::make_shared<state_symbol>(old_source_symbol);
          source_symbol->_size_16_symbol->set_symbol_size(2);
          source_symbol->_size_16_symbol->_size_xh_symbol =
              source_symbol->_size_xh_symbol;
          source_symbol->_size_16_symbol->_size_xl_symbol =
              source_symbol->_size_xl_symbol;
        }
      }
      source_symbol->set_symbol_size(4);
      // branch miss 的情况下记录branchs miss产生的污点符号
      if (exec_mode == 0 && is_cache_miss_location) {
        _state_machine_ptr->_cache_miss_symbol_vector.push_back(source_symbol);
      }
      set_target_symbol(target_addr, source_symbol);
      break;
    }
    case instruction_type::type::aaa: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      {
        // //调整al和ah的值均属于RAX
        // 因此不需要更改RAX的内容，仅需要修改标志寄存器 abstract_addr::ptr
        // source_addr; state_symbol::ptr source_symbol; cs_x86_op source =
        // cs_x86_op(); source.type = X86_OP_REG; source.reg = X86_REG_RAX;
        // analyze_operator(insn.detail->x86.operands[0], source_addr,
        // source_symbol,
        //                  true,exec_mode);
        // //是一个数字的情况下
        // if (source_symbol->is_num()) {
        //   uint64_t value = source_symbol->to_int();
        //   unsigned int tmp = value & 0xffLL;
        //   if (tmp >= 0 && tmp <= 9) {
        //     value = value & 0xffffffffffff00ffLL;
        //     abstract_flags::ptr cf =
        //         _generatr_abstract_addr_tool_ptr->get_abstract_flag(rflags::cf);
        //     _state_machine_ptr->_flag_symbol_map[cf] =
        //         std::make_shared<state_symbol>(0, 1);
        //     abstract_flags::ptr af =
        //         _generatr_abstract_addr_tool_ptr->get_abstract_flag(rflags::af);
        //     _state_machine_ptr->_flag_symbol_map[af] =
        //         std::make_shared<state_symbol>(0, 1);
        //   } else {
        //     tmp = (tmp + 6) & 0xffLL;
        //     value = value & 0xffffffffffffff00LL + tmp;
        //     value += 1 << 8;
        //     abstract_flags::ptr cf =
        //         _generatr_abstract_addr_tool_ptr->get_abstract_flag(rflags::cf);
        //     _state_machine_ptr->_flag_symbol_map[cf] =
        //         std::make_shared<state_symbol>(1, 1);
        //     abstract_flags::ptr af =
        //         _generatr_abstract_addr_tool_ptr->get_abstract_flag(rflags::af);
        //     _state_machine_ptr->_flag_symbol_map[af] =
        //         std::make_shared<state_symbol>(1, 1);
        //   }
        //   _state_machine_ptr->_addr_symbol_map[source_addr] =
        //       std::make_shared<state_symbol>(value, 64);
        // }
        // //非数字的情况下
        // else {
        //   abstract_flags::ptr cf =
        //       _generatr_abstract_addr_tool_ptr->get_abstract_flag(rflags::cf);
        //   _state_machine_ptr->_flag_symbol_map[cf] =
        //       std::make_shared<state_symbol>("unsure" +
        //       std::to_string(_random()),
        //                                      1);
        //   abstract_flags::ptr af =
        //       _generatr_abstract_addr_tool_ptr->get_abstract_flag(rflags::af);
        //   _state_machine_ptr->_flag_symbol_map[af] =
        //       std::make_shared<state_symbol>("unsure" +
        //       std::to_string(_random()),
        //                                      1);
        // }
      }
      break;
    }
    case instruction_type::type::aad: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::aam: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::aas: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::adc: {
      abstract_addr::ptr source_addr;
      abstract_addr::ptr target_addr;
      state_symbol::ptr source_symbol;
      state_symbol::ptr target_symbol;

      uint64_t source_num;
      uint64_t target_num;

      char source_type =
          analyze_operator(insn.detail->x86.operands[1], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);

      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      char target_type =
          analyze_operator(insn.detail->x86.operands[0], target_addr,
                           target_symbol, true, control_leak_state, exec_mode);
      if (target_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (target_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      state_symbol::ptr cf_symbol =
          _state_machine_ptr->_flag_symbol_map
              [_generatr_abstract_addr_tool_ptr->get_abstract_flag(rflags::cf)];
      state_symbol::ptr res_symbol = std::make_shared<state_symbol>(
          source_symbol->op_add(target_symbol).op_add(cf_symbol));

      res_symbol->set_symbol_size(insn.detail->x86.operands[0].size);
      // branch miss 的情况下记录branchs miss产生的污点符号
      if (exec_mode == 0 && is_cache_miss_location) {
        _state_machine_ptr->_cache_miss_symbol_vector.push_back(res_symbol);
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }
      set_target_symbol(target_addr, res_symbol);
      //运算过程中设置标志位暂时可能没有必要
      {
          // _state_machine_ptr->_flag_symbol_map[cf] =
          //     std::make_shared<state_symbol>("unsure" +
          //     std::to_string(_random()),
          //                                    1);
          // _state_machine_ptr->_flag_symbol_map[zf] =
          //     std::make_shared<state_symbol>("unsure" +
          //     std::to_string(_random()),
          //                                    1);
          // _state_machine_ptr->_flag_symbol_map[sf] =
          //     std::make_shared<state_symbol>("unsure" +
          //     std::to_string(_random()),
          //                                    1);
          // _state_machine_ptr->_flag_symbol_map[of] =
          //     std::make_shared<state_symbol>("unsure" +
          //     std::to_string(_random()),
          //                                    1);
          // _state_machine_ptr->_flag_symbol_map[pf] =
          //     std::make_shared<state_symbol>("unsure" +
          //     std::to_string(_random()),
          //                                    1);
          // _state_machine_ptr->_flag_symbol_map[af] =
          //     std::make_shared<state_symbol>("unsure" +
          //     std::to_string(_random()),
          //                                    1);
      }  //设置标志位
      {
        // if (res_symbol->is_num()) {
        //   uint64_t res_number = res_symbol->to_int();
        //   //具体运算设置标志位zf sf pf
        //   {
        //     switch (insn.detail->x86.operands[0].size) {
        //       case 64: {
        //         _state_machine_ptr->_flag_symbol_map[sf] =
        //             std::make_shared<state_symbol>(res_number >> 63, 1);
        //         _state_machine_ptr->_flag_symbol_map[zf] =
        //             std::make_shared<state_symbol>(res_number == 0 ? 1 : 0,
        //             1);
        //         _state_machine_ptr->_flag_symbol_map[pf] =
        //             std::make_shared<state_symbol>(
        //                 get_1_num(res_number) + 1 % 2, 1);
        //         break;
        //       }
        //       case 32: {
        //         _state_machine_ptr->_flag_symbol_map[sf] =
        //             std::make_shared<state_symbol>(
        //                 (res_number & 0xffffffffLL) >> 31, 1);
        //         _state_machine_ptr->_flag_symbol_map[zf] =
        //             std::make_shared<state_symbol>(
        //                 (res_number & 0xffffffffLL) == 0 ? 1 : 0, 1);
        //         _state_machine_ptr->_flag_symbol_map[pf] =
        //             std::make_shared<state_symbol>(
        //                 (get_1_num(res_number & 0xffffffffLL) + 1) % 2, 1);
        //         break;
        //       }
        //       case 16: {
        //         _state_machine_ptr->_flag_symbol_map[sf] =
        //             std::make_shared<state_symbol>((res_number & 0xffffLL) >>
        //             15,
        //                                            1);
        //         _state_machine_ptr->_flag_symbol_map[zf] =
        //             std::make_shared<state_symbol>(
        //                 (res_number & 0xffffLL) == 0 ? 1 : 0, 1);
        //         _state_machine_ptr->_flag_symbol_map[pf] =
        //             std::make_shared<state_symbol>(
        //                 (get_1_num(res_number & 0xffffLL)) + 1 % 2, 1);
        //         break;
        //       }
        //     }
        //   }
        //   //设置标志位 of cf 以及设置 8 位运算情况下的标志位
        //   if (target_symbol->is_num() && source_symbol->is_num()) {
        //     uint64_t target_number = target_symbol->to_int();
        //     uint64_t source_number = source_symbol->to_int();
        //     if (cf_symbol->to_int() == 1) {
        //       if (target_number != 0xffffffffffffffffLL) {
        //         ++target_number;
        //       } else if (source_number != 0xffffffffffffffffLL) {
        //         ++source_num;
        //       } else {
        //         _state_machine_ptr->_flag_symbol_map[cf] =
        //             std::make_shared<state_symbol>(1, 1);
        //         _state_machine_ptr->_flag_symbol_map[of] =
        //             std::make_shared<state_symbol>(1, 1);
        //       }
        //     }
        //     switch (insn.detail->x86.operands[0].size) {
        //       case 64: {
        //         _state_machine_ptr->_flag_symbol_map[cf] =
        //             std::make_shared<state_symbol>(
        //                 (0xffffffffffffffffLL - target_number) <
        //                 source_number
        //                     ? 1
        //                     : 0,
        //                 1);
        //         // source 与 target 同号的情况才有可能溢出，溢出的情况下
        //         if (!(judge_sign(source_number, 64) ^
        //               judge_sign(target_number, 64)) &&
        //             (judge_sign(source_number, 64) ^
        //              judge_sign(res_number, 64))) {
        //           _state_machine_ptr->_flag_symbol_map[of] =
        //               std::make_shared<state_symbol>(1, 1);
        //         } else {
        //           _state_machine_ptr->_flag_symbol_map[of] =
        //               std::make_shared<state_symbol>(0, 1);
        //         }
        //       }
        //       case 32: {
        //         _state_machine_ptr->_flag_symbol_map[cf] =
        //             std::make_shared<state_symbol>(
        //                 (target_number & 0xffffffffLL) <
        //                         (source_number & 0xffffffffLL)
        //                     ? 1
        //                     : 0,
        //                 1);
        //         if (!(judge_sign(source_number & 0xffffffffLL, 32) ^
        //               judge_sign(target_number & 0xffffffffLL, 32)) &&
        //             (judge_sign(source_number & 0xffffffffLL, 32) ^
        //              judge_sign(res_number & 0xffffffffLL, 32))) {
        //           _state_machine_ptr->_flag_symbol_map[of] =
        //               std::make_shared<state_symbol>(1, 1);
        //         } else {
        //           _state_machine_ptr->_flag_symbol_map[of] =
        //               std::make_shared<state_symbol>(0, 1);
        //         }
        //       }
        //       case 16: {
        //         _state_machine_ptr->_flag_symbol_map[cf] =
        //             std::make_shared<state_symbol>(
        //                 (target_number & 0xffffLL) < (source_number &
        //                 0xffffLL) ?
        //                 1
        //                                                                     : 0,
        //                 1);
        //         if (!(judge_sign(source_number & 0xffffLL, 16) ^
        //               judge_sign(target_number & 0xffffLL, 16)) &&
        //             (judge_sign(source_number & 0xffffLL, 16) ^
        //              judge_sign(res_number & 0xffffLL, 16))) {
        //           _state_machine_ptr->_flag_symbol_map[of] =
        //               std::make_shared<state_symbol>(1, 1);
        //         } else {
        //           _state_machine_ptr->_flag_symbol_map[of] =
        //               std::make_shared<state_symbol>(0, 1);
        //         }
        //       }
        //       case 8: {
        //         //重新生成
        //         {
        //           if (target_type == 0) {
        //             if (judge_xh(insn.detail->x86.operands[0].reg)) {
        //               target_number = (target_number & 0xff00LL) >> 8;
        //             } else {
        //               target_number &= 0xffLL;
        //             }
        //           } else {
        //             target_number &= 0xffLL;
        //           }
        //           if (source_number == 0) {
        //             if (judge_xh(insn.detail->x86.operands[1].reg)) {
        //               source_number = (source_number & 0xff00LL) >> 8;
        //             } else {
        //               source_number &= 0xffLL;
        //             }
        //           } else {
        //             source_number &= 0xffLL;
        //           }
        //           res_number = target_number - source_number;
        //         }
        //         _state_machine_ptr->_flag_symbol_map[sf] =
        //             std::make_shared<state_symbol>(res_number >> 7, 1);
        //         _state_machine_ptr->_flag_symbol_map[zf] =
        //             std::make_shared<state_symbol>(res_number == 0 ? 1 : 0,
        //             1);
        //         _state_machine_ptr->_flag_symbol_map[pf] =
        //             std::make_shared<state_symbol>(
        //                 (get_1_num(res_number) + 1) % 2, 1);

        //         _state_machine_ptr->_flag_symbol_map[cf] =
        //             std::make_shared<state_symbol>(
        //                 target_number < source_number ? 1 : 0, 1);
        //         if (!(judge_sign(source_number, 8) ^
        //               judge_sign(target_number, 8)) &&
        //             (judge_sign(source_number, 8) ^
        //              judge_sign(res_number, 8))) {
        //           _state_machine_ptr->_flag_symbol_map[of] =
        //               std::make_shared<state_symbol>(1, 1);
        //         } else {
        //           _state_machine_ptr->_flag_symbol_map[of] =
        //               std::make_shared<state_symbol>(0, 1);
        //         }
        //       }
        //     }
        //   }
        //   // 运算的双方不能转为int时
        //   else {
        //     //不为8 设置 of cf af 未知
        //     if (insn.detail->x86.operands[0].size != 8) {
        //       _state_machine_ptr->_flag_symbol_map[cf] =
        //           std::make_shared<state_symbol>(
        //               "unsure" + std::to_string(_random()), 1);

        //       _state_machine_ptr->_flag_symbol_map[of] =
        //           std::make_shared<state_symbol>(
        //               "unsure" + std::to_string(_random()), 1);

        //       _state_machine_ptr->_flag_symbol_map[af] =
        //           std::make_shared<state_symbol>(
        //               "unsure" + std::to_string(_random()), 1);
        //     }
        //     //为8 全部设为未知
        //     else {
        //       _state_machine_ptr->_flag_symbol_map[cf] =
        //           std::make_shared<state_symbol>(
        //               "unsure" + std::to_string(_random()), 1);
        //       _state_machine_ptr->_flag_symbol_map[zf] =
        //           std::make_shared<state_symbol>(
        //               "unsure" + std::to_string(_random()), 1);
        //       _state_machine_ptr->_flag_symbol_map[sf] =
        //           std::make_shared<state_symbol>(
        //               "unsure" + std::to_string(_random()), 1);
        //       _state_machine_ptr->_flag_symbol_map[of] =
        //           std::make_shared<state_symbol>(
        //               "unsure" + std::to_string(_random()), 1);
        //       _state_machine_ptr->_flag_symbol_map[pf] =
        //           std::make_shared<state_symbol>(
        //               "unsure" + std::to_string(_random()), 1);
        //       _state_machine_ptr->_flag_symbol_map[af] =
        //           std::make_shared<state_symbol>(
        //               "unsure" + std::to_string(_random()), 1);
        //     }
        //   }
        // } else {
        //   _state_machine_ptr->_flag_symbol_map[cf] =
        //       std::make_shared<state_symbol>(
        //           "unsure" + std::to_string(_random()), 1);
        //   _state_machine_ptr->_flag_symbol_map[zf] =
        //       std::make_shared<state_symbol>(
        //           "unsure" + std::to_string(_random()), 1);
        //   _state_machine_ptr->_flag_symbol_map[sf] =
        //       std::make_shared<state_symbol>(
        //           "unsure" + std::to_string(_random()), 1);
        //   _state_machine_ptr->_flag_symbol_map[of] =
        //       std::make_shared<state_symbol>(
        //           "unsure" + std::to_string(_random()), 1);
        //   _state_machine_ptr->_flag_symbol_map[pf] =
        //       std::make_shared<state_symbol>(
        //           "unsure" + std::to_string(_random()), 1);
        //   _state_machine_ptr->_flag_symbol_map[af] =
        //       std::make_shared<state_symbol>(
        //           "unsure" + std::to_string(_random()), 1);
        // }
      }

      break;
    }
    case instruction_type::type::add: {
      abstract_addr::ptr source_addr;
      abstract_addr::ptr target_addr;
      state_symbol::ptr source_symbol;
      state_symbol::ptr target_symbol;

      char source_type =
          analyze_operator(insn.detail->x86.operands[1], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);

      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      char target_type =
          analyze_operator(insn.detail->x86.operands[0], target_addr,
                           target_symbol, true, control_leak_state, exec_mode);
      if (target_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (target_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      state_symbol::ptr res_symbol =
          std::make_shared<state_symbol>(source_symbol->op_add(target_symbol));

      //只有一个数组访问才能够提升污点等级
      //数组访问需要一个基地址和一个偏移，也就是说明两个操作数之间必然有一个内存取值
      //一个足够大的数字也可以作为基地址
      if (!source_symbol->judge_taine_same(target_symbol) &&
          source_symbol->get_symbol_mem_effect() &&
          target_symbol->get_symbol_mem_effect()) {
        res_symbol->set_can_up_taine_lv_true();
      }
      int tmp = 0;
      if ((source_symbol->is_num() && source_symbol->to_int() > 0xfffff)) {
        ++tmp;
      }
      if ((target_symbol->is_num() && target_symbol->to_int() > 0xfffff)) {
        ++tmp;
      }
      if (tmp == 1 && (target_symbol->get_symbol_mem_effect() ||
                       source_symbol->get_symbol_mem_effect())) {
        res_symbol->set_can_up_taine_lv_true();
      }
      // branch miss 的情况下记录branchs miss产生的污点符号
      if (exec_mode == 0 && is_cache_miss_location) {
        _state_machine_ptr->_cache_miss_symbol_vector.push_back(res_symbol);
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }

      set_target_symbol(target_addr, res_symbol);

      //运算过程中设置标准位暂时可能没有必要
      {
          // _state_machine_ptr->_flag_symbol_map[cf] =
          //     std::make_shared<state_symbol>("unsure" +
          //     std::to_string(_random()),
          //                                    1);
          // _state_machine_ptr->_flag_symbol_map[zf] =
          //     std::make_shared<state_symbol>("unsure" +
          //     std::to_string(_random()),
          //                                    1);
          // _state_machine_ptr->_flag_symbol_map[sf] =
          //     std::make_shared<state_symbol>("unsure" +
          //     std::to_string(_random()),
          //                                    1);
          // _state_machine_ptr->_flag_symbol_map[of] =
          //     std::make_shared<state_symbol>("unsure" +
          //     std::to_string(_random()),
          //                                    1);
          // _state_machine_ptr->_flag_symbol_map[pf] =
          //     std::make_shared<state_symbol>("unsure" +
          //     std::to_string(_random()),
          //                                    1);
          // _state_machine_ptr->_flag_symbol_map[af] =
          //     std::make_shared<state_symbol>("unsure" +
          //     std::to_string(_random()),
          //                                    1);
      }  //设置标志位
      {
        if (res_symbol->is_num()) {
          uint64_t res_number = res_symbol->to_int();
          //具体运算设置标志位zf sf pf
          {
            switch (insn.detail->x86.operands[0].size) {
              case 8: {
                _state_machine_ptr->_flag_symbol_map[sf] =
                    std::make_shared<state_symbol>(res_number >> 63, 1);
                _state_machine_ptr->_flag_symbol_map[zf] =
                    std::make_shared<state_symbol>(res_number == 0 ? 1 : 0, 1);
                _state_machine_ptr->_flag_symbol_map[pf] =
                    std::make_shared<state_symbol>(
                        get_1_num(res_number) + 1 % 2, 1);
                break;
              }
              case 4: {
                _state_machine_ptr->_flag_symbol_map[sf] =
                    std::make_shared<state_symbol>(
                        (res_number & 0xffffffffLL) >> 31, 1);
                _state_machine_ptr->_flag_symbol_map[zf] =
                    std::make_shared<state_symbol>(
                        (res_number & 0xffffffffLL) == 0 ? 1 : 0, 1);
                _state_machine_ptr->_flag_symbol_map[pf] =
                    std::make_shared<state_symbol>(
                        (get_1_num(res_number & 0xffffffffLL) + 1) % 2, 1);
                break;
              }
              case 2: {
                _state_machine_ptr->_flag_symbol_map[sf] =
                    std::make_shared<state_symbol>(
                        (res_number & 0xffffLL) >> 15, 1);
                _state_machine_ptr->_flag_symbol_map[zf] =
                    std::make_shared<state_symbol>(
                        (res_number & 0xffffLL) == 0 ? 1 : 0, 1);
                _state_machine_ptr->_flag_symbol_map[pf] =
                    std::make_shared<state_symbol>(
                        (get_1_num(res_number & 0xffffLL)) + 1 % 2, 1);
                break;
              }
            }
          }
          //设置标志位 of cf 以及设置 8 位运算情况下的标志位
          if (target_symbol->is_num() && source_symbol->is_num()) {
            uint64_t target_number = target_symbol->to_int();
            uint64_t source_number = source_symbol->to_int();
            switch (insn.detail->x86.operands[0].size) {
              case 8: {
                _state_machine_ptr->_flag_symbol_map[cf] =
                    std::make_shared<state_symbol>(
                        (0xffffffffffffffffLL - target_number) < source_number
                            ? 1
                            : 0,
                        1);
                // source 与 target 同号的情况才有可能溢出，溢出的情况下
                if (!(judge_sign(source_number, 8) ^
                      judge_sign(target_number, 8)) &&
                    (judge_sign(source_number, 8) ^
                     judge_sign(res_number, 8))) {
                  _state_machine_ptr->_flag_symbol_map[of] =
                      std::make_shared<state_symbol>(1, 1);
                } else {
                  _state_machine_ptr->_flag_symbol_map[of] =
                      std::make_shared<state_symbol>(0, 1);
                }
              }
              case 4: {
                _state_machine_ptr->_flag_symbol_map[cf] =
                    std::make_shared<state_symbol>(
                        (target_number & 0xffffffffLL) <
                                (source_number & 0xffffffffLL)
                            ? 1
                            : 0,
                        1);
                if (!(judge_sign(source_number & 0xffffffffLL, 4) ^
                      judge_sign(target_number & 0xffffffffLL, 4)) &&
                    (judge_sign(source_number & 0xffffffffLL, 4) ^
                     judge_sign(res_number & 0xffffffffLL, 4))) {
                  _state_machine_ptr->_flag_symbol_map[of] =
                      std::make_shared<state_symbol>(1, 1);
                } else {
                  _state_machine_ptr->_flag_symbol_map[of] =
                      std::make_shared<state_symbol>(0, 1);
                }
              }
              case 2: {
                _state_machine_ptr->_flag_symbol_map[cf] =
                    std::make_shared<state_symbol>(
                        (target_number & 0xffffLL) < (source_number & 0xffffLL)
                            ? 1
                            : 0,
                        1);
                if (!(judge_sign(source_number & 0xffffLL, 2) ^
                      judge_sign(target_number & 0xffffLL, 2)) &&
                    (judge_sign(source_number & 0xffffLL, 2) ^
                     judge_sign(res_number & 0xffffLL, 2))) {
                  _state_machine_ptr->_flag_symbol_map[of] =
                      std::make_shared<state_symbol>(1, 1);
                } else {
                  _state_machine_ptr->_flag_symbol_map[of] =
                      std::make_shared<state_symbol>(0, 1);
                }
              }
              case 1: {
                //重新生成
                {
                  target_number &= 0xffLL;
                  source_number &= 0xffLL;
                  res_number = target_number - source_number;
                }
                _state_machine_ptr->_flag_symbol_map[sf] =
                    std::make_shared<state_symbol>(res_number >> 7, 1);
                _state_machine_ptr->_flag_symbol_map[zf] =
                    std::make_shared<state_symbol>(res_number == 0 ? 1 : 0, 1);
                _state_machine_ptr->_flag_symbol_map[pf] =
                    std::make_shared<state_symbol>(
                        (get_1_num(res_number) + 1) % 2, 1);

                _state_machine_ptr->_flag_symbol_map[cf] =
                    std::make_shared<state_symbol>(
                        target_number < source_number ? 1 : 0, 1);
                if (!(judge_sign(source_number, 1) ^
                      judge_sign(target_number, 1)) &&
                    (judge_sign(source_number, 1) ^
                     judge_sign(res_number, 1))) {
                  _state_machine_ptr->_flag_symbol_map[of] =
                      std::make_shared<state_symbol>(1, 1);
                } else {
                  _state_machine_ptr->_flag_symbol_map[of] =
                      std::make_shared<state_symbol>(0, 1);
                }
              }
            }
          }
          // 运算的双方不能转为int时
          else {
            //不为8 设置 of cf af 未知
            if (insn.detail->x86.operands[0].size != 8) {
              _state_machine_ptr->_flag_symbol_map[cf] =
                  std::make_shared<state_symbol>(
                      "unsure" + std::to_string(_random()), 1);

              _state_machine_ptr->_flag_symbol_map[of] =
                  std::make_shared<state_symbol>(
                      "unsure" + std::to_string(_random()), 1);

              _state_machine_ptr->_flag_symbol_map[af] =
                  std::make_shared<state_symbol>(
                      "unsure" + std::to_string(_random()), 1);
            }
            //为8 全部设为未知
            else {
              _state_machine_ptr->_flag_symbol_map[cf] =
                  std::make_shared<state_symbol>(
                      "unsure" + std::to_string(_random()), 1);
              _state_machine_ptr->_flag_symbol_map[zf] =
                  std::make_shared<state_symbol>(
                      "unsure" + std::to_string(_random()), 1);
              _state_machine_ptr->_flag_symbol_map[sf] =
                  std::make_shared<state_symbol>(
                      "unsure" + std::to_string(_random()), 1);
              _state_machine_ptr->_flag_symbol_map[of] =
                  std::make_shared<state_symbol>(
                      "unsure" + std::to_string(_random()), 1);
              _state_machine_ptr->_flag_symbol_map[pf] =
                  std::make_shared<state_symbol>(
                      "unsure" + std::to_string(_random()), 1);
              _state_machine_ptr->_flag_symbol_map[af] =
                  std::make_shared<state_symbol>(
                      "unsure" + std::to_string(_random()), 1);
            }
          }
        } else {
          _state_machine_ptr->_flag_symbol_map[cf] =
              std::make_shared<state_symbol>(
                  "unsure" + std::to_string(_random()), 1);
          _state_machine_ptr->_flag_symbol_map[zf] =
              std::make_shared<state_symbol>(
                  "unsure" + std::to_string(_random()), 1);
          _state_machine_ptr->_flag_symbol_map[sf] =
              std::make_shared<state_symbol>(
                  "unsure" + std::to_string(_random()), 1);
          _state_machine_ptr->_flag_symbol_map[of] =
              std::make_shared<state_symbol>(
                  "unsure" + std::to_string(_random()), 1);
          _state_machine_ptr->_flag_symbol_map[pf] =
              std::make_shared<state_symbol>(
                  "unsure" + std::to_string(_random()), 1);
          _state_machine_ptr->_flag_symbol_map[af] =
              std::make_shared<state_symbol>(
                  "unsure" + std::to_string(_random()), 1);
        }
      }
      break;
    }
    case instruction_type::type::AND: {
      abstract_addr::ptr source_addr;
      abstract_addr::ptr target_addr;
      state_symbol::ptr source_symbol;
      state_symbol::ptr target_symbol;
      char target_type =
          analyze_operator(insn.detail->x86.operands[0], target_addr,
                           target_symbol, true, control_leak_state, exec_mode);
      if (target_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (target_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      char source_type =
          analyze_operator(insn.detail->x86.operands[1], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (source_symbol->is_num()) {
        uint64_t num = source_symbol->to_int();
        if ((num & 0x00000000000001ff) > 0 && target_symbol->_taine == taine_enum::taine2) {
          set_target_symbol(
              target_addr,
              std::make_shared<state_symbol>(
                  get_taine_string(taine_enum::not_a_tine, _random, _dist),
                  target_symbol->get_symbol_size()),
              true);
          break;
        }
      }

      state_symbol::ptr res_symbol =
          std::make_shared<state_symbol>(target_symbol->op_and(source_symbol));

      res_symbol->set_symbol_size(insn.detail->x86.operands[0].size);

      // branch miss 的情况下记录branchs miss产生的污点符号
      if (exec_mode == 0 && is_cache_miss_location) {
        _state_machine_ptr->_cache_miss_symbol_vector.push_back(res_symbol);
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }

      // res_symbol->set_can_up_taine_lv_true();
      set_target_symbol(target_addr, res_symbol);
      break;
    }
    case instruction_type::type::clc: {
      // cf清0
      _state_machine_ptr->_flag_symbol_map[cf] =
          std::make_shared<state_symbol>(0, 1);
      break;
    }
    case instruction_type::type::cld: {
      // df清0
      _state_machine_ptr->_flag_symbol_map[df] =
          std::make_shared<state_symbol>(0, 1);
      break;
    }
    case instruction_type::type::cli: {
      //禁止硬中断，跳过
      break;
    }
    case instruction_type::type::cmc: {
      // cf标志取反
      abstract_flags::ptr cf =
          _generatr_abstract_addr_tool_ptr->get_abstract_flag(rflags::cf);
      state_symbol::ptr cf_symbol = _state_machine_ptr->_flag_symbol_map[cf];
      if (cf_symbol->is_num()) {
        _state_machine_ptr->_flag_symbol_map[cf] =
            std::make_shared<state_symbol>(cf_symbol->op_not());
      }
      break;
    }
    case instruction_type::type::cmpsb: {
      //串比较暂时忽略
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::cmpsw: {
      //串比较暂时忽略
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::daa: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::das: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::dec: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      state_symbol::ptr res_symbol;
      uint64_t source_num;
      uint64_t res_num;
      bool target_xh = false;
      char type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      res_symbol = std::make_shared<state_symbol>(source_symbol->op_sub(
          state_symbol(1, insn.detail->x86.operands[0].size)));

      //运算过程中设置标准位暂时可能没有必要
      {
        // _state_machine_ptr->_flag_symbol_map[cf] =
        //     std::make_shared<state_symbol>(
        //         "unsure" + std::to_string(_random()), 1);
        // _state_machine_ptr->_flag_symbol_map[zf] =
        //     std::make_shared<state_symbol>(
        //         "unsure" + std::to_string(_random()), 1);
        // _state_machine_ptr->_flag_symbol_map[sf] =
        //     std::make_shared<state_symbol>(
        //         "unsure" + std::to_string(_random()), 1);
        // _state_machine_ptr->_flag_symbol_map[of] =
        //     std::make_shared<state_symbol>(
        //         "unsure" + std::to_string(_random()), 1);
        // _state_machine_ptr->_flag_symbol_map[pf] =
        //     std::make_shared<state_symbol>(
        //         "unsure" + std::to_string(_random()), 1);
        // _state_machine_ptr->_flag_symbol_map[af] =
        //     std::make_shared<state_symbol>(
        //         "unsure" + std::to_string(_random()), 1);
      }
      // branch miss 的情况下记录branchs miss产生的污点符号
      if (exec_mode == 0 && is_cache_miss_location) {
        _state_machine_ptr->_cache_miss_symbol_vector.push_back(res_symbol);
        if (type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }

      // res_symbol->set_symbol_size(insn.detail->x86.operands[0].size);
      set_target_symbol(source_addr, res_symbol);
      break;
    }
    case instruction_type::type::div: {
      // rax的
      abstract_addr::ptr rax_addr;
      state_symbol::ptr rax_symbol;
      cs_x86_op rax = cs_x86_op();
      rax.type = X86_OP_REG;
      rax.reg = X86_REG_RAX;
      analyze_operator(rax, rax_addr, rax_symbol, true, control_leak_state,
                       exec_mode);

      // rdx的
      abstract_addr::ptr rdx_addr;
      state_symbol::ptr rdx_symbol;
      cs_x86_op rdx = cs_x86_op();
      rdx.type = X86_OP_REG;
      rdx.reg = X86_REG_RDX;
      analyze_operator(rdx, rdx_addr, rdx_symbol, true, control_leak_state,
                       exec_mode);

      //源操作数
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      // branch miss 的情况下记录branchs miss产生的污点符号
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }

      if (rax_symbol->is_num() && source_symbol->is_num()) {
        uint64_t rax_num = rax_symbol->to_int();
        uint64_t old_rax_num = rax_num;
        uint64_t source_num = source_symbol->to_int();
        if (source_num == 0) {
          return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
        }
        switch (insn.detail->x86.operands[0].size) {
          case 8: {
            uint64_t quotient = rax_num / source_num;
            uint64_t remainder = rax_num % source_num;
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RAX,
                                                                    8),
                std::make_shared<state_symbol>(quotient, 8));
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RDX,
                                                                    8),
                std::make_shared<state_symbol>(remainder, 8));
            break;
          }
          case 4: {
            source_num &= 0xffffffffLL;
            uint64_t quotient = (rax_num / source_num) & 0xffffffffLL;
            uint64_t remainder = (rax_num % source_num) & 0xffffffffLL;

            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EAX,
                                                                    4),
                std::make_shared<state_symbol>(quotient, 4));
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EDX,
                                                                    4),
                std::make_shared<state_symbol>(remainder, 4));
            break;
          }
          case 2: {
            rax_num &= 0xffffffffLL;
            source_num &= 0xffffLL;
            uint64_t quotient = (rax_num / source_num) & 0xffffLL;
            uint64_t remainder = (rax_num % source_num) & 0xffffLL;

            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AX,
                                                                    2),
                std::make_shared<state_symbol>(quotient, 2));
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DX,
                                                                    2),
                std::make_shared<state_symbol>(remainder, 2));

            break;
          }
          case 1: {
            rax_num &= 0xffffLL;
            source_num &= 0xffLL;

            uint64_t quotient = (rax_num / source_num) & 0xffLL;
            uint64_t remainder = (rax_num % source_num) & 0xffLL;
            uint64_t res_num = (quotient << 8) + remainder;
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AX,
                                                                    2),
                std::make_shared<state_symbol>(res_num, 2));
            break;
          }
        }
      } else {
        std::vector<std::string> taine_vector =
            rax_symbol->_taine_effect_vector;
        taine_vector.insert(taine_vector.end(),
                            rax_symbol->_taine_effect_vector.begin(),
                            rax_symbol->_taine_effect_vector.end());
        distinct_taine_str(taine_vector);
        std::shared_ptr<state_symbol> quotient = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), insn.detail->x86.operands[0].size,
            taine_vector);

        std::shared_ptr<state_symbol> remainder =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist),
                                           insn.detail->x86.operands[0].size,
                                           taine_vector);

        switch (insn.detail->x86.operands[0].size) {
          case 8: {
            // quotient
            {
              {
                quotient->set_symbol_size(8);
                // xh xl
                quotient->_size_xh_symbol = std::make_shared<state_symbol>(
                    quotient->to_string() + "xh", 1,
                    quotient->_taine_effect_vector);
                quotient->_size_xl_symbol =
                    std::make_shared<state_symbol>(quotient, 1);
                // xx
                quotient->_size_16_symbol =
                    std::make_shared<state_symbol>(quotient, 2);

                quotient->_size_16_symbol->_size_xh_symbol =
                    quotient->_size_xh_symbol;
                quotient->_size_16_symbol->_size_xl_symbol =
                    quotient->_size_xl_symbol;
                // exh
                quotient->_size_32_symbol =
                    std::make_shared<state_symbol>(quotient, 4);
                quotient->_size_32_symbol->_size_16_symbol =
                    quotient->_size_16_symbol;
                quotient->_size_32_symbol->_size_xh_symbol =
                    quotient->_size_xh_symbol;
                quotient->_size_32_symbol->_size_xl_symbol =
                    quotient->_size_xl_symbol;
              }
              // remainder
              {
                remainder->set_symbol_size(8);
                // xh xl
                remainder->_size_xh_symbol = std::make_shared<state_symbol>(
                    remainder->to_string() + "xh", 1,
                    remainder->_taine_effect_vector);
                remainder->_size_xl_symbol =
                    std::make_shared<state_symbol>(remainder, 1);
                // xx
                remainder->_size_16_symbol =
                    std::make_shared<state_symbol>(remainder, 2);

                remainder->_size_16_symbol->_size_xh_symbol =
                    remainder->_size_xh_symbol;
                remainder->_size_16_symbol->_size_xl_symbol =
                    remainder->_size_xl_symbol;
                // exh
                remainder->_size_32_symbol =
                    std::make_shared<state_symbol>(remainder, 4);
                remainder->_size_32_symbol->_size_16_symbol =
                    remainder->_size_16_symbol;
                remainder->_size_32_symbol->_size_xh_symbol =
                    remainder->_size_xh_symbol;
                remainder->_size_32_symbol->_size_xl_symbol =
                    remainder->_size_xl_symbol;
                // exh
              }
            }

            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RAX,
                                                                    8),
                quotient);
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RDX,
                                                                    8),
                remainder);
            break;
          }
          case 4: {
            {
              {
                quotient->set_symbol_size(4);
                // xh xl
                quotient->_size_xh_symbol = std::make_shared<state_symbol>(
                    quotient->to_string() + "xh", 1,
                    quotient->_taine_effect_vector);
                quotient->_size_xl_symbol =
                    std::make_shared<state_symbol>(quotient, 1);
                // xx
                quotient->_size_16_symbol =
                    std::make_shared<state_symbol>(quotient, 2);

                quotient->_size_16_symbol->_size_xh_symbol =
                    quotient->_size_xh_symbol;
                quotient->_size_16_symbol->_size_xl_symbol =
                    quotient->_size_xl_symbol;
              }
              // remainder
              {
                remainder->set_symbol_size(4);
                // xh xl
                remainder->_size_xh_symbol = std::make_shared<state_symbol>(
                    remainder->to_string() + "xh", 1,
                    remainder->_taine_effect_vector);
                remainder->_size_xl_symbol =
                    std::make_shared<state_symbol>(remainder, 1);
                // xx
                remainder->_size_16_symbol =
                    std::make_shared<state_symbol>(remainder, 2);

                remainder->_size_16_symbol->_size_xh_symbol =
                    remainder->_size_xh_symbol;
                remainder->_size_16_symbol->_size_xl_symbol =
                    remainder->_size_xl_symbol;
              }
            }
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EAX,
                                                                    4),
                quotient);
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EDX,
                                                                    4),
                remainder);
            break;
          }
          case 2: {
            {
              {
                quotient->set_symbol_size(2);
                // xh xl
                quotient->_size_xh_symbol = std::make_shared<state_symbol>(
                    quotient->to_string() + "xh", 1,
                    quotient->_taine_effect_vector);
                quotient->_size_xl_symbol =
                    std::make_shared<state_symbol>(quotient, 1);
              }
              // remainder
              {
                remainder->set_symbol_size(2);
                // xh xl
                remainder->_size_xh_symbol = std::make_shared<state_symbol>(
                    remainder->to_string() + "xh", 1,
                    remainder->_taine_effect_vector);
                remainder->_size_xl_symbol =
                    std::make_shared<state_symbol>(remainder, 1);
              }
            }
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AX,
                                                                    2),
                quotient);
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DX,
                                                                    2),
                remainder);
            break;
          }
          case 1: {
            {
              quotient->set_symbol_size(2);
              // xh xl
              quotient->_size_xh_symbol = std::make_shared<state_symbol>(
                  quotient->to_string() + "xh", 1,
                  quotient->_taine_effect_vector);
              quotient->_size_xl_symbol =
                  std::make_shared<state_symbol>(quotient, 1);
            }
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AX,
                                                                    2),
                quotient);
            break;
          }
        }
      }

      break;
    }
    case instruction_type::type::esc: {
      //直接跳过
      break;
    }
    case instruction_type::type::hlt: {
      //使CPU暂停执行并等待中断
      return std::make_pair(-1, analyze_result::NO_ATTACT);
      break;
    }
    case instruction_type::type::idiv: {
      // rax的
      abstract_addr::ptr rax_addr;
      state_symbol::ptr rax_symbol;
      cs_x86_op rax = cs_x86_op();
      rax.type = X86_OP_REG;
      rax.reg = X86_REG_RAX;
      analyze_operator(rax, rax_addr, rax_symbol, true, control_leak_state,
                       exec_mode);

      // rdx的
      abstract_addr::ptr rdx_addr;
      state_symbol::ptr rdx_symbol;
      cs_x86_op rdx = cs_x86_op();
      rdx.type = X86_OP_REG;
      rdx.reg = X86_REG_RDX;
      analyze_operator(rdx, rdx_addr, rdx_symbol, true, control_leak_state,
                       exec_mode);

      //源操作数
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      // branch miss 的情况下记录branchs miss产生的污点符号
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }
      if (rax_symbol->is_num() && source_symbol->is_num()) {
        int64_t rax_num = rax_symbol->to_int();
        uint64_t old_rax_num = rax_symbol->to_int();
        int64_t source_num = source_symbol->to_int();
        if (source_num == 0) {
          return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
        }
        switch (insn.detail->x86.operands[0].size) {
          case 8: {
            int64_t quotient = rax_num / source_num;
            int64_t remainder = rax_num % source_num;
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RAX,
                                                                    8),
                std::make_shared<state_symbol>(quotient, 8));
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RDX,
                                                                    8),
                std::make_shared<state_symbol>(remainder, 8));
            break;
          }
          case 4: {
            source_num &= 0xffffffffLL;
            int64_t quotient = rax_num / source_num;
            quotient &= 0xffffffffLL;
            int64_t remainder = rax_num % source_num;
            remainder &= 0xffffffffLL;

            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EAX,
                                                                    4),
                std::make_shared<state_symbol>(
                    ((uint64_t)quotient) & 0xffffffffLL, 4));
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EDX,
                                                                    4),
                std::make_shared<state_symbol>(
                    ((uint64_t)remainder) & 0xffffffffLL, 4));
            break;
          }
          case 2: {
            rax_num &= 0xffffffffLL;
            source_num &= 0xffffLL;
            int64_t quotient = rax_num / source_num;
            quotient &= 0xffffLL;
            int64_t remainder = rax_num % source_num;
            remainder &= 0xffffLL;

            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AX,
                                                                    2),
                std::make_shared<state_symbol>(((uint64_t)quotient) & 0xffffLL,
                                               2));
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DX,
                                                                    2),
                std::make_shared<state_symbol>(((uint64_t)remainder) & 0xffffLL,
                                               2));
            break;
          }
          case 1: {
            rax_num &= 0xffffLL;
            source_num &= 0xffLL;
            int64_t quotient = rax_num / source_num;
            int64_t remainder = rax_num % source_num;

            uint64_t res_num = ((((uint64_t)quotient) & 0xffLL) << 8) +
                               (((uint64_t)remainder) & 0xffLL);

            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AX,
                                                                    2),
                std::make_shared<state_symbol>(res_num, 2));
            break;
          }
        }
      } else {
        std::vector<std::string> taine_vector =
            rax_symbol->_taine_effect_vector;
        taine_vector.insert(taine_vector.end(),
                            rax_symbol->_taine_effect_vector.begin(),
                            rax_symbol->_taine_effect_vector.end());
        std::shared_ptr<state_symbol> quotient = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), insn.detail->x86.operands[0].size,
            taine_vector);
        std::shared_ptr<state_symbol> remainder =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist),
                                           insn.detail->x86.operands[0].size,
                                           taine_vector);

        switch (insn.detail->x86.operands[0].size) {
          case 8: {
            // quotient
            {
              {
                quotient->set_symbol_size(8);
                // xh xl
                quotient->_size_xh_symbol = std::make_shared<state_symbol>(
                    quotient->to_string() + "xh", 1,
                    quotient->_taine_effect_vector);
                quotient->_size_xl_symbol =
                    std::make_shared<state_symbol>(quotient, 1);
                // xx
                quotient->_size_16_symbol =
                    std::make_shared<state_symbol>(quotient, 2);

                quotient->_size_16_symbol->_size_xh_symbol =
                    quotient->_size_xh_symbol;
                quotient->_size_16_symbol->_size_xl_symbol =
                    quotient->_size_xl_symbol;
                // exh
                quotient->_size_32_symbol =
                    std::make_shared<state_symbol>(quotient, 4);
                quotient->_size_32_symbol->_size_16_symbol =
                    quotient->_size_16_symbol;
                quotient->_size_32_symbol->_size_xh_symbol =
                    quotient->_size_xh_symbol;
                quotient->_size_32_symbol->_size_xl_symbol =
                    quotient->_size_xl_symbol;
              }
              // remainder
              {
                remainder->set_symbol_size(8);
                // xh xl
                remainder->_size_xh_symbol = std::make_shared<state_symbol>(
                    remainder->to_string() + "xh", 1,
                    remainder->_taine_effect_vector);
                remainder->_size_xl_symbol =
                    std::make_shared<state_symbol>(remainder, 1);
                // xx
                remainder->_size_16_symbol =
                    std::make_shared<state_symbol>(remainder, 2);

                remainder->_size_16_symbol->_size_xh_symbol =
                    remainder->_size_xh_symbol;
                remainder->_size_16_symbol->_size_xl_symbol =
                    remainder->_size_xl_symbol;
                // exh
                remainder->_size_32_symbol =
                    std::make_shared<state_symbol>(remainder, 4);
                remainder->_size_32_symbol->_size_16_symbol =
                    remainder->_size_16_symbol;
                remainder->_size_32_symbol->_size_xh_symbol =
                    remainder->_size_xh_symbol;
                remainder->_size_32_symbol->_size_xl_symbol =
                    remainder->_size_xl_symbol;
                // exh
              }
            }

            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RAX,
                                                                    8),
                quotient);
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RDX,
                                                                    8),
                remainder);
            break;
          }
          case 4: {
            {
              {
                quotient->set_symbol_size(4);
                // xh xl
                quotient->_size_xh_symbol = std::make_shared<state_symbol>(
                    quotient->to_string() + "xh", 1,
                    quotient->_taine_effect_vector);
                quotient->_size_xl_symbol =
                    std::make_shared<state_symbol>(quotient, 1);
                // xx
                quotient->_size_16_symbol =
                    std::make_shared<state_symbol>(quotient, 2);

                quotient->_size_16_symbol->_size_xh_symbol =
                    quotient->_size_xh_symbol;
                quotient->_size_16_symbol->_size_xl_symbol =
                    quotient->_size_xl_symbol;
              }
              // remainder
              {
                remainder->set_symbol_size(4);
                // xh xl
                remainder->_size_xh_symbol = std::make_shared<state_symbol>(
                    remainder->to_string() + "xh", 1,
                    remainder->_taine_effect_vector);
                remainder->_size_xl_symbol =
                    std::make_shared<state_symbol>(remainder, 1);
                // xx
                remainder->_size_16_symbol =
                    std::make_shared<state_symbol>(remainder, 2);

                remainder->_size_16_symbol->_size_xh_symbol =
                    remainder->_size_xh_symbol;
                remainder->_size_16_symbol->_size_xl_symbol =
                    remainder->_size_xl_symbol;
              }
            }
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EAX,
                                                                    4),
                quotient);
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EDX,
                                                                    4),
                remainder);
            break;
          }
          case 2: {
            {
              {
                quotient->set_symbol_size(2);
                // xh xl
                quotient->_size_xh_symbol = std::make_shared<state_symbol>(
                    quotient->to_string() + "xh", 1,
                    quotient->_taine_effect_vector);
                quotient->_size_xl_symbol =
                    std::make_shared<state_symbol>(quotient, 1);
              }
              // remainder
              {
                remainder->set_symbol_size(2);
                // xh xl
                remainder->_size_xh_symbol = std::make_shared<state_symbol>(
                    remainder->to_string() + "xh", 1,
                    remainder->_taine_effect_vector);
                remainder->_size_xl_symbol =
                    std::make_shared<state_symbol>(remainder, 1);
              }
            }
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AX,
                                                                    2),
                quotient);
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DX,
                                                                    2),
                remainder);
            break;
          }
          case 1: {
            {
              quotient->set_symbol_size(2);
              // xh xl
              quotient->_size_xh_symbol = std::make_shared<state_symbol>(
                  quotient->to_string() + "xh", 1,
                  quotient->_taine_effect_vector);
              quotient->_size_xl_symbol =
                  std::make_shared<state_symbol>(quotient, 1);
            }
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AX,
                                                                    2),
                quotient);
            break;
          }
        }
      }
      break;
    }
    case instruction_type::type::mul: {
      // rax的
      abstract_addr::ptr rax_addr;
      state_symbol::ptr rax_symbol;
      cs_x86_op rax = cs_x86_op();
      rax.type = X86_OP_REG;
      rax.reg = X86_REG_RAX;
      analyze_operator(rax, rax_addr, rax_symbol, true, control_leak_state,
                       exec_mode);

      // rdx的
      abstract_addr::ptr rdx_addr;
      state_symbol::ptr rdx_symbol;
      cs_x86_op rdx = cs_x86_op();
      rdx.type = X86_OP_REG;
      rdx.reg = X86_REG_RDX;
      analyze_operator(rdx, rdx_addr, rdx_symbol, true, control_leak_state,
                       exec_mode);

      //源操作数
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      // branch miss 的情况下记录branchs miss产生的污点符号
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }

      if (rax_symbol->is_num() && source_symbol->is_num()) {
        uint64_t rax_num = rax_symbol->to_int();
        uint64_t old_rax_num = rax_num;
        uint64_t source_num = source_symbol->to_int();
        switch (insn.detail->x86.operands[0].size) {
          case 8: {
            auto num = multiply_and_get_parts(rax_num, source_num);

            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RAX,
                                                                    8),
                std::make_shared<state_symbol>(num.first, 8));
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RDX,
                                                                    8),
                std::make_shared<state_symbol>(num.second, 8));
            break;
          }
          case 4: {
            source_num &= 0xffffffffLL;
            rax_num &= 0xffffffffLL;
            uint64_t res_num = source_num * rax_num;

            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EAX,
                                                                    4),
                std::make_shared<state_symbol>(res_num & 0xffffffffLL, 4));
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EDX,
                                                                    4),
                std::make_shared<state_symbol>(
                    (res_num & 0xffffffff00000000LL) >> 32, 4));
            break;
          }
          case 2: {
            rax_num &= 0xffffLL;
            source_num &= 0xffffLL;
            uint64_t res_num = source_num * rax_num;

            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AX,
                                                                    2),
                std::make_shared<state_symbol>(res_num & 0xffffLL, 2));
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DX,
                                                                    2),
                std::make_shared<state_symbol>((res_num & 0xffff0000LL) >> 16,
                                               2));
            break;
          }
          case 1: {
            rax_num &= 0xffLL;
            source_num &= 0xffLL;
            uint64_t res_num = source_num * rax_num;
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AX,
                                                                    2),
                std::make_shared<state_symbol>(res_num & 0xffffLL, 2));
            break;
          }
        }
      } else {
        std::vector<std::string> taine_vector =
            rax_symbol->_taine_effect_vector;
        taine_vector.insert(taine_vector.end(),
                            rax_symbol->_taine_effect_vector.begin(),
                            rax_symbol->_taine_effect_vector.end());
        distinct_taine_str(taine_vector);
        std::shared_ptr<state_symbol> quotient = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), insn.detail->x86.operands[0].size,
            taine_vector);
        std::shared_ptr<state_symbol> remainder =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist),
                                           insn.detail->x86.operands[0].size,
                                           taine_vector);

        switch (insn.detail->x86.operands[0].size) {
          case 8: {
            // quotient
            {
              {
                quotient->set_symbol_size(8);
                // xh xl
                quotient->_size_xh_symbol = std::make_shared<state_symbol>(
                    quotient->to_string() + "xh", 1,
                    quotient->_taine_effect_vector);
                quotient->_size_xl_symbol =
                    std::make_shared<state_symbol>(quotient, 1);
                // xx
                quotient->_size_16_symbol =
                    std::make_shared<state_symbol>(quotient, 2);

                quotient->_size_16_symbol->_size_xh_symbol =
                    quotient->_size_xh_symbol;
                quotient->_size_16_symbol->_size_xl_symbol =
                    quotient->_size_xl_symbol;
                // exh
                quotient->_size_32_symbol =
                    std::make_shared<state_symbol>(quotient, 4);
                quotient->_size_32_symbol->_size_16_symbol =
                    quotient->_size_16_symbol;
                quotient->_size_32_symbol->_size_xh_symbol =
                    quotient->_size_xh_symbol;
                quotient->_size_32_symbol->_size_xl_symbol =
                    quotient->_size_xl_symbol;
              }
              // remainder
              {
                remainder->set_symbol_size(8);
                // xh xl
                remainder->_size_xh_symbol = std::make_shared<state_symbol>(
                    remainder->to_string() + "xh", 1,
                    remainder->_taine_effect_vector);
                remainder->_size_xl_symbol =
                    std::make_shared<state_symbol>(remainder, 1);
                // xx
                remainder->_size_16_symbol =
                    std::make_shared<state_symbol>(remainder, 2);

                remainder->_size_16_symbol->_size_xh_symbol =
                    remainder->_size_xh_symbol;
                remainder->_size_16_symbol->_size_xl_symbol =
                    remainder->_size_xl_symbol;
                // exh
                remainder->_size_32_symbol =
                    std::make_shared<state_symbol>(remainder, 4);
                remainder->_size_32_symbol->_size_16_symbol =
                    remainder->_size_16_symbol;
                remainder->_size_32_symbol->_size_xh_symbol =
                    remainder->_size_xh_symbol;
                remainder->_size_32_symbol->_size_xl_symbol =
                    remainder->_size_xl_symbol;
                // exh
              }
            }

            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RAX,
                                                                    8),
                quotient);
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RDX,
                                                                    8),
                remainder);
            break;
          }
          case 4: {
            {
              {
                quotient->set_symbol_size(4);
                // xh xl
                quotient->_size_xh_symbol = std::make_shared<state_symbol>(
                    quotient->to_string() + "xh", 1,
                    quotient->_taine_effect_vector);
                quotient->_size_xl_symbol =
                    std::make_shared<state_symbol>(quotient, 1);
                // xx
                quotient->_size_16_symbol =
                    std::make_shared<state_symbol>(quotient, 2);

                quotient->_size_16_symbol->_size_xh_symbol =
                    quotient->_size_xh_symbol;
                quotient->_size_16_symbol->_size_xl_symbol =
                    quotient->_size_xl_symbol;
              }
              // remainder
              {
                remainder->set_symbol_size(4);
                // xh xl
                remainder->_size_xh_symbol = std::make_shared<state_symbol>(
                    remainder->to_string() + "xh", 1,
                    remainder->_taine_effect_vector);
                remainder->_size_xl_symbol =
                    std::make_shared<state_symbol>(remainder, 1);
                // xx
                remainder->_size_16_symbol =
                    std::make_shared<state_symbol>(remainder, 2);

                remainder->_size_16_symbol->_size_xh_symbol =
                    remainder->_size_xh_symbol;
                remainder->_size_16_symbol->_size_xl_symbol =
                    remainder->_size_xl_symbol;
              }
            }
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EAX,
                                                                    4),
                quotient);
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EDX,
                                                                    4),
                remainder);
            break;
          }
          case 2: {
            {
              {
                quotient->set_symbol_size(2);
                // xh xl
                quotient->_size_xh_symbol = std::make_shared<state_symbol>(
                    quotient->to_string() + "xh", 1,
                    quotient->_taine_effect_vector);
                quotient->_size_xl_symbol =
                    std::make_shared<state_symbol>(quotient, 1);
              }
              // remainder
              {
                remainder->set_symbol_size(2);
                // xh xl
                remainder->_size_xh_symbol = std::make_shared<state_symbol>(
                    remainder->to_string() + "xh", 1,
                    remainder->_taine_effect_vector);
                remainder->_size_xl_symbol =
                    std::make_shared<state_symbol>(remainder, 1);
              }
            }
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AX,
                                                                    2),
                quotient);
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DX,
                                                                    2),
                remainder);
            break;
          }
          case 1: {
            {
              quotient->set_symbol_size(2);
              // xh xl
              quotient->_size_xh_symbol = std::make_shared<state_symbol>(
                  quotient->to_string() + "xh", 1,
                  quotient->_taine_effect_vector);
              quotient->_size_xl_symbol =
                  std::make_shared<state_symbol>(quotient, 1);
            }
            set_target_symbol(
                _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AX,
                                                                    2),
                quotient);
            break;
          }
        }
      }
      break;
    }
    case instruction_type::type::imul: {
      switch (insn.detail->x86.op_count) {
        case 1: {
          // rax的
          abstract_addr::ptr rax_addr;
          state_symbol::ptr rax_symbol;
          cs_x86_op rax = cs_x86_op();
          rax.type = X86_OP_REG;
          rax.reg = X86_REG_RAX;
          analyze_operator(rax, rax_addr, rax_symbol, true, control_leak_state,
                           exec_mode);

          // rdx的
          abstract_addr::ptr rdx_addr;
          state_symbol::ptr rdx_symbol;
          cs_x86_op rdx = cs_x86_op();
          rdx.type = X86_OP_REG;
          rdx.reg = X86_REG_RDX;
          analyze_operator(rdx, rdx_addr, rdx_symbol, true, control_leak_state,
                           exec_mode);

          //源操作数
          abstract_addr::ptr source_addr;
          state_symbol::ptr source_symbol;
          char source_type = analyze_operator(insn.detail->x86.operands[0],
                                              source_addr, source_symbol, true,
                                              control_leak_state, exec_mode);
          if (source_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }
          // branch miss 的情况下记录branchs miss产生的污点符号
          if (exec_mode == 0 && is_cache_miss_location) {
            if (source_type == 2) {
              _state_machine_ptr->_cache_miss_symbol_vector.push_back(
                  source_symbol);
            }
          }

          if (rax_symbol->is_num() && source_symbol->is_num()) {
            uint64_t rax_num = rax_symbol->to_int();
            uint64_t source_num = source_symbol->to_int();
            switch (insn.detail->x86.operands[0].size) {
              case 8: {
                bool sign = judge_sign(rax_num, 8) ^ judge_sign(source_num, 8);
                auto num = multiply_and_get_parts(rax_num, source_num);
                //结果为负数时
                if (sign) {
                  bool flag = true;
                  for (int i = 63; i >= 0; --i) {
                    if ((num.first & (0x1 << i)) == 0) {
                      num.first |= 0x1 << i;
                    } else {
                      flag = false;
                      break;
                    }
                  }
                  if (flag) {
                    for (int i = 63; i >= 0; --i) {
                      if ((num.second & (0x1 << i)) == 0) {
                        num.second |= 0x1 << i;
                      } else {
                        break;
                      }
                    }
                  }
                }

                set_target_symbol(
                    _generatr_abstract_addr_tool_ptr->get_abstract_addr(
                        X86_REG_RAX, 8),
                    std::make_shared<state_symbol>(num.first, 8));
                set_target_symbol(
                    _generatr_abstract_addr_tool_ptr->get_abstract_addr(
                        X86_REG_RDX, 8),
                    std::make_shared<state_symbol>(num.second, 8));
                break;
              }
              case 4: {
                source_num &= 0xffffffffLL;
                rax_num &= 0xffffffffLL;
                uint64_t res_num = source_num * rax_num;
                bool sign = judge_sign(rax_num, 4) ^ judge_sign(source_num, 4);
                if (sign) {
                  for (int i = 63; i >= 0; --i) {
                    if ((res_num & (0x1 << i)) == 0) {
                      res_num |= 0x1 << i;
                    } else {
                      break;
                    }
                  }
                }
                set_target_symbol(
                    _generatr_abstract_addr_tool_ptr->get_abstract_addr(
                        X86_REG_EAX, 4),
                    std::make_shared<state_symbol>(res_num & 0xffffffffLL, 4));
                set_target_symbol(
                    _generatr_abstract_addr_tool_ptr->get_abstract_addr(
                        X86_REG_EDX, 4),
                    std::make_shared<state_symbol>(
                        (res_num & 0xffffffff00000000LL) >> 32, 4));
                break;
              }
              case 2: {
                rax_num &= 0xffffLL;
                source_num &= 0xffffLL;
                uint64_t res_num = source_num * rax_num;
                bool sign = judge_sign(rax_num, 2) ^ judge_sign(source_num, 2);
                if (sign) {
                  for (int i = 31; i >= 0; --i) {
                    if ((res_num & (0x1 << i)) == 0) {
                      res_num |= 0x1 << i;
                    } else {
                      break;
                    }
                  }
                }

                set_target_symbol(
                    _generatr_abstract_addr_tool_ptr->get_abstract_addr(
                        X86_REG_AX, 2),
                    std::make_shared<state_symbol>(res_num & 0xffffLL, 2));
                set_target_symbol(
                    _generatr_abstract_addr_tool_ptr->get_abstract_addr(
                        X86_REG_DX, 2),
                    std::make_shared<state_symbol>(
                        (res_num & 0xffff0000LL) >> 16, 2));
                break;
              }
              case 1: {
                rax_num &= 0xffLL;
                source_num &= 0xffLL;
                uint64_t res_num = source_num * rax_num;
                bool sign = judge_sign(rax_num, 1) ^ judge_sign(source_num, 1);
                if (sign) {
                  for (int i = 15; i >= 0; --i) {
                    if ((res_num & (0x1 << i)) == 0) {
                      res_num |= 0x1 << i;
                    } else {
                      break;
                    }
                  }
                }
                set_target_symbol(
                    _generatr_abstract_addr_tool_ptr->get_abstract_addr(
                        X86_REG_AX, 2),
                    std::make_shared<state_symbol>(res_num & 0xffffLL, 2));
                break;
              }
            }
          } else {
            std::vector<std::string> taine_vector =
                rax_symbol->_taine_effect_vector;
            taine_vector.insert(taine_vector.end(),
                                rax_symbol->_taine_effect_vector.begin(),
                                rax_symbol->_taine_effect_vector.end());
            std::shared_ptr<state_symbol> quotient =
                std::make_shared<state_symbol>(
                    get_symbol_str(_random, _dist),
                    insn.detail->x86.operands[0].size, taine_vector);
            std::shared_ptr<state_symbol> remainder =
                std::make_shared<state_symbol>(
                    get_symbol_str(_random, _dist),
                    insn.detail->x86.operands[0].size, taine_vector);

            switch (insn.detail->x86.operands[0].size) {
              case 8: {
                // quotient
                {
                  {
                    quotient->set_symbol_size(8);
                    // xh xl
                    quotient->_size_xh_symbol = std::make_shared<state_symbol>(
                        quotient->to_string() + "xh", 1,
                        quotient->_taine_effect_vector);
                    quotient->_size_xl_symbol =
                        std::make_shared<state_symbol>(quotient, 1);
                    // xx
                    quotient->_size_16_symbol =
                        std::make_shared<state_symbol>(quotient, 2);

                    quotient->_size_16_symbol->_size_xh_symbol =
                        quotient->_size_xh_symbol;
                    quotient->_size_16_symbol->_size_xl_symbol =
                        quotient->_size_xl_symbol;
                    // exh
                    quotient->_size_32_symbol =
                        std::make_shared<state_symbol>(quotient, 4);
                    quotient->_size_32_symbol->_size_16_symbol =
                        quotient->_size_16_symbol;
                    quotient->_size_32_symbol->_size_xh_symbol =
                        quotient->_size_xh_symbol;
                    quotient->_size_32_symbol->_size_xl_symbol =
                        quotient->_size_xl_symbol;
                  }
                  // remainder
                  {
                    remainder->set_symbol_size(8);
                    // xh xl
                    remainder->_size_xh_symbol = std::make_shared<state_symbol>(
                        remainder->to_string() + "xh", 1,
                        remainder->_taine_effect_vector);
                    remainder->_size_xl_symbol =
                        std::make_shared<state_symbol>(remainder, 1);
                    // xx
                    remainder->_size_16_symbol =
                        std::make_shared<state_symbol>(remainder, 2);

                    remainder->_size_16_symbol->_size_xh_symbol =
                        remainder->_size_xh_symbol;
                    remainder->_size_16_symbol->_size_xl_symbol =
                        remainder->_size_xl_symbol;
                    // exh
                    remainder->_size_32_symbol =
                        std::make_shared<state_symbol>(remainder, 4);
                    remainder->_size_32_symbol->_size_16_symbol =
                        remainder->_size_16_symbol;
                    remainder->_size_32_symbol->_size_xh_symbol =
                        remainder->_size_xh_symbol;
                    remainder->_size_32_symbol->_size_xl_symbol =
                        remainder->_size_xl_symbol;
                    // exh
                  }
                }

                set_target_symbol(
                    _generatr_abstract_addr_tool_ptr->get_abstract_addr(
                        X86_REG_RAX, 8),
                    quotient);
                set_target_symbol(
                    _generatr_abstract_addr_tool_ptr->get_abstract_addr(
                        X86_REG_RDX, 8),
                    remainder);
                break;
              }
              case 4: {
                {
                  {
                    quotient->set_symbol_size(4);
                    // xh xl
                    quotient->_size_xh_symbol = std::make_shared<state_symbol>(
                        quotient->to_string() + "xh", 1,
                        quotient->_taine_effect_vector);
                    quotient->_size_xl_symbol =
                        std::make_shared<state_symbol>(quotient, 1);
                    // xx
                    quotient->_size_16_symbol =
                        std::make_shared<state_symbol>(quotient, 2);

                    quotient->_size_16_symbol->_size_xh_symbol =
                        quotient->_size_xh_symbol;
                    quotient->_size_16_symbol->_size_xl_symbol =
                        quotient->_size_xl_symbol;
                  }
                  // remainder
                  {
                    remainder->set_symbol_size(4);
                    // xh xl
                    remainder->_size_xh_symbol = std::make_shared<state_symbol>(
                        remainder->to_string() + "xh", 1,
                        remainder->_taine_effect_vector);
                    remainder->_size_xl_symbol =
                        std::make_shared<state_symbol>(remainder, 1);
                    // xx
                    remainder->_size_16_symbol =
                        std::make_shared<state_symbol>(remainder, 2);

                    remainder->_size_16_symbol->_size_xh_symbol =
                        remainder->_size_xh_symbol;
                    remainder->_size_16_symbol->_size_xl_symbol =
                        remainder->_size_xl_symbol;
                  }
                }
                set_target_symbol(
                    _generatr_abstract_addr_tool_ptr->get_abstract_addr(
                        X86_REG_EAX, 4),
                    quotient);
                set_target_symbol(
                    _generatr_abstract_addr_tool_ptr->get_abstract_addr(
                        X86_REG_EDX, 4),
                    remainder);
                break;
              }
              case 2: {
                {
                  {
                    quotient->set_symbol_size(2);
                    // xh xl
                    quotient->_size_xh_symbol = std::make_shared<state_symbol>(
                        quotient->to_string() + "xh", 1,
                        quotient->_taine_effect_vector);
                    quotient->_size_xl_symbol =
                        std::make_shared<state_symbol>(quotient, 1);
                  }
                  // remainder
                  {
                    remainder->set_symbol_size(2);
                    // xh xl
                    remainder->_size_xh_symbol = std::make_shared<state_symbol>(
                        remainder->to_string() + "xh", 1,
                        remainder->_taine_effect_vector);
                    remainder->_size_xl_symbol =
                        std::make_shared<state_symbol>(remainder, 1);
                  }
                }
                set_target_symbol(
                    _generatr_abstract_addr_tool_ptr->get_abstract_addr(
                        X86_REG_AX, 2),
                    quotient);
                set_target_symbol(
                    _generatr_abstract_addr_tool_ptr->get_abstract_addr(
                        X86_REG_DX, 2),
                    remainder);
                break;
              }
              case 1: {
                {
                  quotient->set_symbol_size(2);
                  // xh xl
                  quotient->_size_xh_symbol = std::make_shared<state_symbol>(
                      quotient->to_string() + "xh", 1,
                      quotient->_taine_effect_vector);
                  quotient->_size_xl_symbol =
                      std::make_shared<state_symbol>(quotient, 1);
                }
                set_target_symbol(
                    _generatr_abstract_addr_tool_ptr->get_abstract_addr(
                        X86_REG_AX, 2),
                    quotient);
                break;
              }
            }
          }
          break;
        }
        case 2: {
          //源操作数
          abstract_addr::ptr source_addr;
          state_symbol::ptr source_symbol;
          char source_type = analyze_operator(insn.detail->x86.operands[1],
                                              source_addr, source_symbol, true,
                                              control_leak_state, exec_mode);
          if (source_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }
          //目标操作数
          abstract_addr::ptr target_addr;
          state_symbol::ptr target_symbol;
          char target_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, true,
                                              control_leak_state, exec_mode);
          if (target_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (target_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }
          // branch miss 的情况下记录branchs miss产生的污点符号
          if (exec_mode == 0 && is_cache_miss_location) {
            if (source_type == 2) {
              _state_machine_ptr->_cache_miss_symbol_vector.push_back(
                  source_symbol);
            }
          }

          if (target_symbol->is_num() && source_symbol->is_num()) {
            uint64_t target_num = target_symbol->to_int();
            uint64_t old_target_num = target_num;
            uint64_t source_num = source_symbol->to_int();

            switch (insn.detail->x86.operands[0].size) {
              case 8: {
                bool sign = (target_num >> 63) ^ (source_num >> 63);
                if (target_num >> 63) {
                  target_num = ~(target_num - 1);
                }
                if (source_num >> 63) {
                  source_num = ~(source_num - 1);
                }
                auto num = multiply_and_get_parts(target_num, source_num);
                if (sign) {
                  num.first = ~num.first;
                  num.second = ~num.second;
                  if (num.second == 0xffffffffffffffffLL) {
                    num.second = 0;
                    num.first += 1;
                  } else {
                    num.second += 1;
                  }
                }
                set_target_symbol(
                    target_addr, std::make_shared<state_symbol>(num.second, 8));
                break;
              }
              case 4: {
                source_num &= 0xffffffffLL;
                target_num &= 0xffffffffLL;
                bool sign = (target_num >> 31) ^ (source_num >> 31);
                if (target_num >> 31) {
                  target_num = ~(target_num - 1);
                }
                if (source_num >> 31) {
                  source_num = ~(source_num - 1);
                }
                uint64_t res_num = source_num * target_num;
                if (sign) {
                  res_num = ~res_num + 1;
                }
                set_target_symbol(target_addr,
                                  std::make_shared<state_symbol>(res_num, 4));

                break;
              }
              case 2: {
                target_num &= 0xffffLL;
                source_num &= 0xffffLL;
                bool sign = (target_num >> 15) ^ (source_num >> 15);
                if (target_num >> 15) {
                  target_num = ~(target_num - 1);
                }
                if (source_num >> 15) {
                  source_num = ~(source_num - 1);
                }
                uint64_t res_num = source_num * target_num;
                if (sign) {
                  res_num = ~res_num + 1;
                }
                set_target_symbol(target_addr,
                                  std::make_shared<state_symbol>(res_num, 2));
                break;
              }
              case 1: {
                bool flag = false;

                target_num &= 0xffLL;

                source_num &= 0xffLL;

                bool sign = (target_num >> 7) ^ (source_num >> 7);

                uint64_t res_num = source_num * target_num;
                if (sign) {
                  res_num = ~res_num + 1;
                }

                set_target_symbol(target_addr,
                                  std::make_shared<state_symbol>(res_num, 1));
              }
            }
          } else {
            state_symbol::ptr res_symbol = std::make_shared<state_symbol>(
                source_symbol->op_mul(target_symbol));
            if (source_symbol->_taine == taine_enum::taine2 ||
                target_symbol->_taine == taine_enum::taine2) {
              res_symbol->_taine2_with_mul_or_left_shift = true;
            }
            set_target_symbol(target_addr, res_symbol);
          }

          break;
        }
        case 3: {
          //源操作数1
          abstract_addr::ptr source_addr1;
          state_symbol::ptr source_symbol1;
          char source_type1 = analyze_operator(
              insn.detail->x86.operands[1], source_addr1, source_symbol1, true,
              control_leak_state, exec_mode);
          if (source_type1 == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type1 == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }
          //源操作数1
          abstract_addr::ptr source_addr2;
          state_symbol::ptr source_symbol2;
          char source_type2 = analyze_operator(
              insn.detail->x86.operands[2], source_addr2, source_symbol2, true,
              control_leak_state, exec_mode);
          if (source_type2 == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type2 == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }
          //目标操作数
          abstract_addr::ptr target_addr;
          state_symbol::ptr target_symbol;
          char target_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, false,
                                              control_leak_state, exec_mode);
          if (target_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (target_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }
          // branch miss 的情况下记录branchs miss产生的污点符号
          if (exec_mode == 0 && is_cache_miss_location) {
            if (source_type1 == 2) {
              _state_machine_ptr->_cache_miss_symbol_vector.push_back(
                  source_symbol1);
            }
            if (source_type2 == 2) {
              _state_machine_ptr->_cache_miss_symbol_vector.push_back(
                  source_symbol2);
            }
          }
          if (source_symbol2->is_num() && source_symbol1->is_num()) {
            uint64_t source_num2 = source_symbol2->to_int();
            uint64_t source_num1 = source_symbol1->to_int();

            switch (insn.detail->x86.operands[0].size) {
              case 8: {
                bool sign = (source_num2 >> 63) ^ (source_num1 >> 63);
                if (source_num2 >> 63) {
                  source_num2 = ~(source_num2 - 1);
                }
                if (source_num1 >> 63) {
                  source_num1 = ~(source_num1 - 1);
                }
                auto num = multiply_and_get_parts(source_num2, source_num1);
                if (sign) {
                  num.first = ~num.first;
                  num.second = ~num.second;
                  if (num.second == 0xffffffffffffffffLL) {
                    num.second = 0;
                    num.first += 1;
                  } else {
                    num.second += 1;
                  }
                }
                set_target_symbol(
                    target_addr, std::make_shared<state_symbol>(num.second, 8));
                break;
              }
              case 4: {
                source_num1 &= 0xffffffffLL;
                source_num2 &= 0xffffffffLL;

                bool sign = (source_num2 >> 31) ^ (source_num1 >> 31);
                if (source_num2 >> 31) {
                  source_num2 = ~(source_num2 - 1);
                }
                if (source_num1 >> 31) {
                  source_num1 = ~(source_num1 - 1);
                }
                uint64_t res_num = source_num1 * source_num2;
                if (sign) {
                  res_num = ~res_num + 1;
                }
                set_target_symbol(target_addr,
                                  std::make_shared<state_symbol>(res_num, 4));

                break;
              }
              case 2: {
                source_num2 &= 0xffffLL;
                source_num1 &= 0xffffLL;
                bool sign = (source_num2 >> 15) ^ (source_num1 >> 15);
                if (source_num2 >> 15) {
                  source_num2 = ~(source_num2 - 1);
                }
                if (source_num1 >> 15) {
                  source_num1 = ~(source_num1 - 1);
                }
                uint64_t res_num = source_num1 * source_num2;
                if (sign) {
                  res_num = ~res_num + 1;
                }
                set_target_symbol(target_addr,
                                  std::make_shared<state_symbol>(res_num, 2));
                break;
              }
              case 1: {
                source_num1 &= 0xffLL;
                source_num1 &= 0xffLL;
                bool sign = (source_num2 >> 7) ^ (source_num1 >> 7);
                uint64_t res_num = source_num1 * source_num2;
                if (sign) {
                  res_num = ~res_num + 1;
                }
                set_target_symbol(target_addr,
                                  std::make_shared<state_symbol>(res_num, 1));
              }
            }
          } else {
            state_symbol::ptr res_symbol = std::make_shared<state_symbol>(
                source_symbol1->op_mul(source_symbol2));
            if (source_symbol1->_taine == taine_enum::taine2 ||
                source_symbol2->_taine == taine_enum::taine2) {
              res_symbol->_taine2_with_mul_or_left_shift = true;
            }
            set_target_symbol(target_addr, res_symbol);
          }
          break;
        }
      }
      break;
    }
    case instruction_type::type::in: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::inc: {
      //源操作数
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);

      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      // branch miss 的情况下记录branchs miss产生的污点符号
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }

      state_symbol::ptr res_symbol =
          std::make_shared<state_symbol>(source_symbol->op_add(
              state_symbol(1, insn.detail->x86.operands[0].size)));

      res_symbol->set_symbol_size(insn.detail->x86.operands[0].size);
      // res_symbol->set_can_up_taine_lv_true();
      set_target_symbol(source_addr, res_symbol);
      break;
    }
    case instruction_type::type::INT: {
      //中断向量
      return std::make_pair(-1, analyze_result::NO_ATTACT);
      break;
    }
    case instruction_type::type::INTO: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::IRET: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::call: {
      cs_x86_op rsp = cs_x86_op();
      rsp.type = X86_OP_REG;
      rsp.reg = X86_REG_RSP;
      abstract_addr::ptr rsp_addr;
      state_symbol::ptr rsp_symbol;
      analyze_operator(rsp, rsp_addr, rsp_symbol, true, control_leak_state,
                       exec_mode);
      state_symbol new_rsp_symbol =
          rsp_symbol->op_sub(state_symbol(is_32 ? 4 : 8));

      abstract_addr::ptr stack_addr =
          _generatr_abstract_addr_tool_ptr->get_abstract_addr(new_rsp_symbol,
                                                              is_32 ? 4 : 8);
      set_target_symbol(stack_addr,
                        std::make_shared<state_symbol>(insn.address + insn.size,
                                                       is_32 ? 4 : 8));

      set_target_symbol(rsp_addr,
                        std::make_shared<state_symbol>(new_rsp_symbol));

      abstract_addr::ptr op_addr;
      state_symbol::ptr op_symbol;
      char op_type =
          analyze_operator(insn.detail->x86.operands[0], op_addr, op_symbol,
                           true, control_leak_state, exec_mode);

      if (op_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (op_symbol->is_num()) {
        {
          cs_x86_op rdi = cs_x86_op();
          rdi.type = X86_OP_REG;
          rdi.reg = X86_REG_RDI;
          abstract_addr::ptr rdi_addr;
          state_symbol::ptr rdi_symbol;
          analyze_operator(rdi, rdi_addr, rdi_symbol, true, control_leak_state,
                           exec_mode);
          if (rdi_symbol->_taine == taine_enum::taine2 &&
              rdi_symbol->get_can_up_taine_lv()) {
            return std::make_pair(op_symbol->to_int(),
                                  analyze_result::CALL_INSTRUCTION_WITH_TAINE);
          }
          cs_x86_op rsi = cs_x86_op();
          rsi.type = X86_OP_REG;
          rsi.reg = X86_REG_RSI;
          abstract_addr::ptr rsi_addr;
          state_symbol::ptr rsi_symbol;
          analyze_operator(rsi, rsi_addr, rsi_symbol, true, control_leak_state,
                           exec_mode);
          if (rsi_symbol->_taine == taine_enum::taine2 &&
              rsi_symbol->get_can_up_taine_lv()) {
            return std::make_pair(op_symbol->to_int(),
                                  analyze_result::CALL_INSTRUCTION_WITH_TAINE);
          }
        }

        return std::make_pair(op_symbol->to_int(),
                              analyze_result::CONTINUE_ANALYZE);
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }

      break;
    }
    case instruction_type::type::ja: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      switch (exec) {
        case 0: {
          state_symbol::ptr cf_symbol =
              _state_machine_ptr->_flag_symbol_map[cf];
          state_symbol::ptr zf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];

          if (cf_symbol->is_num() && zf_symbol->is_num()) {
            //正常情况下会跳转的
            if ((cf_symbol->to_int() & 0x1) == 0 &&
                (zf_symbol->to_int() & 0x1) == 0) {
              if (!error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            }
            //正常情况下不会跳转的
            else {
              if (error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            }
          } else {
            if (target_addr > insn.address + insn.size) {
              return std::make_pair(
                  -1, analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW);
            } else {
              return std::make_pair(-1,
                                    analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
            }
          }
          break;
        }
          //执行移动指令
        case 1: {
          return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::jae: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      switch (exec) {
        case 0: {
          state_symbol::ptr cf_symbol =
              _state_machine_ptr->_flag_symbol_map[cf];

          if (cf_symbol->is_num()) {
            if ((cf_symbol->to_int() & 0x1) == 0) {
              if (!error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            } else {
              if (error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            }
          } else {
            if (target_addr > insn.address + insn.size) {
              return std::make_pair(
                  -1, analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW);
              ;
            } else {
              return std::make_pair(-1,
                                    analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
            }
          }
          break;
        }
          //执行移动指令
        case 1: {
          return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::jb: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      switch (exec) {
        case 0: {
          state_symbol::ptr cf_symbol =
              _state_machine_ptr->_flag_symbol_map[cf];

          if (cf_symbol->is_num()) {
            if ((cf_symbol->to_int() & 0x1) == 1) {
              if (!error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            } else {
              if (error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            }
          } else {
            if (target_addr > insn.address + insn.size) {
              return std::make_pair(
                  -1, analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW);
              ;
            } else {
              return std::make_pair(-1,
                                    analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
            }
          }
          break;
        }
          //执行移动指令
        case 1: {
          return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::jbe: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      switch (exec) {
        case 0: {
          state_symbol::ptr cf_symbol =
              _state_machine_ptr->_flag_symbol_map[cf];
          state_symbol::ptr zf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          if ((zf_symbol->is_num() && (zf_symbol->to_int() & 0x1) == 1) ||
              (cf_symbol->is_num() && (cf_symbol->to_int() & 0x1) == 1)) {
            if (!error_path) {
              return std::make_pair(target_addr,
                                    analyze_result::CONTINUE_ANALYZE);
            }
          } else if ((zf_symbol->is_num() &&
                      (zf_symbol->to_int() & 0x1) == 0) &&
                     (cf_symbol->is_num() &&
                      (cf_symbol->to_int() & 0x1) == 0)) {
            if (error_path) {
              return std::make_pair(target_addr,
                                    analyze_result::CONTINUE_ANALYZE);
            }
          } else {
            if (target_addr > insn.address + insn.size) {
              return std::make_pair(
                  -1, analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW);
              ;
            } else {
              return std::make_pair(-1,
                                    analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
            }
          }
          break;
        }
          //执行移动指令
        case 1: {
          return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::jc: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      switch (exec) {
        case 0: {
          state_symbol::ptr cf_symbol =
              _state_machine_ptr->_flag_symbol_map[cf];
          if (cf_symbol->is_num()) {
            if ((cf_symbol->to_int() & 0x1) == 1) {
              if (!error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            } else {
              if (error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            }
          } else {
            if (target_addr > insn.address + insn.size) {
              return std::make_pair(
                  -1, analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW);
              ;
            } else {
              return std::make_pair(-1,
                                    analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
            }
          }
          break;
        }
          //执行移动指令
        case 1: {
          return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::je: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      switch (exec) {
        case 0: {
          state_symbol::ptr zf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          if (zf_symbol->is_num()) {
            // zf==1 跳转
            if ((zf_symbol->to_int() & 0x1) == 1) {
              if (!error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            } else {
              if (error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            }
          } else {
            if (target_addr > insn.address + insn.size) {
              return std::make_pair(
                  -1, analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW);
              ;
            } else {
              return std::make_pair(-1,
                                    analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
            }
          }
          break;
        }
          //执行移动指令
        case 1: {
          return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::jg: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      switch (exec) {
        case 0: {
          state_symbol::ptr sf_symbol =
              _state_machine_ptr->_flag_symbol_map[sf];
          state_symbol::ptr zf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          state_symbol::ptr of_symbol =
              _state_machine_ptr->_flag_symbol_map[of];
          if (sf_symbol->is_num() && zf_symbol->is_num() &&
              of_symbol->is_num()) {
            if ((zf_symbol->to_int() & 0x1) == 0 &&
                ((sf_symbol->to_int() & 0x1) == (of_symbol->to_int() & 0x1))) {
              if (!error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            } else {
              if (error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            }
          } else {
            if (target_addr > insn.address + insn.size) {
              return std::make_pair(
                  -1, analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW);
              ;
            } else {
              return std::make_pair(-1,
                                    analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
            }
          }
          break;
        }
          //执行移动指令
        case 1: {
          return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::jge: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      switch (exec) {
        case 0: {
          state_symbol::ptr sf_symbol =
              _state_machine_ptr->_flag_symbol_map[sf];
          state_symbol::ptr of_symbol =
              _state_machine_ptr->_flag_symbol_map[of];
          if (sf_symbol->is_num() && of_symbol->is_num()) {
            if ((sf_symbol->to_int() & 0x1) == (of_symbol->to_int() & 0x1)) {
              if (!error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            } else {
              if (error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            }
          } else {
            if (target_addr > insn.address + insn.size) {
              return std::make_pair(
                  -1, analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW);
              ;
            } else {
              return std::make_pair(-1,
                                    analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
            }
          }
          break;
        }
          //执行移动指令
        case 1: {
          return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::jl: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      switch (exec) {
        case 0: {
          state_symbol::ptr sf_symbol =
              _state_machine_ptr->_flag_symbol_map[sf];
          state_symbol::ptr of_symbol =
              _state_machine_ptr->_flag_symbol_map[of];
          if (sf_symbol->is_num() && of_symbol->is_num()) {
            if ((sf_symbol->to_int() & 0x1) != (of_symbol->to_int() & 0x1)) {
              if (!error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            } else {
              if (error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            }
          } else {
            if (target_addr > insn.address + insn.size) {
              return std::make_pair(
                  -1, analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW);
              ;
            } else {
              return std::make_pair(-1,
                                    analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
            }
          }
          break;
        }
          //执行移动指令
        case 1: {
          return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::jle: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      switch (exec) {
        case 0: {
          state_symbol::ptr zf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          state_symbol::ptr sf_symbol =
              _state_machine_ptr->_flag_symbol_map[sf];
          state_symbol::ptr of_symbol =
              _state_machine_ptr->_flag_symbol_map[of];
          if ((zf_symbol->is_num() && (zf_symbol->to_int() & 0x1) == 1) &&
              (sf_symbol->is_num() && of_symbol->is_num()) &&
              ((sf_symbol->to_int() & 0x1) != (of_symbol->to_int() & 0x1))) {
            if (!error_path) {
              return std::make_pair(target_addr,
                                    analyze_result::CONTINUE_ANALYZE);
            }
          } else if ((zf_symbol->is_num() &&
                      (zf_symbol->to_int() & 0x1) == 0) ||
                     (sf_symbol->is_num() && of_symbol->is_num()) &&
                         ((sf_symbol->to_int() & 0x1) ==
                          (of_symbol->to_int() & 0x1))) {
            if (error_path) {
              return std::make_pair(target_addr,
                                    analyze_result::CONTINUE_ANALYZE);
            }
          } else {
            if (target_addr > insn.address + insn.size) {
              return std::make_pair(
                  -1, analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW);
              ;
            } else {
              return std::make_pair(-1,
                                    analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
            }
          }
          break;
        }
          //执行移动指令
        case 1: {
          return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::jne: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      switch (exec) {
        case 0: {
          state_symbol::ptr zf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          if (zf_symbol->is_num()) {
            if ((zf_symbol->to_int() & 0x1) == 0) {
              if (!error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            } else {
              if (error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            }
          } else {
            if (target_addr > insn.address + insn.size) {
              return std::make_pair(
                  -1, analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW);
              ;
            } else {
              return std::make_pair(-1,
                                    analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
            }
          }
          break;
        }
          //执行移动指令
        case 1: {
          return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::jno: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      switch (exec) {
        case 0: {
          state_symbol::ptr of_symbol =
              _state_machine_ptr->_flag_symbol_map[of];

          if (of_symbol->is_num()) {
            if ((of_symbol->to_int() & 0x1) == 0) {
              if (!error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            } else {
              if (error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            }
          } else {
            if (target_addr > insn.address + insn.size) {
              return std::make_pair(
                  -1, analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW);
              ;
            } else {
              return std::make_pair(-1,
                                    analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
            }
          }
          break;
        }
          //执行移动指令
        case 1: {
          return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::jnp: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      switch (exec) {
        case 0: {
          state_symbol::ptr pf_symbol =
              _state_machine_ptr->_flag_symbol_map[cf];

          if (pf_symbol->is_num()) {
            if ((pf_symbol->to_int() & 0x1) == 0) {
              if (!error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            } else {
              if (error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            }
          } else {
            if (target_addr > insn.address + insn.size) {
              return std::make_pair(
                  -1, analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW);
              ;
            } else {
              return std::make_pair(-1,
                                    analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
            }
          }
          break;
        }
          //执行移动指令
        case 1: {
          return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::jns: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      switch (exec) {
        case 0: {
          state_symbol::ptr sf_symbol =
              _state_machine_ptr->_flag_symbol_map[cf];

          if (sf_symbol->is_num()) {
            if ((sf_symbol->to_int() & 0x1) == 0) {
              if (!error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            } else {
              if (error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            }
          } else {
            if (target_addr > insn.address + insn.size) {
              return std::make_pair(
                  -1, analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW);
              ;
            } else {
              return std::make_pair(-1,
                                    analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
            }
          }
          break;
        }
          //执行移动指令
        case 1: {
          return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::jo: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      switch (exec) {
        case 0: {
          state_symbol::ptr of_symbol =
              _state_machine_ptr->_flag_symbol_map[cf];

          if (of_symbol->is_num()) {
            if ((of_symbol->to_int() & 0x1) == 1) {
              if (!error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            } else {
              if (error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            }
          } else {
            if (target_addr > insn.address + insn.size) {
              return std::make_pair(
                  -1, analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW);
              ;
            } else {
              return std::make_pair(-1,
                                    analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
            }
          }
          break;
        }
          //执行移动指令
        case 1: {
          return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::jp: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      switch (exec) {
        case 0: {
          state_symbol::ptr pf_symbol =
              _state_machine_ptr->_flag_symbol_map[cf];

          if (pf_symbol->is_num()) {
            if ((pf_symbol->to_int() & 0x1) == 1) {
              if (!error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            } else {
              if (error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            }
          } else {
            if (target_addr > insn.address + insn.size) {
              return std::make_pair(
                  -1, analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW);
              ;
            } else {
              return std::make_pair(-1,
                                    analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
            }
          }
          break;
        }
          //执行移动指令
        case 1: {
          return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::js: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      switch (exec) {
        case 0: {
          state_symbol::ptr sf_symbol =
              _state_machine_ptr->_flag_symbol_map[cf];

          if (sf_symbol->is_num()) {
            if ((sf_symbol->to_int() & 0x1) == 1) {
              if (!error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            } else {
              if (error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            }
          } else {
            if (target_addr > insn.address + insn.size) {
              return std::make_pair(
                  -1, analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW);
              ;
            } else {
              return std::make_pair(-1,
                                    analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
            }
          }
          break;
        }
          //执行移动指令
        case 1: {
          return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::jcxz: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      switch (exec) {
        case 0: {
          state_symbol::ptr rcx_symbol =
              _state_machine_ptr
                  ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                         ->get_abstract_addr(X86_REG_RCX, 8)];

          if (rcx_symbol->is_num()) {
            if ((rcx_symbol->to_int() & 0xffffLL) == 0) {
              if (!error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            } else {
              if (error_path) {
                return std::make_pair(target_addr,
                                      analyze_result::CONTINUE_ANALYZE);
              }
            }
          } else {
            if (target_addr > insn.address + insn.size) {
              return std::make_pair(
                  -1, analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW);
              ;
            } else {
              return std::make_pair(-1,
                                    analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
            }
          }
          break;
        }
          //执行移动指令
        case 1: {
          return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::jmp: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      uint64_t target_addr = 0;
      if (source_symbol->is_num()) {
        target_addr = source_symbol->to_int();
        return std::make_pair(target_addr, analyze_result::CONTINUE_ANALYZE);
      } else {
        return std::make_pair(-1, analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
      }
      break;
    }
    case instruction_type::type::jmps: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::jmpf: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::lahf: {
      //用于将当前标志寄存器（EFLAGS）的低8位加载到AH寄存器中
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::lds: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::lea: {
      abstract_addr::ptr target_addr;
      state_symbol::ptr target_symbol;
      analyze_operator(insn.detail->x86.operands[0], target_addr, target_symbol,
                       false, control_leak_state, exec_mode);

      state_symbol::ptr base_symbol_ptr;
      state_symbol::ptr index_symbol_ptr;
      x86_op_mem mem = insn.detail->x86.operands[1].mem;
      char size = insn.detail->x86.operands[1].size;
      bool base_effect = false;
      //获取base对应的symbol
      if (mem.base == X86_REG_INVALID) {
        base_symbol_ptr = std::make_shared<state_symbol>(0, size);
      } else {
        base_effect = true;
        abstract_addr::ptr mem_base_addr =
            _generatr_abstract_addr_tool_ptr->get_abstract_addr(mem.base, size);

        base_symbol_ptr =
            _state_machine_ptr->get_symbol_from_addr(mem_base_addr);
        if (base_symbol_ptr == nullptr) {
          std::vector<std::string> taine_vector = {};
          base_symbol_ptr = _state_machine_ptr->generate_symbol_for_addr(
              mem_base_addr, get_symbol_str(_random, _dist), taine_vector,
              size);
        }
      }
      state_symbol::ptr addr;
      if (mem.index != X86_REG_INVALID) {
        //获取index对应的symbol
        bool index_effect = false;

        index_effect = true;
        index_symbol_ptr = _state_machine_ptr->get_symbol_from_addr(
            _generatr_abstract_addr_tool_ptr->get_abstract_addr(mem.index,
                                                                size));
        if (index_symbol_ptr == nullptr) {
          index_symbol_ptr = _state_machine_ptr->generate_symbol_for_addr(
              _generatr_abstract_addr_tool_ptr->get_abstract_addr(mem.index,
                                                                  size),
              get_symbol_str(_random, _dist), {}, size);
        }

        //计算出应该访问的地址的symbol
        state_symbol::ptr disp;
        if (mem.disp < 0) {
          auto tmp = state_symbol(-mem.disp);
          disp = std::make_shared<state_symbol>(state_symbol(0) - tmp, 8);
        } else {
          disp = std::make_shared<state_symbol>(mem.disp, 8);
        }
        // 计算出了问题

        auto tmp_addr =
            base_symbol_ptr
                ->op_add(index_symbol_ptr->op_mul(state_symbol(mem.scale, 8)))
                .op_add(disp);
        addr = std::make_shared<state_symbol>(tmp_addr);
        bool can_up_taine = false;
        {
          int num = 0;
          if (base_effect) {
            ++num;
          }
          if (index_effect && (mem.scale != 0)) {
            ++num;
          }
          // if (mem.disp != 0) {
          //   ++num;
          // }
          if (num == 2) {
            if (!base_symbol_ptr->judge_taine_same(index_symbol_ptr) &&
                base_symbol_ptr->get_symbol_mem_effect() &&
                index_symbol_ptr->get_symbol_mem_effect()) {
              can_up_taine = true;
            }
            int num = 0;
            if ((base_symbol_ptr->is_num() &&
                 base_symbol_ptr->to_int() > 0xfffff)) {
              ++num;
            }
            if ((index_symbol_ptr->is_num() &&
                 index_symbol_ptr->to_int() > 0xfffff)) {
              ++num;
            }
            if (num == 1 && (base_symbol_ptr->get_symbol_mem_effect() ||
                             index_symbol_ptr->get_symbol_mem_effect())) {
              can_up_taine = true;
            }
          }
        }
        if (can_up_taine) {
          tmp_addr.set_can_up_taine_lv_true();
        }

      } else {
        state_symbol::ptr disp;
        if (mem.disp < 0) {
          auto tmp = state_symbol(-mem.disp);
          disp = std::make_shared<state_symbol>(state_symbol(0) - tmp, 8);
        } else {
          disp = std::make_shared<state_symbol>(mem.disp, 8);
        }
        if (mem.disp != 0) {
          auto tmp_addr = base_symbol_ptr->op_add(disp);
          addr = std::make_shared<state_symbol>(tmp_addr);
        } else {
          addr = std::make_shared<state_symbol>(base_symbol_ptr);
        }
      }
      set_target_symbol(target_addr, addr);

      break;
    }
    case instruction_type::type::les: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::lfence: {
      return std::make_pair(-1, analyze_result::NO_ATTACT);
      break;
    }
    case instruction_type::type::lods: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::lodsb: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::lodsw: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::loop: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::loope: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::loopne: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::loopnz: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::loopz: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::mfence: {
      return std::make_pair(-1, analyze_result::NO_ATTACT);
      break;
    }
    case instruction_type::type::neg: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }
      state_symbol::ptr res_symbol;
      if (source_symbol->is_num()) {
        uint64_t source_num = source_symbol->to_int();
        switch (insn.detail->x86.operands[0].size) {
          case 8: {
            source_num = -source_num;
            break;
          }
          case 4: {
            source_num = (-source_num) & 0xffffffffLL;
            break;
          }
          case 2: {
            source_num = (-source_num) & 0xffffLL;
            break;
          }
          case 1: {
            source_num = (-source_num) & 0xffLL;
            break;
          }
        }
        res_symbol = std::make_shared<state_symbol>(
            source_num, insn.detail->x86.operands[0].size);
      } else {
        state_symbol res = state_symbol(0, insn.detail->x86.operands[0].size)
                               .op_sub(source_symbol);
        res_symbol = std::make_shared<state_symbol>(res);
      }
      set_target_symbol(source_addr, res_symbol);
      break;
    }
    case instruction_type::type::nop: {
      //空指令
      break;
    }
    case instruction_type::type::NOT: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }

      state_symbol::ptr res_symbol;
      if (source_symbol->is_num()) {
        uint64_t source_num = source_symbol->to_int();
        switch (insn.detail->x86.operands[0].size) {
          case 8: {
            source_num = ~source_num;
            break;
          }
          case 4: {
            source_num = (~source_num) & 0xffffffffLL;
            break;
          }
          case 2: {
            source_num = (~source_num) & 0xffffLL;
            break;
          }
          case 1: {
            source_num = (~source_num) & 0xffLL;
            break;
          }
        }
        res_symbol = std::make_shared<state_symbol>(
            source_num, insn.detail->x86.operands[0].size);
      } else {
        state_symbol res = source_symbol->op_not();
        res_symbol = std::make_shared<state_symbol>(res);
      }
      set_target_symbol(source_addr, res_symbol);
      break;
    }
    case instruction_type::type::bswap: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      state_symbol::ptr res_symbol;
      if (source_symbol->is_num()) {
        uint64_t source_num = source_symbol->to_int();
        uint64_t first = source_num & 0xffLL;
        uint64_t second = (source_num & 0xff00LL) >> 8;
        uint64_t thr = (source_num & 0xff0000LL) >> 16;
        uint64_t four = (source_num & 0xff000000LL) >> 24;
        source_num = (first << 24) + (second << 16) + (thr << 8) + four;

        res_symbol = std::make_shared<state_symbol>(
            source_num, insn.detail->x86.operands[0].size);
      } else {
        res_symbol = std::make_shared<state_symbol>(
            get_symbol_str(_random, _dist), insn.detail->x86.operands[0].size,
            source_symbol->_taine_effect_vector);
        {
          res_symbol->_size_xh_symbol =
              std::make_shared<state_symbol>(res_symbol->to_string() + "xh", 1,
                                             res_symbol->_taine_effect_vector);
          res_symbol->_size_xl_symbol =
              std::make_shared<state_symbol>(res_symbol, 1);
          res_symbol->_size_16_symbol =
              std::make_shared<state_symbol>(res_symbol, 2);
          res_symbol->_size_16_symbol->_size_xh_symbol =
              res_symbol->_size_xh_symbol;
          res_symbol->_size_16_symbol->_size_xl_symbol =
              res_symbol->_size_xl_symbol;
        }
      }
      set_target_symbol(source_addr, res_symbol);
      break;
    }
    case instruction_type::type::OR: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[1], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      abstract_addr::ptr target_addr;
      state_symbol::ptr target_symbol;
      state_symbol::ptr old_target_symbol;
      char target_type =
          analyze_operator(insn.detail->x86.operands[0], target_addr,
                           target_symbol, true, control_leak_state, exec_mode);
      if (target_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (target_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (source_symbol->is_num()) {
        uint64_t num = source_symbol->to_int();
        if (num % 2 == 1 && target_symbol->_taine == taine_enum::taine2) {
          auto symbol = generate_symbol(
              get_symbol_str(_random, _dist), insn.detail->x86.operands[0].size,
              {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
          set_target_symbol(target_addr, symbol, true);
          break;
        }
      }
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }

      state_symbol res = target_symbol->op_or(source_symbol);

      state_symbol::ptr res_symbol = std::make_shared<state_symbol>(res);

      // res_symbol->set_can_up_taine_lv_true();
      set_target_symbol(target_addr, res_symbol);
      break;
    }
    case instruction_type::type::out: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::pop: {
      abstract_addr::ptr operator_addr;
      state_symbol::ptr operator_symbol;
      char operator_type = analyze_operator(
          insn.detail->x86.operands[0], operator_addr, operator_symbol, false,
          control_leak_state, exec_mode);
      if (operator_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (operator_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      cs_x86_op rsp = cs_x86_op();
      rsp.type = X86_OP_REG;
      rsp.reg = X86_REG_RSP;
      rsp.size = 8;
      abstract_addr::ptr rsp_addr;
      state_symbol::ptr rsp_symbol;
      analyze_operator(rsp, rsp_addr, rsp_symbol, true, control_leak_state,
                       exec_mode);

      state_symbol new_rsp_symbol =
          rsp_symbol->op_add(state_symbol(insn.detail->x86.operands[0].size));
      state_symbol::ptr stack_symbol;
      abstract_addr::ptr stack_addr =
          _generatr_abstract_addr_tool_ptr->get_abstract_addr(
              rsp_symbol, insn.detail->x86.operands[0].size);

      if (_state_machine_ptr->_addr_symbol_map.count(stack_addr)) {
        stack_symbol = _state_machine_ptr->_addr_symbol_map[stack_addr];
      } else if (insn.detail->x86.operands[0].reg != X86_REG_RBP &&
                 insn.detail->x86.operands[0].reg != X86_REG_RSP) {
        stack_symbol = generate_symbol(
            get_symbol_str(_random, _dist), 8,
            {get_taine_string(taine_enum::taine1, _random, _dist)});
      } else {
        stack_symbol = generate_symbol(
            get_symbol_str(_random, _dist), 8,
            {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
      }
      set_target_symbol(operator_addr, stack_symbol);
      set_target_symbol(rsp_addr,
                        std::make_shared<state_symbol>(new_rsp_symbol));
      break;
    }
    case instruction_type::type::popf: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::push: {
      abstract_addr::ptr operator_addr;
      state_symbol::ptr operator_symbol;
      char operator_type = analyze_operator(
          insn.detail->x86.operands[0], operator_addr, operator_symbol, true,
          control_leak_state, exec_mode);

      if (operator_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (operator_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      cs_x86_op rsp = cs_x86_op();
      rsp.type = X86_OP_REG;
      rsp.reg = X86_REG_RSP;
      abstract_addr::ptr rsp_addr;
      state_symbol::ptr rsp_symbol;
      analyze_operator(rsp, rsp_addr, rsp_symbol, true, control_leak_state,
                       exec_mode);

      state_symbol new_rsp_symbol =
          rsp_symbol->op_sub(state_symbol(insn.detail->x86.operands[0].size));

      abstract_addr::ptr stack_addr =
          _generatr_abstract_addr_tool_ptr->get_abstract_addr(
              new_rsp_symbol, insn.detail->x86.operands[0].size);
      set_target_symbol(stack_addr, operator_symbol);
      set_target_symbol(rsp_addr,
                        std::make_shared<state_symbol>(new_rsp_symbol));

      break;
    }
    case instruction_type::type::pushf: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::retn: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::retf: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::shl: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }

      abstract_addr::ptr bit_addr;
      state_symbol::ptr bit_symbol;
      char bit_type =
          analyze_operator(insn.detail->x86.operands[1], bit_addr, bit_symbol,
                           true, control_leak_state, exec_mode);
      if (bit_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (bit_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (source_symbol->_taine == taine_enum::taine2) {
        if (bit_symbol->is_num()) {
          auto num = bit_symbol->to_int();
          if (num >= 8) {
            auto symbol = generate_symbol(
                get_symbol_str(_random, _dist),
                source_symbol->get_symbol_size(),
                {get_taine_string(source_symbol->_taine, _random, _dist)});
            symbol->_size_xl_symbol = std::make_shared<state_symbol>(0, 1);
            if (symbol->_size_16_symbol != nullptr) {
              symbol->_size_16_symbol->_size_xl_symbol =
                  symbol->_size_xl_symbol;
            }
            if (symbol->_size_32_symbol != nullptr) {
              symbol->_size_32_symbol->_size_xl_symbol =
                  symbol->_size_xl_symbol;
            }
            if (symbol->_size_64_symbol != nullptr) {
              symbol->_size_64_symbol->_size_xl_symbol =
                  symbol->_size_xl_symbol;
            }
            if (source_symbol->_mem_effect) {
              symbol->_mem_effect = true;
            }
            if (source_symbol->_taine == taine_enum::taine2) {
              symbol->_taine2_with_mul_or_left_shift = true;
              if (symbol->_size_32_symbol != nullptr) {
                symbol->_size_32_symbol->_taine2_with_mul_or_left_shift = true;
              }
              if (symbol->_size_16_symbol != nullptr) {
                symbol->_size_16_symbol->_taine2_with_mul_or_left_shift = true;
              }
            }
            set_target_symbol(source_addr, symbol);
          }
        }
        break;
      } else if (source_symbol->_taine == taine_enum::taine1) {
        if (bit_symbol->is_num()) {
          auto num = bit_symbol->to_int();
          if (num > 1) {
            set_target_symbol(
                source_addr,
                generate_symbol(get_symbol_str(_random, _dist),
                                source_symbol->get_symbol_size(),
                                {get_taine_string(taine_enum::not_a_tine,
                                                  _random, _dist)}));
          }
        }
        break;
      }

      state_symbol res = source_symbol->op_left_shift(bit_symbol);
      state_symbol::ptr res_symbol = std::make_shared<state_symbol>(res);

      set_target_symbol(source_addr, res_symbol);
      break;
    }
    case instruction_type::type::shr: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);

      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }

      abstract_addr::ptr bit_addr;
      state_symbol::ptr bit_symbol;
      char bit_type =
          analyze_operator(insn.detail->x86.operands[1], bit_addr, bit_symbol,
                           true, control_leak_state, exec_mode);
      if (bit_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (bit_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (source_symbol->_taine == taine_enum::taine2) {
        set_target_symbol(
            source_addr,
            generate_symbol(
                get_symbol_str(_random, _dist),
                source_symbol->get_symbol_size(),
                {get_taine_string(taine_enum::not_a_tine, _random, _dist)}));
        break;
      }

      state_symbol res = source_symbol->op_right_shift(bit_symbol);
      state_symbol::ptr res_symbol = std::make_shared<state_symbol>(res);
      set_target_symbol(source_addr, res_symbol);

      break;
    }
    case instruction_type::type::sal: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);

      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }

      abstract_addr::ptr bit_addr;
      state_symbol::ptr bit_symbol;
      char bit_type =
          analyze_operator(insn.detail->x86.operands[1], bit_addr, bit_symbol,
                           true, control_leak_state, exec_mode);
      if (bit_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (bit_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (source_symbol->_taine == taine_enum::taine2) {
        set_target_symbol(source_addr,
                          generate_symbol(get_symbol_str(_random, _dist),
                                          source_symbol->get_symbol_size(),
                                          {get_taine_string(taine_enum::taine1,
                                                            _random, _dist)}));
        break;
      }

      state_symbol res = source_symbol->op_left_shift(bit_symbol);

      state_symbol::ptr res_symbol = std::make_shared<state_symbol>(res);
      set_target_symbol(source_addr, res_symbol);

      break;
    }
    case instruction_type::type::sar: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);

      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }

      abstract_addr::ptr bit_addr;
      state_symbol::ptr bit_symbol;
      char bit_type =
          analyze_operator(insn.detail->x86.operands[1], bit_addr, bit_symbol,
                           true, control_leak_state, exec_mode);
      if (bit_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (bit_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (source_symbol->_taine == taine_enum::taine2) {
        set_target_symbol(
            source_addr,
            generate_symbol(
                get_symbol_str(_random, _dist),
                source_symbol->get_symbol_size(),
                {get_taine_string(taine_enum::not_a_tine, _random, _dist)}));
        break;
      }

      state_symbol res = source_symbol->op_right_shift(bit_symbol);
      state_symbol::ptr res_symbol = std::make_shared<state_symbol>(res);
      set_target_symbol(source_addr, res_symbol);
      break;
    }
    case instruction_type::type::rol: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);

      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }

      abstract_addr::ptr bit_addr;
      state_symbol::ptr bit_symbol;
      char bit_type =
          analyze_operator(insn.detail->x86.operands[1], bit_addr, bit_symbol,
                           true, control_leak_state, exec_mode);
      if (bit_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (bit_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (source_symbol->_taine == taine_enum::taine2) {
        set_target_symbol(
            source_addr,
            generate_symbol(
                get_symbol_str(_random, _dist),
                source_symbol->get_symbol_size(),
                {get_taine_string(taine_enum::not_a_tine, _random, _dist)}));
        break;
      }

      if (source_symbol->is_num() && bit_symbol->is_num()) {
        uint64_t source_num = source_symbol->to_int();
        uint64_t bit_num = bit_symbol->to_int();
        uint64_t res_num;
        switch (insn.detail->x86.operands[0].size) {
          case 8: {
            uint64_t mask = 0xffffffffffffffffLL << (64 - bit_num);
            res_num = (source_num & mask) >> (64 - bit_num);
            break;
          }
          case 4: {
            uint64_t mask =
                (0xffffffffffffffffLL << (32 - bit_num)) & 0xffffffffLL;
            res_num = (source_num & mask) >> (32 - bit_num);
            break;
          }
          case 2: {
            uint64_t mask = (0xffffffffffffffffLL << (16 - bit_num)) & 0xffffLL;
            res_num = (source_num & mask) >> (16 - bit_num);
            break;
          }
          case 1: {
            uint64_t mask = (0xffffffffffffffffLL << (8 - bit_num)) & 0xffLL;
            res_num = (source_num & mask) >> (8 - bit_num);
            break;
          }
        }
        set_target_symbol(source_addr,
                          std::make_shared<state_symbol>(
                              res_num, insn.detail->x86.operands[0].size));
      } else {
        set_target_symbol(
            source_addr,
            generate_symbol(
                get_symbol_str(_random, _dist),
                insn.detail->x86.operands[0].size,
                {get_taine_string(source_symbol->_taine, _random, _dist)}));
      }
      break;
    }
    case instruction_type::type::ror: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }
      abstract_addr::ptr bit_addr;
      state_symbol::ptr bit_symbol;
      char bit_type =
          analyze_operator(insn.detail->x86.operands[1], bit_addr, bit_symbol,
                           true, control_leak_state, exec_mode);
      if (bit_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (bit_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (source_symbol->_taine == taine_enum::taine2) {
        set_target_symbol(
            source_addr,
            generate_symbol(
                get_symbol_str(_random, _dist),
                source_symbol->get_symbol_size(),
                {get_taine_string(taine_enum::not_a_tine, _random, _dist)}));
        break;
      }

      if (source_symbol->is_num() && bit_symbol->is_num()) {
        uint64_t source_num = source_symbol->to_int();
        uint64_t res_num;
        uint64_t bit_num = bit_symbol->to_int();
        switch (insn.detail->x86.operands[0].size) {
          case 8: {
            uint64_t mask = ~(0xffffffffffffffffLL << bit_num);
            res_num = (source_num & mask) << (64 - bit_num);
            break;
          }
          case 4: {
            uint64_t mask = ~(0xffffffffffffffffLL << bit_num);
            res_num = (source_num & mask) >> (32 - bit_num);
            break;
          }
          case 2: {
            uint64_t mask = ~(0xffffffffffffffffLL << bit_num);
            res_num = (source_num & mask) >> (16 - bit_num);
            break;
          }
          case 1: {
            uint64_t mask = ~(0xffffffffffffffffLL << bit_num);
            res_num = (source_num & mask) >> (8 - bit_num);
            break;
          }
        }
        set_target_symbol(source_addr,
                          std::make_shared<state_symbol>(
                              res_num, insn.detail->x86.operands[0].size));
      } else {
        set_target_symbol(
            source_addr,
            generate_symbol(
                get_symbol_str(_random, _dist),
                insn.detail->x86.operands[0].size,
                {get_taine_string(source_symbol->_taine, _random, _dist)}));
      }
      break;
    }
    case instruction_type::type::rcl: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }
      abstract_addr::ptr bit_addr;
      state_symbol::ptr bit_symbol;
      char bit_type =
          analyze_operator(insn.detail->x86.operands[1], bit_addr, bit_symbol,
                           true, control_leak_state, exec_mode);
      if (bit_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (bit_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      if (source_symbol->_taine == taine_enum::taine2) {
        set_target_symbol(
            source_addr,
            generate_symbol(
                get_symbol_str(_random, _dist),
                source_symbol->get_symbol_size(),
                {get_taine_string(taine_enum::not_a_tine, _random, _dist)}));
        break;
      }

      if (source_symbol->is_num() && bit_symbol->is_num()) {
        uint64_t source_num = source_symbol->to_int();
        uint64_t res_num;
        uint64_t bit_num = bit_symbol->to_int();
        switch (insn.detail->x86.operands[0].size) {
          case 8: {
            uint64_t mask = 0xffffffffffffffffLL << (64 - bit_num);
            res_num = (source_num & mask) >> (64 - bit_num);
            break;
          }
          case 4: {
            uint64_t mask =
                (0xffffffffffffffffLL << (32 - bit_num)) & 0xffffffffLL;
            uint64_t tmp = (source_num & mask) >> (32 - bit_num);
            res_num = (source_num << bit_num) & 0xffffffffLL;
            break;
          }
          case 2: {
            uint64_t mask = (0xffffffffffffffffLL << (16 - bit_num)) & 0xffffLL;
            res_num = (source_num & mask) >> (16 - bit_num);
            break;
          }
          case 1: {
            uint64_t mask = (0xffffffffffffffffLL << (8 - bit_num)) & 0xffLL;
            res_num = (source_num & mask) >> (8 - bit_num);
            break;
          }
        }
        set_target_symbol(source_addr,
                          std::make_shared<state_symbol>(
                              res_num, insn.detail->x86.operands[0].size));
      } else {
        set_target_symbol(
            source_addr,
            generate_symbol(
                get_symbol_str(_random, _dist),
                insn.detail->x86.operands[0].size,
                {get_taine_string(source_symbol->_taine, _random, _dist)}));
      }
      break;
    }
    case instruction_type::type::rcr: {
      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      char source_type =
          analyze_operator(insn.detail->x86.operands[0], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }
      abstract_addr::ptr bit_addr;
      state_symbol::ptr bit_symbol;
      char bit_type =
          analyze_operator(insn.detail->x86.operands[1], bit_addr, bit_symbol,
                           true, control_leak_state, exec_mode);
      if (bit_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (bit_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      if (source_symbol->_taine == taine_enum::taine2) {
        set_target_symbol(
            source_addr,
            generate_symbol(
                get_symbol_str(_random, _dist),
                source_symbol->get_symbol_size(),
                {get_taine_string(taine_enum::not_a_tine, _random, _dist)}));
        break;
      }

      if (source_symbol->is_num() && bit_symbol->is_num()) {
        uint64_t source_num = source_symbol->to_int();
        uint64_t res_num;
        uint64_t bit_num = bit_symbol->to_int();
        switch (insn.detail->x86.operands[0].size) {
          case 8: {
            uint64_t mask = ~(0xffffffffffffffffLL << bit_num);
            res_num = (source_num & mask) << (64 - bit_num);
            break;
          }
          case 4: {
            uint64_t mask = ~(0xffffffffffffffffLL << bit_num);
            res_num = (source_num & mask) >> (32 - bit_num);
            break;
          }
          case 2: {
            uint64_t mask = ~(0xffffffffffffffffLL << bit_num);
            res_num = (source_num & mask) >> (16 - bit_num);
            break;
          }
          case 1: {
            uint64_t mask = ~(0xffffffffffffffffLL << bit_num);
            res_num = (source_num & mask) >> (8 - bit_num);
            break;
          }
        }
        set_target_symbol(source_addr,
                          std::make_shared<state_symbol>(
                              res_num, insn.detail->x86.operands[0].size));
      } else {
        set_target_symbol(
            source_addr,
            generate_symbol(
                get_symbol_str(_random, _dist),
                insn.detail->x86.operands[0].size,
                {get_taine_string(source_symbol->_taine, _random, _dist)}));
      }
      break;
    }
    case instruction_type::type::ret: {
      cs_x86_op rsp = cs_x86_op();
      rsp.type = X86_OP_REG;
      rsp.reg = X86_REG_RSP;
      rsp.size = 8;
      abstract_addr::ptr rsp_addr;
      state_symbol::ptr rsp_symbol;
      analyze_operator(rsp, rsp_addr, rsp_symbol, true, control_leak_state,
                       exec_mode);

      state_symbol new_rsp_symbol =
          rsp_symbol->op_add(state_symbol(is_32 ? 4 : 8));

      state_symbol::ptr stack_symbol;
      abstract_addr::ptr stack_addr =
          _generatr_abstract_addr_tool_ptr->get_abstract_addr(rsp_symbol,
                                                              is_32 ? 4 : 8);

      if (_state_machine_ptr->_addr_symbol_map.count(stack_addr)) {
        stack_symbol = _state_machine_ptr->_addr_symbol_map[stack_addr];
      } else {
        return std::make_pair(-1, analyze_result::RET_INSTRUCTION);
      }
      set_target_symbol(rsp_addr,
                        std::make_shared<state_symbol>(new_rsp_symbol));
      if (stack_symbol->is_num()) {
        return std::make_pair(stack_symbol->to_int(),
                              analyze_result::CONTINUE_ANALYZE);
      } else {
        return std::make_pair(-1, analyze_result::RET_INSTRUCTION);
      }

      break;
    }
    case instruction_type::type::sahf: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::salc: {
      //如果CF=1，则AL寄存器的值将被设置为1。
      //如果CF=0，则AL寄存器的值将被设置为0。
      state_symbol::ptr cf_symbol = _state_machine_ptr->_flag_symbol_map[cf];
      state_symbol::ptr rax_symbol =
          _state_machine_ptr
              ->_addr_symbol_map[_generatr_abstract_addr_tool_ptr
                                     ->get_abstract_addr(X86_REG_RAX, 8)];
      state_symbol::ptr res_symbol;
      if (cf_symbol->is_num() && rax_symbol->is_num()) {
        uint64_t rax_num = rax_symbol->to_int();
        if (cf_symbol->to_int() == 0) {
          rax_num = rax_num & 0xffffffffffff00ffLL;
        } else {
          rax_num = rax_num | 0xff00LL;
        }
        res_symbol = std::make_shared<state_symbol>(rax_num, 8);
      } else {
        res_symbol = generate_symbol(
            get_symbol_str(_random, _dist), 8,
            {get_taine_string(rax_symbol->_taine, _random, _dist)});
      }
      set_target_symbol(
          _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RAX, 8),
          res_symbol);
      break;
    }
    case instruction_type::type::sbb: {
      abstract_addr::ptr source_addr;
      abstract_addr::ptr target_addr;
      state_symbol::ptr source_symbol;
      state_symbol::ptr target_symbol;

      uint64_t source_num;
      uint64_t target_num;

      char target_type =
          analyze_operator(insn.detail->x86.operands[0], target_addr,
                           target_symbol, true, control_leak_state, exec_mode);
      if (target_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (target_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      char source_type =
          analyze_operator(insn.detail->x86.operands[1], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }

      state_symbol::ptr cf_symbol = _state_machine_ptr->_flag_symbol_map[cf];

      state_symbol res = target_symbol->op_sub(source_symbol).op_sub(cf_symbol);
      state_symbol::ptr res_symbol = std::make_shared<state_symbol>(res);

      set_target_symbol(target_addr, res_symbol);
      break;
    }
    case instruction_type::type::scasb: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::scasw: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::sfence: {
      return std::make_pair(-1, analyze_result::NO_ATTACT);
      break;
    }
    case instruction_type::type::stc: {
      _state_machine_ptr->_flag_symbol_map[cf] =
          std::make_shared<state_symbol>(1, 1);
      break;
    }
    case instruction_type::type::STD: {
      _state_machine_ptr->_flag_symbol_map[df] =
          std::make_shared<state_symbol>(1, 1);
      break;
    }
    case instruction_type::type::sti: {
      //设置中断标记没什么用处
      break;
    }
    case instruction_type::type::stosb: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::stosw: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::sub: {
      abstract_addr::ptr source_addr;
      abstract_addr::ptr target_addr;
      state_symbol::ptr source_symbol;
      state_symbol::ptr target_symbol;

      uint64_t source_num;
      uint64_t target_num;

      char target_type =
          analyze_operator(insn.detail->x86.operands[0], target_addr,
                           target_symbol, true, control_leak_state, exec_mode);
      if (target_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (target_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }

      char source_type =
          analyze_operator(insn.detail->x86.operands[1], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }

      state_symbol::ptr res_symbol =
          std::make_shared<state_symbol>(target_symbol->op_sub(source_symbol));
      set_target_symbol(target_addr, res_symbol);

      if (res_symbol->is_num()) {
        uint64_t res_number = res_symbol->to_int();
        //具体运算设置标志位zf sf pf
        {
          switch (insn.detail->x86.operands[0].size) {
            case 8: {
              _state_machine_ptr->_flag_symbol_map[sf] =
                  std::make_shared<state_symbol>(res_number >> 63, 1);
              _state_machine_ptr->_flag_symbol_map[zf] =
                  std::make_shared<state_symbol>(res_number == 0 ? 1 : 0, 1);
              _state_machine_ptr->_flag_symbol_map[pf] =
                  std::make_shared<state_symbol>(
                      (get_1_num(res_number) + 1) % 2, 1);
              break;
            }
            case 4: {
              _state_machine_ptr->_flag_symbol_map[sf] =
                  std::make_shared<state_symbol>(
                      (res_number & 0xffffffffLL) >> 31, 1);
              _state_machine_ptr->_flag_symbol_map[zf] =
                  std::make_shared<state_symbol>(
                      (res_number & 0xffffffffLL) == 0 ? 1 : 0, 1);
              _state_machine_ptr->_flag_symbol_map[pf] =
                  std::make_shared<state_symbol>(
                      (get_1_num(res_number & 0xffffffffLL) + 1) % 2, 1);
              break;
            }
            case 2: {
              _state_machine_ptr->_flag_symbol_map[sf] =
                  std::make_shared<state_symbol>((res_number & 0xffffLL) >> 15,
                                                 1);
              _state_machine_ptr->_flag_symbol_map[zf] =
                  std::make_shared<state_symbol>(
                      (res_number & 0xffffLL) == 0 ? 1 : 0, 1);
              _state_machine_ptr->_flag_symbol_map[pf] =
                  std::make_shared<state_symbol>(
                      (get_1_num(res_number & 0xffffLL) + 1) % 2, 1);
              break;
            }
            case 1: {
              _state_machine_ptr->_flag_symbol_map[sf] =
                  std::make_shared<state_symbol>((res_number & 0xffLL) >> 7, 1);
              _state_machine_ptr->_flag_symbol_map[zf] =
                  std::make_shared<state_symbol>(
                      (res_number & 0xffLL) == 0 ? 1 : 0, 1);
              _state_machine_ptr->_flag_symbol_map[pf] =
                  std::make_shared<state_symbol>(
                      (get_1_num(res_number & 0xffffLL) + 1) % 2, 1);
            }
          }
        }
        //设置标志位 of cf
        if (target_symbol->is_num() && source_symbol->is_num()) {
          uint64_t target_number = target_symbol->to_int();
          uint64_t source_number = source_symbol->to_int();
          switch (insn.detail->x86.operands[0].size) {
            case 8: {
              _state_machine_ptr->_flag_symbol_map[cf] =
                  std::make_shared<state_symbol>(
                      target_number < source_number ? 1 : 0, 1);
              if (((judge_sign(source_number, 8) ^
                    judge_sign(target_number, 8)) &&
                   (judge_sign(source_number, 8) ^
                    judge_sign(res_number, 8)))) {
                _state_machine_ptr->_flag_symbol_map[of] =
                    std::make_shared<state_symbol>(1, 1);
              } else {
                _state_machine_ptr->_flag_symbol_map[of] =
                    std::make_shared<state_symbol>(0, 1);
              }
            }
            case 4: {
              _state_machine_ptr->_flag_symbol_map[cf] =
                  std::make_shared<state_symbol>(
                      (target_number & 0xffffffffLL) <
                              (source_number & 0xffffffffLL)
                          ? 1
                          : 0,
                      1);
              if (((judge_sign(source_number & 0xffffffffLL, 4) ^
                    judge_sign(target_number & 0xffffffffLL, 4)) &&
                   (judge_sign(source_number & 0xffffffffLL, 4) ^
                    judge_sign(res_number & 0xffffffffLL, 4)))) {
                _state_machine_ptr->_flag_symbol_map[of] =
                    std::make_shared<state_symbol>(1, 1);
              } else {
                _state_machine_ptr->_flag_symbol_map[of] =
                    std::make_shared<state_symbol>(0, 1);
              }
            }
            case 2: {
              _state_machine_ptr->_flag_symbol_map[cf] =
                  std::make_shared<state_symbol>(
                      (target_number & 0xffffLL) < (source_number & 0xffffLL)
                          ? 1
                          : 0,
                      1);
              if (((judge_sign(source_number & 0xffffLL, 2) ^
                    judge_sign(target_number & 0xffffLL, 2)) &&
                   (judge_sign(source_number & 0xffffLL, 2) ^
                    judge_sign(res_number & 0xffffLL, 2)))) {
                _state_machine_ptr->_flag_symbol_map[of] =
                    std::make_shared<state_symbol>(1, 1);
              } else {
                _state_machine_ptr->_flag_symbol_map[of] =
                    std::make_shared<state_symbol>(0, 1);
              }
            }
            case 1: {
              _state_machine_ptr->_flag_symbol_map[cf] =
                  std::make_shared<state_symbol>(
                      target_number < source_number ? 1 : 0, 1);
              if (((judge_sign(source_number & 0xffLL, 1) ^
                    judge_sign(target_number & 0xffLL, 1)) &&
                   (judge_sign(source_number & 0xffLL, 1) ^
                    judge_sign(res_number & 0xffLL, 1)))) {
                _state_machine_ptr->_flag_symbol_map[of] =
                    std::make_shared<state_symbol>(1, 1);
              } else {
                _state_machine_ptr->_flag_symbol_map[of] =
                    std::make_shared<state_symbol>(0, 1);
              }
            }
          }
        }
        // 运算的双方不能转为int时
        else {
          //设置 of cf af 未知
          _state_machine_ptr->_flag_symbol_map[cf] =
              std::make_shared<state_symbol>(
                  "unsure" + std::to_string(_random()), 1);

          _state_machine_ptr->_flag_symbol_map[of] =
              std::make_shared<state_symbol>(
                  "unsure" + std::to_string(_random()), 1);

          _state_machine_ptr->_flag_symbol_map[af] =
              std::make_shared<state_symbol>(
                  "unsure" + std::to_string(_random()), 1);
        }

      } else {
        _state_machine_ptr->_flag_symbol_map[cf] =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist), 1);
        _state_machine_ptr->_flag_symbol_map[zf] =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist), 1);
        _state_machine_ptr->_flag_symbol_map[sf] =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist), 1);
        _state_machine_ptr->_flag_symbol_map[of] =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist), 1);
        _state_machine_ptr->_flag_symbol_map[pf] =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist), 1);
        _state_machine_ptr->_flag_symbol_map[af] =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist), 1);
      }
      break;
    }
    case instruction_type::type::cmp: {
      abstract_addr::ptr source_addr;
      abstract_addr::ptr target_addr;
      state_symbol::ptr source_symbol;
      state_symbol::ptr target_symbol;

      char target_type =
          analyze_operator(insn.detail->x86.operands[0], target_addr,
                           target_symbol, true, control_leak_state, exec_mode);
      if (exec_mode == 0 && is_cache_miss_location) {
        if (target_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              target_symbol);
        }
      }
      char source_type =
          analyze_operator(insn.detail->x86.operands[1], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }
      
      if (target_type == 3 || source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (target_type == 4 || source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      // cmp或者test的情况下将比较的双方中与branch_miss addr
      if (exec_mode == 0 && is_cmp_location) {
        // 将target相关的设置为初始污点

        if (source_symbol->judge_taine_effect(
                _state_machine_ptr->_cache_miss_symbol_vector)) {
          // 这里获取到全部有关相关符号的地址和符号映射，并进行保存
          // _mem_taine_addr_map = _state_machine_ptr->find_addr_symbol_same(
          //     target_symbol->_contain_symbol,
          //     target_symbol->get_symbol_size());
          //
          //
          // _mem_taine_addr_map =
          //     _state_machine_ptr->find_addr_contain_taine(target_symbol);

          _mem_taine_addr_map =
              _state_machine_ptr->find_addr_contain_taine_without_in(
                  target_symbol, source_symbol);
        }
        // 将source相关的设置为初始污点
        else {
          // _mem_taine_addr_map = _state_machine_ptr->find_addr_symbol_same(
          //     source_symbol->_contain_symbol,
          //     source_symbol->get_symbol_size());
          //
          // _mem_taine_addr_map =
          //     _state_machine_ptr->find_addr_contain_taine(source_symbol);

          _mem_taine_addr_map =
              _state_machine_ptr->find_addr_contain_taine_without_in(
                  source_symbol, target_symbol);
        }

        break;
      }
      if (source_symbol->get_symbol_size() > 1 &&
          source_symbol->_size_xl_symbol != nullptr &&
          source_symbol->_size_xh_symbol != nullptr &&
          source_symbol->_size_xh_symbol->_taine == taine_enum::not_a_tine) {
        source_symbol = source_symbol->_size_xl_symbol;
      }
      if (target_symbol->get_symbol_size() > 1 &&
          target_symbol->_size_xl_symbol != nullptr &&
          target_symbol->_size_xh_symbol != nullptr &&
          target_symbol->_size_xh_symbol->_taine == taine_enum::not_a_tine) {
        target_symbol = target_symbol->_size_xl_symbol;
      }

      if ((!source_symbol->judge_taine_same(target_symbol)) &&
          ((source_symbol->_taine == taine_enum::taine2 &&
            source_symbol->get_symbol_size() == 1 &&
            target_symbol->get_symbol_mem_effect()) ||
           (target_symbol->_taine == taine_enum::taine2 &&
            target_symbol->get_symbol_size() == 1 &&
            source_symbol->get_symbol_mem_effect()))) {
        //这里代表可能通过可能通过控制流泄露
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
        // return std::make_pair(-1, analyze_result::MAY_LEAK_FROM_CONTROL);
      } else if (source_symbol->_taine == taine_enum::taine2 &&
                 target_symbol->is_num()) {
        if (target_symbol->to_int() <= 255 && target_addr != nullptr &&
            (target_addr->is_register() || target_addr->is_string())) {
          //这里代表可能通过可能通过控制流泄露
          return std::make_pair(-1, analyze_result::FIND_ATTACK);
        }
      } else if (target_symbol->_taine == taine_enum::taine2 &&
                 source_symbol->is_num()) {
        if (source_symbol->to_int() <= 255 && source_addr != nullptr &&
            (source_addr->is_register() || source_addr->is_string())) {
          //这里代表可能通过可能通过控制流泄露
          return std::make_pair(-1, analyze_result::FIND_ATTACK);
        }
      }

      state_symbol res = target_symbol->op_sub(source_symbol);
      //设置标志位

      if (res.is_num()) {
        uint64_t res_number = res.to_int();
        //具体运算设置标志位zf sf pf
        {
          switch (insn.detail->x86.operands[0].size) {
            case 8: {
              _state_machine_ptr->_flag_symbol_map[sf] =
                  std::make_shared<state_symbol>(res_number >> 63, 1);
              _state_machine_ptr->_flag_symbol_map[zf] =
                  std::make_shared<state_symbol>(res_number == 0 ? 1 : 0, 1);
              _state_machine_ptr->_flag_symbol_map[pf] =
                  std::make_shared<state_symbol>(
                      (get_1_num(res_number) + 1) % 2, 1);
              break;
            }
            case 4: {
              _state_machine_ptr->_flag_symbol_map[sf] =
                  std::make_shared<state_symbol>(
                      (res_number & 0xffffffffLL) >> 31, 1);
              _state_machine_ptr->_flag_symbol_map[zf] =
                  std::make_shared<state_symbol>(
                      (res_number & 0xffffffffLL) == 0 ? 1 : 0, 1);
              _state_machine_ptr->_flag_symbol_map[pf] =
                  std::make_shared<state_symbol>(
                      (get_1_num(res_number & 0xffffffffLL) + 1) % 2, 1);
              break;
            }
            case 2: {
              _state_machine_ptr->_flag_symbol_map[sf] =
                  std::make_shared<state_symbol>((res_number & 0xffffLL) >> 15,
                                                 1);
              _state_machine_ptr->_flag_symbol_map[zf] =
                  std::make_shared<state_symbol>(
                      (res_number & 0xffffLL) == 0 ? 1 : 0, 1);
              _state_machine_ptr->_flag_symbol_map[pf] =
                  std::make_shared<state_symbol>(
                      (get_1_num(res_number & 0xffffLL) + 1) % 2, 1);
              break;
            }
            case 1: {
              _state_machine_ptr->_flag_symbol_map[sf] =
                  std::make_shared<state_symbol>((res_number & 0xffLL) >> 7, 1);
              _state_machine_ptr->_flag_symbol_map[zf] =
                  std::make_shared<state_symbol>(
                      (res_number & 0xffLL) == 0 ? 1 : 0, 1);
              _state_machine_ptr->_flag_symbol_map[pf] =
                  std::make_shared<state_symbol>(
                      (get_1_num(res_number & 0xffffLL) + 1) % 2, 1);
            }
          }
        }
        //设置标志位 of cf
        if (target_symbol->is_num() && source_symbol->is_num()) {
          uint64_t target_number = target_symbol->to_int();
          uint64_t source_number = source_symbol->to_int();
          switch (insn.detail->x86.operands[0].size) {
            case 8: {
              _state_machine_ptr->_flag_symbol_map[cf] =
                  std::make_shared<state_symbol>(
                      target_number < source_number ? 1 : 0, 1);
              if (((judge_sign(source_number, 8) ^
                    judge_sign(target_number, 8)) &&
                   (judge_sign(source_number, 8) ^
                    judge_sign(res_number, 8)))) {
                _state_machine_ptr->_flag_symbol_map[of] =
                    std::make_shared<state_symbol>(1, 1);
              } else {
                _state_machine_ptr->_flag_symbol_map[of] =
                    std::make_shared<state_symbol>(0, 1);
              }
            }
            case 4: {
              _state_machine_ptr->_flag_symbol_map[cf] =
                  std::make_shared<state_symbol>(
                      (target_number & 0xffffffffLL) <
                              (source_number & 0xffffffffLL)
                          ? 1
                          : 0,
                      1);
              if (((judge_sign(source_number & 0xffffffffLL, 4) ^
                    judge_sign(target_number & 0xffffffffLL, 4)) &&
                   (judge_sign(source_number & 0xffffffffLL, 4) ^
                    judge_sign(res_number & 0xffffffffLL, 4)))) {
                _state_machine_ptr->_flag_symbol_map[of] =
                    std::make_shared<state_symbol>(1, 1);
              } else {
                _state_machine_ptr->_flag_symbol_map[of] =
                    std::make_shared<state_symbol>(0, 1);
              }
            }
            case 2: {
              _state_machine_ptr->_flag_symbol_map[cf] =
                  std::make_shared<state_symbol>(
                      (target_number & 0xffffLL) < (source_number & 0xffffLL)
                          ? 1
                          : 0,
                      1);
              if (((judge_sign(source_number & 0xffffLL, 2) ^
                    judge_sign(target_number & 0xffffLL, 2)) &&
                   (judge_sign(source_number & 0xffffLL, 2) ^
                    judge_sign(res_number & 0xffffLL, 2)))) {
                _state_machine_ptr->_flag_symbol_map[of] =
                    std::make_shared<state_symbol>(1, 1);
              } else {
                _state_machine_ptr->_flag_symbol_map[of] =
                    std::make_shared<state_symbol>(0, 1);
              }
            }
            case 1: {
              _state_machine_ptr->_flag_symbol_map[cf] =
                  std::make_shared<state_symbol>(
                      target_number < source_number ? 1 : 0, 1);
              if (((judge_sign(source_number & 0xffLL, 1) ^
                    judge_sign(target_number & 0xffLL, 1)) &&
                   (judge_sign(source_number & 0xffLL, 1) ^
                    judge_sign(res_number & 0xffLL, 1)))) {
                _state_machine_ptr->_flag_symbol_map[of] =
                    std::make_shared<state_symbol>(1, 1);
              } else {
                _state_machine_ptr->_flag_symbol_map[of] =
                    std::make_shared<state_symbol>(0, 1);
              }
            }
          }
        }
        // 运算的双方不能转为int时
        else {
          //设置 of cf af 未知
          _state_machine_ptr->_flag_symbol_map[cf] =
              std::make_shared<state_symbol>(
                  "unsure" + std::to_string(_random()), 1);

          _state_machine_ptr->_flag_symbol_map[of] =
              std::make_shared<state_symbol>(
                  "unsure" + std::to_string(_random()), 1);

          _state_machine_ptr->_flag_symbol_map[af] =
              std::make_shared<state_symbol>(
                  "unsure" + std::to_string(_random()), 1);
        }

      } else {
        _state_machine_ptr->_flag_symbol_map[cf] =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist), 1);
        _state_machine_ptr->_flag_symbol_map[zf] =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist), 1);
        _state_machine_ptr->_flag_symbol_map[sf] =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist), 1);
        _state_machine_ptr->_flag_symbol_map[of] =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist), 1);
        _state_machine_ptr->_flag_symbol_map[pf] =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist), 1);
        _state_machine_ptr->_flag_symbol_map[af] =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist), 1);
      }
      break;
    }
    case instruction_type::type::test: {
      abstract_addr::ptr target_addr;
      state_symbol::ptr target_symbol;
      uint64_t target_num;
      char target_type =
          analyze_operator(insn.detail->x86.operands[0], target_addr,
                           target_symbol, true, control_leak_state, exec_mode);
      if (target_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (target_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (exec_mode == 0 && is_cache_miss_location) {
        if (target_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              target_symbol);
        }
      }

      abstract_addr::ptr source_addr;
      state_symbol::ptr source_symbol;
      uint64_t source_num;
      char source_type =
          analyze_operator(insn.detail->x86.operands[1], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        }
      }
      // cmp或者test的情况下将比较的双方中与branch_miss addr
      if (exec_mode == 0 && is_cmp_location) {
        // 将target相关的设置为初始污点
        if (source_symbol->judge_taine_effect(
                _state_machine_ptr->_cache_miss_symbol_vector)) {
          // 这里获取到全部有关相关符号的地址和符号映射，并进行保存
          _mem_taine_addr_map =
              _state_machine_ptr->find_addr_contain_taine(target_symbol);
        }
        // 将source相关的设置为初始污点
        else {
          _mem_taine_addr_map =
              _state_machine_ptr->find_addr_contain_taine(source_symbol);
        }
        break;
      }

      // if ((!source_symbol->judge_taine_same(target_symbol)) &&
      //     ((source_symbol->_taine == taine_enum::taine2 &&
      //       // source_symbol->get_symbol_size() == 1 &&
      //       target_symbol->get_symbol_mem_effect()) ||
      //      (target_symbol->_taine == taine_enum::taine2 &&
      //       // target_symbol->get_symbol_size() == 1 &&
      //       source_symbol->get_symbol_mem_effect()))) {
      //   //这里代表可能通过可能通过控制流泄露
      //   return std::make_pair(-1, analyze_result::FIND_ATTACK);
      //   // return std::make_pair(-1, analyze_result::MAY_LEAK_FROM_CONTROL);
      // }

      _state_machine_ptr->_flag_symbol_map[cf] =
          std::make_shared<state_symbol>(0, 1);
      _state_machine_ptr->_flag_symbol_map[of] =
          std::make_shared<state_symbol>(0, 1);

      if (target_symbol->is_num() && source_symbol->is_num()) {
        target_num = target_symbol->to_int();
        source_num = source_symbol->to_int();
        switch (insn.detail->x86.operands[0].size) {
          case 8: {
            uint64_t res = target_num & source_num;

            _state_machine_ptr->_flag_symbol_map[zf] =
                std::make_shared<state_symbol>(res == 0 ? 1 : 0, 1);
            _state_machine_ptr->_flag_symbol_map[sf] =
                std::make_shared<state_symbol>(res >> 63, 1);
            _state_machine_ptr->_flag_symbol_map[sf] =
                std::make_shared<state_symbol>((get_1_num(res) + 1) % 2, 1);

            break;
          }
          case 4: {
            uint64_t res = (target_num & source_num) & 0xffffffffLL;

            _state_machine_ptr->_flag_symbol_map[zf] =
                std::make_shared<state_symbol>(res == 0 ? 1 : 0, 1);
            _state_machine_ptr->_flag_symbol_map[sf] =
                std::make_shared<state_symbol>(res >> 31, 1);
            _state_machine_ptr->_flag_symbol_map[pf] =
                std::make_shared<state_symbol>((get_1_num(res) + 1) % 2, 1);
            break;
          }
          case 2: {
            uint64_t res = target_num & source_num & 0xffffLL;

            _state_machine_ptr->_flag_symbol_map[zf] =
                std::make_shared<state_symbol>(res == 0 ? 1 : 0, 1);
            _state_machine_ptr->_flag_symbol_map[sf] =
                std::make_shared<state_symbol>(res >> 15, 1);
            _state_machine_ptr->_flag_symbol_map[pf] =
                std::make_shared<state_symbol>((get_1_num(res) + 1) % 2, 1);
            break;
          }
          case 1: {
            uint64_t res = target_num & source_num & 0xffLL;

            _state_machine_ptr->_flag_symbol_map[zf] =
                std::make_shared<state_symbol>(res == 0 ? 1 : 0, 1);
            _state_machine_ptr->_flag_symbol_map[sf] =
                std::make_shared<state_symbol>(res >> 7, 1);
            _state_machine_ptr->_flag_symbol_map[pf] =
                std::make_shared<state_symbol>((get_1_num(res) + 1) % 2, 1);
            break;
          }
        }

      } else {
        _state_machine_ptr->_flag_symbol_map[zf] =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist), 1);
        _state_machine_ptr->_flag_symbol_map[sf] =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist), 1);
        _state_machine_ptr->_flag_symbol_map[pf] =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist), 1);
      }

      break;
    }
    case instruction_type::type::wait: {
      return std::make_pair(-1, analyze_result::NO_ATTACT);
      break;
    }
    case instruction_type::type::xchg: {
      abstract_addr::ptr source_addr;
      abstract_addr::ptr target_addr;
      state_symbol::ptr source_symbol;
      state_symbol::ptr target_symbol;

      uint64_t source_num;
      uint64_t target_num;

      char source_type =
          analyze_operator(insn.detail->x86.operands[0], target_addr,
                           target_symbol, true, control_leak_state, exec_mode);
      if (source_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (source_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      char target_type =
          analyze_operator(insn.detail->x86.operands[1], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (target_type == 3) {
        return std::make_pair(-1, analyze_result::FIND_ATTACK);
      } else if (target_type == 4) {
        return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
      }
      if (exec_mode == 0 && is_cache_miss_location) {
        if (source_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              source_symbol);
        } else if (target_type == 2) {
          _state_machine_ptr->_cache_miss_symbol_vector.push_back(
              target_symbol);
        }
      }
      set_target_symbol(target_addr, source_symbol);
      set_target_symbol(source_addr, target_symbol);
      break;
    }
    case instruction_type::type::xlat: {
      return std::make_pair(-1, analyze_result::UNSUPPORT_INSTRUCTION);
      break;
    }
    case instruction_type::type::XOR: {
      abstract_addr::ptr source_addr;
      abstract_addr::ptr target_addr;
      state_symbol::ptr source_symbol;
      state_symbol::ptr target_symbol;

      uint64_t source_num;
      uint64_t target_num;

      char source_type =
          analyze_operator(insn.detail->x86.operands[1], source_addr,
                           source_symbol, true, control_leak_state, exec_mode);
      if (source_type != 4) {
        if (source_type == 3) {
          return std::make_pair(-1, analyze_result::FIND_ATTACK);
        } else if (source_type == 4) {
          return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
        }
        if (exec_mode == 0 && is_cache_miss_location) {
          if (source_type == 2) {
            _state_machine_ptr->_cache_miss_symbol_vector.push_back(
                source_symbol);
          }
        }

        char target_type = analyze_operator(insn.detail->x86.operands[0],
                                            target_addr, target_symbol, true,
                                            control_leak_state, exec_mode);
        if (target_type == 3) {
          return std::make_pair(-1, analyze_result::FIND_ATTACK);
        } else if (target_type == 4) {
          return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
        }       
      } else {
        char source_type = analyze_operator(insn.detail->x86.operands[0],
                                            source_addr, source_symbol, true,
                                            control_leak_state, exec_mode);
        if (source_type == 3) {
          return std::make_pair(-1, analyze_result::FIND_ATTACK);
        } else if (source_type == 4) {
          return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
        }
        cs_x86_op al;
        al.type = X86_OP_REG;
        al.reg = X86_REG_AL;
        al.size = 1;
        char target_type =
            analyze_operator(al, target_addr, target_symbol, true,
                             control_leak_state, exec_mode);
        if (target_type == 3) {
          return std::make_pair(-1, analyze_result::FIND_ATTACK);
        } else if (target_type == 4) {
          return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
        }
      }
      state_symbol res = target_symbol->op_xor(source_symbol);

      state_symbol::ptr res_symbol = std::make_shared<state_symbol>(res);

      set_target_symbol(target_addr, res_symbol);
      break;
    }
    case instruction_type::type::cbw: {
      //用于将8位寄存器al中的有符号数扩展为16位
      //分析源操作数
      //源操作数的抽象地址
      cs_x86_op al = cs_x86_op();
      al.type = X86_OP_REG;
      al.reg = X86_REG_AL;
      abstract_addr::ptr source_addr = nullptr;
      //源操作数的抽象地址对应的符号
      state_symbol::ptr source_symbol = nullptr;
      char source_type = analyze_operator(al, source_addr, source_symbol, true,
                                          control_leak_state, exec_mode);

      if (source_symbol->is_num()) {
        uint64_t source_num = source_symbol->to_int();
        source_num &= 0xffLL;
        if (source_num >> 7) {
          source_num |= 0xff00LL;
        }
        source_symbol = std::make_shared<state_symbol>(source_num, 2);
      } else {
        source_symbol->set_symbol_size(2);
        source_symbol->_size_xh_symbol =
            std::make_shared<state_symbol>(get_symbol_str(_random, _dist), 1);
      }
      //设置目标操作数
      set_target_symbol(
          _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AX, 2),
          source_symbol);
      break;
    }
    case instruction_type::type::cwd: {
      //用于将ax的符号位扩展到dx上
      //分析源操作数
      //源操作数的抽象地址
      cs_x86_op ax = cs_x86_op();
      ax.type = X86_OP_REG;
      ax.reg = X86_REG_AX;
      abstract_addr::ptr ax_addr = nullptr;
      //源操作数的抽象地址对应的符号
      state_symbol::ptr ax_symbol = nullptr;
      char ax_type = analyze_operator(ax, ax_addr, ax_symbol, true,
                                      control_leak_state, exec_mode);

      state_symbol::ptr res_symbol = nullptr;

      if (ax_symbol->is_num()) {
        uint64_t source_num = ax_symbol->to_int();
        source_num &= 0xffffLL;
        if (source_num >> 15) {
          res_symbol = std::make_shared<state_symbol>(0xffffLL, 2);
        } else {
          res_symbol = std::make_shared<state_symbol>(0, 2);
        }
      } else {
        res_symbol = generate_symbol(get_symbol_str(_random, _dist), 2, {});
      }
      set_target_symbol(
          _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DX, 2),
          res_symbol);
      break;
    }
    case instruction_type::type::cwde: {
      //用于将寄存器ax中的有符号数扩展为32位
      //分析源操作数
      //源操作数的抽象地址
      cs_x86_op ax = cs_x86_op();
      ax.type = X86_OP_REG;
      ax.reg = X86_REG_AX;
      abstract_addr::ptr source_addr = nullptr;
      //源操作数的抽象地址对应的符号
      state_symbol::ptr source_symbol = nullptr;
      char source_type = analyze_operator(ax, source_addr, source_symbol, true,
                                          control_leak_state, exec_mode);

      if (source_symbol->is_num()) {
        uint64_t source_num = source_symbol->to_int();
        source_num &= 0xffffLL;
        if (source_num >> 15) {
          source_num |= 0xffff0000LL;
        }
        source_symbol = std::make_shared<state_symbol>(source_num, 4);
      } else {
        auto old_source_symbol = source_symbol;
        source_symbol = std::make_shared<state_symbol>(old_source_symbol);
        source_symbol->set_symbol_size(4);
        source_symbol->_size_16_symbol =
            std::make_shared<state_symbol>(source_symbol);
        source_symbol->_size_16_symbol->set_symbol_size(2);
        source_symbol->_size_16_symbol->_size_xh_symbol =
            source_symbol->_size_xh_symbol;
        source_symbol->_size_16_symbol->_size_xl_symbol =
            source_symbol->_size_xl_symbol;
      }
      set_target_symbol(
          _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EAX, 4),
          source_symbol);
      break;
    }
    case instruction_type::type::cqo: {
      //用于将rax的符号位扩展到rdx上
      //分析源操作数
      //源操作数的抽象地址
      cs_x86_op rax = cs_x86_op();
      rax.type = X86_OP_REG;
      rax.reg = X86_REG_RAX;
      abstract_addr::ptr source_addr = nullptr;
      //源操作数的抽象地址对应的符号
      state_symbol::ptr source_symbol = nullptr;
      char source_type = analyze_operator(rax, source_addr, source_symbol, true,
                                          control_leak_state, exec_mode);

      cs_x86_op rdx = cs_x86_op();
      rdx.type = X86_OP_REG;
      rdx.reg = X86_REG_RDX;
      abstract_addr::ptr rdx_addr = nullptr;
      state_symbol::ptr rdx_symbol = nullptr;
      char rdx_type = analyze_operator(rdx, rdx_addr, rdx_symbol, false,
                                       control_leak_state, exec_mode);

      if (source_symbol->is_num()) {
        uint64_t source_num = source_symbol->to_int();
        if (source_num >> 63) {
          rdx_symbol = std::make_shared<state_symbol>(0xffffffffffffffffLL, 8);
        } else {
          rdx_symbol = std::make_shared<state_symbol>(0, 8);
        }
      } else {
        rdx_symbol = generate_symbol(get_symbol_str(_random, _dist), 8, {});
      }
      set_target_symbol(rdx_addr, source_symbol);
      break;
    }
    case instruction_type::type::cdqe: {
      //用于将寄存器eax中的有符号数扩展为64位
      //分析源操作数
      //源操作数的抽象地址
      cs_x86_op eax = cs_x86_op();
      eax.type = X86_OP_REG;
      eax.reg = X86_REG_EAX;
      abstract_addr::ptr source_addr = nullptr;
      //源操作数的抽象地址对应的符号
      state_symbol::ptr source_symbol = nullptr;
      char source_type = analyze_operator(eax, source_addr, source_symbol, true,
                                          control_leak_state, exec_mode);

      if (source_symbol->is_num()) {
        uint64_t source_num = source_symbol->to_int();
        source_num &= 0xffffffffLL;
        if (source_num >> 31) {
          source_num |= 0xffffffff00000000LL;
        }
        source_symbol = std::make_shared<state_symbol>(source_num);
      } else {
        auto old_source_symbol = source_symbol;
        source_symbol = std::make_shared<state_symbol>(old_source_symbol);
        source_symbol->set_symbol_size(8);
        source_symbol->_size_32_symbol =
            std::make_shared<state_symbol>(source_symbol);
        source_symbol->_size_32_symbol->set_symbol_size(4);
      }

      //设置目标操作数的符号
      set_target_symbol(
          _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RAX, 8),
          source_symbol);
      break;
    }
    case instruction_type::type::cdq: {
      //用于将eax的符号位扩展到edx上
      //分析源操作数
      //源操作数的抽象地址
      cs_x86_op rax = cs_x86_op();
      rax.type = X86_OP_REG;
      rax.reg = X86_REG_RAX;
      abstract_addr::ptr source_addr = nullptr;
      //源操作数的抽象地址对应的符号
      state_symbol::ptr source_symbol = nullptr;
      char source_type = analyze_operator(rax, source_addr, source_symbol, true,
                                          control_leak_state, exec_mode);

      state_symbol::ptr rdx_symbol = nullptr;

      if (source_symbol->is_num()) {
        uint64_t source_num = source_symbol->to_int();
        source_num &= 0xffffffffLL;
        if (source_num >> 31) {
          rdx_symbol = std::make_shared<state_symbol>(0xffffffffLL, 4);
        } else {
          rdx_symbol = std::make_shared<state_symbol>(0, 4);
        }
      } else {
        rdx_symbol = generate_symbol(get_symbol_str(_random, _dist), 4, {});
      }
      //设置目标操作数
      set_target_symbol(
          _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EDX, 4),
          rdx_symbol);
      break;
    }
    case instruction_type::type::endbr64: {
      break;
    }
    case instruction_type::type::cmovo: {
      switch (exec) {
        case 0: {
          state_symbol::ptr of_symbol =
              _state_machine_ptr->_flag_symbol_map[of];
          if (of_symbol->is_num()) {
            if ((of_symbol->to_int() & 0x1) == 1) {
              //进行移动操作
              //分析源操作数
              //源操作数的抽象地址
              abstract_addr::ptr source_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr source_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[1], source_addr, source_symbol,
                  true, control_leak_state, exec_mode);
              //对取得的结果进行处理
              if (source_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (source_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //分析目标操作数
              abstract_addr::ptr target_addr = nullptr;
              state_symbol::ptr target_symbol = nullptr;
              char target_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  true, control_leak_state, exec_mode);
              if (target_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (target_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //设置目标操作数的符号
              set_target_symbol(target_addr, source_symbol);
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行移动操作
          //分析源操作数
          //源操作数的抽象地址
          abstract_addr::ptr source_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr source_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[1],
                                              source_addr, source_symbol, true,
                                              control_leak_state, exec_mode);
          //对取得的结果进行处理
          if (source_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //分析目标操作数
          abstract_addr::ptr target_addr = nullptr;
          state_symbol::ptr target_symbol = nullptr;
          char target_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, true,
                                              control_leak_state, exec_mode);
          if (target_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (target_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //设置目标操作数的符号
          set_target_symbol(target_addr, source_symbol);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::cmovno: {
      switch (exec) {
        case 0: {
          state_symbol::ptr of_symbol =
              _state_machine_ptr->_flag_symbol_map[of];
          if (of_symbol->is_num()) {
            if ((of_symbol->to_int() & 0x1) == 0) {
              //进行移动操作
              //分析源操作数
              //源操作数的抽象地址
              abstract_addr::ptr source_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr source_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[1], source_addr, source_symbol,
                  true, control_leak_state, exec_mode);
              //对取得的结果进行处理
              if (source_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (source_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //分析目标操作数
              abstract_addr::ptr target_addr = nullptr;
              state_symbol::ptr target_symbol = nullptr;
              char target_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  true, control_leak_state, exec_mode);
              if (target_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (target_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //设置目标操作数的符号
              set_target_symbol(target_addr, source_symbol);
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行移动操作
          //分析源操作数
          //源操作数的抽象地址
          abstract_addr::ptr source_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr source_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[1],
                                              source_addr, source_symbol, true,
                                              control_leak_state, exec_mode);
          //对取得的结果进行处理
          if (source_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //分析目标操作数
          abstract_addr::ptr target_addr = nullptr;
          state_symbol::ptr target_symbol = nullptr;
          char target_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, true,
                                              control_leak_state, exec_mode);
          if (target_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (target_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //设置目标操作数的符号
          set_target_symbol(target_addr, source_symbol);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::cmovs: {
      switch (exec) {
        case 0: {
          state_symbol::ptr sf_symbol =
              _state_machine_ptr->_flag_symbol_map[sf];
          if (sf_symbol->is_num()) {
            if ((sf_symbol->to_int() & 0x1) == 1) {
              //进行移动操作

              //分析源操作数
              //源操作数的抽象地址
              abstract_addr::ptr source_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr source_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[1], source_addr, source_symbol,
                  true, control_leak_state, exec_mode);
              //对取得的结果进行处理
              if (source_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (source_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //分析目标操作数
              abstract_addr::ptr target_addr = nullptr;
              state_symbol::ptr target_symbol = nullptr;
              char target_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  true, control_leak_state, exec_mode);
              if (target_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (target_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //设置目标操作数的符号
              set_target_symbol(target_addr, source_symbol);
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行移动操作
          //分析源操作数
          //源操作数的抽象地址
          abstract_addr::ptr source_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr source_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[1],
                                              source_addr, source_symbol, true,
                                              control_leak_state, exec_mode);
          //对取得的结果进行处理
          if (source_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //分析目标操作数
          abstract_addr::ptr target_addr = nullptr;
          state_symbol::ptr target_symbol = nullptr;
          char target_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, true,
                                              control_leak_state, exec_mode);
          if (target_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (target_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //设置目标操作数的符号
          set_target_symbol(target_addr, source_symbol);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::cmovns: {
      switch (exec) {
        case 0: {
          state_symbol::ptr sf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          if (sf_symbol->is_num()) {
            if ((sf_symbol->to_int() & 0x1) == 0) {
              //进行移动操作

              //分析源操作数
              //源操作数的抽象地址
              abstract_addr::ptr source_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr source_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[1], source_addr, source_symbol,
                  true, control_leak_state, exec_mode);
              //对取得的结果进行处理
              if (source_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (source_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //分析目标操作数
              abstract_addr::ptr target_addr = nullptr;
              state_symbol::ptr target_symbol = nullptr;
              char target_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  true, control_leak_state, exec_mode);
              if (target_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (target_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //设置目标操作数的符号
              set_target_symbol(target_addr, source_symbol);
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行移动操作
          //分析源操作数
          //源操作数的抽象地址
          abstract_addr::ptr source_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr source_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[1],
                                              source_addr, source_symbol, true,
                                              control_leak_state, exec_mode);
          //对取得的结果进行处理
          if (source_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //分析目标操作数
          abstract_addr::ptr target_addr = nullptr;
          state_symbol::ptr target_symbol = nullptr;
          char target_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, true,
                                              control_leak_state, exec_mode);
          if (target_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (target_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //设置目标操作数的符号
          set_target_symbol(target_addr, source_symbol);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::cmove: {
      switch (exec) {
        //分析模式
        case 0: {
          state_symbol::ptr zf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          if (zf_symbol->is_num()) {
            if ((zf_symbol->to_int() & 0x1) == 1) {
              //进行移动操作
              //分析源操作数
              //源操作数的抽象地址
              abstract_addr::ptr source_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr source_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[1], source_addr, source_symbol,
                  true, control_leak_state, exec_mode);
              //对取得的结果进行处理
              if (source_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (source_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //分析目标操作数
              abstract_addr::ptr target_addr = nullptr;
              state_symbol::ptr target_symbol = nullptr;
              char target_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  true, control_leak_state, exec_mode);
              if (target_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (target_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //设置目标操作数的符号
              set_target_symbol(target_addr, source_symbol);
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行移动操作

          //分析源操作数
          //源操作数的抽象地址
          abstract_addr::ptr source_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr source_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[1],
                                              source_addr, source_symbol, true,
                                              control_leak_state, exec_mode);
          //对取得的结果进行处理
          if (source_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //分析目标操作数
          abstract_addr::ptr target_addr = nullptr;
          state_symbol::ptr target_symbol = nullptr;
          char target_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, true,
                                              control_leak_state, exec_mode);
          if (target_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (target_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //设置目标操作数的符号
          set_target_symbol(target_addr, source_symbol);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::cmovne: {
      switch (exec) {
        case 0: {
          state_symbol::ptr zf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          if (zf_symbol->is_num()) {
            if ((zf_symbol->to_int() & 0x1) == 0) {
              //进行移动操作

              //分析源操作数
              //源操作数的抽象地址
              abstract_addr::ptr source_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr source_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[1], source_addr, source_symbol,
                  true, control_leak_state, exec_mode);
              //对取得的结果进行处理
              if (source_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (source_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //分析目标操作数
              abstract_addr::ptr target_addr = nullptr;
              state_symbol::ptr target_symbol = nullptr;
              char target_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  true, control_leak_state, exec_mode);
              if (target_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (target_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //设置目标操作数的符号
              set_target_symbol(target_addr, source_symbol);
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行移动操作

          //分析源操作数
          //源操作数的抽象地址
          abstract_addr::ptr source_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr source_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[1],
                                              source_addr, source_symbol, true,
                                              control_leak_state, exec_mode);
          //对取得的结果进行处理
          if (source_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //分析目标操作数
          abstract_addr::ptr target_addr = nullptr;
          state_symbol::ptr target_symbol = nullptr;
          char target_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, true,
                                              control_leak_state, exec_mode);
          if (target_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (target_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //设置目标操作数的符号
          set_target_symbol(target_addr, source_symbol);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::cmovp: {
      switch (exec) {
        case 0: {
          state_symbol::ptr pf_symbol =
              _state_machine_ptr->_flag_symbol_map[pf];
          if (pf_symbol->is_num()) {
            if ((pf_symbol->to_int() & 0x1) == 1) {
              //进行移动操作

              //分析源操作数
              //源操作数的抽象地址
              abstract_addr::ptr source_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr source_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[1], source_addr, source_symbol,
                  true, control_leak_state, exec_mode);
              //对取得的结果进行处理
              if (source_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (source_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //分析目标操作数
              abstract_addr::ptr target_addr = nullptr;
              state_symbol::ptr target_symbol = nullptr;
              char target_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  true, control_leak_state, exec_mode);
              if (target_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (target_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //设置目标操作数的符号
              set_target_symbol(target_addr, source_symbol);
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行移动操作

          //分析源操作数
          //源操作数的抽象地址
          abstract_addr::ptr source_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr source_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[1],
                                              source_addr, source_symbol, true,
                                              control_leak_state, exec_mode);
          //对取得的结果进行处理
          if (source_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //分析目标操作数
          abstract_addr::ptr target_addr = nullptr;
          state_symbol::ptr target_symbol = nullptr;
          char target_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, true,
                                              control_leak_state, exec_mode);
          if (target_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (target_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //设置目标操作数的符号
          set_target_symbol(target_addr, source_symbol);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::cmovnp: {
      switch (exec) {
        case 0: {
          state_symbol::ptr pf_symbol =
              _state_machine_ptr->_flag_symbol_map[pf];
          if (pf_symbol->is_num()) {
            if ((pf_symbol->to_int() & 0x1) == 1) {
              //进行移动操作

              //分析源操作数
              //源操作数的抽象地址
              abstract_addr::ptr source_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr source_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[1], source_addr, source_symbol,
                  true, control_leak_state, exec_mode);
              //对取得的结果进行处理
              if (source_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (source_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //分析目标操作数
              abstract_addr::ptr target_addr = nullptr;
              state_symbol::ptr target_symbol = nullptr;
              char target_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  true, control_leak_state, exec_mode);
              if (target_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (target_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //设置目标操作数的符号
              set_target_symbol(target_addr, source_symbol);
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行移动操作

          //分析源操作数
          //源操作数的抽象地址
          abstract_addr::ptr source_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr source_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[1],
                                              source_addr, source_symbol, true,
                                              control_leak_state, exec_mode);
          //对取得的结果进行处理
          if (source_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //分析目标操作数
          abstract_addr::ptr target_addr = nullptr;
          state_symbol::ptr target_symbol = nullptr;
          char target_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, true,
                                              control_leak_state, exec_mode);
          if (target_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (target_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //设置目标操作数的符号
          set_target_symbol(target_addr, source_symbol);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::cmovb: {
      switch (exec) {
        case 0: {
          state_symbol::ptr cf_symbol =
              _state_machine_ptr->_flag_symbol_map[cf];
          if (cf_symbol->is_num()) {
            if ((cf_symbol->to_int() & 0x1) == 1) {
              //进行移动操作

              //分析源操作数
              //源操作数的抽象地址
              abstract_addr::ptr source_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr source_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[1], source_addr, source_symbol,
                  true, control_leak_state, exec_mode);
              //对取得的结果进行处理
              if (source_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (source_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //分析目标操作数
              abstract_addr::ptr target_addr = nullptr;
              state_symbol::ptr target_symbol = nullptr;
              char target_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  true, control_leak_state, exec_mode);
              if (target_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (target_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //设置目标操作数的符号
              set_target_symbol(target_addr, source_symbol);
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行移动操作

          //分析源操作数
          //源操作数的抽象地址
          abstract_addr::ptr source_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr source_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[1],
                                              source_addr, source_symbol, true,
                                              control_leak_state, exec_mode);
          //对取得的结果进行处理
          if (source_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //分析目标操作数
          abstract_addr::ptr target_addr = nullptr;
          state_symbol::ptr target_symbol = nullptr;
          char target_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, true,
                                              control_leak_state, exec_mode);
          if (target_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (target_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //设置目标操作数的符号
          set_target_symbol(target_addr, source_symbol);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::cmovae: {
      switch (exec) {
        case 0: {
          state_symbol::ptr cf_symbol =
              _state_machine_ptr->_flag_symbol_map[cf];
          if (cf_symbol->is_num()) {
            if ((cf_symbol->to_int() & 0x1) == 0) {
              //进行移动操作

              //分析源操作数
              //源操作数的抽象地址
              abstract_addr::ptr source_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr source_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[1], source_addr, source_symbol,
                  true, control_leak_state, exec_mode);
              //对取得的结果进行处理
              if (source_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (source_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //分析目标操作数
              abstract_addr::ptr target_addr = nullptr;
              state_symbol::ptr target_symbol = nullptr;
              char target_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  true, control_leak_state, exec_mode);
              if (target_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (target_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //设置目标操作数的符号
              set_target_symbol(target_addr, source_symbol);
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行移动操作

          //分析源操作数
          //源操作数的抽象地址
          abstract_addr::ptr source_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr source_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[1],
                                              source_addr, source_symbol, true,
                                              control_leak_state, exec_mode);
          //对取得的结果进行处理
          if (source_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //分析目标操作数
          abstract_addr::ptr target_addr = nullptr;
          state_symbol::ptr target_symbol = nullptr;
          char target_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, true,
                                              control_leak_state, exec_mode);
          if (target_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (target_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //设置目标操作数的符号
          set_target_symbol(target_addr, source_symbol);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::cmovbe: {
      switch (exec) {
        case 0: {
          state_symbol::ptr cf_symbol =
              _state_machine_ptr->_flag_symbol_map[cf];
          state_symbol::ptr zf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          if ((zf_symbol->is_num() && (zf_symbol->to_int() & 0x1) == 1) &&
              (cf_symbol->is_num() && (cf_symbol->to_int() & 0x1) == 1)) {
            //进行移动操作

            //分析源操作数
            //源操作数的抽象地址
            abstract_addr::ptr source_addr = nullptr;
            //源操作数的抽象地址对应的符号
            state_symbol::ptr source_symbol = nullptr;
            char source_type = analyze_operator(
                insn.detail->x86.operands[1], source_addr, source_symbol, true,
                control_leak_state, exec_mode);
            //对取得的结果进行处理
            if (source_type == 3) {
              return std::make_pair(-1, analyze_result::FIND_ATTACK);
            } else if (source_type == 4) {
              return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
            }

            //分析目标操作数
            abstract_addr::ptr target_addr = nullptr;
            state_symbol::ptr target_symbol = nullptr;
            char target_type = analyze_operator(
                insn.detail->x86.operands[0], target_addr, target_symbol, true,
                control_leak_state, exec_mode);
            if (target_type == 3) {
              return std::make_pair(-1, analyze_result::FIND_ATTACK);
            } else if (target_type == 4) {
              return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
            }

            //设置目标操作数的符号
            set_target_symbol(target_addr, source_symbol);

          } else if ((zf_symbol->is_num() &&
                      (zf_symbol->to_int() & 0x1) == 0) ||
                     (cf_symbol->is_num() &&
                      (cf_symbol->to_int() & 0x1) == 0)) {
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行移动操作

          //分析源操作数
          //源操作数的抽象地址
          abstract_addr::ptr source_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr source_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[1],
                                              source_addr, source_symbol, true,
                                              control_leak_state, exec_mode);
          //对取得的结果进行处理
          if (source_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //分析目标操作数
          abstract_addr::ptr target_addr = nullptr;
          state_symbol::ptr target_symbol = nullptr;
          char target_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, true,
                                              control_leak_state, exec_mode);
          if (target_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (target_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //设置目标操作数的符号
          set_target_symbol(target_addr, source_symbol);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::cmova: {
      switch (exec) {
        case 0: {
          state_symbol::ptr cf_symbol =
              _state_machine_ptr->_flag_symbol_map[cf];
          state_symbol::ptr zf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          if (cf_symbol->is_num() && zf_symbol->is_num()) {
            if ((cf_symbol->to_int() & 0x1) == 0 &&
                (zf_symbol->to_int() & 0x1) == 0) {
              //进行移动操作

              //分析源操作数
              //源操作数的抽象地址
              abstract_addr::ptr source_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr source_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[1], source_addr, source_symbol,
                  true, control_leak_state, exec_mode);
              //对取得的结果进行处理
              if (source_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (source_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //分析目标操作数
              abstract_addr::ptr target_addr = nullptr;
              state_symbol::ptr target_symbol = nullptr;
              char target_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  true, control_leak_state, exec_mode);
              if (target_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (target_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //设置目标操作数的符号
              set_target_symbol(target_addr, source_symbol);
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行移动操作

          //分析源操作数
          //源操作数的抽象地址
          abstract_addr::ptr source_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr source_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[1],
                                              source_addr, source_symbol, true,
                                              control_leak_state, exec_mode);
          //对取得的结果进行处理
          if (source_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //分析目标操作数
          abstract_addr::ptr target_addr = nullptr;
          state_symbol::ptr target_symbol = nullptr;
          char target_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, true,
                                              control_leak_state, exec_mode);
          if (target_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (target_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //设置目标操作数的符号
          set_target_symbol(target_addr, source_symbol);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::cmovl: {
      switch (exec) {
        case 0: {
          state_symbol::ptr sf_symbol =
              _state_machine_ptr->_flag_symbol_map[sf];
          state_symbol::ptr of_symbol =
              _state_machine_ptr->_flag_symbol_map[of];
          if (sf_symbol->is_num() && of_symbol->is_num()) {
            if ((sf_symbol->to_int() & 0x1) != (of_symbol->to_int() & 0x1)) {
              //进行移动操作

              //分析源操作数
              //源操作数的抽象地址
              abstract_addr::ptr source_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr source_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[1], source_addr, source_symbol,
                  true, control_leak_state, exec_mode);
              //对取得的结果进行处理
              if (source_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (source_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //分析目标操作数
              abstract_addr::ptr target_addr = nullptr;
              state_symbol::ptr target_symbol = nullptr;
              char target_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  true, control_leak_state, exec_mode);
              if (target_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (target_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //设置目标操作数的符号
              set_target_symbol(target_addr, source_symbol);
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行移动操作

          //分析源操作数
          //源操作数的抽象地址
          abstract_addr::ptr source_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr source_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[1],
                                              source_addr, source_symbol, true,
                                              control_leak_state, exec_mode);
          //对取得的结果进行处理
          if (source_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //分析目标操作数
          abstract_addr::ptr target_addr = nullptr;
          state_symbol::ptr target_symbol = nullptr;
          char target_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, true,
                                              control_leak_state, exec_mode);
          if (target_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (target_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //设置目标操作数的符号
          set_target_symbol(target_addr, source_symbol);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::cmovge: {
      switch (exec) {
        case 0: {
          state_symbol::ptr sf_symbol =
              _state_machine_ptr->_flag_symbol_map[sf];
          state_symbol::ptr of_symbol =
              _state_machine_ptr->_flag_symbol_map[of];
          if (sf_symbol->is_num() && of_symbol->is_num()) {
            if ((sf_symbol->to_int() & 0x1) == (of_symbol->to_int() & 0x1)) {
              //进行移动操作

              //分析源操作数
              //源操作数的抽象地址
              abstract_addr::ptr source_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr source_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[1], source_addr, source_symbol,
                  true, control_leak_state, exec_mode);
              //对取得的结果进行处理
              if (source_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (source_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //分析目标操作数
              abstract_addr::ptr target_addr = nullptr;
              state_symbol::ptr target_symbol = nullptr;
              char target_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  true, control_leak_state, exec_mode);
              if (target_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (target_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //设置目标操作数的符号
              set_target_symbol(target_addr, source_symbol);
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行移动操作

          //分析源操作数
          //源操作数的抽象地址
          abstract_addr::ptr source_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr source_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[1],
                                              source_addr, source_symbol, true,
                                              control_leak_state, exec_mode);
          //对取得的结果进行处理
          if (source_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //分析目标操作数
          abstract_addr::ptr target_addr = nullptr;
          state_symbol::ptr target_symbol = nullptr;
          char target_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, true,
                                              control_leak_state, exec_mode);
          if (target_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (target_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //设置目标操作数的符号
          set_target_symbol(target_addr, source_symbol);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::cmovle: {
      switch (exec) {
        case 0: {
          state_symbol::ptr zf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          state_symbol::ptr sf_symbol =
              _state_machine_ptr->_flag_symbol_map[sf];
          state_symbol::ptr of_symbol =
              _state_machine_ptr->_flag_symbol_map[of];
          if ((zf_symbol->is_num() && (zf_symbol->to_int() & 0x1) == 1) &&
              (sf_symbol->is_num() && of_symbol->is_num()) &&
              ((sf_symbol->to_int() & 0x1) != (of_symbol->to_int() & 0x1))) {
            //进行移动操作

            //分析源操作数
            //源操作数的抽象地址
            abstract_addr::ptr source_addr = nullptr;
            //源操作数的抽象地址对应的符号
            state_symbol::ptr source_symbol = nullptr;
            char source_type = analyze_operator(
                insn.detail->x86.operands[1], source_addr, source_symbol, true,
                control_leak_state, exec_mode);
            //对取得的结果进行处理
            if (source_type == 3) {
              return std::make_pair(-1, analyze_result::FIND_ATTACK);
            } else if (source_type == 4) {
              return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
            }

            //分析目标操作数
            abstract_addr::ptr target_addr = nullptr;
            state_symbol::ptr target_symbol = nullptr;
            char target_type = analyze_operator(
                insn.detail->x86.operands[0], target_addr, target_symbol, true,
                control_leak_state, exec_mode);
            if (target_type == 3) {
              return std::make_pair(-1, analyze_result::FIND_ATTACK);
            } else if (target_type == 4) {
              return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
            }

            //设置目标操作数的符号
            set_target_symbol(target_addr, source_symbol);

          } else if ((zf_symbol->is_num() &&
                      (zf_symbol->to_int() & 0x1) == 0) ||
                     (sf_symbol->is_num() && of_symbol->is_num()) &&
                         ((sf_symbol->to_int() & 0x1) ==
                          (of_symbol->to_int() & 0x1))) {
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行移动操作

          //分析源操作数
          //源操作数的抽象地址
          abstract_addr::ptr source_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr source_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[1],
                                              source_addr, source_symbol, true,
                                              control_leak_state, exec_mode);
          //对取得的结果进行处理
          if (source_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //分析目标操作数
          abstract_addr::ptr target_addr = nullptr;
          state_symbol::ptr target_symbol = nullptr;
          char target_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, true,
                                              control_leak_state, exec_mode);
          if (target_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (target_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //设置目标操作数的符号
          set_target_symbol(target_addr, source_symbol);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::cmovg: {
      switch (exec) {
        case 0: {
          state_symbol::ptr zf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          state_symbol::ptr sf_symbol =
              _state_machine_ptr->_flag_symbol_map[sf];
          state_symbol::ptr of_symbol =
              _state_machine_ptr->_flag_symbol_map[of];
          if (zf_symbol->is_num() && sf_symbol->is_num() &&
              of_symbol->is_num()) {
            if ((zf_symbol->to_int() & 0x1) == 0 &&
                ((sf_symbol->to_int() & 0x1) == (of_symbol->to_int() & 0x1))) {
              //进行移动操作

              //分析源操作数
              //源操作数的抽象地址
              abstract_addr::ptr source_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr source_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[1], source_addr, source_symbol,
                  true, control_leak_state, exec_mode);
              //对取得的结果进行处理
              if (source_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (source_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //分析目标操作数
              abstract_addr::ptr target_addr = nullptr;
              state_symbol::ptr target_symbol = nullptr;
              char target_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  true, control_leak_state, exec_mode);
              if (target_type == 3) {
                return std::make_pair(-1, analyze_result::FIND_ATTACK);
              } else if (target_type == 4) {
                return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
              }

              //设置目标操作数的符号
              set_target_symbol(target_addr, source_symbol);
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行移动操作

          //分析源操作数
          //源操作数的抽象地址
          abstract_addr::ptr source_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr source_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[1],
                                              source_addr, source_symbol, true,
                                              control_leak_state, exec_mode);
          //对取得的结果进行处理
          if (source_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (source_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //分析目标操作数
          abstract_addr::ptr target_addr = nullptr;
          state_symbol::ptr target_symbol = nullptr;
          char target_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, true,
                                              control_leak_state, exec_mode);
          if (target_type == 3) {
            return std::make_pair(-1, analyze_result::FIND_ATTACK);
          } else if (target_type == 4) {
            return std::make_pair(-1, analyze_result::INVALID_INSTRUCTION);
          }

          //设置目标操作数的符号
          set_target_symbol(target_addr, source_symbol);
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::seto: {
      switch (exec) {
        case 0: {
          state_symbol::ptr of_symbol =
              _state_machine_ptr->_flag_symbol_map[of];
          if (of_symbol->is_num()) {
            if ((of_symbol->to_int() & 0x1) == 1) {
              //进行赋值操作
              abstract_addr::ptr target_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr target_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  false, control_leak_state, exec_mode);

              set_target_symbol(target_addr,
                                std::make_shared<state_symbol>(
                                    1, insn.detail->x86.operands[0].size));
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行赋值操作

          abstract_addr::ptr target_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr target_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, false,
                                              control_leak_state, exec_mode);

          set_target_symbol(target_addr,
                            std::make_shared<state_symbol>(
                                1, insn.detail->x86.operands[0].size));
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::setno: {
      switch (exec) {
        case 0: {
          state_symbol::ptr of_symbol =
              _state_machine_ptr->_flag_symbol_map[of];
          if (of_symbol->is_num()) {
            if ((of_symbol->to_int() & 0x1) == 0) {
              //进行赋值操作

              abstract_addr::ptr target_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr target_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  false, control_leak_state, exec_mode);

              set_target_symbol(target_addr,
                                std::make_shared<state_symbol>(
                                    1, insn.detail->x86.operands[0].size));
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行赋值操作

          abstract_addr::ptr target_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr target_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, false,
                                              control_leak_state, exec_mode);

          set_target_symbol(target_addr,
                            std::make_shared<state_symbol>(
                                1, insn.detail->x86.operands[0].size));
          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::sets: {
      switch (exec) {
        case 0: {
          state_symbol::ptr sf_symbol =
              _state_machine_ptr->_flag_symbol_map[sf];
          if (sf_symbol->is_num()) {
            if ((sf_symbol->to_int() & 0x1) == 1) {
              //进行赋值操作
              abstract_addr::ptr target_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr target_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  false, control_leak_state, exec_mode);

              set_target_symbol(target_addr,
                                std::make_shared<state_symbol>(
                                    1, insn.detail->x86.operands[0].size));
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行赋值操作
          abstract_addr::ptr target_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr target_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, false,
                                              control_leak_state, exec_mode);

          set_target_symbol(target_addr,
                            std::make_shared<state_symbol>(
                                1, insn.detail->x86.operands[0].size));

          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::setns: {
      switch (exec) {
        case 0: {
          state_symbol::ptr sf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          if (sf_symbol->is_num()) {
            if ((sf_symbol->to_int() & 0x1) == 0) {
              //进行赋值操作
              abstract_addr::ptr target_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr target_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  false, control_leak_state, exec_mode);

              set_target_symbol(target_addr,
                                std::make_shared<state_symbol>(
                                    1, insn.detail->x86.operands[0].size));
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行赋值操作
          abstract_addr::ptr target_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr target_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, false,
                                              control_leak_state, exec_mode);

          set_target_symbol(target_addr,
                            std::make_shared<state_symbol>(
                                1, insn.detail->x86.operands[0].size));

          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::sete: {
      switch (exec) {
        //分析模式
        case 0: {
          state_symbol::ptr zf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          if (zf_symbol->is_num()) {
            if ((zf_symbol->to_int() & 0x1) == 1) {
              //进行赋值操作
              abstract_addr::ptr target_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr target_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  false, control_leak_state, exec_mode);

              set_target_symbol(target_addr,
                                std::make_shared<state_symbol>(
                                    1, insn.detail->x86.operands[0].size));
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行赋值操作
          abstract_addr::ptr target_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr target_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, false,
                                              control_leak_state, exec_mode);

          set_target_symbol(target_addr,
                            std::make_shared<state_symbol>(
                                1, insn.detail->x86.operands[0].size));

          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::setne: {
      switch (exec) {
        case 0: {
          state_symbol::ptr zf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          if (zf_symbol->is_num()) {
            if ((zf_symbol->to_int() & 0x1) == 0) {
              //进行赋值操作
              abstract_addr::ptr target_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr target_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  false, control_leak_state, exec_mode);

              set_target_symbol(target_addr,
                                std::make_shared<state_symbol>(
                                    1, insn.detail->x86.operands[0].size));
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行赋值操作
          abstract_addr::ptr target_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr target_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, false,
                                              control_leak_state, exec_mode);

          set_target_symbol(target_addr,
                            std::make_shared<state_symbol>(
                                1, insn.detail->x86.operands[0].size));

          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::setp: {
      switch (exec) {
        case 0: {
          state_symbol::ptr pf_symbol =
              _state_machine_ptr->_flag_symbol_map[pf];
          if (pf_symbol->is_num()) {
            if ((pf_symbol->to_int() & 0x1) == 1) {
              //进行赋值操作
              abstract_addr::ptr target_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr target_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  false, control_leak_state, exec_mode);

              set_target_symbol(target_addr,
                                std::make_shared<state_symbol>(
                                    1, insn.detail->x86.operands[0].size));
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行赋值操作
          abstract_addr::ptr target_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr target_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, false,
                                              control_leak_state, exec_mode);

          set_target_symbol(target_addr,
                            std::make_shared<state_symbol>(
                                1, insn.detail->x86.operands[0].size));

          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::setnp: {
      switch (exec) {
        case 0: {
          state_symbol::ptr pf_symbol =
              _state_machine_ptr->_flag_symbol_map[pf];
          if (pf_symbol->is_num()) {
            if ((pf_symbol->to_int() & 0x1) == 1) {
              //进行赋值操作
              abstract_addr::ptr target_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr target_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  false, control_leak_state, exec_mode);

              set_target_symbol(target_addr,
                                std::make_shared<state_symbol>(
                                    1, insn.detail->x86.operands[0].size));
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行赋值操作
          abstract_addr::ptr target_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr target_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, false,
                                              control_leak_state, exec_mode);

          set_target_symbol(target_addr,
                            std::make_shared<state_symbol>(
                                1, insn.detail->x86.operands[0].size));

          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::setb: {
      switch (exec) {
        case 0: {
          state_symbol::ptr cf_symbol =
              _state_machine_ptr->_flag_symbol_map[cf];
          if (cf_symbol->is_num()) {
            if ((cf_symbol->to_int() & 0x1) == 1) {
              //进行赋值操作
              abstract_addr::ptr target_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr target_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  false, control_leak_state, exec_mode);

              set_target_symbol(target_addr,
                                std::make_shared<state_symbol>(
                                    1, insn.detail->x86.operands[0].size));
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行赋值操作
          abstract_addr::ptr target_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr target_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, false,
                                              control_leak_state, exec_mode);

          set_target_symbol(target_addr,
                            std::make_shared<state_symbol>(
                                1, insn.detail->x86.operands[0].size));

          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::setae: {
      switch (exec) {
        case 0: {
          state_symbol::ptr cf_symbol =
              _state_machine_ptr->_flag_symbol_map[cf];
          if (cf_symbol->is_num()) {
            if ((cf_symbol->to_int() & 0x1) == 0) {
              //进行赋值操作
              abstract_addr::ptr target_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr target_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  false, control_leak_state, exec_mode);

              set_target_symbol(target_addr,
                                std::make_shared<state_symbol>(
                                    1, insn.detail->x86.operands[0].size));
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行赋值操作
          abstract_addr::ptr target_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr target_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, false,
                                              control_leak_state, exec_mode);

          set_target_symbol(target_addr,
                            std::make_shared<state_symbol>(
                                1, insn.detail->x86.operands[0].size));

          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::setbe: {
      switch (exec) {
        case 0: {
          state_symbol::ptr cf_symbol =
              _state_machine_ptr->_flag_symbol_map[cf];
          state_symbol::ptr zf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          if ((zf_symbol->is_num() && (zf_symbol->to_int() & 0x1) == 1) &&
              (cf_symbol->is_num() && (cf_symbol->to_int() & 0x1) == 1)) {
            //进行赋值操作
            abstract_addr::ptr target_addr = nullptr;
            //源操作数的抽象地址对应的符号
            state_symbol::ptr target_symbol = nullptr;
            char source_type = analyze_operator(
                insn.detail->x86.operands[0], target_addr, target_symbol, false,
                control_leak_state, exec_mode);

            set_target_symbol(target_addr,
                              std::make_shared<state_symbol>(
                                  1, insn.detail->x86.operands[0].size));

          } else if ((zf_symbol->is_num() &&
                      (zf_symbol->to_int() & 0x1) == 0) ||
                     (cf_symbol->is_num() &&
                      (cf_symbol->to_int() & 0x1) == 0)) {
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行赋值操作
          abstract_addr::ptr target_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr target_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, false,
                                              control_leak_state, exec_mode);

          set_target_symbol(target_addr,
                            std::make_shared<state_symbol>(
                                1, insn.detail->x86.operands[0].size));

          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::seta: {
      switch (exec) {
        case 0: {
          state_symbol::ptr cf_symbol =
              _state_machine_ptr->_flag_symbol_map[cf];
          state_symbol::ptr zf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          if (cf_symbol->is_num() && zf_symbol->is_num()) {
            if ((cf_symbol->to_int() & 0x1) == 0 &&
                (zf_symbol->to_int() & 0x1) == 0) {
              //进行赋值操作
              abstract_addr::ptr target_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr target_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  false, control_leak_state, exec_mode);

              set_target_symbol(target_addr,
                                std::make_shared<state_symbol>(
                                    1, insn.detail->x86.operands[0].size));
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行赋值操作
          abstract_addr::ptr target_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr target_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, false,
                                              control_leak_state, exec_mode);

          set_target_symbol(target_addr,
                            std::make_shared<state_symbol>(
                                1, insn.detail->x86.operands[0].size));

          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::setl: {
      switch (exec) {
        case 0: {
          state_symbol::ptr sf_symbol =
              _state_machine_ptr->_flag_symbol_map[sf];
          state_symbol::ptr of_symbol =
              _state_machine_ptr->_flag_symbol_map[of];
          if (sf_symbol->is_num() && of_symbol->is_num()) {
            if ((sf_symbol->to_int() & 0x1) != (of_symbol->to_int() & 0x1)) {
              //进行赋值操作
              abstract_addr::ptr target_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr target_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  false, control_leak_state, exec_mode);

              set_target_symbol(target_addr,
                                std::make_shared<state_symbol>(
                                    1, insn.detail->x86.operands[0].size));
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行赋值操作
          abstract_addr::ptr target_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr target_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, false,
                                              control_leak_state, exec_mode);

          set_target_symbol(target_addr,
                            std::make_shared<state_symbol>(
                                1, insn.detail->x86.operands[0].size));

          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::setge: {
      switch (exec) {
        case 0: {
          state_symbol::ptr sf_symbol =
              _state_machine_ptr->_flag_symbol_map[sf];
          state_symbol::ptr of_symbol =
              _state_machine_ptr->_flag_symbol_map[of];
          if (sf_symbol->is_num() && of_symbol->is_num()) {
            if ((sf_symbol->to_int() & 0x1) == (of_symbol->to_int() & 0x1)) {
              //进行赋值操作
              abstract_addr::ptr target_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr target_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  false, control_leak_state, exec_mode);

              set_target_symbol(target_addr,
                                std::make_shared<state_symbol>(
                                    1, insn.detail->x86.operands[0].size));
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行赋值操作
          abstract_addr::ptr target_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr target_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, false,
                                              control_leak_state, exec_mode);

          set_target_symbol(target_addr,
                            std::make_shared<state_symbol>(
                                1, insn.detail->x86.operands[0].size));

          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::setle: {
      switch (exec) {
        case 0: {
          state_symbol::ptr zf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          state_symbol::ptr sf_symbol =
              _state_machine_ptr->_flag_symbol_map[sf];
          state_symbol::ptr of_symbol =
              _state_machine_ptr->_flag_symbol_map[of];
          if ((zf_symbol->is_num() && (zf_symbol->to_int() & 0x1) == 1) &&
              (sf_symbol->is_num() && of_symbol->is_num()) &&
              ((sf_symbol->to_int() & 0x1) != (of_symbol->to_int() & 0x1))) {
            //进行赋值操作
            abstract_addr::ptr target_addr = nullptr;
            //源操作数的抽象地址对应的符号
            state_symbol::ptr target_symbol = nullptr;
            char source_type = analyze_operator(
                insn.detail->x86.operands[0], target_addr, target_symbol, false,
                control_leak_state, exec_mode);

            set_target_symbol(target_addr,
                              std::make_shared<state_symbol>(
                                  1, insn.detail->x86.operands[0].size));

          } else if ((zf_symbol->is_num() &&
                      (zf_symbol->to_int() & 0x1) == 0) ||
                     (sf_symbol->is_num() && of_symbol->is_num()) &&
                         ((sf_symbol->to_int() & 0x1) ==
                          (of_symbol->to_int() & 0x1))) {
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行赋值操作
          abstract_addr::ptr target_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr target_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, false,
                                              control_leak_state, exec_mode);

          set_target_symbol(target_addr,
                            std::make_shared<state_symbol>(
                                1, insn.detail->x86.operands[0].size));

          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    case instruction_type::type::setg: {
      switch (exec) {
        case 0: {
          state_symbol::ptr zf_symbol =
              _state_machine_ptr->_flag_symbol_map[zf];
          state_symbol::ptr sf_symbol =
              _state_machine_ptr->_flag_symbol_map[sf];
          state_symbol::ptr of_symbol =
              _state_machine_ptr->_flag_symbol_map[of];
          if (zf_symbol->is_num() && sf_symbol->is_num() &&
              of_symbol->is_num()) {
            if ((zf_symbol->to_int() & 0x1) == 0 &&
                ((sf_symbol->to_int() & 0x1) == (of_symbol->to_int() & 0x1))) {
              //进行赋值操作
              abstract_addr::ptr target_addr = nullptr;
              //源操作数的抽象地址对应的符号
              state_symbol::ptr target_symbol = nullptr;
              char source_type = analyze_operator(
                  insn.detail->x86.operands[0], target_addr, target_symbol,
                  false, control_leak_state, exec_mode);

              set_target_symbol(target_addr,
                                std::make_shared<state_symbol>(
                                    1, insn.detail->x86.operands[0].size));
            }
          } else {
            return std::make_pair(-1,
                                  analyze_result::UNSURE_CONTROL_FOLW_JMP_UP);
          }
          break;
        }
          //执行移动指令
        case 1: {
          //进行赋值操作
          abstract_addr::ptr target_addr = nullptr;
          //源操作数的抽象地址对应的符号
          state_symbol::ptr target_symbol = nullptr;
          char source_type = analyze_operator(insn.detail->x86.operands[0],
                                              target_addr, target_symbol, false,
                                              control_leak_state, exec_mode);

          set_target_symbol(target_addr,
                            std::make_shared<state_symbol>(
                                1, insn.detail->x86.operands[0].size));

          break;
        }
          //不执行移动指令
        case 2: {
          break;
        }
      }
      break;
    }
    default: {
      break;
    }
  }
  return std::make_pair(insn.address + insn.size,
                        analyze_result::CONTINUE_ANALYZE);
}

void instruction_analyze_tool::init_state_machine(
    const register_info_t &register_info, bool is_je_jum) {
  // je的情况下全设为符号
  // is_je_jum = false;
  {
    if (is_je_jum) {
      init_state_machine_symbol(register_info);
      //初始化rflags
      // _state_machine_ptr->_flag_symbol_map
      //     [_generatr_abstract_addr_tool_ptr->get_abstract_flag(rflags::zf)] =
      //     std::make_shared<state_symbol>((register_info.RFLAGS >> 6) & 0x1, 1);
      return;
    }
  }
  //初始化register info
  {  // rax
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RAX, 8),
        register_info.RAX, 8);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EAX, 4),
        register_info.RAX & 0x00000000ffffffffLL, 4);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AX, 2),
        register_info.RAX & 0x000000000000ffffLL, 2);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AH, 1),
        (register_info.RAX & 0x000000000000ff00LL) >> 8, 1);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AL, 1),
        register_info.RAX & 0x00000000000000ffLL, 1);
    // rcx
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RCX, 8),
        register_info.RCX, 8);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_ECX, 4),
        register_info.RCX & 0x00000000ffffffffLL, 4);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_CX, 2),
        register_info.RCX & 0x000000000000ffffLL, 2);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_CH, 1),
        (register_info.RCX & 0x000000000000ff00LL) >> 8, 1);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_CL, 1),
        register_info.RCX & 0x00000000000000ffLL, 1);
    // rdx
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RDX, 8),
        register_info.RDX, 8);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EDX, 4),
        register_info.RDX & 0x00000000ffffffffLL, 4);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DX, 2),
        register_info.RDX & 0x000000000000ffffLL, 2);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DH, 1),
        (register_info.RDX & 0x000000000000ff00LL) >> 8, 1);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DL, 1),
        register_info.RDX & 0x00000000000000ffLL, 1);
    // rbx
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RBX, 8),
        register_info.RBX, 8);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EBX, 4),
        register_info.RBX & 0x00000000ffffffffLL, 4);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_BX, 2),
        register_info.RBX & 0x000000000000ffffLL, 2);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_BH, 1),
        (register_info.RBX & 0x000000000000ff00LL) >> 8, 1);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_BL, 1),
        register_info.RBX & 0x00000000000000ffLL, 1);
    // rsp
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RSP, 8),
        register_info.RSP, 8);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_ESP, 4),
        register_info.RSP & 0x00000000ffffffffLL, 4);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_SP, 2),
        register_info.RSP & 0x000000000000ffffLL, 2);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_SPL, 1),
        register_info.RSP & 0x00000000000000ffLL, 1);
    // bp
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RBP, 8),
        register_info.RBP, 8);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EBP, 4),
        register_info.RBP & 0x00000000ffffffffLL, 4);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_BP, 2),
        register_info.RBP & 0x000000000000ffffLL, 2);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_BPL, 1),
        register_info.RBP & 0x00000000000000ffLL, 1);
    // si
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RSI, 8),
        register_info.RSI, 8);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_ESI, 4),
        register_info.RSI & 0x00000000ffffffffLL, 4);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_SI, 2),
        register_info.RSI & 0x000000000000ffffLL, 2);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_SIL, 1),
        register_info.RSI & 0x00000000000000ffLL, 1);
    // di
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RDI, 8),
        register_info.RDI, 8);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EDI, 4),
        register_info.RDI & 0x00000000ffffffffLL, 4);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DI, 2),
        register_info.RDI & 0x000000000000ffffLL, 2);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DIL, 1),
        register_info.RDI & 0x00000000000000ffLL, 1);

    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R8, 8),
        register_info.R8, 8);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R8D, 4),
        register_info.R8 & 0x00000000ffffffffLL, 4);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R8W, 2),
        register_info.R8 & 0x000000000000ffffLL, 2);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R8B, 1),
        register_info.R8 & 0x00000000000000ffLL, 1);

    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R9, 8),
        register_info.R9, 8);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R9D, 4),
        register_info.R9 & 0x00000000ffffffffLL, 4);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R9W, 2),
        register_info.R9 & 0x000000000000ffffLL, 2);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R9B, 1),
        register_info.R9 & 0x00000000000000ffLL, 1);

    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R10, 8),
        register_info.R10, 8);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R10D, 4),
        register_info.R10 & 0x00000000ffffffffLL, 4);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R10W, 2),
        register_info.R10 & 0x000000000000ffffLL, 2);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R10B, 1),
        register_info.R10 & 0x00000000000000ffLL, 1);

    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R11, 8),
        register_info.R11, 8);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R11D, 4),
        register_info.R11 & 0x00000000ffffffffLL, 4);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R11W, 2),
        register_info.R11 & 0x000000000000ffffLL, 2);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R11B, 1),
        register_info.R11 & 0x00000000000000ffLL, 1);

    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R12, 8),
        register_info.R12, 8);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R12D, 4),
        register_info.R12 & 0x00000000ffffffffLL, 4);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R12W, 2),
        register_info.R12 & 0x000000000000ffffLL, 2);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R12B, 1),
        register_info.R12 & 0x00000000000000ffLL, 1);

    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R13, 8),
        register_info.R13, 8);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R13D, 4),
        register_info.R13 & 0x00000000ffffffffLL, 4);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R13W, 2),
        register_info.R13 & 0x000000000000ffffLL, 2);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R13B, 1),
        register_info.R13 & 0x00000000000000ffLL, 1);

    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R14, 8),
        register_info.R14, 8);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R14D, 4),
        register_info.R14 & 0x00000000ffffffffLL, 4);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R14W, 2),
        register_info.R14 & 0x000000000000ffffLL, 2);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R14B, 1),
        register_info.R14 & 0x00000000000000ffLL, 1);

    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R15, 8),
        register_info.R15, 8);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R15D, 4),
        register_info.R15 & 0x00000000ffffffffLL, 4);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R15W, 2),
        register_info.R15 & 0x000000000000ffffLL, 2);
    _state_machine_ptr->generate_symbol_for_addr(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R15B, 1),
        register_info.R15 & 0x00000000000000ffLL, 1);
  }
  //初始化rflags
  {
    _state_machine_ptr->_flag_symbol_map[_generatr_abstract_addr_tool_ptr
                                             ->get_abstract_flag(rflags::cf)] =
        std::make_shared<state_symbol>(register_info.RFLAGS & 0x1, 1);
    _state_machine_ptr->_flag_symbol_map[_generatr_abstract_addr_tool_ptr
                                             ->get_abstract_flag(rflags::pf)] =
        std::make_shared<state_symbol>((register_info.RFLAGS >> 2) & 0x1, 1);
    _state_machine_ptr->_flag_symbol_map[_generatr_abstract_addr_tool_ptr
                                             ->get_abstract_flag(rflags::af)] =
        std::make_shared<state_symbol>((register_info.RFLAGS >> 4) & 0x1, 1);
    _state_machine_ptr->_flag_symbol_map[_generatr_abstract_addr_tool_ptr
                                             ->get_abstract_flag(rflags::zf)] =
        std::make_shared<state_symbol>((register_info.RFLAGS >> 6) & 0x1, 1);
    _state_machine_ptr->_flag_symbol_map[_generatr_abstract_addr_tool_ptr
                                             ->get_abstract_flag(rflags::sf)] =
        std::make_shared<state_symbol>((register_info.RFLAGS >> 7) & 0x1, 1);
    _state_machine_ptr->_flag_symbol_map[_generatr_abstract_addr_tool_ptr
                                             ->get_abstract_flag(rflags::df)] =
        std::make_shared<state_symbol>((register_info.RFLAGS >> 10) & 0x1, 1);
    _state_machine_ptr->_flag_symbol_map[_generatr_abstract_addr_tool_ptr
                                             ->get_abstract_flag(rflags::of)] =
        std::make_shared<state_symbol>((register_info.RFLAGS >> 11) & 0x1, 1);
  }
}

void instruction_analyze_tool::init_state_machine_symbol(
    const register_info_t &register_info) {
  // reg
  {// rax
   {auto tmp_symbol = generate_symbol(
        get_symbol_str(_random, _dist), 8,
        {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RAX, 8),
      tmp_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EAX, 4),
      tmp_symbol->_size_32_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AX, 2),
      tmp_symbol->_size_16_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AH, 1),
      tmp_symbol->_size_xh_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_AL, 1),
      tmp_symbol->_size_xl_symbol);
}
// rcx
{
  auto tmp_symbol = generate_symbol(
      get_symbol_str(_random, _dist), 8,
      {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RCX, 8),
      tmp_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_ECX, 4),
      tmp_symbol->_size_32_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_CX, 2),
      tmp_symbol->_size_16_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_CH, 1),
      tmp_symbol->_size_xh_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_CL, 1),
      tmp_symbol->_size_xl_symbol);
}
// rdx
{
  auto tmp_symbol = generate_symbol(
      get_symbol_str(_random, _dist), 8,
      {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RDX, 8),
      tmp_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EDX, 4),
      tmp_symbol->_size_32_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DX, 2),
      tmp_symbol->_size_16_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DH, 1),
      tmp_symbol->_size_xh_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DL, 1),
      tmp_symbol->_size_xl_symbol);
}
// rbx
{
  auto tmp_symbol = generate_symbol(
      get_symbol_str(_random, _dist), 8,
      {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RBX, 8),
      tmp_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EBX, 4),
      tmp_symbol->_size_32_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_BX, 2),
      tmp_symbol->_size_16_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_BH, 1),
      tmp_symbol->_size_xh_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_BL, 1),
      tmp_symbol->_size_xl_symbol);
}
// rsp
{
  auto tmp_symbol = generate_symbol(
      get_symbol_str(_random, _dist), 8,
      {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RSP, 8),
      tmp_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_ESP, 4),
      tmp_symbol->_size_32_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_SP, 2),
      tmp_symbol->_size_16_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_SPL, 1),
      tmp_symbol->_size_xl_symbol);
}
// rbp
{
  auto tmp_symbol = generate_symbol(
      get_symbol_str(_random, _dist), 8,
      {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RBP, 8),
      tmp_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EBP, 4),
      tmp_symbol->_size_32_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_BP, 2),
      tmp_symbol->_size_16_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_BPL, 1),
      tmp_symbol->_size_xl_symbol);
}
// rsi
{
  auto tmp_symbol = generate_symbol(
      get_symbol_str(_random, _dist), 8,
      {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RSI, 8),
      tmp_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_ESI, 4),
      tmp_symbol->_size_32_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_SI, 2),
      tmp_symbol->_size_16_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_SIL, 1),
      tmp_symbol->_size_xl_symbol);
}
// rdi
{
  auto tmp_symbol = generate_symbol(
      get_symbol_str(_random, _dist), 8,
      {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RDI, 8),
      tmp_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_EDI, 4),
      tmp_symbol->_size_32_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DI, 2),
      tmp_symbol->_size_16_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_DIL, 1),
      tmp_symbol->_size_xl_symbol);
}
// r8
{
  auto tmp_symbol = generate_symbol(
      get_symbol_str(_random, _dist), 8,
      {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R8, 8),
      tmp_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R8D, 4),
      tmp_symbol->_size_32_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R8W, 2),
      tmp_symbol->_size_16_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R8B, 1),
      tmp_symbol->_size_xl_symbol);
}
// r9
{
  auto tmp_symbol = generate_symbol(
      get_symbol_str(_random, _dist), 8,
      {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R9, 8),
      tmp_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R9D, 4),
      tmp_symbol->_size_32_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R9W, 2),
      tmp_symbol->_size_16_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R9B, 1),
      tmp_symbol->_size_xl_symbol);
}
// r10
{
  auto tmp_symbol = generate_symbol(
      get_symbol_str(_random, _dist), 8,
      {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R10, 8),
      tmp_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R10D, 4),
      tmp_symbol->_size_32_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R10W, 2),
      tmp_symbol->_size_16_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R10B, 1),
      tmp_symbol->_size_xl_symbol);
}
// r11
{
  auto tmp_symbol = generate_symbol(
      get_symbol_str(_random, _dist), 8,
      {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R11, 8),
      tmp_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R11D, 4),
      tmp_symbol->_size_32_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R11W, 2),
      tmp_symbol->_size_16_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R11B, 1),
      tmp_symbol->_size_xl_symbol);
}
// r12
{
  auto tmp_symbol = generate_symbol(
      get_symbol_str(_random, _dist), 8,
      {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R12, 8),
      tmp_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R12D, 4),
      tmp_symbol->_size_32_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R12W, 2),
      tmp_symbol->_size_16_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R12B, 1),
      tmp_symbol->_size_xl_symbol);
}
// r13
{
  auto tmp_symbol = generate_symbol(
      get_symbol_str(_random, _dist), 8,
      {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R13, 8),
      tmp_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R13D, 4),
      tmp_symbol->_size_32_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R13W, 2),
      tmp_symbol->_size_16_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R13B, 1),
      tmp_symbol->_size_xl_symbol);
}
// r14
{
  auto tmp_symbol = generate_symbol(
      get_symbol_str(_random, _dist), 8,
      {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R14, 8),
      tmp_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R14D, 4),
      tmp_symbol->_size_32_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R14W, 2),
      tmp_symbol->_size_16_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R14B, 1),
      tmp_symbol->_size_xl_symbol);
}
// r15
{
  auto tmp_symbol = generate_symbol(
      get_symbol_str(_random, _dist), 8,
      {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R15, 8),
      tmp_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R15D, 4),
      tmp_symbol->_size_32_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R15W, 2),
      tmp_symbol->_size_16_symbol);
  _state_machine_ptr->set_symbol_for_addr(
      _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_R15B, 1),
      tmp_symbol->_size_xl_symbol);
}
}
// rflags
{
  _state_machine_ptr->_flag_symbol_map[_generatr_abstract_addr_tool_ptr
                                           ->get_abstract_flag(rflags::cf)] =
      generate_symbol(
          get_symbol_str(_random, _dist), 1,
          {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->_flag_symbol_map[_generatr_abstract_addr_tool_ptr
                                           ->get_abstract_flag(rflags::pf)] =
      generate_symbol(
          get_symbol_str(_random, _dist), 1,
          {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->_flag_symbol_map[_generatr_abstract_addr_tool_ptr
                                           ->get_abstract_flag(rflags::af)] =
      generate_symbol(
          get_symbol_str(_random, _dist), 1,
          {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->_flag_symbol_map[_generatr_abstract_addr_tool_ptr
                                           ->get_abstract_flag(rflags::zf)] =
      generate_symbol(
          get_symbol_str(_random, _dist), 1,
          {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->_flag_symbol_map[_generatr_abstract_addr_tool_ptr
                                           ->get_abstract_flag(rflags::sf)] =
      generate_symbol(
          get_symbol_str(_random, _dist), 1,
          {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->_flag_symbol_map[_generatr_abstract_addr_tool_ptr
                                           ->get_abstract_flag(rflags::df)] =
      generate_symbol(
          get_symbol_str(_random, _dist), 1,
          {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
  _state_machine_ptr->_flag_symbol_map[_generatr_abstract_addr_tool_ptr
                                           ->get_abstract_flag(rflags::of)] =
      generate_symbol(
          get_symbol_str(_random, _dist), 1,
          {get_taine_string(taine_enum::not_a_tine, _random, _dist)});
}
}

/**
 * @brief 对映射进行初始化
 */
const std::map<std::string, instruction_type::type>
    instruction_type::type_str_map = {
        {"bswap", instruction_type::type::bswap},
        {"movabs", instruction_type::type::mov},
        {"prefetcht0", instruction_type::type::nop},
        {"comvo", instruction_type::type::cmovo},
        {"cmovno", instruction_type::type::cmovno},
        {"cmovs", instruction_type::type::cmovs},
        {"cmovns", instruction_type::type::cmovns},
        {"cmove", instruction_type::type::cmove},
        {"cmovz", instruction_type::type::cmove},
        {"cmovne", instruction_type::type::cmovne},
        {"cmovnz", instruction_type::type::cmovne},
        {"cmovp", instruction_type::type::cmovp},
        {"cmovpe", instruction_type::type::cmovp},
        {"cmovnp", instruction_type::type::cmovnp},
        {"cmovpo", instruction_type::type::cmovnp},
        {"cmovb", instruction_type::type::cmovb},
        {"cmovc", instruction_type::type::cmovb},
        {"cmovnae", instruction_type::type::cmovb},
        {"cmovae", instruction_type::type::cmovae},
        {"cmovnb", instruction_type::type::cmovae},
        {"cmovnc", instruction_type::type::cmovae},
        {"cmovbe", instruction_type::type::cmovbe},
        {"cmovna", instruction_type::type::cmovbe},
        {"cmova", instruction_type::type::cmova},
        {"cmovnbe", instruction_type::type::cmova},
        {"cmovl", instruction_type::type::cmovl},
        {"cmovnge", instruction_type::type::cmovl},
        {"cmovge", instruction_type::type::cmovge},
        {"cmovnl", instruction_type::type::cmovge},
        {"cmovle", instruction_type::type::cmovle},
        {"cmovng", instruction_type::type::cmovle},
        {"cmovg", instruction_type::type::cmovg},
        {"cmovnle", instruction_type::type::cmovg},

        {"seto", instruction_type::type::seto},
        {"setno", instruction_type::type::setno},
        {"sets", instruction_type::type::sets},
        {"setns", instruction_type::type::setns},
        {"sete", instruction_type::type::sete},
        {"setz", instruction_type::type::sete},
        {"setne", instruction_type::type::setne},
        {"setnz", instruction_type::type::setne},
        {"setp", instruction_type::type::setp},
        {"setpe", instruction_type::type::setp},
        {"setnp", instruction_type::type::setnp},
        {"setpo", instruction_type::type::setnp},
        {"setb", instruction_type::type::setb},
        {"setc", instruction_type::type::setb},
        {"setnae", instruction_type::type::setb},
        {"setae", instruction_type::type::setae},
        {"setnb", instruction_type::type::setae},
        {"setnc", instruction_type::type::setae},
        {"setbe", instruction_type::type::setbe},
        {"setna", instruction_type::type::setbe},
        {"seta", instruction_type::type::seta},
        {"setnbe", instruction_type::type::seta},
        {"setl", instruction_type::type::setl},
        {"setnge", instruction_type::type::setl},
        {"setge", instruction_type::type::setge},
        {"setnl", instruction_type::type::setge},
        {"setle", instruction_type::type::setle},
        {"setng", instruction_type::type::setle},
        {"setg", instruction_type::type::setg},
        {"setnle", instruction_type::type::setg},

        {"endbr64", instruction_type::type::endbr64},
        {"cqo", instruction_type::type::cqo},
        {"cdq", instruction_type::type::cdq},
        {"cdqe", instruction_type::type::cdqe},
        {"mov", instruction_type::type::mov},
        {"movs", instruction_type::type::movs},
        {"movsb", instruction_type::type::movsb},
        {"movsw", instruction_type::type::movsw},
        {"movsxd", instruction_type::type::movsxd},
        {"movslq", instruction_type::type::movsxd},
        {"movzx", instruction_type::type::movzx},
        {"movzbl", instruction_type::type::movzbl},
        {"aaa", instruction_type::type::aaa},
        {"aad", instruction_type::type::aad},
        {"aam", instruction_type::type::aam},
        {"aas", instruction_type::type::aas},
        {"adc", instruction_type::type::adc},
        {"add", instruction_type::type::add},
        {"and", instruction_type::type::AND},
        {"call", instruction_type::type::call},
        {"cbw", instruction_type::type::cbw},
        {"cwde", instruction_type::type::cwde},
        {"clc", instruction_type::type::clc},
        {"cld", instruction_type::type::cld},
        {"cli", instruction_type::type::cli},
        {"cmc", instruction_type::type::cmc},
        {"cmp", instruction_type::type::cmp},
        {"cmpsb", instruction_type::type::cmpsb},
        {"cmpsw", instruction_type::type::cmpsw},
        {"cwd", instruction_type::type::cwd},
        {"daa", instruction_type::type::daa},
        {"das", instruction_type::type::das},
        {"dec", instruction_type::type::dec},
        {"div", instruction_type::type::div},
        {"esc", instruction_type::type::esc},
        {"hlt", instruction_type::type::hlt},
        {"idiv", instruction_type::type::idiv},
        {"imul", instruction_type::type::imul},
        {"in", instruction_type::type::in},
        {"inc", instruction_type::type::inc},
        {"int", instruction_type::type::INT},
        {"into", instruction_type::type::INTO},
        {"iret", instruction_type::type::IRET},
        {"ja", instruction_type::type::ja},
        {"jae", instruction_type::type::jae},
        {"jb", instruction_type::type::jb},
        {"jbe", instruction_type::type::jbe},
        {"jc", instruction_type::type::jc},
        {"je", instruction_type::type::je},
        {"jg", instruction_type::type::jg},
        {"jge", instruction_type::type::jge},
        {"jl", instruction_type::type::jl},
        {"jle", instruction_type::type::jle},
        {"jna", instruction_type::type::jbe},
        {"jnae", instruction_type::type::jb},
        {"jnb", instruction_type::type::jae},
        {"jnbe", instruction_type::type::ja},
        {"jnc", instruction_type::type::jae},
        {"jne", instruction_type::type::jne},
        {"jng", instruction_type::type::jle},
        {"jnbe", instruction_type::type::ja},
        {"jnge", instruction_type::type::jl},
        {"jnl", instruction_type::type::jge},
        {"jnle", instruction_type::type::jg},
        {"jno", instruction_type::type::jno},
        {"jnp", instruction_type::type::jnp},
        {"jns", instruction_type::type::jns},
        {"jnz", instruction_type::type::jne},
        {"jo", instruction_type::type::jo},
        {"jp", instruction_type::type::jp},
        {"jpe", instruction_type::type::jp},
        {"jpo", instruction_type::type::jnp},
        {"js", instruction_type::type::js},
        {"jz", instruction_type::type::je},
        {"jcxz", instruction_type::type::jcxz},
        {"jmp", instruction_type::type::jmp},
        {"jmps", instruction_type::type::jmps},
        {"jmpf", instruction_type::type::jmpf},
        {"lahf", instruction_type::type::lahf},
        {"lds", instruction_type::type::lds},
        {"lea", instruction_type::type::lea},
        {"les", instruction_type::type::les},
        {"lfence", instruction_type::type::lfence},
        {"lods", instruction_type::type::lods},
        {"lodsb", instruction_type::type::lodsb},
        {"lodsw", instruction_type::type::lodsw},
        {"loop", instruction_type::type::loop},
        {"loope", instruction_type::type::loope},
        {"loopne", instruction_type::type::loopne},
        {"loopnz", instruction_type::type::loopnz},
        {"loopz", instruction_type::type::loopz},
        {"mfence", instruction_type::type::mfence},
        {"mul", instruction_type::type::mul},
        {"neg", instruction_type::type::neg},
        {"nop", instruction_type::type::nop},
        {"not", instruction_type::type::NOT},
        {"or", instruction_type::type::OR},
        {"out", instruction_type::type::out},
        {"pop", instruction_type::type::pop},
        {"popf", instruction_type::type::popf},
        {"push", instruction_type::type::push},
        {"pushf", instruction_type::type::pushf},
        {"rcl", instruction_type::type::rcl},
        {"rcr", instruction_type::type::rcr},
        {"ret", instruction_type::type::ret},
        {"retn", instruction_type::type::retn},
        {"retf", instruction_type::type::retf},
        {"rol", instruction_type::type::rol},
        {"ror", instruction_type::type::ror},
        {"sahf", instruction_type::type::sahf},
        {"sal", instruction_type::type::sal},
        {"sar", instruction_type::type::sar},
        {"salc", instruction_type::type::salc},
        {"sbb", instruction_type::type::sbb},
        {"scasb", instruction_type::type::scasb},
        {"scasw", instruction_type::type::scasw},
        {"sfence", instruction_type::type::sfence},
        {"shl", instruction_type::type::shl},
        {"shr", instruction_type::type::shr},
        {"stc", instruction_type::type::stc},
        {"std", instruction_type::type::STD},
        {"sti", instruction_type::type::sti},
        {"stosb", instruction_type::type::stosb},
        {"stosw", instruction_type::type::stosw},
        {"sub", instruction_type::type::sub},
        {"test", instruction_type::type::test},
        {"wait", instruction_type::type::wait},
        {"xchg", instruction_type::type::xchg},
        {"xlat", instruction_type::type::xlat},
        {"xor", instruction_type::type::XOR},

};
