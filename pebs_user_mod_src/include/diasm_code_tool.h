#ifndef DIASM_CODE_TOOL
#define DIASM_CODE_TOOL
#include <capstone/capstone.h>

#include <boost/archive/text_iarchive.hpp>
#include <boost/archive/text_oarchive.hpp>
#include <boost/serialization/array_wrapper.hpp>
#include <boost/serialization/serialization.hpp>
#include <boost/serialization/string.hpp>
#include <boost/serialization/vector.hpp>
#include <cstddef>
#include <cstdint>
#include <iostream>
#include <memory>

#include "conf.h"
/**
 * @brief 
 *
 */
class diasm_code_tool {
 public:
  typedef std::shared_ptr<diasm_code_tool> ptr;
  diasm_code_tool() { init_capstone(); }
  diasm_code_tool(bool is_32) { init_capstone(is_32); }
  ~diasm_code_tool() { destory_capstone(); }

  cs_insn *get_diasm_info() { return _insn; }
  size_t get_size() { return _count; }
  bool diasm_code(const uint8_t *code, size_t size, uint64_t addr);
  uint64_t get_start_addr() { return _insn[0].address; }
  uint64_t get_stop_addr() { return _insn[_count - 1].address; }

  //
  void set_err_true() { _err = true; }

 private:
  csh _handle;
  cs_insn *_insn = nullptr;
  size_t _count = 0;
  bool _err = false;
  
  void init_capstone(bool is_32 = false);
  void destory_capstone();
  

  friend class boost::serialization::access;

  template <class Archive>
  void serialize(Archive &ar, const unsigned int version) {
    ar &_handle;
    ar &_count;
    ar &_err;
    if (Archive::is_loading::value) {
      _insn = new cs_insn[_count];
      _err = true;
    }
    for (int i = 0; i < _count; ++i) {
      ar &_insn[i];
    }
  }
};
namespace boost {
namespace serialization {

template <class Archive>
void serialize(Archive &ar, cs_insn &d, const unsigned int version) {
  ar &d.id;
  ar &d.address;
  ar &d.size;
  ar &d.bytes;
  ar &d.mnemonic;
  ar &d.op_str;
  ar &d.detail;
}

template <class Archive>
void serialize(Archive &ar, cs_detail &d, const unsigned int version) {
  ar &d.regs_read;
  ar &d.regs_read_count;
  ar &d.regs_write;
  ar &d.regs_write_count;
  ar &d.groups;
  ar &d.groups_count;
  ar &d.x86;
}

template <class Archive>
void serialize(Archive &ar, cs_x86 &d, const unsigned int version) {
  ar &d.prefix;
  ar &d.opcode;
  ar &d.rex;
  ar &d.addr_size;
  ar &d.modrm;
  ar &d.sib;
  ar &d.disp;
  ar &d.sib_index;
  ar &d.sib_scale;
  ar &d.sib_base;
  ar &d.xop_cc;
  ar &d.sse_cc;
  ar &d.avx_cc;
  ar &d.avx_sae;
  ar &d.avx_rm;
  ar &d.eflags;
  ar &d.op_count;
  ar &d.operands;
  ar &d.encoding;
}

template <class Archive>
void serialize(Archive &ar, x86_reg &d, const unsigned int version) {
  ar &reinterpret_cast<int &>(d);
}

template <class Archive>
void serialize(Archive &ar, x86_xop_cc &d, const unsigned int version) {
  ar &reinterpret_cast<int &>(d);
}

template <class Archive>
void serialize(Archive &ar, x86_sse_cc &d, const unsigned int version) {
  ar &reinterpret_cast<int &>(d);
}

template <class Archive>
void serialize(Archive &ar, x86_avx_cc &d, const unsigned int version) {
  ar &reinterpret_cast<int &>(d);
}

template <class Archive>
void serialize(Archive &ar, x86_avx_rm &d, const unsigned int version) {
  ar &reinterpret_cast<int &>(d);
}

template <class Archive>
void serialize(Archive &ar, x86_avx_bcast &d, const unsigned int version) {
  ar &reinterpret_cast<int &>(d);
}

template <class Archive>
void serialize(Archive &ar, x86_op_type &d, const unsigned int version) {
  ar &reinterpret_cast<int &>(d);
}

template <class Archive>
void serialize(Archive &ar, cs_x86_op &d, const unsigned int version) {
  ar &d.type;
  switch (d.type) {
    case X86_OP_REG: {
      ar &d.reg;
      break;
    }
    case X86_OP_IMM: {
      ar &d.imm;
      break;
    }
    case X86_OP_MEM: {
      ar &d.mem;
      break;
    }
  }
  ar &d.size;
  ar &d.access;
  ar &d.avx_bcast;
  ar &d.avx_zero_opmask;
}

template <class Archive>
void serialize(Archive &ar, cs_x86_encoding &d, const unsigned int version) {
  ar &d.modrm_offset;
  ar &d.disp_offset;
  ar &d.disp_size;
  ar &d.imm_offset;
  ar &d.imm_size;
}

template <class Archive>
void serialize(Archive &ar, x86_op_mem &d, const unsigned int version) {
  ar &d.segment;
  ar &d.base;
  ar &d.index;
  ar &d.scale;
  ar &d.disp;
}

template <class Archive>
void serialize(Archive &ar, register_info_t &d, const unsigned int version) {
  ar &d.RFLAGS;
  ar &d.RAX;
  ar &d.RCX;
  ar &d.RDX;
  ar &d.RBX;
  ar &d.RSP;
  ar &d.RBP;
  ar &d.RSI;
  ar &d.RDI;
  ar &d.R8;
  ar &d.R9;
  ar &d.R10;
  ar &d.R11;
  ar &d.R12;
  ar &d.R13;
  ar &d.R14;
  ar &d.R15;
}

}  // namespace serialization
}  // namespace boost
#endif