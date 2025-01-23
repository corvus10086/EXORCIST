#include "pebs_taine_tool.h"
#define NULL ((void *)0)

char *map = "\x00\x01\x03\x07\x0F\x1F\x3F\x7F\xFF";

// offset0
void set_stack_bit(unsigned long int offset, short length,
                   char *stack_map_addr) {
  unsigned long int new_offset = (offset - length) >> 3;
  unsigned short inline_offset = (offset - length) & 7;

  if ((8 - inline_offset) < length) {
    stack_map_addr[new_offset] |= map[8 - inline_offset] << inline_offset;
    stack_map_addr[new_offset + 1] |= map[length + inline_offset - 8];
  } else {
    stack_map_addr[new_offset] |= map[length] << inline_offset;
  }
}

void unset_stack_bit(unsigned long int offset, short length,
                     char *stack_map_addr) {
  unsigned long int new_offset = (offset - length) >> 3;
  unsigned short inline_offset = (offset - length) & 7;
  if ((8 - inline_offset) < length) {
    stack_map_addr[new_offset] &= ~(map[8 - inline_offset] << inline_offset);
    stack_map_addr[new_offset + 1] &= ~(map[length + inline_offset - 8]);
  } else {
    stack_map_addr[new_offset] &= ~(map[length] << inline_offset);
  }
}

char get_stack_bit(unsigned long int offset, short length,
                   char *stack_map_addr) {
  unsigned long int new_offset = (offset - length) >> 3;
  unsigned short inline_offset = (offset - length) & 7;
  char res = 0;
  if ((8 - inline_offset) < length) {
    res = (stack_map_addr[new_offset] & map[8 - inline_offset]
                                            << (inline_offset)) >>
          inline_offset;
    res += (stack_map_addr[new_offset + 1] & map[length + inline_offset - 8])
           << (8 - inline_offset);
  } else {
    res = (stack_map_addr[new_offset] & map[length] << (inline_offset)) >>
          inline_offset;
  }
  return res;
}

char set_stack_value(unsigned long int offset, short length,
                     unsigned long long int value, char *stack_map_addr) {
  int index = 1;
  for (; index <= length; ++index) {
    stack_map_addr[offset - length + index] = value & 0xff;
    value = value >> 8;
  }
  return 1;
}

void get_stack_value(unsigned long int offset, short length,
                     char *stack_map_addr, unsigned long long int *res) {
  int index = length;
  unsigned long long int tmp = 0;
  for (; index > 1; --index) {
    tmp = tmp + ((stack_map_addr[offset - length + index]) & 0xff);
    tmp = tmp << 8;
  }
  tmp = tmp + ((stack_map_addr[offset - length + index]) & 0xff);
  *res = tmp;
  return;
}

void set_register_taine(char *register_name,
                        register_taines_map_t *register_map) {
  //？
  if (register_name[0] == 'r') {
    // rax,rcx,rdx,rbx
    if (register_name[1] == 'a') {
      SET_RAX_1(register_map->registers_can_break);
    } else if (register_name[1] == 'c') {
      SET_RCX_1(register_map->registers_can_break);
    } else if (register_name[1] == 'd' && register_name[2] == 'x') {
      SET_RDX_1(register_map->registers_can_break);
    } else if (register_name[1] == 'b' && register_name[2] == 'x') {
      SET_RBX_1(register_map->registers_can_break);
    }

    // RSP RBP
    else if (register_name[1] == 'b' && register_name[2] == 'p') {
      SET_RBP_1(register_map->registers_can_break);
    } else if (register_name[1] == 's' && register_name[2] == 'p') {
      SET_RSP_1(register_map->registers_can_break);
    }

    // RSI RDI
    else if (register_name[1] == 'd' && register_name[2] == 'i') {
      SET_RDI_1(register_map->registers_can_break);
    } else if (register_name[1] == 's' && register_name[2] == 'i') {
      SET_RSI_1(register_map->registers_can_break);
    }

    // r8-r15
    else if (register_name[1] == '8') {
      SET_R8_1(register_map->registers);
    } else if (register_name[1] == '9') {
      SET_R9_1(register_map->registers);
    } else if (register_name[2] == '0') {
      SET_R10_1(register_map->registers);
    } else if (register_name[2] == '1') {
      SET_R11_1(register_map->registers);
    } else if (register_name[2] == '2') {
      SET_R12_1(register_map->registers);
    } else if (register_name[2] == '3') {
      SET_R13_1(register_map->registers);
    } else if (register_name[2] == '4') {
      SET_R14_1(register_map->registers);
    } else if (register_name[2] == '5') {
      SET_R15_1(register_map->registers);
    }

  } else if (register_name[0] == 'e') {
    // eax,ecx,edx,ebx
    if (register_name[1] == 'a') {
      SET_EAX_1(register_map->registers_can_break);
    } else if (register_name[1] == 'c') {
      SET_ECX_1(register_map->registers_can_break);
    } else if (register_name[1] == 'd') {
      SET_EDX_1(register_map->registers_can_break);
    } else if (register_name[1] == 'b') {
      SET_EBX_1(register_map->registers_can_break);
    }
  } else {
    // ax,cx,dx,bx
    if (register_name[0] == 'a') {
      SET_AX_1(register_map->registers_can_break);
    } else if (register_name[0] == 'c') {
      SET_CX_1(register_map->registers_can_break);
    } else if (register_name[0] == 'd') {
      SET_DX_1(register_map->registers_can_break);
    } else if (register_name[0] == 'b') {
      SET_BX_1(register_map->registers_can_break);
    }
  }
}

void unset_register_taine(char *register_name,
                          register_taines_map_t *register_map) {
  //？
  if (register_name[0] == 'r') {
    // rax,rcx,rdx,rbx
    if (register_name[1] == 'a') {
      SET_RAX_0(register_map->registers_can_break);
    } else if (register_name[1] == 'c') {
      SET_RCX_0(register_map->registers_can_break);
    } else if (register_name[1] == 'd' && register_name[2] == 'x') {
      SET_RDX_0(register_map->registers_can_break);
    } else if (register_name[1] == 'b' && register_name[2] == 'x') {
      SET_RBX_0(register_map->registers_can_break);
    }

    // RSP RBP
    else if (register_name[1] == 'b' && register_name[2] == 'p') {
      SET_RBP_0(register_map->registers_can_break);
    } else if (register_name[1] == 's' && register_name[2] == 'p') {
      SET_RSP_0(register_map->registers_can_break);
    }

    // RSI RDI
    else if (register_name[1] == 'd' && register_name[2] == 'i') {
      SET_RDI_0(register_map->registers_can_break);
    } else if (register_name[1] == 's' && register_name[2] == 'i') {
      SET_RSI_0(register_map->registers_can_break);
    }

    // r8-r15
    else if (register_name[1] == '8') {
      SET_R8_0(register_map->registers);
    } else if (register_name[1] == '9') {
      SET_R9_0(register_map->registers);
    } else if (register_name[2] == '0') {
      SET_R10_0(register_map->registers);
    } else if (register_name[2] == '1') {
      SET_R11_0(register_map->registers);
    } else if (register_name[2] == '2') {
      SET_R12_0(register_map->registers);
    } else if (register_name[2] == '3') {
      SET_R13_0(register_map->registers);
    } else if (register_name[2] == '4') {
      SET_R14_0(register_map->registers);
    } else if (register_name[2] == '5') {
      SET_R15_0(register_map->registers);
    }

  } else if (register_name[0] == 'e') {
    // eax,ecx,edx,ebx
    if (register_name[1] == 'a') {
      SET_EAX_0(register_map->registers_can_break);
    } else if (register_name[1] == 'c') {
      SET_ECX_0(register_map->registers_can_break);
    } else if (register_name[1] == 'd') {
      SET_EDX_0(register_map->registers_can_break);
    } else if (register_name[1] == 'b') {
      SET_EBX_0(register_map->registers_can_break);
    }
  } else {
    // ax,cx,dx,bx
    if (register_name[0] == 'a') {
      SET_AX_0(register_map->registers_can_break);
    } else if (register_name[0] == 'c') {
      SET_CX_0(register_map->registers_can_break);
    } else if (register_name[0] == 'd') {
      SET_DX_0(register_map->registers_can_break);
    } else if (register_name[0] == 'b') {
      SET_BX_0(register_map->registers_can_break);
    }
  }
}

short get_register_taine(char *register_name,
                         register_taines_map_t *register_map) {
  //？
  if (register_name[0] == 'r') {
    // rax,rcx,rdx,rbx
    if (register_name[1] == 'a') {
      return GET_RAX(register_map->registers_can_break);
    } else if (register_name[1] == 'c') {
      return GET_RCX(register_map->registers_can_break);
    } else if (register_name[1] == 'd' && register_name[2] == 'x') {
      return GET_RDX(register_map->registers_can_break);
    } else if (register_name[1] == 'b' && register_name[2] == 'x') {
      return GET_RBX(register_map->registers_can_break);
    }

    // RSP RBP
    else if (register_name[1] == 'b' && register_name[2] == 'p') {
      return GET_RBP(register_map->registers_can_break);
    } else if (register_name[1] == 's' && register_name[2] == 'p') {
      return GET_RSP(register_map->registers_can_break);
    }

    // RSI RDI
    else if (register_name[1] == 'd' && register_name[2] == 'i') {
      return GET_RDI(register_map->registers_can_break);
    } else if (register_name[1] == 's' && register_name[2] == 'i') {
      return GET_RSI(register_map->registers_can_break);
    }

    // r8-r15
    else if (register_name[1] == '8') {
      return GET_R8(register_map->registers);
    } else if (register_name[1] == '9') {
      return GET_R9(register_map->registers);
    } else if (register_name[2] == '0') {
      return GET_R10(register_map->registers);
    } else if (register_name[2] == '1') {
      return GET_R11(register_map->registers);
    } else if (register_name[2] == '2') {
      return GET_R12(register_map->registers);
    } else if (register_name[2] == '3') {
      return GET_R13(register_map->registers);
    } else if (register_name[2] == '4') {
      return GET_R14(register_map->registers);
    } else if (register_name[2] == '5') {
      return GET_R15(register_map->registers);
    } else {
      return 0;
    }
  } else if (register_name[0] == 'e') {
    // eax,ecx,edx,ebx
    if (register_name[1] == 'a') {
      return GET_EAX(register_map->registers_can_break);
    } else if (register_name[1] == 'c') {
      return GET_ECX(register_map->registers_can_break);
    } else if (register_name[1] == 'd') {
      return GET_EDX(register_map->registers_can_break);
    } else if (register_name[1] == 'b') {
      return GET_EBX(register_map->registers_can_break);
    } else {
      return 0;
    }
  } else {
    // ax,cx,dx,bx
    if (register_name[0] == 'a') {
      return GET_AX(register_map->registers_can_break);
    } else if (register_name[0] == 'c') {
      return GET_CX(register_map->registers_can_break);
    } else if (register_name[0] == 'd') {
      return GET_DX(register_map->registers_can_break);
    } else if (register_name[0] == 'b') {
      return GET_BX(register_map->registers_can_break);
    } else {
      return 0;
    }
  }
}

int analyze_branch_instruction(int branch_type,
                               register_simulation_t *register_info) {
  // return 1 
  // return 0 
  // return -1 
  // return 2 call
  // return 3 ret
  switch (branch_type) {
    case 1: {
      // JO  OF=1
      if (GET_OF(register_info->rflags_unsure)) {
        return 0;
      } else if (GET_OF(register_info->register_info.RFLAGS)) {
        return 1;
      }
      return -1;
    }
    case 2: {
      // JC  CF=1
      if (GET_CF(register_info->rflags_unsure)) {
        return 0;
      } else if (GET_CF(register_info->register_info.RFLAGS)) {
        return 1;
      }
      return -1;
    }
    case 3: {
      // JE  ZF=1
      if (GET_ZF(register_info->rflags_unsure)) {
        return 0;
      } else if (GET_ZF(register_info->register_info.RFLAGS)) {
        return 1;
      }
      return -1;
    }
    case 4: {
      // JA  CF=0&&ZF=0
      //
      if (GET_CF(register_info->rflags_unsure) == 0 &&
          GET_CF(register_info->register_info.RFLAGS)) {
        return -1;
      } else if (GET_ZF(register_info->rflags_unsure) == 0 &&
                 GET_ZF(register_info->register_info.RFLAGS)) {
        return -1;
      } else if (GET_CF(register_info->rflags_unsure) ||
                 GET_ZF(register_info->rflags_unsure)) {
        return 0;
      } else {
        return 1;
      }
    }
    case 5: {
      // JS  SF=1
      if (GET_SF(register_info->rflags_unsure)) {
        return 0;
      } else if (GET_SF(register_info->register_info.RFLAGS)) {
        return 1;
      }
      return -1;
    }
    case 6: {
      // JP  PF=1
      if (GET_PF(register_info->rflags_unsure)) {
        return 0;
      } else if (GET_PF(register_info->register_info.RFLAGS)) {
        return 1;
      }
      return -1;
    }
    case 7: {
      // JL  SF!=OF
      if (GET_SF(register_info->rflags_unsure) ||
          GET_OF(register_info->rflags_unsure)) {
        return 0;
      } else if (GET_SF(register_info->register_info.RFLAGS) !=
                 GET_OF(register_info->register_info.RFLAGS)) {
        return 1;
      }
      return -1;
    }
    case 8: {
      // JG  ZF=0&&SF=OF
      //
      if (GET_ZF(register_info->rflags_unsure) == 0 &&
          GET_ZF(register_info->register_info.RFLAGS)) {
        return -1;
      } else if ((GET_SF(register_info->rflags_unsure) == 0 &&
                  GET_OF(register_info->rflags_unsure) == 0) &&
                 GET_SF(register_info->register_info.RFLAGS) !=
                     GET_OF(register_info->register_info.RFLAGS)) {
        return -1;
      } else if (GET_ZF(register_info->rflags_unsure) ||
                 GET_SF(register_info->rflags_unsure) ||
                 GET_OF(register_info->rflags_unsure)) {
        return 0;
      }
      return 1;
    }
    case 9: {
      // JB  CF=1
      if (GET_CF(register_info->rflags_unsure)) {
        return 0;
      } else if (GET_CF(register_info->register_info.RFLAGS)) {
        return 1;
      }
      return -1;
    }
    case 10: {
      // JECXZ ECX=0
      if (GET_ECX(register_info->registers_can_break_unsure)) {
        return 0;
      } else if ((register_info->register_info.RCX & 0x0000ffff) == 0) {
        return 1;
      }
      return 0;
    }
    case 11: {
      // jmp
      return 1;
    }
    case 12: {
      // call
      return 2;
    }
    case 13: {
      // RET
      return 3;
    }
    case -1: {
      // JNO OF=0
      if (GET_OF(register_info->rflags_unsure)) {
        return 0;
      } else if (!GET_OF(register_info->register_info.RFLAGS)) {
        return 1;
      }
      return -1;
    }
    case -2: {
      // JNC CF=0
      if (GET_CF(register_info->rflags_unsure)) {
        return 0;
      } else if (!GET_CF(register_info->register_info.RFLAGS)) {
        return 1;
      }
      return -1;
    }
    case -3: {
      // JNE ZF=0
      if (GET_ZF(register_info->rflags_unsure)) {
        return 0;
      } else if (!GET_ZF(register_info->register_info.RFLAGS)) {
        return 1;
      }
      return -1;
    }
    case -4: {
      // JNA CF=1||ZF=1
      if ((GET_ZF(register_info->rflags_unsure) == 0 &&
           GET_ZF(register_info->register_info.RFLAGS)) ||
          (GET_CF(register_info->rflags_unsure) == 0 &&
           GET_CF(register_info->register_info.RFLAGS))) {
        return 1;
      } else if (GET_ZF(register_info->rflags_unsure) &&
                 GET_CF(register_info->rflags_unsure)) {
        return 0;
      }
      return -1;
    }
    case -5: {
      // JNS SF=0
      if (GET_SF(register_info->rflags_unsure)) {
        return 0;
      } else if (!GET_SF(register_info->register_info.RFLAGS)) {
        return 1;
      }
      return -1;
    }
    case -6: {
      // JNP PF=0
      if (GET_PF(register_info->rflags_unsure)) {
        return 0;
      } else if (!GET_PF(register_info->register_info.RFLAGS)) {
        return 1;
      }
      return -1;
    }
    case -7: {
      // JNL SF=OF
      if (GET_SF(register_info->rflags_unsure) ||
          GET_OF(register_info->rflags_unsure)) {
        return 0;
      } else if (GET_SF(register_info->register_info.RFLAGS) ==
                 GET_OF(register_info->register_info.RFLAGS)) {
        return 1;
      }
      return -1;
    }
    case -8: {
      // JNG ZF=1||SF！=OF
      if ((GET_ZF(register_info->rflags_unsure) == 0 &&
           GET_ZF(register_info->register_info.RFLAGS)) ||
          (GET_SF(register_info->rflags_unsure) == 0 &&
           GET_OF(register_info->rflags_unsure) == 0 &&
           (GET_SF(register_info->register_info.RFLAGS) !=
            GET_OF(register_info->register_info.RFLAGS)))) {
        return 1;
      } else if (GET_ZF(register_info->rflags_unsure) ||
                 GET_SF(register_info->rflags_unsure) ||
                 GET_OF(register_info->rflags_unsure)) {
        return 0;
      }
      return -1;
    }
    case -9: {
      // JNB CF=0
      if (GET_CF(register_info->rflags_unsure)) {
        return 0;
      } else if (!GET_CF(register_info->register_info.RFLAGS)) {
        return 1;
      }
      return -1;
    }
  }
  return -1;
}

void set_register_taine_by_num(int num, register_taines_map_t *register_map) {
  //？
  switch (num) {
    case 0x1: {
      SET_RAX_1(register_map->registers_can_break);
      break;
    }
    case 0x2: {
      SET_RCX_1(register_map->registers_can_break);
      break;
    }
    case 0x4: {
      SET_RDX_1(register_map->registers_can_break);
      break;
    }
    case 0x8: {
      SET_RBX_1(register_map->registers_can_break);
      break;
    }
    case 0x10: {
      SET_RSP_1(register_map->registers_can_break);
      break;
    }
    case 0x20: {
      SET_RBP_1(register_map->registers_can_break);
      break;
    }
    case 0x40: {
      SET_RSI_1(register_map->registers_can_break);
      break;
    }
    case 0x80: {
      SET_RDI_1(register_map->registers_can_break);
      break;
    }
    case 0x100: {
      SET_R8_1(register_map->registers);
      break;
    }
    case 0x200: {
      SET_R9_1(register_map->registers);
      break;
    }
    case 0x400: {
      SET_R10_1(register_map->registers);
      break;
    }
    case 0x800: {
      SET_R11_1(register_map->registers);
      break;
    }
    case 0x1000: {
      SET_R12_1(register_map->registers);
      break;
    }
    case 0x2000: {
      SET_R13_1(register_map->registers);
      break;
    }
    case 0x4000: {
      SET_R14_1(register_map->registers);
      break;
    }
    case 0x8000: {
      SET_R15_1(register_map->registers);
      break;
    }
  }
}

void unset_register_taine_by_num(int num, register_taines_map_t *register_map) {
  //？
  switch (num) {
    case 0x1: {
      SET_RAX_0(register_map->registers_can_break);
      break;
    }
    case 0x2: {
      SET_RCX_0(register_map->registers_can_break);
      break;
    }
    case 0x4: {
      SET_RDX_0(register_map->registers_can_break);
      break;
    }
    case 0x8: {
      SET_RBX_0(register_map->registers_can_break);
      break;
    }
    case 0x10: {
      SET_RSP_0(register_map->registers_can_break);
      break;
    }
    case 0x20: {
      SET_RBP_0(register_map->registers_can_break);
      break;
    }
    case 0x40: {
      SET_RSI_0(register_map->registers_can_break);
      break;
    }
    case 0x80: {
      SET_RDI_0(register_map->registers_can_break);
      break;
    }
    case 0x100: {
      SET_R8_0(register_map->registers);
      break;
    }
    case 0x200: {
      SET_R9_0(register_map->registers);
      break;
    }
    case 0x400: {
      SET_R10_0(register_map->registers);
      break;
    }
    case 0x800: {
      SET_R11_0(register_map->registers);
      break;
    }
    case 0x1000: {
      SET_R12_0(register_map->registers);
      break;
    }
    case 0x2000: {
      SET_R13_0(register_map->registers);
      break;
    }
    case 0x4000: {
      SET_R14_0(register_map->registers);
      break;
    }
    case 0x8000: {
      SET_R15_0(register_map->registers);
      break;
    }
  }
}

short get_register_taine_by_num(int num, register_taines_map_t *register_map) {
  //？
  switch (num) {
    case 0x0: {
      return 0;
    }
    case 0x1: {
      return GET_RAX(register_map->registers_can_break);
    }
    case 0x2: {
      return GET_RCX(register_map->registers_can_break);
    }
    case 0x4: {
      return GET_RDX(register_map->registers_can_break);
    }
    case 0x8: {
      return GET_RBX(register_map->registers_can_break);
    }
    case 0x10: {
      return GET_RSP(register_map->registers_can_break);
    }
    case 0x20: {
      return GET_RBP(register_map->registers_can_break);
    }
    case 0x40: {
      return GET_RSI(register_map->registers_can_break);
    }
    case 0x80: {
      return GET_RDI(register_map->registers_can_break);
    }
    case 0x100: {
      return GET_R8(register_map->registers);
    }
    case 0x200: {
      return GET_R9(register_map->registers);
    }
    case 0x400: {
      return GET_R10(register_map->registers);
    }
    case 0x800: {
      return GET_R11(register_map->registers);
    }
    case 0x1000: {
      return GET_R12(register_map->registers);
    }
    case 0x2000: {
      return GET_R13(register_map->registers);
    }
    case 0x4000: {
      return GET_R14(register_map->registers);
    }
    case 0x8000: {
      return GET_R15(register_map->registers);
    }
    default: {
      return 0;
    }
  }
}

void set_register_unsure_by_num(int num, register_simulation_t *register_info) {
  switch (num) {
    case 0x1: {
      SET_RAX_1(register_info->registers_can_break_unsure);
      break;
    }
    case 0x2: {
      SET_RCX_1(register_info->registers_can_break_unsure);
      break;
    }
    case 0x4: {
      SET_RDX_1(register_info->registers_can_break_unsure);
      break;
    }
    case 0x8: {
      SET_RBX_1(register_info->registers_can_break_unsure);
      break;
    }
    case 0x10: {
      SET_RSP_1(register_info->registers_can_break_unsure);
      break;
    }
    case 0x20: {
      SET_RBP_1(register_info->registers_can_break_unsure);
      break;
    }
    case 0x40: {
      SET_RSI_1(register_info->registers_can_break_unsure);
      break;
    }
    case 0x80: {
      SET_RDI_1(register_info->registers_can_break_unsure);
      break;
    }
    case 0x100: {
      SET_R8_1(register_info->registers_unsure);
      break;
    }
    case 0x200: {
      SET_R9_1(register_info->registers_unsure);
      break;
    }
    case 0x400: {
      SET_R10_1(register_info->registers_unsure);
      break;
    }
    case 0x800: {
      SET_R11_1(register_info->registers_unsure);
      break;
    }
    case 0x1000: {
      SET_R12_1(register_info->registers_unsure);
      break;
    }
    case 0x2000: {
      SET_R13_1(register_info->registers_unsure);
      break;
    }
    case 0x4000: {
      SET_R14_1(register_info->registers_unsure);
      break;
    }
    case 0x8000: {
      SET_R15_1(register_info->registers_unsure);
      break;
    }
  }
}

void unset_register_unsure_by_num(int num,
                                  register_simulation_t *register_info) {
  switch (num) {
    case 0x1: {
      SET_RAX_0(register_info->registers_can_break_unsure);
      break;
    }
    case 0x2: {
      SET_RCX_0(register_info->registers_can_break_unsure);
      break;
    }
    case 0x4: {
      SET_RDX_0(register_info->registers_can_break_unsure);
      break;
    }
    case 0x8: {
      SET_RBX_0(register_info->registers_can_break_unsure);
      break;
    }
    case 0x10: {
      SET_RSP_0(register_info->registers_can_break_unsure);
      break;
    }
    case 0x20: {
      SET_RBP_0(register_info->registers_can_break_unsure);
      break;
    }
    case 0x40: {
      SET_RSI_0(register_info->registers_can_break_unsure);
      break;
    }
    case 0x80: {
      SET_RDI_0(register_info->registers_can_break_unsure);
      break;
    }
    case 0x100: {
      SET_R8_0(register_info->registers_unsure);
      break;
    }
    case 0x200: {
      SET_R9_0(register_info->registers_unsure);
      break;
    }
    case 0x400: {
      SET_R10_0(register_info->registers_unsure);
      break;
    }
    case 0x800: {
      SET_R11_0(register_info->registers_unsure);
      break;
    }
    case 0x1000: {
      SET_R12_0(register_info->registers_unsure);
      break;
    }
    case 0x2000: {
      SET_R13_0(register_info->registers_unsure);
      break;
    }
    case 0x4000: {
      SET_R14_0(register_info->registers_unsure);
      break;
    }
    case 0x8000: {
      SET_R15_0(register_info->registers_unsure);
      break;
    }
  }
}

char get_register_unsure_by_num(int num, register_simulation_t *register_info) {
  switch (num) {
    case 0x1: {
      return GET_RAX(register_info->registers_can_break_unsure);
    }
    case 0x2: {
      return GET_RCX(register_info->registers_can_break_unsure);
    }
    case 0x4: {
      return GET_RDX(register_info->registers_can_break_unsure);
    }
    case 0x8: {
      return GET_RBX(register_info->registers_can_break_unsure);
    }
    case 0x10: {
      return GET_RSP(register_info->registers_can_break_unsure);
    }
    case 0x20: {
      return GET_RBP(register_info->registers_can_break_unsure);
    }
    case 0x40: {
      return GET_RSI(register_info->registers_can_break_unsure);
    }
    case 0x80: {
      return GET_RDI(register_info->registers_can_break_unsure);
    }
    case 0x100: {
      return GET_R8(register_info->registers_unsure);
    }
    case 0x200: {
      return GET_R9(register_info->registers_unsure);
    }
    case 0x400: {
      return GET_R10(register_info->registers_unsure);
    }
    case 0x800: {
      return GET_R11(register_info->registers_unsure);
    }
    case 0x1000: {
      return GET_R12(register_info->registers_unsure);
    }
    case 0x2000: {
      return GET_R13(register_info->registers_unsure);
    }
    case 0x4000: {
      return GET_R14(register_info->registers_unsure);
    }
    case 0x8000: {
      return GET_R15(register_info->registers_unsure);
    }
    default: {
      return 0;
    }
  }
}

char set_register_value_by_num(int register_num, unsigned long long int value,
                               char *value_unsure, int length,
                               register_simulation_t *register_info) {
  unsigned long long int value_set;
  unsigned long long int mask;
  if (value_unsure != NULL && length > 0) {
    int i;
    value_set = register_info->symbolic_useable;
    i = 0;
    for (; i < length; ++i) {
      register_info->symbolic[register_info->symbolic_useable + i] =
          value_unsure[i];
      if (register_info->symbolic_useable + i > 510 || value_unsure[i] == 0) {
        return 0;
      }
    }
    register_info->symbolic[register_info->symbolic_useable + i] = 0;
    register_info->symbolic_useable = register_info->symbolic_useable + i + 1;

  } else if (value_unsure == NULL) {
    value_set = value;
  }

  if (length >= 64) {
    mask = 0xffffffffffffffff;
  } else {
    mask = ~(0xffffffffffffffff << length);
  }
  value_set &= mask;

  switch (register_num) {
    case 0x1: {
      register_info->register_info.RAX &= mask;
      register_info->register_info.RAX += value_set;
      break;
    }
    case 0x2: {
      register_info->register_info.RCX &= mask;
      register_info->register_info.RCX += value_set;
      break;
    }
    case 0x4: {
      register_info->register_info.RDX &= mask;
      register_info->register_info.RDX += value_set;
      break;
    }
    case 0x8: {
      register_info->register_info.RBX &= mask;
      register_info->register_info.RBX += value_set;
      break;
    }
    case 0x10: {
      register_info->register_info.RSP &= mask;
      register_info->register_info.RSP += value_set;
      break;
    }
    case 0x20: {
      register_info->register_info.RBP &= mask;
      register_info->register_info.RBP += value_set;
      break;
    }
    case 0x40: {
      register_info->register_info.RSI &= mask;
      register_info->register_info.RSI += value_set;
      break;
    }
    case 0x80: {
      register_info->register_info.RDI &= mask;
      register_info->register_info.RDI += value_set;
      break;
    }
    case 0x100: {
      register_info->register_info.R8 &= mask;
      register_info->register_info.R8 += value_set;
      break;
    }
    case 0x200: {
      register_info->register_info.R9 &= mask;
      register_info->register_info.R9 += value_set;
      break;
    }
    case 0x400: {
      register_info->register_info.R10 &= mask;
      register_info->register_info.R10 += value_set;
      break;
    }
    case 0x800: {
      register_info->register_info.R11 &= mask;
      register_info->register_info.R11 += value_set;
      break;
    }
    case 0x1000: {
      register_info->register_info.R12 &= mask;
      register_info->register_info.R12 += value_set;
      break;
    }
    case 0x2000: {
      register_info->register_info.R13 &= mask;
      register_info->register_info.R13 += value_set;
      break;
    }
    case 0x4000: {
      register_info->register_info.R14 &= mask;
      register_info->register_info.R14 += value_set;
      break;
    }
    case 0x8000: {
      register_info->register_info.R15 &= mask;
      register_info->register_info.R15 += value_set;
      break;
    }
  }
  return 1;
}

unsigned long long int get_register_value_by_num(
    int register_num, register_simulation_t *register_info, int size) {
  unsigned long long int value_set;
  unsigned long long int mask;
  switch (register_num) {
    case 0x1: {
      value_set = register_info->register_info.RAX;
      break;
    }
    case 0x2: {
      value_set = register_info->register_info.RCX;
      break;
    }
    case 0x4: {
      value_set = register_info->register_info.RDX;
      break;
    }
    case 0x8: {
      value_set = register_info->register_info.RBX;
      break;
    }
    case 0x10: {
      value_set = register_info->register_info.RSP;
      break;
    }
    case 0x20: {
      value_set = register_info->register_info.RBP;
      break;
    }
    case 0x40: {
      value_set = register_info->register_info.RSI;
      break;
    }
    case 0x80: {
      value_set = register_info->register_info.RDI;
      break;
    }
    case 0x100: {
      value_set = register_info->register_info.R8;
      break;
    }
    case 0x200: {
      value_set = register_info->register_info.R9;
      break;
    }
    case 0x400: {
      value_set = register_info->register_info.R10;
      break;
    }
    case 0x800: {
      value_set = register_info->register_info.R11;
      break;
    }
    case 0x1000: {
      value_set = register_info->register_info.R12;
      break;
    }
    case 0x2000: {
      value_set = register_info->register_info.R13;
      break;
    }
    case 0x4000: {
      value_set = register_info->register_info.R14;
      break;
    }
    case 0x8000: {
      value_set = register_info->register_info.R15;
      break;
    }
    default: {
      return 0xffff5555;
    }
  }

  if (size >= 64) {
    mask = 0xffffffffffffffff;
  } else {
    mask = ~(0xffffffffffffffff << size);
  }
  value_set = value_set & mask;
  return value_set;
}

unsigned long long int convert_string_to_num(char *num_str) {
  char bit = 1;
  int index = 0;
  unsigned long long int value = 0;
  while (bit != 0 && index < 16) {
    bit = num_str[index];
    if (bit <= '9' && bit >= '0') {
      value = (value << 4) + (bit - '0');
      ++index;
    } else if (bit >= 'a' && bit <= 'f') {
      value = (value << 4) + ((bit - 'a') + 10);
      ++index;
    } else if (bit >= 'A' && bit <= 'F') {
      value = (value << 4) + ((bit - 'A') + 10);
      ++index;
    } else {
      break;
    }
  }
  return value;
}

void rflag_set_taine(register_taines_map_t *register_map) {
  SET_ZF_1(register_map->rflags);
  SET_SF_1(register_map->rflags);
  SET_CF_1(register_map->rflags);
  SET_OF_1(register_map->rflags);
  SET_PF_1(register_map->rflags);
  SET_AF_1(register_map->rflags);
}
void rflag_unset_taine(register_taines_map_t *register_map) {
  SET_ZF_0(register_map->rflags);
  SET_SF_0(register_map->rflags);
  SET_CF_0(register_map->rflags);
  SET_OF_0(register_map->rflags);
  SET_PF_0(register_map->rflags);
  SET_AF_0(register_map->rflags);
}
void rflag_set_unsure(register_simulation_t *register_info) {
  SET_ZF_1(register_info->rflags_unsure);
  SET_SF_1(register_info->rflags_unsure);
  SET_CF_1(register_info->rflags_unsure);
  SET_OF_1(register_info->rflags_unsure);
  SET_PF_1(register_info->rflags_unsure);
  SET_AF_1(register_info->rflags_unsure);
}
void rflag_unset_unsure(register_simulation_t *register_info) {
  SET_ZF_0(register_info->rflags_unsure);
  SET_SF_0(register_info->rflags_unsure);
  SET_CF_0(register_info->rflags_unsure);
  SET_OF_0(register_info->rflags_unsure);
  SET_PF_0(register_info->rflags_unsure);
  SET_AF_0(register_info->rflags_unsure);
}

char judge_attack(int branch_type, register_taines_map_t *register_map,
                  operator_analyze_result_t *jmp_addr_analyze_result) {
  switch (branch_type) {
    case 1: {
      // JO  OF=1
      if (GET_OF(register_map->rflags)) {
        return 1;
      } else {
        return 0;
      }
    }
    case 2: {
      // JC  CF=1
      if (GET_CF(register_map->rflags)) {
        return 1;
      } else {
        return 0;
      }
    }
    case 3: {
      // JE  ZF=1
      if (GET_ZF(register_map->rflags)) {
        return 1;
      } else {
        return 0;
      }
    }
    case 4: {
      // JA  CF=0&&ZF=0
      //
      if (GET_CF(register_map->rflags) || GET_ZF(register_map->rflags)) {
        return 1;
      } else {
        return 0;
      }
    }
    case 5: {
      // JS  SF=1
      if (GET_SF(register_map->rflags)) {
        return 1;
      } else {
        return 0;
      }
    }
    case 6: {
      // JP  PF=1
      if (GET_PF(register_map->rflags)) {
        return 1;
      } else {
        return 0;
      }
    }
    case 7: {
      // JL  SF!=OF
      if (GET_SF(register_map->rflags) || GET_OF(register_map->rflags)) {
        return 1;
      } else {
        return 0;
      }
    }
    case 8: {
      // JG  ZF=0&&SF=OF
      //
      if (GET_ZF(register_map->rflags) || GET_SF(register_map->rflags) ||
          GET_OF(register_map->rflags)) {
        return 1;
      } else {
        return 0;
      }
    }
    case 9: {
      // JB  CF=1
      if (GET_CF(register_map->rflags)) {
        return 1;
      } else {
        return 0;
      }
    }
    case 10: {
      // JECXZ ECX=0
      if (GET_ECX(register_map->registers_can_break)) {
        return 1;
      } else {
        return 0;
      }
    }
    case 11: {
      // jmp
      if (jmp_addr_analyze_result->taine_flag) {
        return 1;
      } else {
        return 0;
      }
    }
    case 12: {
      // call
      if (jmp_addr_analyze_result->taine_flag) {
        return 1;
      } else {
        return 0;
      }
    }
    case 13: {
      // ret
      //0
      return 0;
    }

    case -1: {
      // JNO OF=0
      if (GET_OF(register_map->rflags)) {
        return 1;
      } else {
        return 0;
      }
    }
    case -2: {
      // JNC CF=0
      if (GET_CF(register_map->rflags)) {
        return 1;
      } else {
        return 0;
      }
    }
    case -3: {
      // JNE ZF=0
      if (GET_ZF(register_map->rflags)) {
        return 1;
      } else {
        return 0;
      }
    }
    case -4: {
      // JNA CF=1||ZF=1
      if (GET_CF(register_map->rflags) || GET_ZF(register_map->rflags)) {
        return 1;
      } else {
        return 0;
      }
    }
    case -5: {
      // JNS SF=0
      if (GET_SF(register_map->rflags)) {
        return 1;
      } else {
        return 0;
      }
    }
    case -6: {
      // JNP PF=0
      if (GET_PF(register_map->rflags)) {
        return 1;
      } else {
        return 0;
      }
    }
    case -7: {
      // JNL SF=OF
      if (GET_SF(register_map->rflags) || GET_OF(register_map->rflags)) {
        return 1;
      } else {
        return 0;
      }
    }
    case -8: {
      // JNG ZF=1||SF！=OF
      if (GET_ZF(register_map->rflags) || GET_SF(register_map->rflags) ||
          GET_OF(register_map->rflags)) {
        return 1;
      } else {
        return 0;
      }
    }
    case -9: {
      // JNB CF=0
      if (GET_CF(register_map->rflags)) {
        return 1;
      } else {
        return 0;
      }
    }
    default: {
      return 0;
    }
  }
}

char analyze_memory_operator(operator_analyze_result_t *operator_analyze_result,
                             unsigned long long int base_register_num,
                             unsigned long long int index_register_num,
                             unsigned long long int scale,
                             unsigned long long int displacement, int size,
                             register_simulation_t *register_info,
                             register_taines_map_t *register_map,
                             stack_simulation_t *stack_simulation_info,
                             heap_simulation_t *heap_simulation_info) {
  //
  operator_analyze_result->taine_flag = 0;
  operator_analyze_result->unsure_flag = 0;

  if (get_register_taine_by_num(base_register_num, register_map) ||
      (get_register_taine_by_num(index_register_num, register_map) &&
       scale != 0)) {
    //
    operator_analyze_result->taine_flag = 1;
  }
  if (get_register_unsure_by_num(base_register_num, register_info) ||
      (get_register_unsure_by_num(index_register_num, register_info) &&
       scale != 0)) {
    //
    operator_analyze_result->unsure_flag = 1;
    return 0;
  } else {
    //
    unsigned long long int addr = base_register_num =
        get_register_value_by_num(base_register_num, register_info, 64) +
        get_register_value_by_num(index_register_num, register_info, 64) *
            scale +
        displacement;
    //addrrbp
    long long int offset = base_register_num =
        get_register_value_by_num(0x20, register_info, 64) - addr;
    if (offset < -504 || offset > 512) {
      //
      //
      int index = 0;
      for (; index < heap_simulation_info->heap_size; ++index) {
        if (heap_simulation_info->address[index] == addr) {
          //
          if (heap_simulation_info->taine[index] > 0) {
            //
            operator_analyze_result->taine_flag = 1;
          }
          if (heap_simulation_info->unsure[index] > 0) {
            //
            operator_analyze_result->unsure_flag = 1;
            return 0;
          } else {
            //
            operator_analyze_result->value = heap_simulation_info->value[index];
          }
        }
      }
      if (index >= heap_simulation_info->heap_size) {
        //
        operator_analyze_result->unsure_flag = 1;
        return 0;
      }
    } else {
      //
      if (get_stack_bit(stack_simulation_info->rbp_offset + offset, size / 8,
                        stack_simulation_info->simulation_stack_set_info)) {
        //
        if (get_stack_bit(
                stack_simulation_info->rbp_offset + offset, size / 8,
                stack_simulation_info->simulation_stack_taines_info)) {
          //
          operator_analyze_result->taine_flag = 1;
        }
        if (get_stack_bit(
                stack_simulation_info->rbp_offset + offset, size / 8,
                stack_simulation_info->simulation_stack_unsure_info)) {
          //
          operator_analyze_result->unsure_flag = 1;
        } else {
          //
          get_stack_value(stack_simulation_info->rbp_offset + offset, size / 8,
                          stack_simulation_info->simulation_stack_info,
                          &(operator_analyze_result->value));
        }
      } else {
        //
        operator_analyze_result->unsure_flag = 1;
        operator_analyze_result->taine_flag = 0;
      }
    }
  }
  return 1;
}

char set_memory_operator(operator_analyze_result_t *operator_analyze_result,
                         unsigned long long int base_register_num,
                         unsigned long long int index_register_num,
                         unsigned long long int scale,
                         unsigned long long int displacement, int size,
                         register_simulation_t *register_info,
                         register_taines_map_t *register_map,
                         stack_simulation_t *stack_simulation_info,
                         heap_simulation_t *heap_simulation_info) {
  char taine_flag = 0;
  if (get_register_taine_by_num(base_register_num, register_map) ||
      (get_register_taine_by_num(index_register_num, register_map) &&
       scale != 0)) {
    //
    taine_flag = 1;
  }
  if (get_register_unsure_by_num(base_register_num, register_info) ||
      (get_register_unsure_by_num(index_register_num, register_info) &&
       scale != 0)) {
    //
    return 0;
  } else {
    //
    unsigned long long int addr =
        get_register_value_by_num(base_register_num, register_info, 64) +
        get_register_value_by_num(index_register_num, register_info, 64) *
            scale +
        displacement;
    //addrrbp
    long long int offset = base_register_num =
        get_register_value_by_num(0x20, register_info, 64) - addr;
    if (offset < -504 || offset > 512) {
      //
      //
      heap_simulation_info->address[heap_simulation_info->heap_size] = addr;
      if (operator_analyze_result->taine_flag || taine_flag) {
        //
        heap_simulation_info->taine[heap_simulation_info->heap_size] = 1;
      }
      if (operator_analyze_result->unsure_flag) {
        //
        heap_simulation_info->unsure[heap_simulation_info->heap_size] = 1;
      } else {
        //
        heap_simulation_info->value[heap_simulation_info->heap_size] =
            operator_analyze_result->value;
      }
      ++heap_simulation_info->heap_size;
    } else {
      //
      //
      set_stack_bit(stack_simulation_info->rbp_offset + offset, size / 8,
                    stack_simulation_info->simulation_stack_set_info);

      if (operator_analyze_result->taine_flag || taine_flag) {
        //
        set_stack_bit(stack_simulation_info->rbp_offset + offset, size / 8,
                      stack_simulation_info->simulation_stack_taines_info);
      } else {
        unset_stack_bit(stack_simulation_info->rbp_offset + offset, size / 8,
                        stack_simulation_info->simulation_stack_taines_info);
      }
      if (operator_analyze_result->unsure_flag) {
        //
        set_stack_bit(stack_simulation_info->rbp_offset + offset, size / 8,
                      stack_simulation_info->simulation_stack_unsure_info);
      } else {
        //
        unset_stack_bit(stack_simulation_info->rbp_offset + offset, size / 8,
                        stack_simulation_info->simulation_stack_unsure_info);
        //
        set_stack_value(stack_simulation_info->rbp_offset + offset, size / 8,
                        operator_analyze_result->value,
                        stack_simulation_info->simulation_stack_info);
      }
    }
  }
  return 1;
}

// CWD: AXDX
// CDQ: EAXEDX
// CQO: RAXRDX

// CBW: ALDX
// CWDE: AXEAX
// CDQE: EAXRAX
char exec_cwd_and(char *disass_str, register_simulation_t *register_info,
                  register_taines_map_t *register_map) {
  if (disass_str[1] == 'd' && disass_str[2] == 'q' && disass_str[3] == 'e') {
    // cdqe
    //EAX(bit 31)RAX32
    //
    if (GET_EAX(register_map->registers_can_break)) {
      SET_RAX_1(register_map->registers_can_break);
    }
    // eax
    if (GET_EAX(register_info->registers_unsure)) {
      SET_RAX_1(register_info->registers_unsure);
    } else if (register_info->register_info.RAX & (1 << 31)) {
      register_info->register_info.RAX |= 0xffffffff00000000;
    } else {
      register_info->register_info.RAX &= 0x00000000ffffffff;
    }
  } else if (disass_str[1] == 'd' && disass_str[2] == 'q') {
    // cdq
    //EAX(bit 31)EDX
    if (GET_EAX(register_map->registers_can_break)) {
      SET_EDX_1(register_map->registers_can_break);
    }
    if (GET_EAX(register_info->registers_unsure)) {
      SET_EDX_1(register_info->registers_unsure);
    } else if (register_info->register_info.RAX & (1 << 31)) {
      register_info->register_info.RDX |= 0x00000000ffffffff;
    } else {
      register_info->register_info.RDX &= 0xfffffff00000000;
    }
  } else if (disass_str[1] == 'w' && disass_str[2] == 'd' &&
             disass_str[3] == 'e') {
    // cwde
    // AXEAX
    if (GET_AX(register_map->registers_can_break)) {
      SET_EAX_1(register_map->registers_can_break);
    }
    if (GET_AX(register_info->registers_unsure)) {
      SET_EAX_1(register_info->registers_unsure);
    } else if (register_info->register_info.RAX & (1 << 15)) {
      register_info->register_info.RAX |= 0x000000000000ffff;
    } else {
      register_info->register_info.RAX &= 0xffffffffffff0000;
    }
  } else if (disass_str[1] == 'w' && disass_str[2] == 'd') {
    // cwd
    //AX(bit 15)DX
    if (GET_AX(register_map->registers_can_break)) {
      SET_DX_1(register_map->registers_can_break);
    }
    if (GET_AX(register_info->registers_unsure)) {
      SET_DX_1(register_info->registers_unsure);
    } else if (register_info->register_info.RAX & (1 << 15)) {
      register_info->register_info.RDX |= 0x000000000000ffff;
    } else {
      register_info->register_info.RDX &= 0xffffffffffff0000;
    }
  } else if (disass_str[1] == 'q' && disass_str[2] == 'o') {
    // cqo
    //RAX(bit 63)RDX
    if (GET_RAX(register_map->registers_can_break)) {
      SET_RDX_1(register_map->registers_can_break);
    }
    if (GET_RAX(register_info->registers_unsure)) {
      SET_RDX_1(register_info->registers_unsure);
    } else if (register_info->register_info.RAX & (0x8000000000000000)) {
      register_info->register_info.RDX |= 0xffffffffffffffff;
    } else {
      register_info->register_info.RDX &= 0x0;
    }
  } else if (disass_str[1] == 'b' && disass_str[2] == 'w') {
    // cbw
    // ALDX
    if (GET_AX(register_map->registers_can_break)) {
      SET_DX_1(register_map->registers_can_break);
    }
    if (GET_AX(register_info->registers_unsure)) {
      SET_DX_1(register_info->registers_unsure);
    } else if (register_info->register_info.RAX & (1 << 7)) {
      register_info->register_info.RDX |= 0xffff;
    } else {
      register_info->register_info.RDX &= 0xffffffffffff0000;
    }
  } else {
    return 0;
  }
  return 1;
}

void operator_expend(operator_analyze_result_t *operator_analyze_result,
                     long int source_size, long int dest_size, char sign) {
  char expend_bit = 0;
  int expend_num;
  if (source_size >= dest_size) {
    return;
  }

  if (sign) {
    //
    expend_bit = (operator_analyze_result->value &
                  (((unsigned long long int)1) << (source_size - 1))) >>
                 (source_size - 1);
  }
  expend_num = dest_size - source_size;

  if (expend_bit) {
    unsigned long long int mask = ~(0xffffffffffffffff << expend_num);
    operator_analyze_result->value |= (mask << source_size);
  } else {
    unsigned long long int mask;
    if (dest_size == 64) {
      mask = (~(0xffffffffffffffff << source_size));
    } else {
      mask = ((~(0xffffffffffffffff << (64 - dest_size))) << dest_size) +
             (~(0xffffffffffffffff << source_size));
    }
    operator_analyze_result->value &= mask;
  }
  return;
}

//
void sub_set_flag(operator_analyze_result_t *operator_analyze_dest,
                  operator_analyze_result_t *operator_analyze_source,
                  register_simulation_t *register_info,
                  register_taines_map_t *register_map, int length) {
  // subcmp
  //
  // if(operator_analyze_dest->taine_flag||operator_analyze_source->taine_flag){
  //   rflag_set_taine(register_map);
  // }else{
  //   rflag_unset_taine(register_map);
  // }
  // //
  // if(operator_analyze_dest->unsure_flag||operator_analyze_source->unsure_flag){
  //   rflag_set_unsure(register_info);
  //   return;
  // }else{
  //   rflag_unset_unsure(register_info);
  // }
  // dest-source op1-op2
  // dest=src zf=1 cf=0
  // dest<src zf=0 cf=1
  // dest>src zf=0 cf=0
  unsigned long long int tmp;
  if (length > 64 || length < 0) {
    length = 64;
  }
  operator_expend(operator_analyze_dest, length, 64, 0);
  operator_expend(operator_analyze_source, length, 64, 0);

  tmp = operator_analyze_dest->value - operator_analyze_dest->value;
  if (tmp & 1) {
    SET_PF_0(register_info->register_info.RFLAGS);
  } else {
    SET_PF_1(register_info->register_info.RFLAGS);
  }

  if ((unsigned long long int)operator_analyze_dest->value ==
      (unsigned long long int)operator_analyze_source->value) {
    SET_ZF_1(register_info->register_info.RFLAGS);
    SET_CF_0(register_info->register_info.RFLAGS);
  } else if ((unsigned long long int)operator_analyze_dest->value <
             (unsigned long long int)operator_analyze_source->value) {
    SET_ZF_0(register_info->register_info.RFLAGS);
    SET_CF_1(register_info->register_info.RFLAGS);

  } else {
    SET_ZF_0(register_info->register_info.RFLAGS);
    SET_CF_0(register_info->register_info.RFLAGS);
  }
  //
  //
  operator_expend(operator_analyze_dest, length, 64, 1);
  operator_expend(operator_analyze_source, length, 64, 1);

  if ((long long int)operator_analyze_dest->value ==
      (long long int)operator_analyze_source->value) {
    //
    SET_OF_0(register_info->register_info.RFLAGS);
    SET_SF_0(register_info->register_info.RFLAGS);
  } else {
    //
    if (((long long int)operator_analyze_dest->value < 0 &&
         (long long int)operator_analyze_source->value < 0) ||
        ((long long int)operator_analyze_dest->value > 0 &&
         (long long int)operator_analyze_source->value > 0)) {
      //
      SET_OF_0(register_info->register_info.RFLAGS);
      if ((long long int)operator_analyze_dest->value <
          (long long int)operator_analyze_source->value) {
        SET_SF_1(register_info->register_info.RFLAGS);
      } else {
        SET_SF_0(register_info->register_info.RFLAGS);
      }
    } else {
      //
      if ((long long int)operator_analyze_dest->value < 0) {
        // dest<0 source>0
        if ((long long int)operator_analyze_dest->value -
                (long long int)operator_analyze_source->value >
            0) {
          //0
          //
          SET_OF_1(register_info->register_info.RFLAGS);
          SET_SF_0(register_info->register_info.RFLAGS);
        } else {
          // 64
          long long int tmp = -(long long int)operator_analyze_dest->value +
                              (long long int)operator_analyze_source->value;
          if ((tmp >= 2147483647 && length <= 32) ||
              (tmp >= 32767 && length <= 16) || (tmp >= 127 && length <= 8)) {
            //
            SET_OF_1(register_info->register_info.RFLAGS);
            SET_SF_0(register_info->register_info.RFLAGS);
          } else {
            SET_OF_0(register_info->register_info.RFLAGS);
            SET_SF_1(register_info->register_info.RFLAGS);
          }
        }
      } else {
        // dest>0 source<0
        if ((long long int)operator_analyze_dest->value -
                (long long int)operator_analyze_source->value <
            0) {
          //0
          //
          SET_OF_1(register_info->register_info.RFLAGS);
          SET_SF_1(register_info->register_info.RFLAGS);
        } else {
          // 64
          long long int tmp = (long long int)operator_analyze_dest->value -
                              (long long int)operator_analyze_source->value;
          if ((tmp >= 2147483647 && length <= 32) ||
              (tmp >= 32767 && length <= 16) || (tmp >= 127 && length <= 8)) {
            //
            SET_OF_1(register_info->register_info.RFLAGS);
            SET_SF_1(register_info->register_info.RFLAGS);
          } else {
            SET_OF_0(register_info->register_info.RFLAGS);
            SET_SF_0(register_info->register_info.RFLAGS);
          }
        }
      }
    }
  }
}

//
void add_set_flag(operator_analyze_result_t *operator_analyze_dest,
                  operator_analyze_result_t *operator_analyze_source,
                  register_simulation_t *register_info,
                  register_taines_map_t *register_map, int length) {
  // if(operator_analyze_dest->taine_flag||operator_analyze_source->taine_flag){
  //   rflag_set_taine(register_map);
  // }else{
  //   rflag_unset_taine(register_map);
  // }
  // //
  // if(operator_analyze_dest->unsure_flag||operator_analyze_source->unsure_flag){
  //   rflag_set_unsure(register_info);
  //   return;
  // }else{
  //   rflag_unset_unsure(register_info);
  // }
  // dest+source op1+op2
  unsigned long long int tmp;
  if (length > 64 || length < 0) {
    length = 64;
  }
  //
  //0，
  operator_expend(operator_analyze_dest, length, 64, 0);
  operator_expend(operator_analyze_source, length, 64, 0);
  if ((unsigned long long int)operator_analyze_dest->value == 0 &&
      (unsigned long long int)operator_analyze_source->value == 0) {
    SET_ZF_1(register_info->register_info.RFLAGS);
    SET_PF_1(register_info->register_info.RFLAGS);
  } else {
    SET_ZF_0(register_info->register_info.RFLAGS);
    tmp = (unsigned long long int)operator_analyze_dest->value +
          (unsigned long long int)operator_analyze_source->value;

    if (tmp & 1) {
      SET_PF_0(register_info->register_info.RFLAGS);
    } else {
      SET_PF_1(register_info->register_info.RFLAGS);
    }

    if (length < 64) {
      //64
      if ((tmp > 4294967295 && length <= 32) || (tmp > 65535 && length <= 16) ||
          (tmp > 255 && length <= 8)) {
        SET_CF_1(register_info->register_info.RFLAGS);
      } else {
        SET_CF_0(register_info->register_info.RFLAGS);
      }
    } else {
      if (tmp < (unsigned long long int)operator_analyze_dest->value ||
          tmp < (unsigned long long int)operator_analyze_source->value) {
        SET_CF_1(register_info->register_info.RFLAGS);
      } else {
        SET_CF_0(register_info->register_info.RFLAGS);
      }
    }
  }
  //
  //
  operator_expend(operator_analyze_dest, length, 64, 1);
  operator_expend(operator_analyze_source, length, 64, 1);

  if ((long long int)operator_analyze_dest->value == 0 &&
      (long long int)operator_analyze_source->value == 0) {
    //
    SET_OF_0(register_info->register_info.RFLAGS);
    SET_SF_0(register_info->register_info.RFLAGS);
  } else {
    //
    if (((long long int)operator_analyze_dest->value < 0 &&
         (long long int)operator_analyze_source->value > 0) ||
        ((long long int)operator_analyze_dest->value > 0 &&
         (long long int)operator_analyze_source->value < 0)) {
      //
      SET_OF_0(register_info->register_info.RFLAGS);
      if ((long long int)operator_analyze_dest->value +
              (long long int)operator_analyze_source->value <
          0) {
        SET_SF_1(register_info->register_info.RFLAGS);
      } else {
        SET_SF_0(register_info->register_info.RFLAGS);
      }
    } else {
      //
      if ((long long int)operator_analyze_dest->value < 0) {
        // dest<0 source<0
        if ((long long int)operator_analyze_dest->value +
                (long long int)operator_analyze_source->value >
            0) {
          //+0
          //
          SET_OF_1(register_info->register_info.RFLAGS);
          SET_SF_0(register_info->register_info.RFLAGS);
        } else {
          // 64
          long long int tmp = -(long long int)operator_analyze_dest->value -
                              (long long int)operator_analyze_source->value;
          if ((tmp >= 2147483647 && length <= 32) ||
              (tmp >= 32767 && length <= 16) || (tmp >= 127 && length <= 8)) {
            //
            SET_OF_1(register_info->register_info.RFLAGS);
            SET_SF_0(register_info->register_info.RFLAGS);
          } else {
            SET_OF_0(register_info->register_info.RFLAGS);
            SET_SF_1(register_info->register_info.RFLAGS);
          }
        }
      } else {
        // dest>0 source<0
        if ((long long int)operator_analyze_dest->value +
                (long long int)operator_analyze_source->value <
            0) {
          //+0
          //
          SET_OF_1(register_info->register_info.RFLAGS);
          SET_SF_1(register_info->register_info.RFLAGS);
        } else {
          // 64
          long long int tmp = (long long int)operator_analyze_dest->value +
                              (long long int)operator_analyze_source->value;
          if ((tmp > 2147483647 && length <= 32) ||
              (tmp > 32767 && length <= 16) || (tmp > 127 && length <= 8)) {
            //
            SET_OF_1(register_info->register_info.RFLAGS);
            SET_SF_1(register_info->register_info.RFLAGS);
          } else {
            SET_OF_0(register_info->register_info.RFLAGS);
            SET_SF_0(register_info->register_info.RFLAGS);
          }
        }
      }
    }
  }
}

unsigned long long int top64(unsigned long long int x,
                             unsigned long long int y) {
  unsigned long long int a = x >> 32, b = x & 0xffffffff;
  unsigned long long int c = y >> 32, d = y & 0xffffffff;

  unsigned long long int ac = a * c;
  unsigned long long int bc = b * c;
  unsigned long long int ad = a * d;
  unsigned long long int bd = b * d;

  unsigned long long int mid34 =
      (bd >> 32) + (bc & 0xffffffff) + (ad & 0xffffffff);

  unsigned long long int upper64 = ac + (bc >> 32) + (ad >> 32) + (mid34 >> 32);
  // unsigned long long int lower64 = (mid34 << 32) | (bd & 0xffffffff);

  return upper64;
}
unsigned long long int low64(unsigned long long int x,
                             unsigned long long int y) {
  unsigned long long int a = x >> 32, b = x & 0xffffffff;
  unsigned long long int c = y >> 32, d = y & 0xffffffff;

  unsigned long long int ac;
  unsigned long long int bc;
  unsigned long long int ad;
  unsigned long long int bd;

  unsigned long long int mid34;
  // unsigned long long int upper64 = ac + (bc >> 32) + (ad >> 32) + (mid34 >>
  // 32);
  unsigned long long int lower64;
  ac = a * c;
  bc = b * c;
  ad = a * d;
  bd = b * d;
  mid34 = (bd >> 32) + (bc & 0xffffffff) + (ad & 0xffffffff);
  lower64 = (mid34 << 32) | (bd & 0xffffffff);

  return lower64;
}

//64
void op_sign_expend(operator_analyze_result_t *operator_analyze_res1,
                    int op_size) {
  if (op_size > 64 || op_size < 0 || op_size == 64) {
    return;
  }
  if (operator_analyze_res1->value &
      (((unsigned long long int)1) << (op_size - 1))) {
    unsigned long long int mask;
    if (op_size >= 64) {
      mask = 0x0;
    } else {
      mask = 0xffffffffffffffff << op_size;
    }
    operator_analyze_res1->value |= mask;
  } else {
    unsigned long long int mask;
    if (op_size >= 64) {
      mask = 0x0;
    } else {
      mask = 0xffffffffffffffff << op_size;
    }
    operator_analyze_res1->value &= ~mask;
    return;
  }
}

void compute_operator(operator_analyze_result_t *operator_analyze_res1,
                      operator_analyze_result_t *operator_analyze_res2,
                      operator_analyze_result_t *operator_analyze_res3,
                      operator_analyze_result_t *operator_analyze_res4,
                      int op_size, char compute_type, char imul_op_num,
                      register_simulation_t *register_info,
                      register_taines_map_t *register_map) {
  char taine_flag = 0;
  char unsure_flag = 0;
  if (op_size > 64 || op_size < 0) {
    op_size = 64;
  }
  //
  if (operator_analyze_res1->taine_flag || operator_analyze_res2->taine_flag) {
    operator_analyze_res3->taine_flag = 1;
    operator_analyze_res4->taine_flag = 1;
    taine_flag = 1;
  }
  if (operator_analyze_res1->unsure_flag ||
      operator_analyze_res2->unsure_flag) {
    operator_analyze_res3->unsure_flag = 1;
    operator_analyze_res4->unsure_flag = 1;
    unsure_flag = 1;
  }

  //
  switch (compute_type) {
    // add
    case 0: {
      // if (taine_flag) {
      //   rflag_set_taine(register_map);
      // } else {
      //   rflag_unset_taine(register_map);
      // }
      // if (unsure_flag) {
      //   rflag_set_unsure(register_info);
      //   return;
      // } else {
      //   rflag_unset_unsure(register_info);
      // }
      unsigned long long int mask;
      operator_analyze_res3->value =
          operator_analyze_res1->value + operator_analyze_res2->value;

      if (op_size >= 64) {
        mask = 0xffffffffffffffff;
      } else {
        mask = ~(0xffffffffffffffff << op_size);
      }
      operator_analyze_res3->value &= mask;
      // add_set_flag(operator_analyze_res1, operator_analyze_res2,
      // register_info,
      //              register_map, op_size);
      return;
    }
    // adc
    case 1: {
      // if (GET_CF(register_map->rflags) || taine_flag) {
      //   operator_analyze_res3->taine_flag = 1;
      //   rflag_set_taine(register_map);
      // } else {
      //   rflag_unset_taine(register_map);
      // }
      // if (unsure_flag || GET_CF(register_info->rflags_unsure)) {
      //   operator_analyze_res3->unsure_flag = 1;
      //   rflag_set_unsure(register_info);
      //   return;
      // } else {
      //   rflag_unset_unsure(register_info);
      // }
      unsigned long long int mask;
      operator_analyze_res3->value =
          operator_analyze_res1->value + operator_analyze_res2->value +
          (GET_CF(register_info->register_info.RFLAGS));

      if (op_size == 64) {
        mask = 0xffffffffffffffff;
      } else {
        mask = ~(0xffffffffffffffff << op_size);
      }
      operator_analyze_res3->value &= mask;

      if (GET_CF(register_info->register_info.RFLAGS) == 0) {
        return;
      }

      if (operator_analyze_res1->value == 0xffffffffffffffff &&
          operator_analyze_res2->value == 0xffffffffffffffff) {
        SET_ZF_0(register_info->register_info.RFLAGS);
        SET_CF_1(register_info->register_info.RFLAGS);
        SET_SF_1(register_info->register_info.RFLAGS);
        SET_OF_1(register_info->register_info.RFLAGS);
        return;
      } else if (operator_analyze_res1->value != 0xffffffffffffffff) {
        operator_analyze_res1->value += 1;
      } else {
        operator_analyze_res2->value += 1;
      }
      // add_set_flag(operator_analyze_res1, operator_analyze_res2,
      // register_info,
      //              register_map, op_size);
      return;
    }
    // inc
    case 3: {
      // if (taine_flag) {
      //   rflag_set_taine(register_map);
      // } else {
      //   rflag_unset_taine(register_map);
      // }
      // if (unsure_flag) {
      //   rflag_set_unsure(register_info);
      //   return;
      // } else {
      //   rflag_unset_unsure(register_info);
      // }
      unsigned long long int mask;
      char cf;
      operator_analyze_result_t tmp;
      operator_analyze_res3->value = operator_analyze_res1->value + 1;
      if (op_size == 64) {
        mask = 0xffffffffffffffff;
      } else {
        mask = ~(0xffffffffffffffff << op_size);
      }
      operator_analyze_res3->value &= mask;
      cf = GET_CF(register_info->register_info.RFLAGS);
      tmp.taine_flag = 0;
      tmp.unsure_flag = 0;
      tmp.value = 1;
      // add_set_flag(operator_analyze_res1, &tmp, register_info, register_map,
      //              op_size);
      // if (cf) {
      //   SET_CF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_CF_0(register_info->register_info.RFLAGS);
      // }
      return;
    }
    // sub
    case 4: {
      // if (taine_flag) {
      //   rflag_set_taine(register_map);
      // } else {
      //   rflag_unset_taine(register_map);
      // }
      // if (unsure_flag) {
      //   rflag_set_unsure(register_info);
      //   return;
      // } else {
      //   rflag_unset_unsure(register_info);
      // }
      unsigned long long int mask;
      operator_analyze_res3->value =
          operator_analyze_res1->value - operator_analyze_res2->value;
      if (op_size == 64) {
        mask = 0xffffffffffffffff;
      } else {
        mask = ~(0xffffffffffffffff << op_size);
      }
      operator_analyze_res3->value &= mask;

      // sub_set_flag(operator_analyze_res1, operator_analyze_res2,
      // register_info,
      //              register_map, op_size);
      return;
    }
    // sbb
    case 5: {
      // if (GET_CF(register_map->rflags) || taine_flag) {
      //   operator_analyze_res3->taine_flag = 1;
      //   rflag_set_taine(register_map);
      // } else {
      //   rflag_unset_taine(register_map);
      // }
      // if (unsure_flag || GET_CF(register_info->rflags_unsure)) {
      //   operator_analyze_res3->unsure_flag = 1;
      //   rflag_set_unsure(register_info);
      //   return;
      // } else {
      //   rflag_unset_unsure(register_info);
      // }
      unsigned long long int mask;
      operator_analyze_res3->value =
          operator_analyze_res1->value - operator_analyze_res2->value -
          (GET_CF(register_info->register_info.RFLAGS));

      if (op_size == 64) {
        mask = 0xffffffffffffffff;
      } else {
        mask = ~(0xffffffffffffffff << op_size);
      }
      operator_analyze_res3->value &= mask;
      if (operator_analyze_res1->value == 0 &&
          operator_analyze_res2->value == 0) {
        // SET_ZF_0(register_info->register_info.RFLAGS);
        // SET_CF_1(register_info->register_info.RFLAGS);
        // SET_SF_1(register_info->register_info.RFLAGS);
        // SET_OF_0(register_info->register_info.RFLAGS);
      } else if (operator_analyze_res1->value != 0) {
        operator_analyze_res1->value -= 1;
      } else {
        operator_analyze_res2->value -= 1;
      }
      // sub_set_flag(operator_analyze_res1, operator_analyze_res2,
      // register_info,
      //              register_map, op_size);
      return;
    }
    // dec
    case 6: {
      // if (taine_flag) {
      //   rflag_set_taine(register_map);
      // } else {
      //   rflag_unset_taine(register_map);
      // }
      // if (unsure_flag) {
      //   rflag_set_unsure(register_info);
      //   return;
      // } else {
      //   rflag_unset_unsure(register_info);
      // }
      unsigned long long int mask;
      char cf;
      operator_analyze_result_t tmp;
      operator_analyze_res3->value = operator_analyze_res1->value - 1;
      if (op_size == 64) {
        mask = 0xffffffffffffffff;
      } else {
        mask = ~(0xffffffffffffffff << op_size);
      }
      operator_analyze_res3->value &= mask;
      cf = GET_CF(register_info->register_info.RFLAGS);
      tmp.taine_flag = 0;
      tmp.unsure_flag = 0;
      tmp.value = 1;
      // sub_set_flag(operator_analyze_res1, &tmp, register_info, register_map,
      //              op_size);
      // if (cf) {
      //   SET_CF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_CF_0(register_info->register_info.RFLAGS);
      // }
      return;
    }
    // mul
    case 7: {
      //
      // if (taine_flag) {
      //   SET_CF_1(register_map->rflags);
      //   SET_OF_1(register_map->rflags);
      // } else {
      //   SET_CF_0(register_map->rflags);
      //   SET_OF_0(register_map->rflags);
      // }
      // if (unsure_flag) {
      //   SET_CF_1(register_info->rflags_unsure);
      //   SET_OF_1(register_info->rflags_unsure);
      //   return;
      // } else {
      //   SET_CF_0(register_info->rflags_unsure);
      //   SET_OF_0(register_info->rflags_unsure);
      // }

      if (op_size == 8) {
        operator_analyze_res3->value =
            operator_analyze_res1->value * operator_analyze_res2->value;
        // if (operator_analyze_res3->value & (0xff00)) {
        //   SET_CF_1(register_info->register_info.RFLAGS);
        //   SET_OF_1(register_info->register_info.RFLAGS);
        // } else {
        //   SET_CF_0(register_info->register_info.RFLAGS);
        //   SET_OF_0(register_info->register_info.RFLAGS);
        // }
        // if(operator_analyze_res3->value&1){
        //   SET_PF_0(register_info->register_info.RFLAGS);
        // }else{
        //   SET_PF_1(register_info->register_info.RFLAGS);
        // }
        return;
      } else if (op_size == 16) {
        unsigned long long int res =
            operator_analyze_res1->value * operator_analyze_res2->value;
        operator_analyze_res3->value = (res & (0xffff << 16)) >> 16;
        operator_analyze_res4->value = res & 0xffff;
      } else if (op_size == 32) {
        unsigned long long int res =
            operator_analyze_res1->value * operator_analyze_res2->value;
        operator_analyze_res3->value = (res & (0xffffffffffffffff) << 32) >> 32;
        operator_analyze_res4->value = res & 0xffffffff;
      } else {
        operator_analyze_res3->value =
            top64(operator_analyze_res1->value, operator_analyze_res2->value);
        operator_analyze_res4->value =
            low64(operator_analyze_res1->value, operator_analyze_res2->value);
      }
      // if (operator_analyze_res3->value != 0) {
      //   SET_CF_1(register_info->register_info.RFLAGS);
      //   SET_OF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_CF_0(register_info->register_info.RFLAGS);
      //   SET_OF_0(register_info->register_info.RFLAGS);
      // }
      // if(operator_analyze_res4->value&1){
      //   SET_PF_0(register_info->register_info.RFLAGS);
      // }else{
      //   SET_PF_1(register_info->register_info.RFLAGS);
      // }
      return;
    }
    // div
    case 8: {
      if (unsure_flag || operator_analyze_res2->value == 0) {
        return;
      }
      if (op_size == 8) {
        unsigned long long int q =
            operator_analyze_res1->value / operator_analyze_res2->value;
        unsigned long long int r =
            operator_analyze_res1->value % operator_analyze_res2->value;
        operator_analyze_res3->value = q;
        operator_analyze_res3->value += r << 8;
      } else {
        unsigned long long int q =
            operator_analyze_res1->value / operator_analyze_res2->value;
        unsigned long long int r =
            operator_analyze_res1->value % operator_analyze_res2->value;
        operator_analyze_res3->value = q;
        operator_analyze_res4->value = r;
      }
      return;
    }
    // imul
    case 9: {
      //OF=CF=0，OF=CF=1
      // if (taine_flag) {
      //   SET_CF_1(register_map->rflags);
      //   SET_OF_1(register_map->rflags);
      // } else {
      //   SET_CF_0(register_map->rflags);
      //   SET_OF_0(register_map->rflags);
      // }
      // if (unsure_flag) {
      //   SET_CF_1(register_info->rflags_unsure);
      //   SET_OF_1(register_info->rflags_unsure);
      //   return;
      // } else {
      //   SET_CF_0(register_info->rflags_unsure);
      //   SET_OF_0(register_info->rflags_unsure);
      // }

      op_sign_expend(operator_analyze_res1, op_size);
      op_sign_expend(operator_analyze_res2, op_size);
      if (imul_op_num == 1) {
        //mul
        char sign = 0;
        if (((long long int)operator_analyze_res1->value > 0 &&
             (long long int)operator_analyze_res2->value > 0) ||
            ((long long int)operator_analyze_res1->value < 0 &&
             (long long int)operator_analyze_res2->value < 0)) {
          //
          sign = 0;
        } else {
          //
          sign = 1;
        }

        if (op_size == 8) {
          unsigned long long int mask = 0xffff;
          operator_analyze_res3->value =
              (long long int)operator_analyze_res1->value *
              (long long int)operator_analyze_res2->value;
          operator_analyze_res3->value &= mask;

          // if ((operator_analyze_res3->value & (0xff00)) == 0 ||
          //     (operator_analyze_res3->value & (0xff00)) == (0xff00)) {
          //   //，
          //   //1
          //   SET_CF_0(register_info->register_info.RFLAGS);
          //   SET_OF_0(register_info->register_info.RFLAGS);
          // } else {
          //   SET_CF_1(register_info->register_info.RFLAGS);
          //   SET_OF_1(register_info->register_info.RFLAGS);
          // }
          return;
        } else if (op_size == 16) {
          unsigned long long int mask;
          operator_analyze_res3->value =
              (long long int)operator_analyze_res1->value *
              (long long int)operator_analyze_res2->value;
          mask = 0xffffffff;
          operator_analyze_res3->value &= mask;
          // if ((operator_analyze_res3->value & (0xffff0000)) == 0 ||
          //     (operator_analyze_res3->value & (0xffff0000)) == (0xffff0000))
          //     {
          //   //，
          //   //1
          //   SET_CF_0(register_info->register_info.RFLAGS);
          //   SET_OF_0(register_info->register_info.RFLAGS);
          // } else {
          //   SET_CF_1(register_info->register_info.RFLAGS);
          //   SET_OF_1(register_info->register_info.RFLAGS);
          // }
          return;
        } else if (op_size == 32) {
          unsigned long long int res =
              (long long int)operator_analyze_res1->value *
              (long long int)operator_analyze_res2->value;
          operator_analyze_res3->value =
              (res & (0xffffffffffffffff) << 32) >> 32;
          operator_analyze_res4->value = res & 0xffffffff;
          // if (operator_analyze_res3->value == 0 ||
          //     operator_analyze_res3->value == 0xffffffff) {
          //   //，
          //   //1
          //   SET_CF_0(register_info->register_info.RFLAGS);
          //   SET_OF_0(register_info->register_info.RFLAGS);
          // } else {
          //   SET_CF_1(register_info->register_info.RFLAGS);
          //   SET_OF_1(register_info->register_info.RFLAGS);
          // }
          return;
        } else {
          //
          //，
          if ((long long int)operator_analyze_res1->value < 0) {
            operator_analyze_res1->value =
                -(long long int)operator_analyze_res1->value;
          }
          if ((long long int)operator_analyze_res2->value < 0) {
            operator_analyze_res2->value =
                -(long long int)operator_analyze_res2->value;
          }
          operator_analyze_res3->value =
              top64(operator_analyze_res1->value, operator_analyze_res2->value);
          operator_analyze_res4->value =
              low64(operator_analyze_res1->value, operator_analyze_res2->value);
          if (sign) {
            int index = 0;
            if (operator_analyze_res3->value != 0) {
              for (; index < 64; ++index) {
                if (operator_analyze_res3->value &
                    (((unsigned long long int)1) << (63 - index))) {
                  break;
                }
                operator_analyze_res3->value |= ((unsigned long long int)1)
                                                << (63 - index);
              }
              // SET_CF_1(register_info->register_info.RFLAGS);
              // SET_OF_1(register_info->register_info.RFLAGS);
            } else {
              index = 0;
              operator_analyze_res3->value = 0xffffffffffffffff;
              for (; index < 64; ++index) {
                if (operator_analyze_res4->value &
                    (((unsigned long long int)1) << (63 - index))) {
                  break;
                }
                operator_analyze_res4->value |= ((unsigned long long int)1)
                                                << (63 - index);
              }
              // SET_CF_0(register_info->register_info.RFLAGS);
              // SET_OF_0(register_info->register_info.RFLAGS);
            }
          }
        }
        return;
      } else {
        long long int tmp = (long long int)operator_analyze_res1->value *
                            (long long int)operator_analyze_res2->value;
        unsigned long long int mask;
        char sign = 0;
        if (tmp < 0) {
          sign = 1;
        }
        if (op_size == 64) {
          mask = 0xffffffffffffffff;
        } else {
          mask = ~(0xffffffffffffffff << op_size);
        }
        operator_analyze_res3->value = mask & tmp;
        // if (op_size == 16) {
        //   if ((operator_analyze_res3->value & 0xffff0000) == 0 ||
        //       (operator_analyze_res3->value & (0xffff0000)) == 0xffff0000) {
        //     //，
        //     //1
        //     SET_CF_0(register_info->register_info.RFLAGS);
        //     SET_OF_0(register_info->register_info.RFLAGS);
        //   } else {
        //     SET_CF_1(register_info->register_info.RFLAGS);
        //     SET_OF_1(register_info->register_info.RFLAGS);
        //   }
        // } else if (op_size == 32) {
        //   if ((operator_analyze_res3->value & 0xffffffff00000000) == 0 ||
        //       (operator_analyze_res3->value & 0xffffffff00000000) ==
        //           0xffffffff00000000) {
        //     //，
        //     //1
        //     SET_CF_0(register_info->register_info.RFLAGS);
        //     SET_OF_0(register_info->register_info.RFLAGS);
        //   } else {
        //     SET_CF_1(register_info->register_info.RFLAGS);
        //     SET_OF_1(register_info->register_info.RFLAGS);
        //   }
        // } else {
        //   // 64
        //   if (tmp / (long long int)operator_analyze_res1->value !=
        //       (long long int)operator_analyze_res2->value) {
        //     SET_CF_1(register_info->register_info.RFLAGS);
        //     SET_OF_1(register_info->register_info.RFLAGS);
        //   } else {
        //     SET_CF_0(register_info->register_info.RFLAGS);
        //     SET_OF_0(register_info->register_info.RFLAGS);
        //   }
        // }
      }
      return;
    }
    // idiv
    case 10: {
      if (unsure_flag || operator_analyze_res2->value) {
        return;
      }
      op_sign_expend(operator_analyze_res1, op_size);
      op_sign_expend(operator_analyze_res2, op_size);
      if (op_size == 8) {
        long long int q = (long long int)operator_analyze_res1->value /
                          (long long int)operator_analyze_res2->value;
        long long int r = (long long int)operator_analyze_res1->value %
                          (long long int)operator_analyze_res2->value;
        operator_analyze_res3->value = q & 0xff;
        operator_analyze_res3->value += (r & 0xff) << 8;
      } else {
        long long int q = (long long int)operator_analyze_res1->value /
                          (long long int)operator_analyze_res2->value;
        long long int r = (long long int)operator_analyze_res1->value %
                          (long long int)operator_analyze_res2->value;
        unsigned long long int mask;
        if (op_size >= 64) {
          mask = 0xffffffffffffffff;
        } else {
          mask = ~(0xffffffffffffffff << op_size);
        }
        operator_analyze_res3->value = q & mask;
        operator_analyze_res4->value = r & mask;
      }
    }
    default: {
      return;
    }
  }
}

void logic_al_operator(operator_analyze_result_t *operator_analyze_res1,
                       operator_analyze_result_t *operator_analyze_res2,
                       operator_analyze_result_t *operator_analyze_res3,
                       int op_size, char compute_type,
                       register_simulation_t *register_info,
                       register_taines_map_t *register_map) {
  char taine_flag = 0;
  char unsure_flag = 0;
  if (op_size > 64 || op_size < 0) {
    op_size = 64;
  }

  //
  if (operator_analyze_res1->taine_flag || operator_analyze_res2->taine_flag) {
    operator_analyze_res3->taine_flag = 1;
    taine_flag = 1;
  }
  if (operator_analyze_res1->unsure_flag ||
      operator_analyze_res2->unsure_flag) {
    operator_analyze_res3->unsure_flag = 1;
    unsure_flag = 1;
  }
  switch (compute_type) {
    // not
    case 0: {
      // not
      return;
    }
    // and
    case 1: {
      //cf of andcfof
      // {
      //   SET_CF_0(register_map->rflags);
      //   SET_OF_0(register_map->rflags);
      //   SET_CF_0(register_info->rflags_unsure);
      //   SET_OF_0(register_info->rflags_unsure);
      //   SET_CF_0(register_info->register_info.RFLAGS);
      //   SET_OF_0(register_info->register_info.RFLAGS);
      // }
      // if (taine_flag) {
      //   SET_SF_1(register_map->rflags);
      //   SET_ZF_1(register_map->rflags);
      //   SET_PF_1(register_map->rflags);
      // } else {
      //   SET_SF_0(register_map->rflags);
      //   SET_ZF_0(register_map->rflags);
      //   SET_PF_0(register_map->rflags);
      // }
      // if (unsure_flag) {
      //   SET_SF_1(register_info->rflags_unsure);
      //   SET_ZF_1(register_info->rflags_unsure);
      //   SET_PF_1(register_info->rflags_unsure);
      //   return;
      // } else {
      //   SET_SF_0(register_info->rflags_unsure);
      //   SET_ZF_0(register_info->rflags_unsure);
      //   SET_PF_0(register_info->rflags_unsure);
      // }
      operator_analyze_res3->value =
          operator_analyze_res1->value & operator_analyze_res2->value;
      // if (operator_analyze_res3->value == 0) {
      //   SET_CF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_CF_0(register_info->register_info.RFLAGS);
      // }
      // if (operator_analyze_res3->value & (((unsigned long long int)1) <<
      // (op_size - 1))) {
      //   SET_SF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_SF_0(register_info->register_info.RFLAGS);
      // }
      // if (operator_analyze_res3->value & 1) {
      //   SET_PF_0(register_info->register_info.RFLAGS);
      // } else {
      //   SET_PF_1(register_info->register_info.RFLAGS);
      // }

      return;
    }
    // or
    case 2: {
      // {
      //   SET_CF_0(register_map->rflags);
      //   SET_OF_0(register_map->rflags);
      //   SET_CF_0(register_info->rflags_unsure);
      //   SET_OF_0(register_info->rflags_unsure);
      //   SET_CF_0(register_info->register_info.RFLAGS);
      //   SET_OF_0(register_info->register_info.RFLAGS);
      // }
      // if (taine_flag) {
      //   SET_SF_1(register_map->rflags);
      //   SET_ZF_1(register_map->rflags);
      //   SET_PF_1(register_map->rflags);
      // } else {
      //   SET_SF_0(register_map->rflags);
      //   SET_ZF_0(register_map->rflags);
      //   SET_PF_0(register_map->rflags);
      // }
      // if (unsure_flag) {
      //   SET_SF_1(register_info->rflags_unsure);
      //   SET_ZF_1(register_info->rflags_unsure);
      //   SET_PF_1(register_info->rflags_unsure);
      //   return;
      // } else {
      //   SET_SF_0(register_info->rflags_unsure);
      //   SET_ZF_0(register_info->rflags_unsure);
      //   SET_PF_0(register_info->rflags_unsure);
      // }
      operator_analyze_res3->value =
          operator_analyze_res1->value | operator_analyze_res2->value;
      // if (operator_analyze_res3->value == 0) {
      //   SET_CF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_CF_0(register_info->register_info.RFLAGS);
      // }
      // if (operator_analyze_res3->value & (((unsigned long long int)1) <<
      // (op_size - 1))) {
      //   SET_SF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_SF_0(register_info->register_info.RFLAGS);
      // }
      // if (operator_analyze_res3->value & 1) {
      //   SET_PF_0(register_info->register_info.RFLAGS);
      // } else {
      //   SET_PF_1(register_info->register_info.RFLAGS);
      // }
      return;
    }
    // xor
    case 3: {
      // {
      //   SET_CF_0(register_map->rflags);
      //   SET_OF_0(register_map->rflags);
      //   SET_CF_0(register_info->rflags_unsure);
      //   SET_OF_0(register_info->rflags_unsure);
      //   SET_CF_0(register_info->register_info.RFLAGS);
      //   SET_OF_0(register_info->register_info.RFLAGS);
      // }
      // if (taine_flag) {
      //   SET_SF_1(register_map->rflags);
      //   SET_ZF_1(register_map->rflags);
      //   SET_PF_1(register_map->rflags);
      // } else {
      //   SET_SF_0(register_map->rflags);
      //   SET_ZF_0(register_map->rflags);
      //   SET_PF_0(register_map->rflags);
      // }
      // if (unsure_flag) {
      //   SET_SF_1(register_info->rflags_unsure);
      //   SET_ZF_1(register_info->rflags_unsure);
      //   SET_PF_1(register_info->rflags_unsure);
      //   return;
      // } else {
      //   SET_SF_0(register_info->rflags_unsure);
      //   SET_ZF_0(register_info->rflags_unsure);
      //   SET_PF_0(register_info->rflags_unsure);
      // }
      operator_analyze_res3->value =
          operator_analyze_res1->value ^ operator_analyze_res2->value;
      // if (operator_analyze_res3->value == 0) {
      //   SET_CF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_CF_0(register_info->register_info.RFLAGS);
      // }
      // if (operator_analyze_res3->value & (((unsigned long long int)1) <<
      // (op_size - 1))) {
      //   SET_SF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_SF_0(register_info->register_info.RFLAGS);
      // }
      // if (operator_analyze_res3->value & 1) {
      //   SET_PF_0(register_info->register_info.RFLAGS);
      // } else {
      //   SET_PF_1(register_info->register_info.RFLAGS);
      // }
      return;
    }
  }
}

void logic_shift_operator(operator_analyze_result_t *operator_analyze_res1,
                          operator_analyze_result_t *operator_analyze_res2,
                          operator_analyze_result_t *operator_analyze_res3,
                          int op_size, char compute_type,
                          register_simulation_t *register_info,
                          register_taines_map_t *register_map) {
  //
  char taine_flag = 0;
  char unsure_flag = 0;
  if (op_size > 64 || op_size < 0) {
    op_size = 64;
  }
  // SHL SHR SAL SAR ROL ROR RCL RCR
  operator_analyze_res2->value %= op_size;
  //
  if (operator_analyze_res1->taine_flag || operator_analyze_res2->taine_flag) {
    operator_analyze_res3->taine_flag = 1;
    taine_flag = 1;
  }
  if (operator_analyze_res1->unsure_flag ||
      operator_analyze_res2->unsure_flag) {
    operator_analyze_res3->unsure_flag = 1;
    unsure_flag = 1;
  }
  switch (compute_type) {
    // SHL
    case 0: {
      // {
      //   if (taine_flag) {
      //     SET_CF_1(register_map->rflags);
      //     SET_OF_1(register_map->rflags);
      //   } else {
      //     SET_CF_0(register_map->rflags);
      //     SET_OF_0(register_map->rflags);
      //   }
      //   if (unsure_flag) {
      //     SET_CF_1(register_info->registers_unsure);
      //     SET_OF_1(register_info->registers_unsure);
      //     return;
      //   } else {
      //     SET_CF_0(register_info->registers_unsure);
      //     SET_OF_0(register_info->registers_unsure);
      //   }
      // }
      unsigned long long int mask;
      if (operator_analyze_res2->value == 0) {
        operator_analyze_res3->value = operator_analyze_res1->value;
        // SET_CF_0(register_info->register_info.RFLAGS);
        // SET_OF_0(register_info->register_info.RFLAGS);
        return;
      }

      operator_analyze_res3->value = operator_analyze_res1->value
                                     << operator_analyze_res2->value;

      if (op_size == 64) {
        mask = 0xffffffffffffffff;
      } else {
        mask = ~(0xffffffffffffffff << op_size);
      }
      operator_analyze_res3->value &= mask;
      // if (operator_analyze_res1->value &
      //     (((unsigned long long int)1) << (op_size -
      //     operator_analyze_res2->value - 1))) {
      //   SET_CF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_CF_0(register_info->register_info.RFLAGS);
      // }
      // if ((operator_analyze_res3->value & (((unsigned long long int)1) <<
      // (op_size - 1))) !=
      //     (operator_analyze_res1->value & (((unsigned long long int)1) <<
      //     (op_size - 1)))) {
      //   SET_OF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_OF_0(register_info->register_info.RFLAGS);
      // }
      return;
    }
    // SHR
    case 1: {
      // {
      //   if (taine_flag) {
      //     SET_CF_1(register_map->rflags);
      //     SET_OF_1(register_map->rflags);
      //   } else {
      //     SET_CF_0(register_map->rflags);
      //     SET_OF_0(register_map->rflags);
      //   }
      //   if (unsure_flag) {
      //     SET_CF_1(register_info->registers_unsure);
      //     SET_OF_1(register_info->registers_unsure);
      //     return;
      //   } else {
      //     SET_CF_0(register_info->registers_unsure);
      //     SET_OF_0(register_info->registers_unsure);
      //   }
      // }

      if (operator_analyze_res2->value == 0) {
        operator_analyze_res3->value = operator_analyze_res1->value;
        // SET_CF_0(register_info->register_info.RFLAGS);
        // SET_OF_0(register_info->register_info.RFLAGS);
        return;
      }

      operator_analyze_res3->value =
          operator_analyze_res1->value >> operator_analyze_res2->value;
      // if (operator_analyze_res1->value &
      //     (((unsigned long long int)1) << (operator_analyze_res2->value -
      //     1))) {
      //   SET_CF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_CF_0(register_info->register_info.RFLAGS);
      // }
      // if ((operator_analyze_res3->value & (((unsigned long long int)1) <<
      // (op_size - 1))) !=
      //     (operator_analyze_res1->value & (((unsigned long long int)1) <<
      //     (op_size - 1)))) {
      //   SET_OF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_OF_0(register_info->register_info.RFLAGS);
      // }
      return;
    }
    // SAL
    case 2: {
      unsigned long long int mask;
      {
        // if (taine_flag) {
        //   SET_CF_1(register_map->rflags);
        //   SET_OF_1(register_map->rflags);
        // } else {
        //   SET_CF_0(register_map->rflags);
        //   SET_OF_0(register_map->rflags);
        // }
        // if (unsure_flag) {
        //   SET_CF_1(register_info->registers_unsure);
        //   SET_OF_1(register_info->registers_unsure);
        //   return;
        // } else {
        //   SET_CF_0(register_info->registers_unsure);
        //   SET_OF_0(register_info->registers_unsure);
        // }
      }

      if (operator_analyze_res2->value == 0) {
        operator_analyze_res3->value = operator_analyze_res1->value;
        // SET_CF_0(register_info->register_info.RFLAGS);
        // SET_OF_0(register_info->register_info.RFLAGS);
        return;
      }

      operator_analyze_res3->value = operator_analyze_res1->value
                                     << operator_analyze_res2->value;
      if (op_size == 64) {
        mask = 0xffffffffffffffff;
      } else {
        mask = ~(0xffffffffffffffff << op_size);
      }
      operator_analyze_res3->value &= mask;
      // if (operator_analyze_res1->value &
      //     (((unsigned long long int)1) << (op_size -
      //     operator_analyze_res2->value - 1))) {
      //   SET_CF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_CF_0(register_info->register_info.RFLAGS);
      // }
      // if ((operator_analyze_res3->value & (((unsigned long long int)1) <<
      // (op_size - 1))) !=
      //     (operator_analyze_res1->value & (((unsigned long long int)1) <<
      //     (op_size - 1)))) {
      //   SET_OF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_OF_0(register_info->register_info.RFLAGS);
      // }
      return;
    }
    // SAR
    case 3: {
      {
        // if (taine_flag) {
        //   SET_CF_1(register_map->rflags);
        // } else {
        //   SET_CF_0(register_map->rflags);
        // }
        // if (unsure_flag) {
        //   SET_CF_1(register_info->registers_unsure);
        //   return;
        // } else {
        //   SET_CF_0(register_info->registers_unsure);
        // }
      }

      if (operator_analyze_res2->value == 0) {
        operator_analyze_res3->value = operator_analyze_res1->value;
        // SET_CF_0(register_info->register_info.RFLAGS);
        return;
      }

      operator_analyze_res3->value =
          operator_analyze_res1->value >> operator_analyze_res2->value;

      if (operator_analyze_res1->value &
          (((unsigned long long int)1) << (op_size - 1))) {
        unsigned long long int mask =
            0xffffffffffffffff << (op_size - operator_analyze_res2->value);
        operator_analyze_res3->value |= mask;
      }

      // if (operator_analyze_res1->value &
      //     (((unsigned long long int)1) << (operator_analyze_res2->value -
      //     1))) {
      //   SET_CF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_CF_0(register_info->register_info.RFLAGS);
      // }
      return;
    }
    // ROL
    case 4: {
      unsigned long long int mask;
      unsigned long long int tmp;
      {
        // if (taine_flag) {
        //   SET_CF_1(register_map->rflags);
        //   SET_OF_1(register_map->rflags);
        // } else {
        //   SET_CF_0(register_map->rflags);
        //   SET_OF_0(register_map->rflags);
        // }
        // if (unsure_flag) {
        //   SET_CF_1(register_info->registers_unsure);
        //   SET_OF_1(register_info->registers_unsure);
        //   return;
        // } else {
        //   SET_CF_0(register_info->registers_unsure);
        //   SET_OF_0(register_info->registers_unsure);
        // }
      }
      if (operator_analyze_res2->value == 0) {
        operator_analyze_res3->value = operator_analyze_res1->value;
        // SET_CF_0(register_info->register_info.RFLAGS);
        // SET_OF_0(register_info->register_info.RFLAGS);
        return;
      }

      operator_analyze_res3->value = operator_analyze_res1->value
                                     << operator_analyze_res2->value;

      if (op_size == 64) {
        mask = 0xffffffffffffffff;
      } else {
        mask = ~(0xffffffffffffffff << op_size);
      }
      operator_analyze_res3->value &= mask;

      tmp = (operator_analyze_res1->value &
             ((~(0xffffffffffffffff << operator_analyze_res2->value))
              << (op_size - operator_analyze_res2->value))) >>
            (op_size - operator_analyze_res2->value);

      operator_analyze_res3->value ^= tmp;

      // if (operator_analyze_res1->value &
      //     (((unsigned long long int)1) << (op_size -
      //     operator_analyze_res2->value))) {
      //   SET_CF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_CF_0(register_info->register_info.RFLAGS);
      // }
      // if ((operator_analyze_res3->value & (((unsigned long long int)1) <<
      // (op_size - 1))) !=
      //     (operator_analyze_res1->value & (((unsigned long long int)1) <<
      //     (op_size - 1)))) {
      //   SET_OF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_OF_0(register_info->register_info.RFLAGS);
      // }
      return;
    }
    // ROR
    case 5: {
      unsigned long long int mask;
      unsigned long long int tmp;
      {
        // if (taine_flag) {
        //   SET_CF_1(register_map->rflags);
        //   SET_OF_1(register_map->rflags);
        // } else {
        //   SET_CF_0(register_map->rflags);
        //   SET_OF_0(register_map->rflags);
        // }
        // if (unsure_flag) {
        //   SET_CF_1(register_info->registers_unsure);
        //   SET_OF_1(register_info->registers_unsure);
        //   return;
        // } else {
        //   SET_CF_0(register_info->registers_unsure);
        //   SET_OF_0(register_info->registers_unsure);
        // }
      }

      if (operator_analyze_res2->value == 0) {
        operator_analyze_res3->value = operator_analyze_res1->value;
        // SET_CF_0(register_info->register_info.RFLAGS);
        // SET_OF_0(register_info->register_info.RFLAGS);
        return;
      }

      operator_analyze_res3->value =
          operator_analyze_res1->value >> operator_analyze_res2->value;

      if (op_size == 64) {
        mask = 0xffffffffffffffff;
      } else {
        mask = ~(0xffffffffffffffff << op_size);
      }
      operator_analyze_res3->value &= mask;

      tmp = operator_analyze_res1->value &
            (~(0xffffffffffffffff << operator_analyze_res2->value));

      operator_analyze_res3->value ^=
          tmp << (op_size - operator_analyze_res2->value);

      // if (operator_analyze_res1->value &
      //     ((unsigned long long int)1) << (operator_analyze_res2->value - 1))
      //     {
      //   SET_CF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_CF_0(register_info->register_info.RFLAGS);
      // }

      // if ((operator_analyze_res3->value & (((unsigned long long int)1) <<
      // (op_size - 1))) !=
      //     (operator_analyze_res1->value & (((unsigned long long int)1) <<
      //     (op_size - 1)))) {
      //   SET_OF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_OF_0(register_info->register_info.RFLAGS);
      // }

      return;
    }
    // RCL
    case 6: {
      unsigned long long int mask;
      unsigned long long int tmp;
      {
        // if (taine_flag || GET_CF(register_map->rflags)) {
        //   SET_CF_1(register_map->rflags);
        //   SET_OF_1(register_map->rflags);
        // } else {
        //   SET_CF_0(register_map->rflags);
        //   SET_OF_0(register_map->rflags);
        // }
        // if (unsure_flag || GET_CF(register_info->rflags_unsure)) {
        //   SET_CF_1(register_info->registers_unsure);
        //   SET_OF_1(register_info->registers_unsure);
        //   return;
        // } else {
        //   SET_CF_0(register_info->registers_unsure);
        //   SET_OF_0(register_info->registers_unsure);
        // }
      }

      if (operator_analyze_res2->value == 0) {
        operator_analyze_res3->value = operator_analyze_res1->value;
        // SET_CF_0(register_info->register_info.RFLAGS);
        // SET_OF_0(register_info->register_info.RFLAGS);
        return;
      }

      operator_analyze_res3->value = operator_analyze_res1->value
                                     << operator_analyze_res2->value;

      if (op_size == 64) {
        mask = 0xffffffffffffffff;
      } else {
        mask = ~(0xffffffffffffffff << op_size);
      }
      operator_analyze_res3->value &= mask;
      //
      tmp = (operator_analyze_res1->value &
             ((~(0xffffffffffffffff << (operator_analyze_res2->value - 1)))
              << (op_size - operator_analyze_res2->value + 1))) >>
            (op_size - operator_analyze_res2->value + 1);

      if (GET_CF(register_info->register_info.RFLAGS)) {
        tmp ^= ((unsigned long long int)1)
               << (operator_analyze_res2->value - 1);
      }
      operator_analyze_res3->value ^= tmp;

      // if (operator_analyze_res1->value &
      //     (((unsigned long long int)1) << (op_size -
      //     operator_analyze_res2->value))) {
      //   SET_CF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_CF_0(register_info->register_info.RFLAGS);
      // }
      // if ((operator_analyze_res1->value &
      //      (((unsigned long long int)1) << (op_size -
      //      operator_analyze_res2->value))) !=
      //     (operator_analyze_res3->value & (((unsigned long long int)1) <<
      //     (op_size - 1)))) {
      //   SET_OF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_OF_0(register_info->register_info.RFLAGS);
      // }
      return;
    }
    // RCR
    case 7: {
      unsigned long long int mask;
      unsigned long long int tmp;
      {
        // if (taine_flag) {
        //   SET_CF_1(register_map->rflags);
        //   SET_OF_1(register_map->rflags);
        // } else {
        //   SET_CF_0(register_map->rflags);
        //   SET_OF_0(register_map->rflags);
        // }
        // if (unsure_flag) {
        //   SET_CF_1(register_info->registers_unsure);
        //   SET_OF_1(register_info->registers_unsure);
        //   return;
        // } else {
        //   SET_CF_0(register_info->registers_unsure);
        //   SET_OF_0(register_info->registers_unsure);
        // }
      }

      if (operator_analyze_res2->value == 0) {
        operator_analyze_res3->value = operator_analyze_res1->value;
        // SET_CF_0(register_info->register_info.RFLAGS);
        // SET_OF_0(register_info->register_info.RFLAGS);
        return;
      }

      operator_analyze_res3->value =
          operator_analyze_res1->value >> operator_analyze_res2->value;

      if (op_size == 64) {
        mask = 0xffffffffffffffff;
      } else {
        mask = ~(0xffffffffffffffff << op_size);
      }
      operator_analyze_res3->value &= mask;
      //

      tmp =
          operator_analyze_res1->value &
          ((~(0xffffffffffffffff << (operator_analyze_res2->value - 1))) << 1);
      if (GET_CF(register_info->register_info.RFLAGS)) {
        tmp ^= 1;
      }

      operator_analyze_res3->value ^=
          tmp << (op_size - operator_analyze_res2->value);

      // if (operator_analyze_res1->value &
      //     (((unsigned long long int)1) << (operator_analyze_res2->value -
      //     1))) {
      //   SET_CF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_CF_0(register_info->register_info.RFLAGS);
      // }

      // if ((operator_analyze_res1->value &
      //      (((unsigned long long int)1) << (operator_analyze_res2->value -
      //      1))) !=
      //     (operator_analyze_res3->value & (((unsigned long long int)1) <<
      //     (op_size - 1)))) {
      //   SET_OF_1(register_info->register_info.RFLAGS);
      // } else {
      //   SET_OF_0(register_info->register_info.RFLAGS);
      // }
      return;
    }
    default: {
      return;
    }
      return;
  }
}

void test_set_flag(operator_analyze_result_t *operator_analyze_res1,
                   operator_analyze_result_t *operator_analyze_res2,
                   int op_size, register_simulation_t *register_info,
                   register_taines_map_t *register_map) {
  unsigned long long int res;
  if (op_size > 64 || op_size < 0) {
    op_size = 64;
  }
  //cf of testcfof
  {
    SET_CF_0(register_map->rflags);
    SET_OF_0(register_map->rflags);
    SET_CF_0(register_info->rflags_unsure);
    SET_OF_0(register_info->rflags_unsure);
    SET_CF_0(register_info->register_info.RFLAGS);
    SET_OF_0(register_info->register_info.RFLAGS);
  }
  //
  if (operator_analyze_res1->taine_flag || operator_analyze_res2->taine_flag) {
    SET_ZF_1(register_map->rflags);
    SET_SF_1(register_map->rflags);
    SET_PF_1(register_map->rflags);
  } else {
    SET_ZF_0(register_map->rflags);
    SET_SF_0(register_map->rflags);
    SET_PF_0(register_map->rflags);
  }
  if (operator_analyze_res1->unsure_flag ||
      operator_analyze_res2->unsure_flag) {
    SET_ZF_1(register_info->rflags_unsure);
    SET_SF_1(register_info->rflags_unsure);
    SET_PF_1(register_info->rflags_unsure);
    return;
  } else {
    SET_ZF_0(register_info->rflags_unsure);
    SET_SF_0(register_info->rflags_unsure);
    SET_PF_0(register_info->rflags_unsure);
  }

  res = operator_analyze_res1->value & operator_analyze_res2->value;
  if (res == 0) {
    SET_ZF_1(register_info->register_info.RFLAGS);
  } else {
    SET_ZF_0(register_info->register_info.RFLAGS);
  }
  if (res & (((unsigned long long int)1) << (op_size - 1))) {
    SET_SF_1(register_info->register_info.RFLAGS);
  } else {
    SET_SF_0(register_info->register_info.RFLAGS);
  }
  if (res & 1) {
    SET_PF_0(register_info->register_info.RFLAGS);
  } else {
    SET_PF_1(register_info->register_info.RFLAGS);
  }
  return;
}

void setcc_analyze(char *setcc_str,
                   operator_analyze_result_t *operator_analyze_res1,
                   register_simulation_t *register_info,
                   register_taines_map_t *register_map) {
  // seto
  if (setcc_str[3] == 'o') {
    if (GET_OF(register_map->rflags)) {
      operator_analyze_res1->taine_flag = 1;
    }
    if (GET_OF(register_info->rflags_unsure)) {
      operator_analyze_res1->unsure_flag = 1;
      return;
    } else {
      if (GET_OF(register_info->register_info.RFLAGS)) {
        operator_analyze_res1->value = 1;
      }
    }
  }
  // setno
  else if (setcc_str[3] == 'n' && setcc_str[4] == 'o') {
    if (GET_OF(register_map->rflags)) {
      operator_analyze_res1->taine_flag = 1;
    }
    if (GET_OF(register_info->rflags_unsure)) {
      operator_analyze_res1->unsure_flag = 1;
      return;
    } else {
      if (GET_OF(register_info->register_info.RFLAGS) == 0) {
        operator_analyze_res1->value = 1;
      }
    }
  }
  // sets
  else if (setcc_str[3] == 's') {
    if (GET_SF(register_map->rflags)) {
      operator_analyze_res1->taine_flag = 1;
    }
    if (GET_SF(register_info->rflags_unsure)) {
      operator_analyze_res1->unsure_flag = 1;
      return;
    } else {
      if (GET_SF(register_info->register_info.RFLAGS)) {
        operator_analyze_res1->value = 1;
      }
    }
  }
  // setns
  else if (setcc_str[3] == 'n' && setcc_str[4] == 's') {
    if (GET_SF(register_map->rflags)) {
      operator_analyze_res1->taine_flag = 1;
    }
    if (GET_SF(register_info->rflags_unsure)) {
      operator_analyze_res1->unsure_flag = 1;
      return;
    } else {
      if (GET_SF(register_info->register_info.RFLAGS) == 0) {
        operator_analyze_res1->value = 1;
      }
    }
  }
  // sete
  else if (setcc_str[3] == 'e') {
    if (GET_ZF(register_map->rflags)) {
      operator_analyze_res1->taine_flag = 1;
    }
    if (GET_ZF(register_info->rflags_unsure)) {
      operator_analyze_res1->unsure_flag = 1;
      return;
    } else {
      if (GET_ZF(register_info->register_info.RFLAGS)) {
        operator_analyze_res1->value = 1;
      }
    }
  }
  // setne
  else if (setcc_str[3] == 'n' && setcc_str[4] == 'e') {
    if (GET_ZF(register_map->rflags)) {
      operator_analyze_res1->taine_flag = 1;
    }
    if (GET_ZF(register_info->rflags_unsure)) {
      operator_analyze_res1->unsure_flag = 1;
      return;
    } else {
      if (GET_ZF(register_info->register_info.RFLAGS) == 0) {
        operator_analyze_res1->value = 1;
      }
    }
  }
  // setp
  else if (setcc_str[3] == 'p') {
    if (GET_PF(register_map->rflags)) {
      operator_analyze_res1->taine_flag = 1;
    }
    if (GET_PF(register_info->rflags_unsure)) {
      operator_analyze_res1->unsure_flag = 1;
      return;
    } else {
      if (GET_PF(register_info->register_info.RFLAGS)) {
        operator_analyze_res1->value = 1;
      }
    }
  }
  // setnp
  else if (setcc_str[3] == 'n' && setcc_str[4] == 'p') {
    if (GET_PF(register_map->rflags)) {
      operator_analyze_res1->taine_flag = 1;
    }
    if (GET_PF(register_info->rflags_unsure)) {
      operator_analyze_res1->unsure_flag = 1;
      return;
    } else {
      if (GET_PF(register_info->register_info.RFLAGS) == 0) {
        operator_analyze_res1->value = 1;
      }
    }
  }
  // setbe
  else if (setcc_str[3] == 'b' && setcc_str[4] == 'e') {
    // CF = 1 or ZF = 1
    if (GET_CF(register_map->rflags) || GET_ZF(register_map->rflags)) {
      operator_analyze_res1->taine_flag = 1;
    }

    if ((GET_ZF(register_info->rflags_unsure) == 0 &&
         GET_ZF(register_info->register_info.RFLAGS)) ||
        (GET_CF(register_info->rflags_unsure) == 0 &&
         GET_CF(register_info->register_info.RFLAGS))) {
      operator_analyze_res1->value = 1;
    } else if (GET_ZF(register_info->rflags_unsure) &&
               GET_CF(register_info->rflags_unsure)) {
      operator_analyze_res1->unsure_flag = 1;
    }
    return;
  }
  // setb
  else if (setcc_str[3] == 'b') {
    if (GET_CF(register_map->rflags)) {
      operator_analyze_res1->taine_flag = 1;
    }
    if (GET_CF(register_info->rflags_unsure)) {
      operator_analyze_res1->unsure_flag = 1;
      return;
    } else {
      if (GET_CF(register_info->register_info.RFLAGS)) {
        operator_analyze_res1->value = 1;
      }
    }
  }
  // setnb
  else if (setcc_str[3] == 'n' && setcc_str[4] == 'b') {
    if (GET_CF(register_map->rflags)) {
      operator_analyze_res1->taine_flag = 1;
    }
    if (GET_CF(register_info->rflags_unsure)) {
      operator_analyze_res1->unsure_flag = 1;
      return;
    } else {
      if (GET_CF(register_info->register_info.RFLAGS) == 0) {
        operator_analyze_res1->value = 1;
      }
    }
  }
  // seta
  else if (setcc_str[3] == 'a') {
    // CF = 0 and ZF = 0
    if (GET_CF(register_map->rflags) || GET_ZF(register_map->rflags)) {
      operator_analyze_res1->taine_flag = 1;
    }
    if (GET_CF(register_info->rflags_unsure) == 0 &&
        GET_CF(register_info->register_info.RFLAGS)) {
      return;
    } else if (GET_ZF(register_info->rflags_unsure) == 0 &&
               GET_ZF(register_info->register_info.RFLAGS)) {
      return;
    } else if (GET_CF(register_info->rflags_unsure) ||
               GET_ZF(register_info->rflags_unsure)) {
      operator_analyze_res1->unsure_flag = 1;
      return;
    } else {
      operator_analyze_res1->value = 1;
      return;
    }

    // if(GET_CF(register_info->rflags_unsure)||GET_ZF(register_info->rflags_unsure)){
    //   operator_analyze_res1->unsure_flag = 1;
    //   return;
    // }else{
    //   if(GET_CF(register_info->register_info.RFLAGS)==0 &&
    //   GET_ZF(register_info->register_info.RFLAGS)==0){
    //     operator_analyze_res1->value = 1;
    //   }
    // }
  }
  // setnge
  else if (setcc_str[3] == 'n' && setcc_str[4] == 'g') {
    // SF <> OF
    if (GET_SF(register_map->rflags) || GET_OF(register_map->rflags)) {
      operator_analyze_res1->taine_flag = 1;
    }
    if (GET_SF(register_info->rflags_unsure) ||
        GET_OF(register_info->rflags_unsure)) {
      operator_analyze_res1->unsure_flag = 1;
      return;
    } else {
      if (GET_SF(register_info->register_info.RFLAGS) !=
          GET_OF(register_info->register_info.RFLAGS)) {
        operator_analyze_res1->value = 1;
      }
    }
  }
  // setge
  else if (setcc_str[3] == 'g' && setcc_str[4] == 'e') {
    if (GET_SF(register_map->rflags) || GET_OF(register_map->rflags)) {
      operator_analyze_res1->taine_flag = 1;
    }
    if (GET_SF(register_info->rflags_unsure) ||
        GET_OF(register_info->rflags_unsure)) {
      operator_analyze_res1->unsure_flag = 1;
      return;
    } else {
      if (GET_SF(register_info->register_info.RFLAGS) ==
          GET_OF(register_info->register_info.RFLAGS)) {
        operator_analyze_res1->value = 1;
      }
    }
  }
  // setle
  else if (setcc_str[3] == 'l' && setcc_str[4] == 'e') {
    // ZF = 1 or SF <> OF
    if (GET_SF(register_map->rflags) || GET_OF(register_map->rflags) ||
        GET_ZF(register_map->rflags)) {
      operator_analyze_res1->taine_flag = 1;
    }

    if ((GET_ZF(register_info->rflags_unsure) == 0 &&
         GET_ZF(register_info->register_info.RFLAGS)) ||
        (GET_SF(register_info->rflags_unsure) == 0 &&
         GET_OF(register_info->rflags_unsure) == 0 &&
         (GET_SF(register_info->register_info.RFLAGS) !=
          GET_OF(register_info->register_info.RFLAGS)))) {
      operator_analyze_res1->value = 1;
      return;
    } else if (GET_ZF(register_info->rflags_unsure) ||
               GET_SF(register_info->rflags_unsure) ||
               GET_OF(register_info->rflags_unsure)) {
      operator_analyze_res1->unsure_flag = 1;
      return;
    }
    return;
  }
  // setnle
  else if (setcc_str[3] == 'n' && setcc_str[4] == 'l') {
    // ZF = 0 and SF = OF
    if (GET_SF(register_map->rflags) || GET_OF(register_map->rflags) ||
        GET_ZF(register_map->rflags)) {
      operator_analyze_res1->taine_flag = 1;
    }

    if (GET_ZF(register_info->rflags_unsure) == 0 &&
        GET_ZF(register_info->register_info.RFLAGS)) {
      return;
    } else if ((GET_SF(register_info->rflags_unsure) == 0 &&
                GET_OF(register_info->rflags_unsure) == 0) &&
               GET_SF(register_info->register_info.RFLAGS) !=
                   GET_OF(register_info->register_info.RFLAGS)) {
      return;
    } else if (GET_ZF(register_info->rflags_unsure) ||
               GET_SF(register_info->rflags_unsure) ||
               GET_OF(register_info->rflags_unsure)) {
      operator_analyze_res1->unsure_flag = 1;
      return;
    }
    operator_analyze_res1->value = 1;
    return;
  }
}

void flag_control_analyze(char *ins_str, register_simulation_t *register_info,
                          register_taines_map_t *register_map) {
  // clc
  if (ins_str[0] == 'c' && ins_str[1] == 'l' && ins_str[2] == 'c') {
    SET_CF_0(register_map->rflags);
    SET_CF_0(register_info->rflags_unsure);
    SET_CF_0(register_info->register_info.RFLAGS);
  }
  // cld
  else if (ins_str[0] == 'c' && ins_str[1] == 'l' && ins_str[2] == 'd') {
    SET_DF_0(register_map->rflags);
    SET_DF_0(register_info->rflags_unsure);
    SET_DF_0(register_info->register_info.RFLAGS);
  }
  // cli
  else if (ins_str[0] == 'c' && ins_str[1] == 'l' && ins_str[2] == 'd') {
    SET_IF_0(register_map->rflags);
    SET_IF_0(register_info->rflags_unsure);
    SET_IF_0(register_info->register_info.RFLAGS);
  }
  // cmc
  else if (ins_str[0] == 'c' && ins_str[1] == 'm' && ins_str[2] == 'c') {
    if (GET_CF(register_info->rflags_unsure)) {
      return;
    } else {
      if (GET_CF(register_info->register_info.RFLAGS)) {
        SET_CF_0(register_info->register_info.RFLAGS);
      } else {
        SET_CF_1(register_info->register_info.RFLAGS);
      }
    }
  }
  // stc
  else if (ins_str[0] == 's' && ins_str[1] == 't' && ins_str[2] == 'c') {
    SET_CF_0(register_map->rflags);
    SET_CF_0(register_info->rflags_unsure);
    SET_CF_1(register_info->register_info.RFLAGS);
  }
  // std
  else if (ins_str[0] == 's' && ins_str[1] == 't' && ins_str[2] == 'd') {
    SET_DF_0(register_map->rflags);
    SET_DF_0(register_info->rflags_unsure);
    SET_DF_1(register_info->register_info.RFLAGS);
  }
  // sti
  else if (ins_str[0] == 's' && ins_str[1] == 't' && ins_str[2] == 'i') {
    SET_IF_0(register_map->rflags);
    SET_IF_0(register_info->rflags_unsure);
    SET_IF_1(register_info->register_info.RFLAGS);
  }
}
