#include "static_analyze_tools.h"

#include <capstone/capstone.h>
#include <capstone/x86.h>

#include <cmath>
#include <cstdint>
#include <map>
#include <memory>
#include <string>
#include <utility>

#include "abstract_addr.h"
#include "conf.h"
#include "diasm_code_tool.h"
#include "state_symbol.h"
#include "test.h"
/**
 * @brief
 * diasm_info，，，，
 *
 * @param step 
 * @param exec  0 1 2
 * @param error_path 
 * @param deep 
 * @param exec_mode  0 ，1 ，2

 * @return std::pair<std::pair<diasm_code_tool::ptr, int>, analyze_result>
 */
std::pair<std::pair<diasm_code_tool::ptr, int>, analyze_result>
static_analyze_tools::static_analyze(
    short step, const std::pair<short, diasm_code_tool::ptr> start_info,
    char exec, bool error_path, char exec_mode, char deep, short cmp_index,
    std::map<abstract_addr::ptr, state_symbol::ptr> &analyze_addr_taine_map) {
  //

  if (step >= MAX_STATIC_STEP_SIZE || step < 0) {
    return std::make_pair(std::make_pair(nullptr, 0),
                          analyze_result::NO_ATTACT);
  }
  if (deep >= 3) {
    return std::make_pair(std::make_pair(nullptr, 0),
                          analyze_result::NO_ATTACT);
  }
  int jcc_num = 0;
  short index = start_info.first;
  diasm_code_tool::ptr diasm_info = start_info.second;
  cs_insn *single_info = &(diasm_info->get_diasm_info()[index]);
  // 
  if (error_path) {
    auto next_info = _instruction_analyze_tool_ptr->analyze_instruction(
        *single_info, exec, true, false, exec_mode, false, false,
        analyze_addr_taine_map, _diasm_info_ptr->get_is_32());
    error_path = false;
    // 
    if (next_info.second == analyze_result::CONTINUE_ANALYZE) {
      if (next_info.first != single_info->address + single_info->size) {
        try {
          auto new_diasm_info =
              find_single_instruction_by_addr(next_info.first);
          index = new_diasm_info.first;
          diasm_info = new_diasm_info.second;
          single_info = &(diasm_info->get_diasm_info()[index]);
          exec = 0;
        } catch (analyze_result e) {
          return std::make_pair(std::make_pair(nullptr, 0), e);
        }
      } else {
        ++index;
        if (index >= diasm_info->get_size()) {
          return std::make_pair(std::make_pair(nullptr, 0),
                                analyze_result::NO_ATTACT);
        }
        single_info = &(diasm_info->get_diasm_info()[index]);
      }
      ++step;
    } else if (next_info.second ==
                   analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW ||
               next_info.second == analyze_result::UNSURE_CONTROL_FOLW_JMP_UP) {
    }
    //
    else {
      return std::make_pair(std::make_pair(nullptr, 0), next_info.second);
    }
  }
  error_path = false;
  uint64_t jcc_count = 0;
  bool control_leak_state = false;
  bool is_cmp_location = false;
  bool is_cache_location = false;
  while (true) {
    if (deep >= 3) {
      return std::make_pair(std::make_pair(nullptr, 0),
                            analyze_result::NO_ATTACT);
    }
    if (step >= MAX_STATIC_STEP_SIZE || step < 0) {
      return std::make_pair(std::make_pair(nullptr, 0),
                            analyze_result::NO_ATTACT);
    }
    // cache miss
    if ((index == cmp_index) && exec_mode == 0) {
      is_cmp_location = true;
    }
    if (single_info->address == _diasm_info_ptr->get_cache_miss_addr()) {
      is_cache_location = true;
    }
    //
    auto next_info = _instruction_analyze_tool_ptr->analyze_instruction(
        *single_info, exec, false, control_leak_state, exec_mode,
        is_cmp_location, is_cache_location, analyze_addr_taine_map,
        _diasm_info_ptr->get_is_32());
    //
    is_cmp_location = false;
    is_cache_location = false;
    ++step;
    exec = 0;
    switch (next_info.second) {
        //  
      case analyze_result::UNSURE_CONTROL_FOLW_JMP_BELOW: {
        ++deep;
        if (deep >= 3) {
          return std::make_pair(std::make_pair(nullptr, 0),
                                analyze_result::NO_ATTACT);
        }
        //
        static_analyze_tools tmp(*this);
        --step;
        auto state = tmp.static_analyze(step, std::make_pair(index, diasm_info),
                                        1, false, exec_mode, deep, cmp_index,
                                        analyze_addr_taine_map);
        if (state.second == analyze_result::FIND_ATTACK ||
            state.second == analyze_result::ALREADY_FIND_INIT_TAINE) {
          return state;
        }
        exec = 2;
        break;
      }
        // 
      case analyze_result::UNSURE_CONTROL_FOLW_JMP_UP: {
        ++deep;
        if (deep >= 3) {
          return std::make_pair(std::make_pair(nullptr, 0),
                                analyze_result::NO_ATTACT);
        }
        static_analyze_tools tmp(*this);
        --step;
        auto state = tmp.static_analyze(step, std::make_pair(index, diasm_info),
                                        2, false, exec_mode, deep, cmp_index,
                                        analyze_addr_taine_map);
        if (state.second == analyze_result::FIND_ATTACK ||
            state.second == analyze_result::ALREADY_FIND_INIT_TAINE) {
          return state;
        }
        exec = 1;
        break;
      }
        // ret 
      case analyze_result::RET_INSTRUCTION: {
        if (_diasm_info_ptr->get_ret_addr() != 0) {
          try {
            auto new_diasm_info = find_single_instruction_by_addr(
                _diasm_info_ptr->get_ret_addr());
            index = new_diasm_info.first;
            diasm_info = new_diasm_info.second;
            single_info = &(diasm_info->get_diasm_info()[index]);
            _diasm_info_ptr->reset_ret_addr();
          } catch (analyze_result e) {
            return std::make_pair(std::make_pair(nullptr, 0), e);
          }
        } else {
          return std::make_pair(std::make_pair(nullptr, 0),
                                analyze_result::CANNOT_FIND_NEXT_INSTRUCTION);
        }
        break;
      }
        // 
      case analyze_result::CONTINUE_ANALYZE: {
        // branchmiss
        if (exec_mode == 0 &&
            next_info.first == _diasm_info_ptr->get_branch_miss_addr()) {
          for (auto iter : _instruction_analyze_tool_ptr->_mem_taine_addr_map) {
            if (iter.second !=
                _instruction_analyze_tool_ptr->get_state_machine_ptr()
                    ->get_symbol_from_addr(iter.first)) {
              break;
            }
            // 
            auto taine_str = _instruction_analyze_tool_ptr->get_taine_str(
                taine_enum::taine1);

            // mem
            if (iter.first->get_addr_string() != "") {
              auto symbol_str_vec = iter.first->get_symbol_str_vector();
              auto map = _instruction_analyze_tool_ptr->get_state_machine_ptr()
                             ->find_addr_contain_symbol(symbol_str_vec,
                                                        iter.first->_size);
              for (auto no_taine_iter : map) {
                analyze_addr_taine_map[no_taine_iter.first] =
                    no_taine_iter.second;
              }
              auto tmp = _instruction_analyze_tool_ptr->generate_symbol(
                  _instruction_analyze_tool_ptr->get_symbol_string(),
                  iter.first->_size, {taine_str});
              tmp->set_symbol_mem_effect_true();
              analyze_addr_taine_map[iter.first] = tmp;
            }
            // reg
            else {
              analyze_addr_taine_map[iter.first] =
                  _instruction_analyze_tool_ptr->generate_symbol(
                      _instruction_analyze_tool_ptr->get_symbol_string(),
                      iter.first->_size, {taine_str});
            }
          }
          if (analyze_addr_taine_map.size() == 0) {
            return std::make_pair(std::make_pair(nullptr, 0),
                                  analyze_result::NO_ATTACT);
          }
          return std::make_pair(std::make_pair(nullptr, 0),
                                analyze_result::ALREADY_FIND_INIT_TAINE);
        }
        // cache miss
        if (exec_mode == 0 &&
            next_info.first == _diasm_info_ptr->get_cache_miss_addr()) {
          is_cache_location = true;
        }
        // 
        if (next_info.first != single_info->address + single_info->size) {
          try {
            auto new_diasm_info =
                find_single_instruction_by_addr(next_info.first);
            index = new_diasm_info.first;
            diasm_info = new_diasm_info.second;
            single_info = &(diasm_info->get_diasm_info()[index]);
            exec = 0;
          } catch (analyze_result e) {
            return std::make_pair(std::make_pair(nullptr, 0), e);
          }
        }
        // 
        else {
          ++index;
          if (index >= diasm_info->get_size()) {
            return std::make_pair(std::make_pair(nullptr, 0),
                                  analyze_result::NO_ATTACT);
          }
          single_info = &(diasm_info->get_diasm_info()[index]);
          exec = 0;
        }
        break;
      }
        // callrsirdi
      case analyze_result::CALL_INSTRUCTION_WITH_TAINE: {
        // 
        if (judge_call_func_mem(_diasm_info_ptr->get_target_pid(),
                                next_info.first)) {
          return std::make_pair(std::make_pair(diasm_info, index),
                                analyze_result::FIND_ATTACK);
        }
        // 
        try {
          auto new_diasm_info =
              find_single_instruction_by_addr(next_info.first);
          index = new_diasm_info.first;
          diasm_info = new_diasm_info.second;
          single_info = &(diasm_info->get_diasm_info()[index]);
          exec = 0;
        } catch (analyze_result e) {
          return std::make_pair(std::make_pair(nullptr, 0), e);
        }
        break;
      }
        // 
      case analyze_result::FIND_ATTACK: {
        return std::make_pair(std::make_pair(diasm_info, index),
                              next_info.second);
        break;
      }
      case analyze_result::MAY_LEAK_FROM_CONTROL: {
        control_leak_state = true;
        break;
      }
        //
      default: {
        return std::make_pair(std::make_pair(nullptr, 0), next_info.second);
        break;
      }
    }
  }

  return std::make_pair(std::make_pair(nullptr, 0), analyze_result::NO_ATTACT);
}

std::pair<short, diasm_code_tool::ptr>
static_analyze_tools::find_single_instruction_by_addr(uint64_t addr) {
  for (auto diasm_info : _diasm_info_ptr->get_diasm_info()) {
    if (addr >= diasm_info->get_start_addr() &&
        addr <= diasm_info->get_stop_addr()) {
      for (int i = 0; i < diasm_info->get_size(); ++i) {
        std::string key = diasm_info->get_diasm_info()[i].mnemonic;
        // if (key == "ret") {
        //   break;
        // }
        if (addr == diasm_info->get_diasm_info()[i].address) {
          return std::make_pair(i, diasm_info);
        }
      }
    }
  }
  throw analyze_result::CANNOT_FIND_NEXT_INSTRUCTION;
}

// 
std::pair<std::pair<diasm_code_tool::ptr, int>, analyze_result>
static_analyze_tools::analyze() {
  //
  // test 
  // branchmisscmptest
  // cmpindex

  // 
  std::map<abstract_addr::ptr, state_symbol::ptr> analyze_addr_taine_map;

  char exec_mode = -1;
  uint32_t start_offset =
      get_start_addr_offset(_diasm_info_ptr->get_over_head_info().c_str(),
                            _diasm_info_ptr->get_virtual_start_addr(),
                            _diasm_info_ptr->get_cache_miss_addr());
  _diasm_info_ptr->set_start_offset(start_offset);

  std::map<uint64_t, bool> analyze_mem;
  for (int i = 0; i < 16; ++i) {
    if (_diasm_info_ptr->get_over_head_info() == "") {
      exec_mode = 2;
      break;
    }
    // 
    if (((_diasm_info_ptr->get_start_offset() >> i) & 0x1) > 0) {
      // 
      diasm_code_tool::ptr tmp = std::make_shared<diasm_code_tool>();
      // 
      // cache miss addr
      if (tmp->diasm_code(
              (const uint8_t *)_diasm_info_ptr->get_over_head_info().c_str() +
                  i,
              _diasm_info_ptr->get_over_head_info().size() - i,
              _diasm_info_ptr->get_virtual_start_addr() + i)) {
        //  
        int branch_miss_index = tmp->get_size() - 1;
        if (branch_miss_index > 0) {
          // 
          // cmptest
          bool judge_cmp_type = true;
          // 
          bool analyze_state = false;
          // cmptest
          short cmp_index = -1;
          for (int index = branch_miss_index; index >= 0; --index) {
            std::string tmp_str =
                std::string(tmp->get_diasm_info()[index].mnemonic);
            cs_insn *tmp_ins = &tmp->get_diasm_info()[index];
            if (tmp_str == "cmp") {
              if (judge_cmp_type) {
                if ((tmp->get_diasm_info()[index]
                         .detail->x86.operands[0]
                         .type == X86_OP_IMM) ||
                    tmp->get_diasm_info()[index].detail->x86.operands[1].type ==
                        X86_OP_IMM) {
                  auto test = tmp->get_diasm_info()[index];
                  if ((test.detail->x86.operands[0].type == X86_OP_IMM &&
                       test.detail->x86.operands[0].imm == 0) ||
                      (test.detail->x86.operands[1].type == X86_OP_IMM &&
                       test.detail->x86.operands[1].imm == 0)) {
                    exec_mode = 2;
                  }
                  goto end_label;
                }
                judge_cmp_type = false;
                cmp_index = index;
              }
            } else if (tmp_str == "test") {
              if (judge_cmp_type) {
                if (tmp->get_diasm_info()[index].detail->x86.operands[0].type ==
                        X86_OP_IMM ||
                    tmp->get_diasm_info()[index].detail->x86.operands[1].type ==
                        X86_OP_IMM ||
                    judge_opearter_same(
                        tmp->get_diasm_info()[index].detail->x86.operands[0],
                        tmp->get_diasm_info()[index].detail->x86.operands[1])) {
                  exec_mode = 2;
                  goto end_label;
                }
                judge_cmp_type = false;
                cmp_index = index;
              }
            }
            // push rbp mov rbp rsp sub rsp xx
            //  sub rsp xxx
            else if (tmp_str == "sub" && cmp_index > 0 &&
                     (tmp_ins->detail->x86.operands[0].reg == X86_REG_RSP ||
                      tmp_ins->detail->x86.operands[0].reg == X86_REG_ESP)) {
              // 
              analyze_state = true;
              if (analyze_mem.count(tmp_ins->address)) {
                break;
              }
              if (index + 1 > branch_miss_index) {
                break;
              }
              //  
              //  
              _instruction_analyze_tool_ptr->clear_state_machine();
              _instruction_analyze_tool_ptr->init_state_machine_symbol(
                  _diasm_info_ptr->get_branch_miss_register_info());
              auto diasm_info = std::make_pair(index + 1, tmp);
              auto res = static_analyze(1, diasm_info, 0, false, 0, 0,
                                        cmp_index, analyze_addr_taine_map);
              if (!(res.second == analyze_result::ALREADY_FIND_INIT_TAINE)) {
                break;
              }
              // 
              {
                // 
                _instruction_analyze_tool_ptr->clear_state_machine();
                // branch miss
                auto diasm_info = find_single_instruction_by_addr(
                    _diasm_info_ptr->get_branch_miss_addr());
                bool is_je = false;
                {
                  auto jcc_ins =
                      diasm_info.second->get_diasm_info()[diasm_info.first];
                  for (int i = 1; i < 10; ++i) {
                    auto this_ins =
                        diasm_info.second
                            ->get_diasm_info()[diasm_info.first + i];
                    if (jcc_ins.detail->x86.operands[0].type == X86_OP_IMM &&
                        jcc_ins.detail->x86.operands[0].imm ==
                            this_ins.address) {
                      break;
                    } else if (jcc_ins.detail->x86.operands[0].type !=
                                   X86_OP_IMM &&
                               i > 3) {
                      break;
                    } else if (this_ins.mnemonic[0] == 'r' &&
                               this_ins.mnemonic[1] == 'e' &&
                               this_ins.mnemonic[2] == 't') {
                      is_je = true;
                    }
                  }
                  // auto str =
                  //     diasm_info.second->get_diasm_info()[diasm_info.first]
                  //         .mnemonic;
                  // if (str[0] == 'j' && (str[1] == 'e' || str[1] == 'a') &&
                  //     str[2] != 'e') {
                  //   is_je = true;
                  // }
                }
                // pebs
                _instruction_analyze_tool_ptr->init_state_machine(
                    _diasm_info_ptr->get_branch_miss_register_info(), is_je);
                // 
                _instruction_analyze_tool_ptr->set_init_taine(
                    analyze_addr_taine_map);
                // 
                auto res = static_analyze(1, diasm_info, 0, true, 1, 0, 0,
                                          analyze_addr_taine_map);
                if (res.second == analyze_result::FIND_ATTACK) {
                  return res;
                }
              }
              // 
              analyze_mem[tmp_ins->address] = true;

              break;
            }
            //  mov rbp rsp
            else if (tmp_str == "mov" && cmp_index > 0 &&
                     ((tmp_ins->detail->x86.operands[0].reg == X86_REG_RBP &&
                       tmp_ins->detail->x86.operands[1].reg == X86_REG_RSP) ||
                      (tmp_ins->detail->x86.operands[0].reg == X86_REG_EBP &&
                       tmp_ins->detail->x86.operands[1].reg == X86_REG_ESP))) {
              analyze_state = true;
              // 
              if (analyze_mem.count(tmp_ins->address)) {
                break;
              }
              if (index + 1 > branch_miss_index) {
                break;
              }
              //  
              //  
              _instruction_analyze_tool_ptr->clear_state_machine();
              _instruction_analyze_tool_ptr->init_state_machine_symbol(
                  _diasm_info_ptr->get_branch_miss_register_info());

              auto diasm_info = std::make_pair(index + 1, tmp);
              auto res = static_analyze(1, diasm_info, 0, false, 0, 0,
                                        cmp_index, analyze_addr_taine_map);
              if (!(res.second == analyze_result::ALREADY_FIND_INIT_TAINE)) {
                break;
              }
              // 
              {
                // 
                _instruction_analyze_tool_ptr->clear_state_machine();
                // branch miss
                auto diasm_info = find_single_instruction_by_addr(
                    _diasm_info_ptr->get_branch_miss_addr());
                bool is_je = false;
                {
                  auto jcc_ins =
                      diasm_info.second->get_diasm_info()[diasm_info.first];
                  for (int i = 1; i < 10; ++i) {
                    auto this_ins =
                        diasm_info.second
                            ->get_diasm_info()[diasm_info.first + i];
                    if (jcc_ins.detail->x86.operands[0].type == X86_OP_IMM &&
                        jcc_ins.detail->x86.operands[0].imm ==
                            this_ins.address) {
                      break;
                    } else if (jcc_ins.detail->x86.operands[0].type !=
                                   X86_OP_IMM &&
                               i > 3) {
                      break;
                    } else if (this_ins.mnemonic[0] == 'r' &&
                               this_ins.mnemonic[1] == 'e' &&
                               this_ins.mnemonic[2] == 't') {
                      is_je = true;
                    }
                  }
                  // auto str =
                  //     diasm_info.second->get_diasm_info()[diasm_info.first]
                  //         .mnemonic;
                  // if (str[0] == 'j' &&
                  //     (str[1] == 'e' || str[1] == 'a' || str[1] == 'b') &&
                  //     str[2] != 'e') {
                  //   is_je = true;
                  // }
                }
                // pebs
                _instruction_analyze_tool_ptr->init_state_machine(
                    _diasm_info_ptr->get_branch_miss_register_info(), is_je);
                // 
                _instruction_analyze_tool_ptr->set_init_taine(
                    analyze_addr_taine_map);
                // 
                auto res = static_analyze(1, diasm_info, 0, true, 1, 0, 0,
                                          analyze_addr_taine_map);
                if (res.second == analyze_result::FIND_ATTACK) {
                  return res;
                }
              }
              // 
              analyze_mem[tmp_ins->address] = true;
            } else if (tmp_str == "push" && cmp_index > 0 &&
                       ((tmp_ins->detail->x86.operands[0].reg == X86_REG_RBP) ||
                        (tmp_ins->detail->x86.operands[0].reg ==
                         X86_REG_EBP))) {
              analyze_state = true;
              // 
              if (analyze_mem.count(tmp_ins->address)) {
                break;
              }
              if (index + 1 > branch_miss_index) {
                break;
              }
              //  
              //  
              _instruction_analyze_tool_ptr->clear_state_machine();
              _instruction_analyze_tool_ptr->init_state_machine_symbol(
                  _diasm_info_ptr->get_branch_miss_register_info());

              auto diasm_info = std::make_pair(index + 1, tmp);
              auto res = static_analyze(1, diasm_info, 0, false, 0, 0,
                                        cmp_index, analyze_addr_taine_map);
              if (!(res.second == analyze_result::ALREADY_FIND_INIT_TAINE)) {
                break;
              }
              // 
              {
                // 
                _instruction_analyze_tool_ptr->clear_state_machine();
                // branch miss
                auto diasm_info = find_single_instruction_by_addr(
                    _diasm_info_ptr->get_branch_miss_addr());
                bool is_je = false;
                {
                  auto jcc_ins =
                      diasm_info.second->get_diasm_info()[diasm_info.first];
                  for (int i = 1; i < 10; ++i) {
                    auto this_ins =
                        diasm_info.second
                            ->get_diasm_info()[diasm_info.first + i];
                    if (jcc_ins.detail->x86.operands[0].type == X86_OP_IMM &&
                        jcc_ins.detail->x86.operands[0].imm ==
                            this_ins.address) {
                      break;
                    } else if (jcc_ins.detail->x86.operands[0].type !=
                                   X86_OP_IMM &&
                               i > 3) {
                      break;
                    } else if (this_ins.mnemonic[0] == 'r' &&
                               this_ins.mnemonic[1] == 'e' &&
                               this_ins.mnemonic[2] == 't') {
                      is_je = true;
                    }
                  }
                  // auto str =
                  //     diasm_info.second->get_diasm_info()[diasm_info.first]
                  //         .mnemonic;
                  // if (str[0] == 'j' &&
                  //     (str[1] == 'e' || str[1] == 'a' || str[1] == 'b') &&
                  //     str[2] != 'e') {
                  //   is_je = true;
                  // }
                }
                // pebs
                _instruction_analyze_tool_ptr->init_state_machine(
                    _diasm_info_ptr->get_branch_miss_register_info(), is_je);
                // 
                _instruction_analyze_tool_ptr->set_init_taine(
                    analyze_addr_taine_map);
                // 
                auto res = static_analyze(1, diasm_info, 0, true, 1, 0, 0,
                                          analyze_addr_taine_map);
                if (res.second == analyze_result::FIND_ATTACK) {
                  return res;
                }
              }
              // 
              analyze_mem[tmp_ins->address] = true;
            } else if (tmp_str == "endbr64" && cmp_index > 0) {
              analyze_state = true;
              // 
              if (analyze_mem.count(tmp_ins->address)) {
                break;
              }
              if (index + 1 > branch_miss_index) {
                break;
              }
              //  
              //  
              _instruction_analyze_tool_ptr->clear_state_machine();
              _instruction_analyze_tool_ptr->init_state_machine_symbol(
                  _diasm_info_ptr->get_branch_miss_register_info());

              auto diasm_info = std::make_pair(index + 1, tmp);
              auto res = static_analyze(1, diasm_info, 0, false, 0, 0,
                                        cmp_index, analyze_addr_taine_map);
              if (!(res.second == analyze_result::ALREADY_FIND_INIT_TAINE)) {
                break;
              }
              // 
              {
                // 
                _instruction_analyze_tool_ptr->clear_state_machine();
                // branch miss
                auto diasm_info = find_single_instruction_by_addr(
                    _diasm_info_ptr->get_branch_miss_addr());
                bool is_je = false;
                {
                  auto jcc_ins =
                      diasm_info.second->get_diasm_info()[diasm_info.first];
                  for (int i = 1; i < 10; ++i) {
                    auto this_ins =
                        diasm_info.second
                            ->get_diasm_info()[diasm_info.first + i];
                    if (jcc_ins.detail->x86.operands[0].type == X86_OP_IMM &&
                        jcc_ins.detail->x86.operands[0].imm ==
                            this_ins.address) {
                      break;
                    } else if (jcc_ins.detail->x86.operands[0].type !=
                                   X86_OP_IMM &&
                               i > 3) {
                      break;
                    } else if (this_ins.mnemonic[0] == 'r' &&
                               this_ins.mnemonic[1] == 'e' &&
                               this_ins.mnemonic[2] == 't') {
                      is_je = true;
                    }
                  }
                  // auto str =
                  //     diasm_info.second->get_diasm_info()[diasm_info.first]
                  //         .mnemonic;
                  // if (str[0] == 'j' &&
                  //     (str[1] == 'e' || str[1] == 'a' || str[1] == 'b') &&
                  //     str[2] != 'e') {
                  //   is_je = true;
                  // }
                }
                // pebs
                _instruction_analyze_tool_ptr->init_state_machine(
                    _diasm_info_ptr->get_branch_miss_register_info(), is_je);
                // 
                _instruction_analyze_tool_ptr->set_init_taine(
                    analyze_addr_taine_map);
                // 
                auto res = static_analyze(1, diasm_info, 0, true, 1, 0, 0,
                                          analyze_addr_taine_map);
                if (res.second == analyze_result::FIND_ATTACK) {
                  return res;
                }
              }
              // 
              analyze_mem[tmp_ins->address] = true;
            } else if (tmp_str == "ret" && cmp_index > 0) {
              analyze_state = true;
              // 
              if (analyze_mem.count(tmp_ins->address)) {
                break;
              }
              if (index + 1 > branch_miss_index) {
                break;
              }
              //  
              //  
              _instruction_analyze_tool_ptr->clear_state_machine();
              _instruction_analyze_tool_ptr->init_state_machine_symbol(
                  _diasm_info_ptr->get_branch_miss_register_info());

              auto diasm_info = std::make_pair(index + 1, tmp);
              auto res = static_analyze(1, diasm_info, 0, false, 0, 0,
                                        cmp_index, analyze_addr_taine_map);
              if (!(res.second == analyze_result::ALREADY_FIND_INIT_TAINE)) {
                break;
              }
              // 
              {
                // 
                _instruction_analyze_tool_ptr->clear_state_machine();
                // branch miss
                auto diasm_info = find_single_instruction_by_addr(
                    _diasm_info_ptr->get_branch_miss_addr());
                bool is_je = false;
                {
                  auto jcc_ins =
                      diasm_info.second->get_diasm_info()[diasm_info.first];
                  for (int i = 1; i < 10; ++i) {
                    auto this_ins =
                        diasm_info.second
                            ->get_diasm_info()[diasm_info.first + i];
                    if (jcc_ins.detail->x86.operands[0].type == X86_OP_IMM &&
                        jcc_ins.detail->x86.operands[0].imm ==
                            this_ins.address) {
                      break;
                    } else if (jcc_ins.detail->x86.operands[0].type !=
                                   X86_OP_IMM &&
                               i > 3) {
                      break;
                    } else if (this_ins.mnemonic[0] == 'r' &&
                               this_ins.mnemonic[1] == 'e' &&
                               this_ins.mnemonic[2] == 't') {
                      is_je = true;
                    }
                  }
                  // auto str =
                  //     diasm_info.second->get_diasm_info()[diasm_info.first]
                  //         .mnemonic;
                  // if (str[0] == 'j' &&
                  //     (str[1] == 'e' || str[1] == 'a' || str[1] == 'b') &&
                  //     str[2] != 'e') {
                  //   is_je = true;
                  // }
                }
                // pebs
                _instruction_analyze_tool_ptr->init_state_machine(
                    _diasm_info_ptr->get_branch_miss_register_info(), is_je);
                // 
                _instruction_analyze_tool_ptr->set_init_taine(
                    analyze_addr_taine_map);
                // 
                auto res = static_analyze(1, diasm_info, 0, true, 1, 0, 0,
                                          analyze_addr_taine_map);
                if (res.second == analyze_result::FIND_ATTACK) {
                  return res;
                }
              }
              // 
              analyze_mem[tmp_ins->address] = true;
            }
          }
          // 
          if (!analyze_state && cmp_index > 0) {
            _instruction_analyze_tool_ptr->clear_state_machine();
            _instruction_analyze_tool_ptr->init_state_machine_symbol(
                _diasm_info_ptr->get_branch_miss_register_info());

            auto diasm_info = std::make_pair(0, tmp);
            auto res = static_analyze(1, diasm_info, 0, false, 0, 0, cmp_index,
                                      analyze_addr_taine_map);
            if (!(res.second == analyze_result::ALREADY_FIND_INIT_TAINE)) {
              continue;
            }
            // 
            {
              // 
              _instruction_analyze_tool_ptr->clear_state_machine();
              // branch miss
              auto diasm_info = find_single_instruction_by_addr(
                  _diasm_info_ptr->get_branch_miss_addr());
              bool is_je = false;
              {
                auto jcc_ins =
                    diasm_info.second->get_diasm_info()[diasm_info.first];
                for (int i = 1; i < 10; ++i) {
                  auto this_ins =
                      diasm_info.second->get_diasm_info()[diasm_info.first + i];
                  if (jcc_ins.detail->x86.operands[0].type == X86_OP_IMM &&
                      jcc_ins.detail->x86.operands[0].imm == this_ins.address) {
                    break;
                  } else if (jcc_ins.detail->x86.operands[0].type !=
                                 X86_OP_IMM &&
                             i > 3) {
                    break;
                  } else if (this_ins.mnemonic[0] == 'r' &&
                             this_ins.mnemonic[1] == 'e' &&
                             this_ins.mnemonic[2] == 't') {
                    is_je = true;
                  }
                }
                // auto str =
                // diasm_info.second->get_diasm_info()[diasm_info.first]
                //                .mnemonic;
                // if (str[0] == 'j' &&
                //     (str[1] == 'e' || str[1] == 'a' || str[1] == 'b') &&
                //     str[2] != 'e') {
                //   is_je = true;
                // }
              }
              // pebs
              _instruction_analyze_tool_ptr->init_state_machine(
                  _diasm_info_ptr->get_branch_miss_register_info(), is_je);
              // 
              _instruction_analyze_tool_ptr->set_init_taine(
                  analyze_addr_taine_map);
              // 
              auto res = static_analyze(1, diasm_info, 0, true, 1, 0, 0,
                                        analyze_addr_taine_map);
              if (res.second == analyze_result::FIND_ATTACK) {
                return res;
              }
            }
          }
        }
      }
    }
  }

end_label:
  if (exec_mode == 2) {
    // 
    {
      // 
      _instruction_analyze_tool_ptr->clear_state_machine();
      // pebs
      _instruction_analyze_tool_ptr->init_state_machine(
          _diasm_info_ptr->get_branch_miss_register_info());
      _instruction_analyze_tool_ptr->set_init_taine_for_exec_mode_is_2();
      // 
      auto diasm_info = find_single_instruction_by_addr(
          _diasm_info_ptr->get_branch_miss_addr());
      return static_analyze(1, diasm_info, 0, true, 2, 0, 0,
                            analyze_addr_taine_map);
    }
  } else {
    std::pair<std::pair<diasm_code_tool::ptr, int>, analyze_result> res =
        std::make_pair(std::make_pair(nullptr, 0), analyze_result::NO_ATTACT);
    return res;
  }
}
