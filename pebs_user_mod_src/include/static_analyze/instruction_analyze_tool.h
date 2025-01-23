#ifndef INSTRUCTION_ANALYZE_TOOL
#define INSTRUCTION_ANALYZE_TOOL
#include <capstone/capstone.h>
#include <capstone/x86.h>

#include <cstddef>
#include <cstdint>
#include <ctime>
#include <map>
#include <memory>
#include <random>
#include <string>
#include <utility>
#include <vector>

#include "conf.h"
#include "diasm_code_tool.h"
#include "state_symbol.h"
#include "static_analyze/abstract_addr.h"
#include "static_analyze/state_machine.h"

class instruction_analyze_tool {
 public:
  typedef std::shared_ptr<instruction_analyze_tool> ptr;
  /**
   * @brief Construct a new instruction analyze tool object
   * 
   * @param ptr
   */
  instruction_analyze_tool(std::uniform_int_distribution<int> &dist)
      : _dist(dist) {
    _random.seed(time(0));
    _generatr_abstract_addr_tool_ptr =
        std::make_shared<generate_abstract_addr_tool>(_random, _dist);
    _state_machine_ptr = std::make_shared<state_machine>(_random, _dist);
  }
  /**
   * @brief 
   *
   * @param other_ptr
   */
  instruction_analyze_tool(const instruction_analyze_tool *other_ptr)
      : _dist(other_ptr->_dist) {
    
    _random = other_ptr->_random;
   
    _state_machine_ptr = other_ptr->_state_machine_ptr->shallow_copy();
    //
    _generatr_abstract_addr_tool_ptr =
        other_ptr->_generatr_abstract_addr_tool_ptr->shallow_copy();
  }

  std::shared_ptr<state_symbol> generate_symbol(
      std::string symbol_name, size_t symbol_size,
      std::vector<std::string> taine_vector) {
    auto tmp =
        std::make_shared<state_symbol>(symbol_name, symbol_size, taine_vector);
    switch (symbol_size) {
      case 8: {
        tmp->_size_xh_symbol =
            std::make_shared<state_symbol>(symbol_name + "xh", 1, taine_vector);
        tmp->_size_xl_symbol = std::make_shared<state_symbol>(tmp, 1);
        tmp->_size_16_symbol = std::make_shared<state_symbol>(tmp, 2);
        tmp->_size_16_symbol->_size_xl_symbol = tmp->_size_xl_symbol;
        tmp->_size_16_symbol->_size_xh_symbol = tmp->_size_xh_symbol;
        tmp->_size_32_symbol = std::make_shared<state_symbol>(tmp, 4);
        tmp->_size_32_symbol->_size_16_symbol = tmp->_size_16_symbol;
        tmp->_size_32_symbol->_size_xh_symbol = tmp->_size_xh_symbol;
        tmp->_size_32_symbol->_size_xl_symbol = tmp->_size_xl_symbol;
      }
      case 4: {
        tmp->_size_xh_symbol =
            std::make_shared<state_symbol>(symbol_name + "xh", 1, taine_vector);
        tmp->_size_xl_symbol = std::make_shared<state_symbol>(tmp, 1);
        tmp->_size_16_symbol = std::make_shared<state_symbol>(tmp, 2);
        tmp->_size_16_symbol->_size_xl_symbol = tmp->_size_xl_symbol;
        tmp->_size_16_symbol->_size_xh_symbol = tmp->_size_xh_symbol;
      }
      case 2: {
        tmp->_size_xh_symbol =
            std::make_shared<state_symbol>(symbol_name + "xh", 1, taine_vector);
        tmp->_size_xl_symbol = std::make_shared<state_symbol>(tmp, 1);
      }
    }
    return tmp;
  }
  /**
   * @brief 
   *
   * @return instruction_analyze_tool::ptr
   */
  instruction_analyze_tool::ptr shallow_copy() {
    return std::make_shared<instruction_analyze_tool>(this);
  }
  /**
   * @brief 
   *
   */
  void init_state_machine(const register_info_t &register_info,
                          bool is_je_jum = false);
  // 
  void init_state_machine_symbol(const register_info_t &register_info);
  // 
  void clear_state_machine() {
    _state_machine_ptr->clear_all_symbol();
    _generatr_abstract_addr_tool_ptr->clear_addr();
    _mem_taine_addr_map.clear();
  }
  // 
  void set_init_taine(
      std::map<abstract_addr::ptr, state_symbol::ptr> taine_addr_map) {
    std::vector<abstract_addr::ptr> addr_vec;
    for (auto iter : taine_addr_map) {
      // 
      if (iter.first->get_reg() != X86_REG_INVALID) {
        auto symbol = _state_machine_ptr->get_symbol_from_addr(
            _generatr_abstract_addr_tool_ptr->get_abstract_addr(
                iter.first->get_reg(), iter.first->_size));
        if (iter.second->_taine != taine_enum::not_a_tine && symbol->is_num() &&
            symbol->to_int() < 1000) {
          continue;
        }
        set_target_symbol(_generatr_abstract_addr_tool_ptr->get_abstract_addr(
                              iter.first->get_reg(), iter.first->_size),
                          iter.second, true);
      }
      // 
      else {
        addr_vec.push_back(iter.first);
        _state_machine_ptr->_addr_symbol_map[iter.first] = iter.second;
      }
    }
    _generatr_abstract_addr_tool_ptr->set_addr(addr_vec);
  }
  void set_init_taine_for_exec_mode_is_2() {
    auto symbol =
        generate_symbol(get_symbol_str(_random, _dist), 8,
                        {get_taine_string(taine_enum::taine1, _random, _dist)});
    set_target_symbol(
        _generatr_abstract_addr_tool_ptr->get_abstract_addr(X86_REG_RDI, 8),
        symbol, true);
  }
  std::string get_symbol_string() { return get_symbol_str(_random, _dist); }
  std::string get_taine_str(taine_enum taine) {
    return get_taine_string(taine, _random, _dist);
  }
  /**
   * @brief 
   *
   * @param insn 
   * @param exec 
   * @param error_path 
   * @param exec_mode 
   * @param is_cmp_location 
   * 
   * @return uint64_t
   */
  std::pair<uint64_t, analyze_result> analyze_instruction(
      const cs_insn &insn, char exec, bool error_path, bool control_leak_state,
      char exec_mode, bool is_cmp_location, bool is_cache_miss_location,
      std::map<abstract_addr::ptr, state_symbol::ptr> &analyze_addr_taine_map,
      bool is_32);

  // 
  std::map<abstract_addr::ptr, state_symbol::ptr> _mem_taine_addr_map;
  generate_abstract_addr_tool::ptr get_generatr_abstract_addr_tool_ptr() {
    return _generatr_abstract_addr_tool_ptr;
  }
  state_machine::ptr get_state_machine_ptr() { return _state_machine_ptr; }

 private:
  /**
   * @brief 
   */
  state_machine::ptr _state_machine_ptr;
  /**
   * @brief 
   */
  generate_abstract_addr_tool::ptr _generatr_abstract_addr_tool_ptr;

  // 
  std::default_random_engine _random;
  // 
  std::uniform_int_distribution<int> &_dist;

  /**
   * @brief 
   *
   * @param op
   * @param addr
   * @param symbol
   * @param read
   * @param control_leak_model
   * @param exec_mode 
   * @return 
   */
  char analyze_operator(const cs_x86_op &op, abstract_addr::ptr &addr,
                        state_symbol::ptr &symbol, bool read,
                        bool control_leak_model, char exec_mode);

  void set_target_symbol(abstract_addr::ptr target_addr,
                         state_symbol::ptr symbol,
                         bool is_set_init_taine = false);
};

class instruction_type {
 public:
  enum class type {
    bswap,
    endbr64,
    mov,
    movs,
    movsb,
    movsw,
    movsxd,
    movzx,
    movzbl,
    cmovo,
    seto,
    cmovno,
    setno,
    cmovs,
    sets,
    cmovns,
    setns,
    cmove,
    cmovne,
    sete,
    setne,
    cmovp,
    setp,
    cmovnp,
    setnp,
    cmovb,
    setb,
    cmovae,
    setae,
    cmovbe,
    setbe,
    cmova,
    seta,
    cmovl,
    setl,
    cmovge,
    setge,
    cmovle,
    setle,
    cmovg,
    setg,

    aaa,
    aad,
    aam,
    aas,
    adc,
    add,
    AND,
    call,
    cbw,
    cwde,
    cqo,
    clc,
    cld,
    cli,
    cmc,
    cmp,
    cmpsb,
    cmpsw,
    cwd,
    daa,
    das,
    dec,
    div,
    esc,
    hlt,
    idiv,
    imul,
    in,
    inc,
    INT,
    INTO,
    IRET,
    ja,
    jae,
    jb,
    jbe,
    jc,
    je,
    jg,
    jge,
    jl,
    jle,
    jne,
    jno,
    jnp,
    jns,
    jo,
    jp,
    js,
    jcxz,
    jmp,
    jmps,
    jmpf,
    lahf,
    lds,
    lea,
    les,
    lfence,
    lods,
    lodsb,
    lodsw,
    loop,
    loope,
    loopne,
    loopnz,
    loopz,
    mfence,
    mul,
    neg,
    nop,
    NOT,
    OR,
    out,
    pop,
    popf,
    push,
    pushf,
    rcl,
    rcr,
    ret,
    retn,
    retf,
    rol,
    ror,
    sahf,
    sal,
    sar,
    salc,
    sbb,
    scasb,
    scasw,
    sfence,
    shl,
    shr,
    stc,
    STD,
    sti,
    stosb,
    stosw,
    sub,
    test,
    wait,
    xchg,
    xlat,
    XOR,
    cdqe,
    cdq,
  };
  type _type;
  const static std::map<std::string, type> type_str_map;
  instruction_type(std::string type_str) {}
};

#endif