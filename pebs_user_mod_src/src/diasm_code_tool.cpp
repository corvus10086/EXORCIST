#include "diasm_code_tool.h"

#include <capstone/capstone.h>

#include "conf.h"

void diasm_code_tool::init_capstone(bool is_32) {
  if (is_32) {
    if (cs_open(CS_ARCH_X86, CS_MODE_32, &_handle) != CS_ERR_OK) {
      _err = true;
    }
  } else {
    if (cs_open(CS_ARCH_X86, CS_MODE_64, &_handle) != CS_ERR_OK) {
      _err = true;
    }
  }
  
  // cs_option(_handle, CS_OPT_SYNTAX, CS_OPT_SYNTAX_ATT);
  cs_option(_handle, CS_OPT_DETAIL, CS_OPT_ON);
}

void diasm_code_tool::destory_capstone() {
  if (_err) {
    if (_insn != nullptr) {
      delete [] _insn;
      _insn = nullptr;
    }
    return;
  }
  cs_free(_insn, _count);
  cs_close(&_handle);
}

bool diasm_code_tool::diasm_code(const uint8_t *code, size_t size,
                                 uint64_t addr) {
  if (_err) {
    return false;
  }
  _count = cs_disasm(_handle, code, size, addr, 0, &_insn);
  if (_count < 0) {
    _err = true;
    return false;
  }
  return true;
}

