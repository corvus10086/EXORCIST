#ifndef PEBS_TAINE_TOOL_H
#define PEBS_TAINE_TOOL_H

#include "pebs_buffer.h"

typedef struct {
  unsigned long int rflags;
  unsigned long int registers;
  unsigned long int registers_can_break;
} register_taines_map_t;

typedef struct {
  register_info_t register_info;
  char* symbolic;
  unsigned long int rflags_unsure;
  unsigned long int registers_unsure;
  unsigned long int registers_can_break_unsure;
  unsigned long long int symbolic_useable;
} register_simulation_t;

typedef struct {
  unsigned long long int rbp_offset;
  unsigned long long int rsp_offset;
  char* simulation_stack_taines_info;  //栈污点位图
  char* simulation_stack_info;         //模拟的栈

  char* simulation_stack_set_info;     //栈上是否存在值
  char* simulation_stack_unsure_info;  //栈上的值是否为未知的

  //符号执行相关 先不管
  // char* symbolic;
  // unsigned long long int symbolic_useable;
} stack_simulation_t;

typedef struct {
  short heap_size;
  unsigned long long int* address;  //堆区数据采用一个地址对应一个值的方式
  char* taine;
  char* unsure;
  unsigned long long int* value;

  //符号执行相关 先不管
  // char* symbolic;
  // unsigned long long int symbolic_useable;
} heap_simulation_t;

typedef struct {
  unsigned long long int value;
  char value_str[16];
  char taine_flag;
  char unsure_flag;
  char can_exprex_by_symbol;
} operator_analyze_result_t;

typedef struct {
  unsigned long long int jmp_addr;
  char taine_flag;
  char unsure_flag;
} jmp_addr_analyze_result_t;

void set_stack_bit(unsigned long int offset, short length,
                   char* stack_map_addr);

void unset_stack_bit(unsigned long int offset, short length,
                     char* stack_map_addr);

char get_stack_bit(unsigned long int offset, short length,
                   char* stack_map_addr);

char set_stack_value(unsigned long int offset, short length,
                     unsigned long long int value, char* stack_map_addr);
void get_stack_value(unsigned long int offset, short length,
                     char* stack_map_addr, unsigned long long int* res);

void set_register_taine(char* register_name,
                        register_taines_map_t* register_map);
void set_register_taine_by_num(int num, register_taines_map_t* register_map);

void unset_register_taine(char* register_name,
                          register_taines_map_t* register_map);
void unset_register_taine_by_num(int num, register_taines_map_t* register_map);

short get_register_taine(char* register_name,
                         register_taines_map_t* register_map);
short get_register_taine_by_num(int num, register_taines_map_t* register_map);

int analyze_branch_instruction(int branch_type,
                               register_simulation_t* register_info);

void set_register_unsure_by_num(int num, register_simulation_t* register_info);

void unset_register_unsure_by_num(int num,
                                  register_simulation_t* register_info);

char get_register_unsure_by_num(int num, register_simulation_t* register_info);

unsigned long long int get_register_value_by_num(
    int register_num, register_simulation_t* register_info, int size);
char set_register_value_by_num(int register_num, unsigned long long int value,
                               char* value_unsure, int length,
                               register_simulation_t* register_info);

unsigned long long int convert_string_to_num(char* num_str);

void sub_set_flag(operator_analyze_result_t* operator_analyze_dest,
                  operator_analyze_result_t* operator_analyze_source,
                  register_simulation_t* register_info,
                  register_taines_map_t* register_map, int length);

char judge_attack(int branch_type, register_taines_map_t* register_map,
                  operator_analyze_result_t* jmp_addr_analyze_result_t);

char analyze_memory_operator(operator_analyze_result_t* operator_analyze_result,
                             unsigned long long int base_register_num,
                             unsigned long long int index_register_num,
                             unsigned long long int scale,
                             unsigned long long int displacement, int size,
                             register_simulation_t* register_info,
                             register_taines_map_t* register_map,
                             stack_simulation_t* stack_simulation_info,
                             heap_simulation_t* heap_simulation_info);
char set_memory_operator(operator_analyze_result_t* operator_analyze_result,
                         unsigned long long int base_register_num,
                         unsigned long long int index_register_num,
                         unsigned long long int scale,
                         unsigned long long int displacement, int size,
                         register_simulation_t* register_info,
                         register_taines_map_t* register_map,
                         stack_simulation_t* stack_simulation_info,
                         heap_simulation_t* heap_simulation_info);

char exec_cwd_and(char* disass_str, register_simulation_t* register_info,
                  register_taines_map_t* register_map);

void operator_expend(operator_analyze_result_t* operator_analyze_result,
                     long int source_size, long int dest_size, char sign);

void compute_operator(operator_analyze_result_t* operator_analyze_res1,
                      operator_analyze_result_t* operator_analyze_res2,
                      operator_analyze_result_t* operator_analyze_res3,
                      operator_analyze_result_t* operator_analyze_res4,
                      int op_size, char compute_type, char imul_op_num,
                      register_simulation_t* register_info,
                      register_taines_map_t* register_map);
void logic_al_operator(operator_analyze_result_t* operator_analyze_res1,
                       operator_analyze_result_t* operator_analyze_res2,
                       operator_analyze_result_t* operator_analyze_res3,
                       int op_size, char compute_type,
                       register_simulation_t* register_info,
                       register_taines_map_t* register_map);
void logic_shift_operator(operator_analyze_result_t* operator_analyze_res1,
                          operator_analyze_result_t* operator_analyze_res2,
                          operator_analyze_result_t* operator_analyze_res3,
                          int op_size, char compute_type,
                          register_simulation_t* register_info,
                          register_taines_map_t* register_map);

void test_set_flag(operator_analyze_result_t* operator_analyze_res1,
                   operator_analyze_result_t* operator_analyze_res2,
                   int op_size, register_simulation_t* register_info,
                   register_taines_map_t* register_map);

void setcc_analyze(char* setcc_str,
                   operator_analyze_result_t* operator_analyze_res1,
                   register_simulation_t* register_info,
                   register_taines_map_t* register_map);

void flag_control_analyze(char* ins_str, register_simulation_t* register_info,
                          register_taines_map_t* register_map);

void rflag_set_taine(register_taines_map_t* register_map);
void rflag_unset_taine(register_taines_map_t* register_map);
void rflag_set_unsure(register_simulation_t* register_info);
void rflag_unset_unsure(register_simulation_t* register_info);

// EFLAG 标志寄存器
#define SET_CF_1(x) x |= (1 << 0)
#define SET_CF_0(x) x &= ~(1 << 0)
#define GET_CF(x) (x & (1 << 0)) >> 0

#define SET_PF_1(x) x |= (1 << 2)
#define SET_PF_0(x) x &= ~(1 << 2)
#define GET_PF(x) (x & (1 << 2)) >> 2

#define SET_AF_1(x) x |= (1 << 4)
#define SET_AF_0(x) x &= ~(1 << 4)
#define GET_AF(x) (x & (1 << 4)) >> 4

#define SET_ZF_1(x) x |= (1 << 6)
#define SET_ZF_0(x) x &= ~(1 << 6)
#define GET_ZF(x) (x & (1 << 6)) >> 6

#define SET_SF_1(x) x |= (1 << 7)
#define SET_SF_0(x) x &= ~(1 << 7)
#define GET_SF(x) (x & (1 << 7)) >> 7

#define SET_TF_1(x) x |= (1 << 8)
#define SET_TF_0(x) x &= ~(1 << 8)
#define GET_TF(x) (x & (1 << 8)) >> 8

#define SET_IF_1(x) x |= (1 << 9)
#define SET_IF_0(x) x &= ~(1 << 9)
#define GET_IF(x) (x & (1 << 9)) >> 9

#define SET_DF_1(x) x |= (1 << 10)
#define SET_DF_0(x) x &= ~(1 << 10)
#define GET_DF(x) (x & (1 << 10)) >> 10

#define SET_OF_1(x) x |= (1 << 11)
#define SET_OF_0(x) x &= ~(1 << 11)
#define GET_OF(x) (x & (1 << 11)) >> 11

#define SET_IOPL_1(x) x |= (3 << 12)
#define SET_IOPL_0(x) x &= ~(3 << 12)
#define GET_IOPL(x) (x & (3 << 12)) >> 12

#define SET_NT_1(x) x |= (1 << 14)
#define SET_NT_0(x) x &= ~(1 << 14)
#define GET_NT(x) (x & (1 << 14)) >> 14

// #define SET_MD_1(x) x|=(1<<11)
// #define SET_MD_0(x) x&=~(1<<11)
// #define GET_MD(x) (x&(1<<11))>>11

#define SET_RF_1(x) x |= (1 << 16)
#define SET_RF_0(x) x &= ~(1 << 16)
#define GET_RF(x) (x & (1 << 16)) >> 16

#define SET_VM_1(x) x |= (1 << 17)
#define SET_VM_0(x) x &= ~(1 << 17)
#define GET_VM(x) (x & (1 << 17)) >> 17

#define SET_AC_1(x) x |= (1 << 18)
#define SET_AC_0(x) x &= ~(1 << 18)
#define GET_AC(x) (x & (1 << 18)) >> 18

#define SET_VIF_1(x) x |= (1 << 19)
#define SET_VIF_0(x) x &= ~(1 << 19)
#define GET_VIF(x) (x & (1 << 19)) >> 19

#define SET_VIP_1(x) x |= (1 << 20)
#define SET_VIP_0(x) x &= ~(1 << 20)
#define GET_VIP(x) (x & (1 << 20)) >> 20

#define SET_ID_1(x) x |= (1 << 21)
#define SET_ID_0(x) x &= ~(1 << 21)
#define GET_ID(x) (x & (1 << 21)) >> 21

// #define SET_NONE_1(x) x|=(1<<18)
// #define SET_NONE_0(x) x&=~(1<<18)
// #define GET_NONE(x) (x&(1<<18))>>18

// #define SET_AI_1(x) x|=(1<<19)
// #define SET_AI_0(x) x&=~(1<<19)
// #define GET_AI(x) (x&(1<<19))>>19

//剩下的通用寄存器不可拆分因此用一位就可以表示
#define SET_RSP_1(x) x |= (1 << 4)
#define SET_RSP_0(x) x &= ~(1 << 4)
#define GET_RSP(x) (x & (1 << 4)) >> 4

#define SET_RBP_1(x) x |= (1 << 5)
#define SET_RBP_0(x) x &= ~(1 << 5)
#define GET_RBP(x) (x & (1 << 5)) >> 5

#define SET_RSI_1(x) x |= (1 << 6)
#define SET_RSI_0(x) x &= ~(1 << 6)
#define GET_RSI(x) (x & (1 << 6)) >> 6

#define SET_RDI_1(x) x |= (1 << 7)
#define SET_RDI_0(x) x &= ~(1 << 7)
#define GET_RDI(x) (x & (1 << 7)) >> 7

#define SET_R8_1(x) x |= (1 << 8)
#define SET_R8_0(x) x &= ~(1 << 8)
#define GET_R8(x) (x & (1 << 8)) >> 8

#define SET_R9_1(x) x |= (1 << 9)
#define SET_R9_0(x) x &= ~(1 << 9)
#define GET_R9(x) (x & (1 << 9)) >> 9

#define SET_R10_1(x) x |= (1 << 10)
#define SET_R10_0(x) x &= ~(1 << 10)
#define GET_R10(x) (x & (1 << 10)) >> 10

#define SET_R11_1(x) x |= (1 << 11)
#define SET_R11_0(x) x &= ~(1 << 11)
#define GET_R11(x) (x & (1 << 11)) >> 11

#define SET_R12_1(x) x |= (1 << 12)
#define SET_R12_0(x) x &= ~(1 << 12)
#define GET_R12(x) (x & (1 << 12)) >> 12

#define SET_R13_1(x) x |= (1 << 13)
#define SET_R13_0(x) x &= ~(1 << 13)
#define GET_R13(x) (x & (1 << 13)) >> 13

#define SET_R14_1(x) x |= (1 << 14)
#define SET_R14_0(x) x &= ~(1 << 14)
#define GET_R14(x) (x & (1 << 14)) >> 14

#define SET_R15_1(x) x |= (1 << 15)
#define SET_R15_0(x) x &= ~(1 << 15)
#define GET_R15(x) (x & (1 << 15)) >> 15

// RAX,RCX,RDX,RBX可以拆分需要三位进行表示
//设置RAX相关的寄存器
#define SET_RAX_1(x) x |= (15 << 0)
#define SET_RAX_0(x) x &= ~(15 << 0)
#define GET_RAX(x) (x & (15 << 0)) >> 0

#define SET_EAX_1(x) x |= (7 << 0)
#define SET_EAX_0(x) x &= ~(7 << 0)
#define GET_EAX(x) (x & (7 << 0)) >> 0

#define SET_AX_1(x) x |= (3 << 0)
#define SET_AX_0(x) x &= ~(3 << 0)
#define GET_AX(x) (x & (3 << 0)) >> 0

#define SET_AH_1(x) x |= (1 << 1)
#define SET_AH_0(x) x &= ~(1 << 1)
#define GET_AH(x) (x & (1 << 1)) >> 1

#define SET_AL_1(x) x |= (1 << 0)
#define SET_AL_0(x) x &= ~(1 << 0)
#define GET_AL(x) (x & (1 << 0)) >> 0

//设置RCX相关的寄存器
#define SET_RCX_1(x) x |= (15 << 4)
#define SET_RCX_0(x) x &= ~(15 << 4)
#define GET_RCX(x) (x & (15 << 4)) >> 4

#define SET_ECX_1(x) x |= (7 << 4)
#define SET_ECX_0(x) x &= ~(7 << 4)
#define GET_ECX(x) (x & (7 << 4)) >> 4

#define SET_CX_1(x) x |= (3 << 4)
#define SET_CX_0(x) x &= ~(3 << 4)
#define GET_CX(x) (x & (3 << 4)) >> 4

#define SET_CH_1(x) x |= (1 << 5)
#define SET_CH_0(x) x &= ~(1 << 5)
#define GET_CH(x) (x & (1 << 5)) >> 5

#define SET_CL_1(x) x |= (1 << 4)
#define SET_CL_0(x) x &= ~(1 << 4)
#define GET_CL(x) (x & (1 << 4)) >> 4

//设置RDX相关的寄存器
#define SET_RDX_1(x) x |= (15 << 8)
#define SET_RDX_0(x) x &= ~(15 << 8)
#define GET_RDX(x) (x & (15 << 8)) >> 8

#define SET_EDX_1(x) x |= (7 << 8)
#define SET_EDX_0(x) x &= ~(7 << 8)
#define GET_EDX(x) (x & (7 << 8)) >> 8

#define SET_DX_1(x) x |= (3 << 8)
#define SET_DX_0(x) x &= ~(3 << 8)
#define GET_DX(x) (x & (3 << 8)) >> 8

#define SET_DH_1(x) x |= (1 << 9)
#define SET_DH_0(x) x &= ~(1 << 9)
#define GET_DH(x) (x & (1 << 9)) >> 9

#define SET_DL_1(x) x |= (1 << 8)
#define SET_DL_0(x) x &= ~(1 << 8)
#define GET_DL(x) (x & (1 << 8)) >> 8

//设置RBX相关的寄存器
#define SET_RBX_1(x) x |= (15 << 12)
#define SET_RBX_0(x) x &= ~(15 << 12)
#define GET_RBX(x) (x & (15 << 12)) >> 12

#define SET_EBX_1(x) x |= (7 << 12)
#define SET_EBX_0(x) x &= ~(7 << 12)
#define GET_EBX(x) (x & (7 << 12)) >> 12

#define SET_BX_1(x) x |= (3 << 12)
#define SET_BX_0(x) x &= ~(3 << 12)
#define GET_BX(x) (x & (3 << 12)) >> 12

#define SET_BH_1(x) x |= (1 << 13)
#define SET_BH_0(x) x &= ~(1 << 13)
#define GET_BH(x) (x & (1 << 13)) >> 13

#define SET_BL_1(x) x |= (1 << 13)
#define SET_BL_0(x) x &= ~(1 << 13)
#define GET_BL(x) (x & (1 << 13)) >> 13



#endif