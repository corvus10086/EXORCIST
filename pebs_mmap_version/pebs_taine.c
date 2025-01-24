/*
 * @Date: 2023-07-12 13:53:11
 * @LastEditors: liuchang chang.liu@zhejianglab.com
 * @LastEditTime: 2023-07-12 16:33:45
 * @FilePath: /pebs/src/pebs_taine.c
 */
#include "pebs_taine.h"

#include <linux/kernel.h>
#include <linux/kprobes.h>
#include <linux/module.h>

#include "/home/corvus/code/pebs_all/pebs_netlink_test/beaengine/include/beaengine/basic_types.h"
#include "/home/corvus/code/pebs_all/pebs_netlink_test/beaengine/src/BeaEngine.c"
#include "conf.h"
#include "pebs_message_send.h"
#include "pebs_taine_tool.h"

#define SIMULATION_STACK_SIZE 1024
#define MAX_SYMBOLIC_EXECUTION_DEEPTH 50
#define MAX_CYCLE_EXECUTION_DEEPTH 3
#define DIASM_CODE_SIZE 60

#define TAINE_ANALYZE_LIST_PID_MAX_NUM 1024
#define TAINE_PID_CONTAIN_ADDR_MAX_NUM 1024
typedef struct taine_addr {
  uint64_t start_addr;
  uint64_t end_addr;
  uint32_t num;
} taine_addr_t;

typedef struct taine_info {
  uint32_t pid;
  uint32_t num;
  uint32_t total_num;
  taine_addr_t addr[TAINE_PID_CONTAIN_ADDR_MAX_NUM];
} taine_info_t;
typedef struct taine_mem {
  taine_info_t *info;
  uint32_t num;
} taine_mem_t;

typedef struct disassemble_code_info {
  DISASM info_list[DIASM_CODE_SIZE];
  short size;
} disassemble_code_info_t;

taine_mem_t taine_mem_list;
char alloc_taine_analyze_list(void) {
  if (taine_mem_list.info == NULL) {
    taine_mem_list.info =
        vmalloc(TAINE_ANALYZE_LIST_PID_MAX_NUM * sizeof(taine_info_t));
    taine_mem_list.num = 0;
    if (taine_mem_list.info == NULL) {
      return 0;
    }
  }
  return 1;
}
void free_taine_analyze_list(void) {
  if (taine_mem_list.info != NULL) {
    vfree(taine_mem_list.info);
    taine_mem_list.num = 0;
    taine_mem_list.info = NULL;
  }
}
// pid
// return 10
char insert_and_search_analyze_list(uint32_t pid, uint64_t start_addr,
                                    uint64_t end_addr) {
  int pid_index = 0;
  int insert_index_by_pid = -1;
  int insert_index_by_num = 0;
  int min_mun = taine_mem_list.info[0].num;
  int pid_find = 0;
  int num_find_insert = 0;
  //pid
  for (; pid_index < taine_mem_list.num; ++pid_index) {
    //pid
    if ((taine_mem_list.info[pid_index].num != 0)) {
      if (taine_mem_list.info[pid_index].pid == 0) {
        if (insert_index_by_pid == -1) {
          insert_index_by_pid = pid_index;
        }
        continue;
      }
      struct pid *pid_struct = find_vpid(taine_mem_list.info[pid_index].pid);
      if (pid_struct != NULL) {
        struct task_struct *task = pid_task(pid_struct, PIDTYPE_PID);
        if (task == NULL) {
          if (insert_index_by_pid == -1) {
            insert_index_by_pid = pid_index;
          }
          continue;
        }
      }
      // pid
      else {
        if (insert_index_by_pid == -1) {
          insert_index_by_pid = pid_index;
        }
        continue;
      }
    }
    //pidnum
    if (num_find_insert == 0 && taine_mem_list.info[pid_index].total_num == 0) {
      insert_index_by_num = pid_index;
      num_find_insert = 1;
    }
    if (num_find_insert == 0 &&
        taine_mem_list.info[pid_index].total_num < min_mun) {
      min_mun = taine_mem_list.info[pid_index].total_num;
      insert_index_by_num = pid_index;
    }
    //pid
    if (taine_mem_list.info[pid_index].pid == pid) {
      taine_mem_list.info[pid_index].total_num++;
      pid_find = 1;
      int addr_index = 0;
      int addr_find = 0;
      taine_addr_t *tmp = taine_mem_list.info[pid_index].addr;
      int addr_min_num = tmp[0].num;
      int addr_space_find = 0;
      int addr_insert_num = 0;
      for (; addr_index < taine_mem_list.info[pid_index].num; ++addr_index) {
        if (tmp[addr_index].num == 0) {
          addr_space_find = 1;
          addr_insert_num = addr_index;
        }
        if (addr_space_find == 0 && tmp[addr_index].num < addr_min_num) {
          addr_min_num = tmp[addr_index].num;
          addr_insert_num = addr_index;
        }
        if (tmp[addr_index].start_addr == start_addr &&
            tmp[addr_index].end_addr == end_addr) {
          addr_find = 1;
          tmp[addr_index].num++;
          return 1;
        }
      }
      //addr
      if (addr_find == 0) {
        //
        if (taine_mem_list.info[pid_index].num <
            TAINE_PID_CONTAIN_ADDR_MAX_NUM) {
          tmp[taine_mem_list.info[pid_index].num].start_addr = start_addr;
          tmp[taine_mem_list.info[pid_index].num].end_addr = end_addr;
          tmp[taine_mem_list.info[pid_index].num].num = 1;
          taine_mem_list.info[pid_index].num++;
        }
        //
        else {
          tmp[addr_insert_num].start_addr = start_addr;
          tmp[addr_insert_num].end_addr = end_addr;
          tmp[addr_insert_num].num = 1;
        }
      }
      break;
    }
  }
  // pid
  if (pid_find == 0) {
    // pid
    if (insert_index_by_pid != -1) {
      taine_mem_list.info[insert_index_by_pid].pid = pid;
      taine_mem_list.info[insert_index_by_pid].num = 1;
      taine_mem_list.info[insert_index_by_pid].addr[0].start_addr = start_addr;
      taine_mem_list.info[insert_index_by_pid].addr[0].end_addr = end_addr;
      taine_mem_list.info[insert_index_by_pid].addr[0].num = 1;
    }
    // 
    else if (taine_mem_list.num < TAINE_ANALYZE_LIST_PID_MAX_NUM) {
      taine_mem_list.info[taine_mem_list.num].pid = pid;
      taine_mem_list.info[taine_mem_list.num].num = 1;
      taine_mem_list.info[taine_mem_list.num].addr[0].start_addr = start_addr;
      taine_mem_list.info[taine_mem_list.num].addr[0].end_addr = end_addr;
      taine_mem_list.info[taine_mem_list.num].addr[0].num = 1;
      taine_mem_list.num++;
    }
    // pid
    else if (insert_index_by_num != -1) {
      if (taine_mem_list.info[insert_index_by_num].pid == 12805) {
        printk(KERN_INFO "expulsion by num");
      }
      taine_mem_list.info[insert_index_by_num].pid = pid;
      taine_mem_list.info[insert_index_by_num].num = 1;
      taine_mem_list.info[insert_index_by_num].addr[0].start_addr = start_addr;
      taine_mem_list.info[insert_index_by_num].addr[0].end_addr = end_addr;
      taine_mem_list.info[insert_index_by_num].addr[0].num = 1;
    }
  }
  return 0;
}

char search_white_list(uint32_t pid, uint64_t start_addr, uint64_t end_addr) {
  //
  int pid_index = 0;
  for (; pid_index < 1024; ++pid_index) {
    if (taine_mem_list.info[pid_index].pid == pid) {
      int addr_index = 0;
      taine_addr_t *tmp = taine_mem_list.info[pid_index].addr;
      for (; addr_index < TAINE_PID_CONTAIN_ADDR_MAX_NUM; ++addr_index) {
        if (tmp->start_addr == start_addr && tmp->end_addr == end_addr) {
          tmp->num = tmp->num + 1;
          return 1;
        }
      }
      break;
    }
  }
  return 0;
}

char analyze_jmp_addr(OPTYPE *operator_type,
                      jmp_addr_analyze_result_t *jmp_addr_analyze_result,
                      register_simulation_t *register_info,
                      register_taines_map_t *register_map) {
  switch (operator_type->OpType) {
    case (0x4040000): {
      // 00001210h
      jmp_addr_analyze_result->taine_flag = 0;
      jmp_addr_analyze_result->unsure_flag = 0;
      jmp_addr_analyze_result->jmp_addr =
          convert_string_to_num(operator_type->OpMnemonic);
      return 1;
    }
    case (0x30000): {
      //
      //
      //
      jmp_addr_analyze_result->unsure_flag = 1;
      return 0;
    }
  }
  return 1;
}

//
char updata_register_taine_map(DISASM *info,
                               register_taines_map_t *register_map) {
  // start_addrregister_info
  // infocache miss
  // 
  // if ((info->Instruction.Category & 0x0000FFFF) != 1) {
  //   return 0;
  // }

  //
  // infos.Operand1
  //cache missmovx pop xchg

  // movx
  if (info->Instruction.Mnemonic[0] == 'm' &&
      info->Instruction.Mnemonic[1] == 'o' &&
      info->Instruction.Mnemonic[2] == 'v') {
    //
    //
    if (info->Operand1.OpType == 0x20000) {
      if (!(info->Operand1.Registers.type & GENERAL_REG)) {
        //
        return 0;
      }
      set_register_taine_by_num(info->Operand1.Registers.gpr, register_map);
      // set_register_taine(info->Operand1.OpMnemonic, register_map);
    } else if (info->Operand1.OpType == 0x30000) {
      //
      return 0;
    }
  }
  // cmp
  else if (info->Instruction.Mnemonic[0] == 'c' &&
           info->Instruction.Mnemonic[1] == 'm' &&
           info->Instruction.Mnemonic[2] == 'p') {
    rflag_set_taine(register_map);
  }
  //
  else if ((info->Instruction.Category & 0x0000ffff) == 2) {
    if (info->Operand1.OpType == 0x20000) {
      set_register_taine_by_num(info->Operand1.Registers.gpr, register_map);
    } else {
      return 0;
    }
  }
  // pop
  else if (info->Instruction.Mnemonic[0] == 'p' &&
           info->Instruction.Mnemonic[1] == 'o') {
    // pop
    set_register_taine_by_num(info->Operand1.Registers.gpr, register_map);
    // set_register_taine(info->Operand1.OpMnemonic, register_map);
  }
  // xchg
  //
  //cache miss 
  else {
    if (info->Operand1.OpType == 0x20000) {
      set_register_taine_by_num(info->Operand1.Registers.gpr, register_map);
      // set_register_taine(info->Operand1.OpMnemonic, register_map);
    } else {
      set_register_taine_by_num(info->Operand2.Registers.gpr, register_map);
      // set_register_taine(info->Operand2.OpMnemonic, register_map);
    }
  }
  //

  return 1;
}

//
char analyze_source_operator(OPTYPE *source_operator,
                             operator_analyze_result_t *operator_analyze_result,
                             register_simulation_t *register_info,
                             register_taines_map_t *register_map,
                             stack_simulation_t *stack_simulation_info,
                             heap_simulation_t *heap_simulation_info) {
  if (source_operator->OpType == 0x20000 &&
      source_operator->Registers.type & GENERAL_REG) {
    //
    //
    if (get_register_taine_by_num(source_operator->Registers.gpr,
                                  register_map) > 0) {
      operator_analyze_result->taine_flag = 1;
    }
    //
    if (get_register_unsure_by_num(source_operator->Registers.gpr,
                                   register_info) > 0) {
      operator_analyze_result->unsure_flag = 1;
      // int offset = get_register_value_by_num(source_operator->Registers.gpr,
      // register_info); char i = 1; int index = 0;

      // while(offset<256 && i!=0){
      //   i = register_info->symbolic[offset+i];
      //   operator_analyze_result->value_str[index] = i;
      //   ++index;
      // }

      // operator_analyze_result->value_str[index] = i;
      // operator_analyze_result->can_exprex_by_symbol = 1;
    } else {
      //
      operator_analyze_result->value =
          get_register_value_by_num(source_operator->Registers.gpr,
                                    register_info, source_operator->OpSize);
    }
  } else if (source_operator->OpType == 0x30000) {
    //
    analyze_memory_operator(
        operator_analyze_result, source_operator->Memory.BaseRegister,
        source_operator->Memory.IndexRegister, source_operator->Memory.Scale,
        source_operator->Memory.Displacement, source_operator->OpSize,
        register_info, register_map, stack_simulation_info,
        heap_simulation_info);

  } else if (source_operator->OpType == 0x8040000) {
    //
    operator_analyze_result->value =
        convert_string_to_num(source_operator->OpMnemonic);
    operator_analyze_result->taine_flag = 0;
    operator_analyze_result->unsure_flag = 0;
  } else {
    //
    return 0;
  }
  return 1;
}

//
char set_dest_operator(OPTYPE *dest_operator,
                       operator_analyze_result_t *operator_analyze_result,
                       register_simulation_t *register_info,
                       register_taines_map_t *register_map,
                       stack_simulation_t *stack_simulation_info,
                       heap_simulation_t *heap_simulation_info) {
  if (dest_operator->OpType == 0x20000 &&
      dest_operator->Registers.type & GENERAL_REG) {
    //
    //
    if (operator_analyze_result->taine_flag) {
      set_register_taine_by_num(dest_operator->Registers.gpr, register_map);
    } else {
      unset_register_taine_by_num(dest_operator->Registers.gpr, register_map);
    }
    //
    if (operator_analyze_result->unsure_flag) {
      //
      // set_register_value_by_num(dest_operator->Registers.gpr, 0,
      // operator_analyze_result->value_str, 20,register_info);
      return 0;
    } else {
      //
      set_register_value_by_num(dest_operator->Registers.gpr,
                                operator_analyze_result->value, NULL,
                                dest_operator->OpSize, register_info);
    }
  } else if (dest_operator->OpType == 0x30000) {
    //
    set_memory_operator(
        operator_analyze_result, dest_operator->Memory.BaseRegister,
        dest_operator->Memory.IndexRegister, dest_operator->Memory.Scale,
        dest_operator->Memory.Displacement, dest_operator->OpSize,
        register_info, register_map, stack_simulation_info,
        heap_simulation_info);
  } else {
    //
    return 0;
  }
  return 1;
}

//
// return 1 lock 
char symbolic_execution_one_step(DISASM *disassemble_info,
                                 register_simulation_t *register_info,
                                 register_taines_map_t *register_map,
                                 stack_simulation_t *stack_simulation_info,
                                 heap_simulation_t *heap_simulation_info) {
  if (disassemble_info->Prefix.LockPrefix > 0) {
    return 1;
  }
  //
  switch (disassemble_info->Instruction.Category & 0x0000ffff) {
    case 0: {
      // rdtscp endbr
      //
      break;
    }
    case 1: {
      // DATA_TRANSFER
      //
      // cbw cdqe cwd cdq cqo mov xchg push pop
      //
      if (disassemble_info->CompleteInstr[0] == 'c' &&
          disassemble_info->CompleteInstr[1] != 'm') {
        // cdqe cwd cdq cqo
        // cbw cwde
        exec_cwd_and(disassemble_info->CompleteInstr, register_info,
                     register_map);
      } else if (disassemble_info->CompleteInstr[0] == 'm' ||
                 (disassemble_info->CompleteInstr[0] == 'c' &&
                  disassemble_info->CompleteInstr[1] != 'm')) {
        // mov
        operator_analyze_result_t operator_analyze_result;
        memset(&operator_analyze_result, 0, sizeof(operator_analyze_result_t));
        //
        analyze_source_operator(&(disassemble_info->Operand2),
                                &operator_analyze_result, register_info,
                                register_map, stack_simulation_info,
                                heap_simulation_info);

        //movsxmovzx
        // movsx movzx
        if (disassemble_info->CompleteInstr[3] == 's') {
          operator_expend(&operator_analyze_result,
                          disassemble_info->Operand2.OpSize,
                          disassemble_info->Operand1.OpSize, 1);
        }
        //
        set_dest_operator(&(disassemble_info->Operand2),
                          &operator_analyze_result, register_info, register_map,
                          stack_simulation_info, heap_simulation_info);
      } else if (disassemble_info->CompleteInstr[0] == 'p' &&
                 disassemble_info->CompleteInstr[1] == 'u') {
        // push
        if (GET_RSP(register_info->registers_can_break_unsure)) {
          return 0;
        }
        operator_analyze_result_t operator_analyze_result;
        analyze_source_operator(&(disassemble_info->Operand2),
                                &operator_analyze_result, register_info,
                                register_map, stack_simulation_info,
                                heap_simulation_info);
        //
        set_memory_operator(&operator_analyze_result, 0x10, 0x10, 0, 0,
                            disassemble_info->Operand2.OpSize, register_info,
                            register_map, stack_simulation_info,
                            heap_simulation_info);

        register_info->register_info.RSP -=
            disassemble_info->Operand1.OpSize / 8;
      } else if (disassemble_info->CompleteInstr[0] == 'p' &&
                 disassemble_info->CompleteInstr[1] == 'o') {
        // pop op1
        if (GET_RSP(register_info->registers_can_break_unsure)) {
          return 0;
        }
        operator_analyze_result_t operator_analyze_result;
        //
        analyze_memory_operator(&operator_analyze_result, 0x10, 0x10, 0, 0,
                                disassemble_info->Operand1.OpSize,
                                register_info, register_map,
                                stack_simulation_info, heap_simulation_info);

        set_dest_operator(&(disassemble_info->Operand1),
                          &operator_analyze_result, register_info, register_map,
                          stack_simulation_info, heap_simulation_info);

        register_info->register_info.RSP +=
            disassemble_info->Operand1.OpSize / 8;
      } else if (disassemble_info->CompleteInstr[0] == 'x' &&
                 disassemble_info->CompleteInstr[1] == 'c') {
        // xchg
        //
        operator_analyze_result_t operator_analyze_result1;
        memset(&operator_analyze_result1, 0, sizeof(operator_analyze_result_t));
        analyze_source_operator(&(disassemble_info->Operand1),
                                &operator_analyze_result1, register_info,
                                register_map, stack_simulation_info,
                                heap_simulation_info);

        operator_analyze_result_t operator_analyze_result2;
        memset(&operator_analyze_result2, 0, sizeof(operator_analyze_result_t));
        analyze_source_operator(&(disassemble_info->Operand2),
                                &operator_analyze_result2, register_info,
                                register_map, stack_simulation_info,
                                heap_simulation_info);

        set_dest_operator(&(disassemble_info->Operand2),
                          &operator_analyze_result1, register_info,
                          register_map, stack_simulation_info,
                          heap_simulation_info);

        set_dest_operator(&(disassemble_info->Operand1),
                          &operator_analyze_result2, register_info,
                          register_map, stack_simulation_info,
                          heap_simulation_info);
      }
      break;
    }
    case 2: {
      // ARITHMETIC_INSTRUCTION
      //
      // cmp add sub mul div neg
      // op1  op2op3
      //1
      operator_analyze_result_t operator_analyze_result1;
      memset(&operator_analyze_result1, 0, sizeof(operator_analyze_result_t));
      analyze_source_operator(&(disassemble_info->Operand1),
                              &operator_analyze_result1, register_info,
                              register_map, stack_simulation_info,
                              heap_simulation_info);
      //2
      operator_analyze_result_t operator_analyze_result2;
      memset(&operator_analyze_result2, 0, sizeof(operator_analyze_result_t));
      analyze_source_operator(&(disassemble_info->Operand2),
                              &operator_analyze_result2, register_info,
                              register_map, stack_simulation_info,
                              heap_simulation_info);
      //3
      operator_analyze_result_t operator_analyze_result3;
      memset(&operator_analyze_result3, 0, sizeof(operator_analyze_result_t));
      // analyze_source_operator(&(disassemble_info->Operand3),&operator_analyze_result3,
      // register_info, register_map,stack_simulation_info,
      // heap_simulation_info);
      //4
      operator_analyze_result_t operator_analyze_result4;
      memset(&operator_analyze_result4, 0, sizeof(operator_analyze_result_t));

      // cmp
      if (disassemble_info->CompleteInstr[0] == 'c' &&
          disassemble_info->CompleteInstr[1] == 'm') {
        int length = disassemble_info->Operand1.OpSize;
        int index = 0;
        char flag = 0;
        while (disassemble_info->Operand1.OpMnemonic[index] != '\n' &&
               index < 10) {
          if (disassemble_info->Operand1.OpMnemonic[index] !=
              disassemble_info->Operand2.OpMnemonic[index]) {
            flag = 1;
            break;
          }
          ++index;
        }
        if ((!flag) && disassemble_info->Operand2.OpMnemonic[index] == '\n') {
          //
          memset(&operator_analyze_result1, 0,
                 sizeof(operator_analyze_result_t));
          memset(&operator_analyze_result2, 0,
                 sizeof(operator_analyze_result_t));
        }
        if (operator_analyze_result1.taine_flag ||
            operator_analyze_result2.taine_flag) {
          rflag_set_taine(register_map);
        } else {
          rflag_unset_taine(register_map);
        }
        //
        if (operator_analyze_result1.unsure_flag ||
            operator_analyze_result2.unsure_flag) {
          rflag_set_unsure(register_info);
          return 0;
        } else {
          rflag_unset_unsure(register_info);
        }
        sub_set_flag(&operator_analyze_result1, &operator_analyze_result2,
                     register_info, register_map, length);
      }
      // add
      else if (disassemble_info->CompleteInstr[0] == 'a' &&
               disassemble_info->CompleteInstr[1] == 'd' &&
               disassemble_info->CompleteInstr[1] == 'd') {
        int length = disassemble_info->Operand1.OpSize;
        compute_operator(&operator_analyze_result1, &operator_analyze_result2,
                         &operator_analyze_result3, &operator_analyze_result4,
                         length, 0, 2, register_info, register_map);
        set_dest_operator(&(disassemble_info->Operand1),
                          &operator_analyze_result3, register_info,
                          register_map, stack_simulation_info,
                          heap_simulation_info);
      }
      // adc
      else if (disassemble_info->CompleteInstr[0] == 'a' &&
               disassemble_info->CompleteInstr[1] == 'd' &&
               disassemble_info->CompleteInstr[2] == 'c') {
        int length = disassemble_info->Operand1.OpSize;
        compute_operator(&operator_analyze_result1, &operator_analyze_result2,
                         &operator_analyze_result3, &operator_analyze_result4,
                         length, 1, 2, register_info, register_map);
        set_dest_operator(&(disassemble_info->Operand1),
                          &operator_analyze_result3, register_info,
                          register_map, stack_simulation_info,
                          heap_simulation_info);
      }
      // inc
      else if (disassemble_info->CompleteInstr[0] == 'i' &&
               disassemble_info->CompleteInstr[1] == 'n' &&
               disassemble_info->CompleteInstr[2] == 'c') {
        int length = disassemble_info->Operand1.OpSize;
        compute_operator(&operator_analyze_result1, &operator_analyze_result2,
                         &operator_analyze_result3, &operator_analyze_result4,
                         length, 3, 2, register_info, register_map);
        set_dest_operator(&(disassemble_info->Operand1),
                          &operator_analyze_result3, register_info,
                          register_map, stack_simulation_info,
                          heap_simulation_info);
      }
      // sub
      else if (disassemble_info->CompleteInstr[0] == 's' &&
               disassemble_info->CompleteInstr[1] == 'u') {
        int index = 0;
        char flag = 0;
        while (disassemble_info->Operand1.OpMnemonic[index] != '\n' &&
               index < 10) {
          if (disassemble_info->Operand1.OpMnemonic[index] !=
              disassemble_info->Operand2.OpMnemonic[index]) {
            flag = 1;
            break;
          }
          ++index;
        }
        if ((!flag) && disassemble_info->Operand2.OpMnemonic[index] == '\n') {
          //
          memset(&operator_analyze_result1, 0,
                 sizeof(operator_analyze_result_t));
          memset(&operator_analyze_result2, 0,
                 sizeof(operator_analyze_result_t));
        }
        int length = disassemble_info->Operand1.OpSize;
        compute_operator(&operator_analyze_result1, &operator_analyze_result2,
                         &operator_analyze_result3, &operator_analyze_result4,
                         length, 4, 2, register_info, register_map);
        set_dest_operator(&(disassemble_info->Operand1),
                          &operator_analyze_result3, register_info,
                          register_map, stack_simulation_info,
                          heap_simulation_info);
      }
      // sbb
      else if (disassemble_info->CompleteInstr[0] == 's' &&
               disassemble_info->CompleteInstr[1] == 'b') {
        int length = disassemble_info->Operand1.OpSize;
        compute_operator(&operator_analyze_result1, &operator_analyze_result2,
                         &operator_analyze_result3, &operator_analyze_result4,
                         length, 5, 2, register_info, register_map);
        set_dest_operator(&(disassemble_info->Operand1),
                          &operator_analyze_result3, register_info,
                          register_map, stack_simulation_info,
                          heap_simulation_info);
      }
      // dec
      else if (disassemble_info->CompleteInstr[0] == 'd' &&
               disassemble_info->CompleteInstr[1] == 'e') {
        int length = disassemble_info->Operand1.OpSize;
        compute_operator(&operator_analyze_result1, &operator_analyze_result2,
                         &operator_analyze_result3, &operator_analyze_result4,
                         length, 6, 1, register_info, register_map);
        set_dest_operator(&(disassemble_info->Operand1),
                          &operator_analyze_result3, register_info,
                          register_map, stack_simulation_info,
                          heap_simulation_info);
      }
      // mul 
      else if (disassemble_info->CompleteInstr[0] == 'm' &&
               disassemble_info->CompleteInstr[1] == 'u') {
        operator_analyze_result2.taine_flag =
            get_register_taine_by_num(0x1, register_map);
        operator_analyze_result2.unsure_flag =
            get_register_unsure_by_num(0x1, register_info);
        operator_analyze_result2.value = get_register_value_by_num(
            0x1, register_info, disassemble_info->Operand1.OpSize);
        if (disassemble_info->Operand1.OpType == 0x8040000 &&
            convert_string_to_num(disassemble_info->Operand1.OpMnemonic) == 0) {
          //0
          operator_analyze_result1.taine_flag = 0;
          operator_analyze_result1.unsure_flag = 0;
          operator_analyze_result2.taine_flag = 0;
          operator_analyze_result2.unsure_flag = 0;
        }
        int length = disassemble_info->Operand1.OpSize;
        compute_operator(&operator_analyze_result1, &operator_analyze_result2,
                         &operator_analyze_result3, &operator_analyze_result4,
                         length, 7, 1, register_info, register_map);
        if (length == 8) {
          set_register_value_by_num(0x1, operator_analyze_result3.value, NULL,
                                    length * 2, register_info);
        } else {
          set_register_value_by_num(0x1, operator_analyze_result3.value, NULL,
                                    length, register_info);
          set_register_value_by_num(0x4, operator_analyze_result4.value, NULL,
                                    length, register_info);
        }
      }
      // div
      else if (disassemble_info->CompleteInstr[0] == 'd' &&
               disassemble_info->CompleteInstr[1] == 'i') {
        switch (disassemble_info->Operand1.OpSize) {
          case 8: {
            operator_analyze_result2.taine_flag =
                get_register_taine_by_num(0x1, register_map);
            operator_analyze_result2.unsure_flag =
                get_register_unsure_by_num(0x1, register_info);
            operator_analyze_result2.value =
                get_register_value_by_num(0x1, register_info, 16);
            break;
          }
          case 16: {
            operator_analyze_result2.taine_flag =
                get_register_taine_by_num(0x1, register_map) ||
                get_register_taine_by_num(0x4, register_map);
            operator_analyze_result2.unsure_flag =
                get_register_unsure_by_num(0x1, register_info) ||
                get_register_unsure_by_num(0x4, register_info);
            operator_analyze_result2.value =
                (get_register_value_by_num(0x4, register_info, 16) << 16) ^
                get_register_value_by_num(0x1, register_info, 16);
            break;
          }
          case 32: {
            operator_analyze_result2.taine_flag =
                get_register_taine_by_num(0x1, register_map) ||
                get_register_taine_by_num(0x4, register_map);
            operator_analyze_result2.unsure_flag =
                get_register_unsure_by_num(0x1, register_info) ||
                get_register_unsure_by_num(0x4, register_info);
            operator_analyze_result2.value =
                (get_register_value_by_num(0x4, register_info, 32) << 32) ^
                get_register_value_by_num(0x1, register_info, 32);
            break;
          }
          default: {
            return 0;
          }
        }
        int length = disassemble_info->Operand1.OpSize;
        compute_operator(&operator_analyze_result2, &operator_analyze_result1,
                         &operator_analyze_result3, &operator_analyze_result4,
                         length, 8, 1, register_info, register_map);
        if (length == 8) {
          set_register_value_by_num(0x1, operator_analyze_result3.value, NULL,
                                    length * 2, register_info);
        } else {
          set_register_value_by_num(0x1, operator_analyze_result3.value, NULL,
                                    length, register_info);
          set_register_value_by_num(0x4, operator_analyze_result4.value, NULL,
                                    length, register_info);
        }
      }
      // imul
      else if (disassemble_info->CompleteInstr[0] == 'i' &&
               disassemble_info->CompleteInstr[1] == 'm') {
        // todo 
        int op_num = 1;
        if (disassemble_info->Operand2.OpType != 0x10000) {
          ++op_num;
        }
        if (disassemble_info->Operand3.OpType != 0x10000) {
          ++op_num;
        }
        int length = disassemble_info->Operand1.OpSize;
        if (op_num == 1) {
          //1imul
          int length = disassemble_info->Operand1.OpSize;
          operator_analyze_result2.taine_flag =
              get_register_taine_by_num(0x1, register_map);
          operator_analyze_result2.unsure_flag =
              get_register_unsure_by_num(0x1, register_info);
          operator_analyze_result2.value =
              get_register_value_by_num(0x1, register_info, length);
          if (disassemble_info->Operand1.OpType == 0x8040000 &&
              convert_string_to_num(disassemble_info->Operand1.OpMnemonic) ==
                  0) {
            //0
            operator_analyze_result1.taine_flag = 0;
            operator_analyze_result1.unsure_flag = 0;
            operator_analyze_result2.taine_flag = 0;
            operator_analyze_result2.unsure_flag = 0;
          }

          compute_operator(&operator_analyze_result1, &operator_analyze_result2,
                           &operator_analyze_result3, &operator_analyze_result4,
                           length, 9, op_num, register_info, register_map);
          if (length == 8) {
            set_register_value_by_num(0x1, operator_analyze_result3.value, NULL,
                                      length * 2, register_info);
          } else {
            set_register_value_by_num(0x1, operator_analyze_result3.value, NULL,
                                      length, register_info);
            set_register_value_by_num(0x4, operator_analyze_result4.value, NULL,
                                      length, register_info);
          }
        } else if (op_num == 2) {
          //2imul
          if (disassemble_info->Operand2.OpType == 0x8040000 &&
              convert_string_to_num(disassemble_info->Operand2.OpMnemonic) ==
                  0) {
            //0
            operator_analyze_result1.taine_flag = 0;
            operator_analyze_result1.unsure_flag = 0;
            operator_analyze_result2.taine_flag = 0;
            operator_analyze_result2.unsure_flag = 0;
          }
          compute_operator(&operator_analyze_result1, &operator_analyze_result2,
                           &operator_analyze_result3, &operator_analyze_result4,
                           length, 9, op_num, register_info, register_map);
          set_dest_operator(&(disassemble_info->Operand1),
                            &operator_analyze_result3, register_info,
                            register_map, stack_simulation_info,
                            heap_simulation_info);
        } else if (op_num == 3) {
          //imul
          analyze_source_operator(&(disassemble_info->Operand3),
                                  &operator_analyze_result3, register_info,
                                  register_map, stack_simulation_info,
                                  heap_simulation_info);
          if ((disassemble_info->Operand3.OpType == 0x8040000) &&
              (operator_analyze_result3.value == 0)) {
            //0
            operator_analyze_result2.taine_flag = 0;
            operator_analyze_result2.unsure_flag = 0;
          }
          compute_operator(&operator_analyze_result2, &operator_analyze_result3,
                           &operator_analyze_result4, &operator_analyze_result1,
                           length, 9, op_num, register_info, register_map);
          set_dest_operator(&(disassemble_info->Operand1),
                            &operator_analyze_result4, register_info,
                            register_map, stack_simulation_info,
                            heap_simulation_info);
        }
      }
      // idiv
      else if (disassemble_info->CompleteInstr[0] == 'i' &&
               disassemble_info->CompleteInstr[1] == 'd') {
        int length = disassemble_info->Operand1.OpSize;
        compute_operator(&operator_analyze_result1, &operator_analyze_result2,
                         &operator_analyze_result3, &operator_analyze_result4,
                         length, 10, 1, register_info, register_map);
        if (length == 8) {
          set_register_value_by_num(0x1, operator_analyze_result3.value, NULL,
                                    length * 2, register_info);
        } else {
          set_register_value_by_num(0x1, operator_analyze_result3.value, NULL,
                                    length, register_info);
          set_register_value_by_num(0x4, operator_analyze_result4.value, NULL,
                                    length, register_info);
        }
      }
      // neg
      else if (disassemble_info->CompleteInstr[0] == 'n' &&
               disassemble_info->CompleteInstr[1] == 'e') {
        int length = disassemble_info->Operand1.OpSize;

        memset(&operator_analyze_result2, 0, sizeof(operator_analyze_result_t));

        compute_operator(&operator_analyze_result2, &operator_analyze_result1,
                         &operator_analyze_result3, &operator_analyze_result4,
                         length, 4, 2, register_info, register_map);
        set_dest_operator(&(disassemble_info->Operand1),
                          &operator_analyze_result3, register_info,
                          register_map, stack_simulation_info,
                          heap_simulation_info);
      }
      break;
    }
    case 3: {
      // LOGICAL_INSTRUCTION
      //
      operator_analyze_result_t operator_analyze_result1;
      operator_analyze_result_t operator_analyze_result2;
      operator_analyze_result_t operator_analyze_result3;
      memset(&operator_analyze_result1, 0, sizeof(operator_analyze_result_t));
      analyze_source_operator(&(disassemble_info->Operand1),
                              &operator_analyze_result1, register_info,
                              register_map, stack_simulation_info,
                              heap_simulation_info);
      //2
      memset(&operator_analyze_result2, 0, sizeof(operator_analyze_result_t));
      analyze_source_operator(&(disassemble_info->Operand2),
                              &operator_analyze_result2, register_info,
                              register_map, stack_simulation_info,
                              heap_simulation_info);
      memset(&operator_analyze_result3, 0, sizeof(operator_analyze_result_t));
      // not
      if (disassemble_info->Instruction.Mnemonic[0] == 'n') {
        logic_al_operator(&operator_analyze_result1, &operator_analyze_result2,
                          &operator_analyze_result3,
                          disassemble_info->Operand1.OpSize, 0, register_info,
                          register_map);
        set_dest_operator(&(disassemble_info->Operand1),
                          &operator_analyze_result3, register_info,
                          register_map, stack_simulation_info,
                          heap_simulation_info);
      }
      // and
      if (disassemble_info->Instruction.Mnemonic[0] == 'a') {
        int length = disassemble_info->Operand1.OpSize >
                             disassemble_info->Operand2.OpSize
                         ? disassemble_info->Operand1.OpSize
                         : disassemble_info->Operand2.OpSize;
        logic_al_operator(&operator_analyze_result1, &operator_analyze_result2,
                          &operator_analyze_result3, length, 1, register_info,
                          register_map);
        set_dest_operator(&(disassemble_info->Operand1),
                          &operator_analyze_result3, register_info,
                          register_map, stack_simulation_info,
                          heap_simulation_info);
      }
      // or
      if (disassemble_info->Instruction.Mnemonic[0] == 'o') {
        int length = disassemble_info->Operand1.OpSize >
                             disassemble_info->Operand2.OpSize
                         ? disassemble_info->Operand1.OpSize
                         : disassemble_info->Operand2.OpSize;
        logic_al_operator(&operator_analyze_result1, &operator_analyze_result2,
                          &operator_analyze_result3, length, 2, register_info,
                          register_map);
        set_dest_operator(&(disassemble_info->Operand1),
                          &operator_analyze_result3, register_info,
                          register_map, stack_simulation_info,
                          heap_simulation_info);
      }
      // xor
      if (disassemble_info->Instruction.Mnemonic[0] == 'o') {
        int index = 0;
        char flag = 0;
        while (disassemble_info->Operand1.OpMnemonic[index] != '\n' &&
               index < 10) {
          if (disassemble_info->Operand1.OpMnemonic[index] !=
              disassemble_info->Operand2.OpMnemonic[index]) {
            flag = 1;
            break;
          }
          ++index;
        }
        if ((!flag) && disassemble_info->Operand2.OpMnemonic[index] == '\n') {
          //
          memset(&operator_analyze_result1, 0,
                 sizeof(operator_analyze_result_t));
          memset(&operator_analyze_result2, 0,
                 sizeof(operator_analyze_result_t));
        }
        int length = disassemble_info->Operand1.OpSize;
        logic_al_operator(&operator_analyze_result1, &operator_analyze_result2,
                          &operator_analyze_result3, length, 3, register_info,
                          register_map);
        set_dest_operator(&(disassemble_info->Operand1),
                          &operator_analyze_result3, register_info,
                          register_map, stack_simulation_info,
                          heap_simulation_info);
      }
      break;
    }
    case 4: {
      // SHIFT_ROTATE
      // SHL SHR SAL SAR ROL ROR RCL RCR
      operator_analyze_result_t operator_analyze_result1;
      memset(&operator_analyze_result1, 0, sizeof(operator_analyze_result_t));
      analyze_source_operator(&(disassemble_info->Operand1),
                              &operator_analyze_result1, register_info,
                              register_map, stack_simulation_info,
                              heap_simulation_info);
      //2
      operator_analyze_result_t operator_analyze_result2;
      memset(&operator_analyze_result2, 0, sizeof(operator_analyze_result_t));
      analyze_source_operator(&(disassemble_info->Operand2),
                              &operator_analyze_result2, register_info,
                              register_map, stack_simulation_info,
                              heap_simulation_info);
      operator_analyze_result_t operator_analyze_result3;
      memset(&operator_analyze_result3, 0, sizeof(operator_analyze_result_t));

      {
        // shl
        if (disassemble_info->Instruction.Mnemonic[0] == 's' &&
            disassemble_info->Instruction.Mnemonic[0] == 'h' &&
            disassemble_info->Instruction.Mnemonic[0] == 'l') {
          logic_shift_operator(
              &operator_analyze_result1, &operator_analyze_result2,
              &operator_analyze_result3, disassemble_info->Operand1.OpSize, 0,
              register_info, register_map);
          set_dest_operator(&(disassemble_info->Operand1),
                            &operator_analyze_result3, register_info,
                            register_map, stack_simulation_info,
                            heap_simulation_info);
        }
        // shr
        else if (disassemble_info->Instruction.Mnemonic[0] == 's' &&
                 disassemble_info->Instruction.Mnemonic[0] == 'h' &&
                 disassemble_info->Instruction.Mnemonic[0] == 'r') {
          logic_shift_operator(
              &operator_analyze_result1, &operator_analyze_result2,
              &operator_analyze_result3, disassemble_info->Operand1.OpSize, 1,
              register_info, register_map);
          set_dest_operator(&(disassemble_info->Operand1),
                            &operator_analyze_result3, register_info,
                            register_map, stack_simulation_info,
                            heap_simulation_info);
        }
        // sal
        else if (disassemble_info->Instruction.Mnemonic[0] == 's' &&
                 disassemble_info->Instruction.Mnemonic[0] == 'a' &&
                 disassemble_info->Instruction.Mnemonic[0] == 'l') {
          logic_shift_operator(
              &operator_analyze_result1, &operator_analyze_result2,
              &operator_analyze_result3, disassemble_info->Operand1.OpSize, 2,
              register_info, register_map);
          set_dest_operator(&(disassemble_info->Operand1),
                            &operator_analyze_result3, register_info,
                            register_map, stack_simulation_info,
                            heap_simulation_info);
        }
        // sar
        else if (disassemble_info->Instruction.Mnemonic[0] == 's' &&
                 disassemble_info->Instruction.Mnemonic[0] == 'a' &&
                 disassemble_info->Instruction.Mnemonic[0] == 'r') {
          logic_shift_operator(
              &operator_analyze_result1, &operator_analyze_result2,
              &operator_analyze_result3, disassemble_info->Operand1.OpSize, 3,
              register_info, register_map);
          set_dest_operator(&(disassemble_info->Operand1),
                            &operator_analyze_result3, register_info,
                            register_map, stack_simulation_info,
                            heap_simulation_info);
        }
        // rol
        else if (disassemble_info->Instruction.Mnemonic[0] == 'r' &&
                 disassemble_info->Instruction.Mnemonic[0] == 'o' &&
                 disassemble_info->Instruction.Mnemonic[0] == 'l') {
          logic_shift_operator(
              &operator_analyze_result1, &operator_analyze_result2,
              &operator_analyze_result3, disassemble_info->Operand1.OpSize, 4,
              register_info, register_map);
          set_dest_operator(&(disassemble_info->Operand1),
                            &operator_analyze_result3, register_info,
                            register_map, stack_simulation_info,
                            heap_simulation_info);
        }
        // ror
        else if (disassemble_info->Instruction.Mnemonic[0] == 'r' &&
                 disassemble_info->Instruction.Mnemonic[0] == 'o' &&
                 disassemble_info->Instruction.Mnemonic[0] == 'r') {
          logic_shift_operator(
              &operator_analyze_result1, &operator_analyze_result2,
              &operator_analyze_result3, disassemble_info->Operand1.OpSize, 5,
              register_info, register_map);
          set_dest_operator(&(disassemble_info->Operand1),
                            &operator_analyze_result3, register_info,
                            register_map, stack_simulation_info,
                            heap_simulation_info);
        }
        // rcl
        else if (disassemble_info->Instruction.Mnemonic[0] == 'r' &&
                 disassemble_info->Instruction.Mnemonic[0] == 'c' &&
                 disassemble_info->Instruction.Mnemonic[0] == 'l') {
          logic_shift_operator(
              &operator_analyze_result1, &operator_analyze_result2,
              &operator_analyze_result3, disassemble_info->Operand1.OpSize, 6,
              register_info, register_map);
          set_dest_operator(&(disassemble_info->Operand1),
                            &operator_analyze_result3, register_info,
                            register_map, stack_simulation_info,
                            heap_simulation_info);
        }
        // rcr
        else if (disassemble_info->Instruction.Mnemonic[0] == 'r' &&
                 disassemble_info->Instruction.Mnemonic[0] == 'c' &&
                 disassemble_info->Instruction.Mnemonic[0] == 'r') {
          logic_shift_operator(
              &operator_analyze_result1, &operator_analyze_result2,
              &operator_analyze_result3, disassemble_info->Operand1.OpSize, 7,
              register_info, register_map);
          set_dest_operator(&(disassemble_info->Operand1),
                            &operator_analyze_result3, register_info,
                            register_map, stack_simulation_info,
                            heap_simulation_info);
        }
      }

      break;
    }
    case 5: {
      // BIT_BYTE
      // test sete
      int op_size = disassemble_info->Operand1.OpSize;
      // test
      if (disassemble_info->CompleteInstr[0] == 't' &&
          disassemble_info->CompleteInstr[1] == 'e') {
        //1
        operator_analyze_result_t operator_analyze_result1;
        //2
        operator_analyze_result_t operator_analyze_result2;
        memset(&operator_analyze_result1, 0, sizeof(operator_analyze_result_t));
        analyze_source_operator(&(disassemble_info->Operand1),
                                &operator_analyze_result1, register_info,
                                register_map, stack_simulation_info,
                                heap_simulation_info);
        memset(&operator_analyze_result2, 0, sizeof(operator_analyze_result_t));
        analyze_source_operator(&(disassemble_info->Operand2),
                                &operator_analyze_result2, register_info,
                                register_map, stack_simulation_info,
                                heap_simulation_info);

        test_set_flag(&operator_analyze_result1, &operator_analyze_result2,
                      op_size, register_info, register_map);
      }
      // setcc
      if (disassemble_info->CompleteInstr[0] == 's' &&
          disassemble_info->CompleteInstr[1] == 'e' &&
          disassemble_info->CompleteInstr[2] == 't') {
        //1
        operator_analyze_result_t operator_analyze_result1;
        memset(&operator_analyze_result1, 0, sizeof(operator_analyze_result_t));
        setcc_analyze(disassemble_info->Instruction.Mnemonic,
                      &operator_analyze_result1, register_info, register_map);
        set_dest_operator(&(disassemble_info->Operand1),
                          &operator_analyze_result1, register_info,
                          register_map, stack_simulation_info,
                          heap_simulation_info);
      }
      break;
    }
    case 10: {
      // FLAG_CONTROL_INSTRUCTION
      flag_control_analyze(disassemble_info->Instruction.Mnemonic,
                           register_info, register_map);
      break;
    }
    case 12: {
      // MISCELLANEOUS_INSTRUCTION
      // lea nop
      if (disassemble_info->CompleteInstr[0] == 'l' &&
          disassemble_info->CompleteInstr[1] == 'e') {
        operator_analyze_result_t operator_analyze_result;
        memset(&operator_analyze_result, 0, sizeof(operator_analyze_result_t));
        if (disassemble_info->Operand2.OpType == 0x4030000) {
          uint64_t value =
              convert_string_to_num(disassemble_info->Operand2.OpMnemonic);
          set_register_value_by_num(
              disassemble_info->Operand1.Memory.IndexRegister, value, NULL,
              disassemble_info->Operand1.OpSize, register_info);
          return 0;
        } else {
          if (get_register_taine_by_num(
                  disassemble_info->Operand2.Memory.BaseRegister,
                  register_map) > 0 ||
              (get_register_taine_by_num(
                   disassemble_info->Operand2.Memory.IndexRegister,
                   register_map) > 0 &&
               disassemble_info->Operand2.Memory.Scale != 0)) {
            //
            set_register_taine_by_num(
                disassemble_info->Operand1.Memory.IndexRegister, register_map);
          }
          if (get_register_unsure_by_num(
                  disassemble_info->Operand2.Memory.BaseRegister,
                  register_info) > 0 ||
              (get_register_unsure_by_num(
                   disassemble_info->Operand2.Memory.IndexRegister,
                   register_info) > 0 &&
               disassemble_info->Operand2.Memory.Scale != 0)) {
            //
            set_register_unsure_by_num(
                disassemble_info->Operand1.Memory.IndexRegister, register_info);
            return 0;
          } else {
            //
            uint64_t value =
                get_register_value_by_num(
                    disassemble_info->Operand2.Memory.BaseRegister,
                    register_info, 64) +
                get_register_value_by_num(
                    disassemble_info->Operand2.Memory.IndexRegister,
                    register_info, 64) *
                    disassemble_info->Operand2.Memory.Scale +
                disassemble_info->Operand2.Memory.Displacement;
            set_register_value_by_num(
                disassemble_info->Operand1.Memory.IndexRegister, value, NULL,
                disassemble_info->Operand1.OpSize, register_info);
          }
        }
      }
      break;
    }
  }

  return -1;
}

//
void free_simulation_info(stack_simulation_t *stack, heap_simulation_t *heap,
                          register_simulation_t *register_info) {
  if (stack->simulation_stack_info != NULL) {
    kvfree(stack->simulation_stack_info);
    stack->simulation_stack_info = NULL;
  }
  if (stack->simulation_stack_set_info != NULL) {
    kvfree(stack->simulation_stack_set_info);
    stack->simulation_stack_set_info = NULL;
  }
  if (stack->simulation_stack_taines_info != NULL) {
    kvfree(stack->simulation_stack_taines_info);
    stack->simulation_stack_taines_info = NULL;
  }
  if (stack->simulation_stack_unsure_info != NULL) {
    kvfree(stack->simulation_stack_unsure_info);
    stack->simulation_stack_unsure_info = NULL;
  }
  if (heap->address != NULL) {
    kvfree(heap->address);
    heap->address = NULL;
  }
  if (heap->taine != NULL) {
    kvfree(heap->taine);
    heap->taine = NULL;
  }
  if (heap->unsure != NULL) {
    kvfree(heap->unsure);
    heap->unsure = NULL;
  }
  if (heap->value != NULL) {
    kvfree(heap->value);
    heap->value = NULL;
  }
  if (register_info->symbolic != NULL) {
    kvfree(register_info->symbolic);
    register_info->symbolic = NULL;
  }
}

//
//
char copy_simulation_info(stack_simulation_t *source_stack,
                          stack_simulation_t *dest_stack,
                          heap_simulation_t *source_heap,
                          heap_simulation_t *dest_heap,
                          register_simulation_t *source_register,
                          register_simulation_t *dest_register) {
  memcpy(dest_stack, source_stack, sizeof(stack_simulation_t));
  dest_stack->simulation_stack_info = NULL;
  dest_stack->simulation_stack_taines_info = NULL;
  dest_stack->simulation_stack_set_info = NULL;
  dest_stack->simulation_stack_unsure_info = NULL;
  // 
  dest_stack->simulation_stack_info =
      kvmalloc(SIMULATION_STACK_SIZE, GFP_KERNEL);
  if (dest_stack->simulation_stack_info == NULL) {
    // printk(KERN_ERR "Failed to allocate memory.....\n");
    free_simulation_info(dest_stack, dest_heap, dest_register);
    return 0;
  }
  memcpy(dest_stack->simulation_stack_info, source_stack->simulation_stack_info,
         SIMULATION_STACK_SIZE);

  //
  dest_stack->simulation_stack_set_info =
      kvmalloc(SIMULATION_STACK_SIZE / 8, GFP_KERNEL);
  if (dest_stack->simulation_stack_set_info == NULL) {
    // printk(KERN_ERR "Failed to allocate memory.....\n");
    free_simulation_info(dest_stack, dest_heap, dest_register);
    return 0;
  }
  memcpy(dest_stack->simulation_stack_set_info,
         source_stack->simulation_stack_set_info, SIMULATION_STACK_SIZE / 8);

  // 
  dest_stack->simulation_stack_taines_info =
      kvmalloc(SIMULATION_STACK_SIZE / 8, GFP_KERNEL);
  if (dest_stack->simulation_stack_taines_info == NULL) {
    // printk(KERN_ERR "Failed to allocate memory.....\n");
    free_simulation_info(dest_stack, dest_heap, dest_register);
    return 0;
  }
  memcpy(dest_stack->simulation_stack_taines_info,
         source_stack->simulation_stack_taines_info, SIMULATION_STACK_SIZE / 8);

  //
  dest_stack->simulation_stack_unsure_info =
      kvmalloc(SIMULATION_STACK_SIZE / 8, GFP_KERNEL);
  if (dest_stack->simulation_stack_unsure_info == NULL) {
    // printk(KERN_ERR "Failed to allocate memory.....\n");
    free_simulation_info(dest_stack, dest_heap, dest_register);
    return 0;
  }
  memcpy(dest_stack->simulation_stack_unsure_info,
         source_stack->simulation_stack_unsure_info, SIMULATION_STACK_SIZE / 8);

  memcpy(dest_heap, source_heap, sizeof(heap_simulation_t));
  dest_heap->address = NULL;
  dest_heap->value = NULL;
  dest_heap->taine = NULL;
  dest_heap->unsure = NULL;
  //
  dest_heap->address = kvmalloc(128 * sizeof(uint64_t), GFP_KERNEL);
  if (dest_heap->address == NULL) {
    // printk(KERN_ERR "Failed to allocate memory.....\n");
    free_simulation_info(dest_stack, dest_heap, dest_register);
    return 0;
  }
  memcpy(dest_heap->address, source_heap->address, 128 * sizeof(uint64_t));

  //
  dest_heap->value = kvmalloc(128 * sizeof(uint64_t), GFP_KERNEL);
  if (dest_heap->value == NULL) {
    // printk(KERN_ERR "Failed to allocate memory.....\n");
    free_simulation_info(dest_stack, dest_heap, dest_register);
    return 0;
  }
  memcpy(dest_heap->value, source_heap->value, 128 * sizeof(uint64_t));
  //
  dest_heap->taine = kvmalloc(128 * sizeof(char), GFP_KERNEL);
  if (dest_heap->taine == NULL) {
    // printk(KERN_ERR "Failed to allocate memory.....\n");
    free_simulation_info(dest_stack, dest_heap, dest_register);
    return 0;
  }
  memcpy(dest_heap->taine, source_heap->taine, 128 * sizeof(char));

  dest_heap->unsure = kvmalloc(128 * sizeof(char), GFP_KERNEL);
  if (dest_heap->unsure == NULL) {
    // printk(KERN_ERR "Failed to allocate memory.....\n");
    free_simulation_info(dest_stack, dest_heap, dest_register);
    return 0;
  }
  memcpy(dest_heap->unsure, source_heap->unsure, 128 * sizeof(char));

  memcpy(dest_register, source_register, sizeof(register_simulation_t));
  dest_register->symbolic = NULL;
  dest_register->symbolic = kvmalloc(512 * sizeof(char), GFP_KERNEL);
  if (dest_register->symbolic == NULL) {
    // printk(KERN_ERR "Failed to allocate memory.....\n");
    free_simulation_info(dest_stack, dest_heap, dest_register);
    return 0;
  }
  memcpy(dest_register->symbolic, source_register->symbolic,
         512 * sizeof(char));

  return 1;
}

char analyze_address_to_index(uint64_t address,
                              disassemble_code_info_t *disassemble_info) {
  int i = 0;
  for (; i < disassemble_info->size; i++) {
    if (disassemble_info->info_list[i].VirtualAddr == address) {
      return i;
    }
  }
  return -1;
}

char symbolic_execution(int64_t start_addr, int64_t end_addr, short start_index,
                        short deepth, short cycle,
                        disassemble_code_info_t *disassemble_info,
                        register_simulation_t *register_info,
                        register_taines_map_t *register_map,
                        stack_simulation_t *stack_simulation_info,
                        heap_simulation_t *heap_simulation_info) {
  // todo
  //
  //
  //
  //
  //
  //10
  int index = start_index;
  int limitaition = deepth;
  while (limitaition < MAX_SYMBOLIC_EXECUTION_DEEPTH &&
         index < disassemble_info->size && index >= 0 &&
         cycle < MAX_CYCLE_EXECUTION_DEEPTH) {
    //
    //
    if ((disassemble_info->info_list[index].Instruction.Category &
         0x0000FFFF) != 6) {
      //
      //
      char res = symbolic_execution_one_step(
          &(disassemble_info->info_list[index]), register_info, register_map,
          stack_simulation_info, heap_simulation_info);
      if (res == 1) {
        return 0;
      }
      ++index;
      ++limitaition;
    } else {
      //
      //
      if (index == disassemble_info->size - 1) {
        //

        operator_analyze_result_t jmp_addr_analyze_result;
        analyze_source_operator(&(disassemble_info->info_list[index].Operand1),
                                &jmp_addr_analyze_result, register_info,
                                register_map, stack_simulation_info,
                                heap_simulation_info);
        if (judge_attack(
                disassemble_info->info_list[index].Instruction.BranchType,
                register_map, &jmp_addr_analyze_result)) {
          //
          return 1;
        } else {
          //
          return 0;
        }
        return 0;
      } else {
        //
        switch (analyze_branch_instruction(
            disassemble_info->info_list[index].Instruction.BranchType,
            register_info)) {
          case -1: {
            //
            //
            //
            ++index;
            ++limitaition;
            symbolic_execution_one_step(
                &(disassemble_info->info_list[index]), register_info,
                register_map, stack_simulation_info, heap_simulation_info);
            break;
          }
          case 0: {
            //
            //
            //
            register_simulation_t local_register_info;

            register_taines_map_t local_register_map;
            memcpy(&local_register_map, register_map,
                   sizeof(register_taines_map_t));

            stack_simulation_t local_stack_simulation_info;
            heap_simulation_t local_heap_simulation_info;

            if (copy_simulation_info(
                    stack_simulation_info, &local_stack_simulation_info,
                    heap_simulation_info, &local_heap_simulation_info,
                    register_info, &local_register_info) == 0) {
              //
              free_simulation_info(&local_stack_simulation_info,
                                   &local_heap_simulation_info, register_info);
              return 0;
            }
            //
            // todo
            operator_analyze_result_t jmp_addr_analyze_result;
            memset(&jmp_addr_analyze_result, 0,
                   sizeof(operator_analyze_result_t));
            analyze_source_operator(
                &(disassemble_info->info_list[index].Operand1),
                &jmp_addr_analyze_result, register_info, register_map,
                stack_simulation_info, heap_simulation_info);

            if (jmp_addr_analyze_result.unsure_flag ||
                jmp_addr_analyze_result.taine_flag) {
              return 0;
            }
            if (jmp_addr_analyze_result.value < start_addr ||
                jmp_addr_analyze_result.value > end_addr) {
              return 0;
            }
            int new_index = analyze_address_to_index(
                jmp_addr_analyze_result.value, disassemble_info);
            if (new_index < 0) {
              //
              return 0;
            }
            if (new_index > index) {
              //
              if (symbolic_execution(start_addr, end_addr, new_index,
                                     limitaition + 1, cycle, disassemble_info,
                                     &local_register_info, &local_register_map,
                                     &local_stack_simulation_info,
                                     &local_heap_simulation_info)) {
                free_simulation_info(&local_stack_simulation_info,
                                     &local_heap_simulation_info,
                                     register_info);
                return 1;
              } else {
                ++index;
                ++limitaition;
                free_simulation_info(&local_stack_simulation_info,
                                     &local_heap_simulation_info,
                                     register_info);
                continue;
              }
            } else {
              //
              //
              if (symbolic_execution(start_addr, end_addr, index + 1,
                                     limitaition, cycle, disassemble_info,
                                     &local_register_info, &local_register_map,
                                     &local_stack_simulation_info,
                                     &local_heap_simulation_info)) {
                free_simulation_info(&local_stack_simulation_info,
                                     &local_heap_simulation_info,
                                     register_info);
                return 1;
              }
              //
              if (symbolic_execution(
                      start_addr, end_addr, new_index, limitaition + 1,
                      cycle + 1, disassemble_info, &local_register_info,
                      &local_register_map, &local_stack_simulation_info,
                      &local_heap_simulation_info)) {
                free_simulation_info(&local_stack_simulation_info,
                                     &local_heap_simulation_info,
                                     register_info);
                return 1;
              }
            }
            return 0;
          }
          case 1: {
            //
            //
            //
            operator_analyze_result_t jmp_addr_analyze_result;
            memset(&jmp_addr_analyze_result, 0,
                   sizeof(operator_analyze_result_t));
            analyze_source_operator(
                &(disassemble_info->info_list[index].Operand1),
                &jmp_addr_analyze_result, register_info, register_map,
                stack_simulation_info, heap_simulation_info);

            if (jmp_addr_analyze_result.unsure_flag ||
                jmp_addr_analyze_result.taine_flag) {
              return 0;
            }
            if (jmp_addr_analyze_result.value < start_addr ||
                jmp_addr_analyze_result.value > end_addr) {
              return 0;
            }
            int new_index = analyze_address_to_index(
                jmp_addr_analyze_result.value, disassemble_info);
            if (new_index > 0) {
              // new_index
              // index = new_index+1;
              index = new_index;
              ++limitaition;
              continue;
            } else {
              return 0;
            }
          }
          case 2: {
            // call 
            //return 0
            return 0;
          }
          case 3: {
            // ret 
            return 0;
          }
        }
      }
    }
  }

  return 0;
}

char symbolic_execution_prepare(int64_t start_addr, int64_t end_addr,
                                disassemble_code_info_t *disassemble_info,
                                register_info_t *start_info,
                                register_info_t *end_info) {
  // 
  register_taines_map_t register_map;
  (void)memset(&register_map, 0, sizeof(register_taines_map_t));

  //
  register_simulation_t register_info;
  (void)memset(&register_info, 0, sizeof(register_simulation_t));
  memcpy(&(register_info.register_info), start_info, sizeof(register_info_t));
  register_info.symbolic = kvmalloc(512, GFP_KERNEL);
  if (register_info.symbolic == NULL) {
    // printk(KERN_ERR "Failed to allocate memory.....\n");
    return 0;
  }

  //
  stack_simulation_t stack_simulation_info;
  heap_simulation_t heap_simulation_info;

  (void)memset(&stack_simulation_info, 0, sizeof(stack_simulation_t));
  // 
  stack_simulation_info.simulation_stack_info =
      kvmalloc(SIMULATION_STACK_SIZE, GFP_KERNEL);
  if (stack_simulation_info.simulation_stack_info == NULL) {
    // printk(KERN_ERR "Failed to allocate memory.....\n");
    free_simulation_info(&stack_simulation_info, &heap_simulation_info,
                         &register_info);
    return 0;
  }
  stack_simulation_info.rbp_offset = SIMULATION_STACK_SIZE / 2;
  stack_simulation_info.rsp_offset =
      SIMULATION_STACK_SIZE / 2 - (start_info->RBP - start_info->RSP);

  // 
  stack_simulation_info.simulation_stack_taines_info =
      kvmalloc(SIMULATION_STACK_SIZE / 8, GFP_KERNEL);
  if (stack_simulation_info.simulation_stack_taines_info == NULL) {
    // printk(KERN_ERR "Failed to allocate memory.....\n");
    free_simulation_info(&stack_simulation_info, &heap_simulation_info,
                         &register_info);
    return 0;
  }
  //
  stack_simulation_info.simulation_stack_set_info =
      kvmalloc(SIMULATION_STACK_SIZE / 8, GFP_KERNEL);
  if (stack_simulation_info.simulation_stack_set_info == NULL) {
    // printk(KERN_ERR "Failed to allocate memory.....\n");
    free_simulation_info(&stack_simulation_info, &heap_simulation_info,
                         &register_info);
    return 0;
  }
  //
  stack_simulation_info.simulation_stack_unsure_info =
      kvmalloc(SIMULATION_STACK_SIZE / 8, GFP_KERNEL);
  if (stack_simulation_info.simulation_stack_unsure_info == NULL) {
    // printk(KERN_ERR "Failed to allocate memory.....\n");
    free_simulation_info(&stack_simulation_info, &heap_simulation_info,
                         &register_info);
    return 0;
  }

  //

  (void)memset(&heap_simulation_info, 0, sizeof(heap_simulation_t));
  //
  heap_simulation_info.address = kvmalloc(128 * sizeof(uint64_t), GFP_KERNEL);
  if (heap_simulation_info.address == NULL) {
    // printk(KERN_ERR "Failed to allocate memory.....\n");
    free_simulation_info(&stack_simulation_info, &heap_simulation_info,
                         &register_info);
    return 0;
  }

  //
  heap_simulation_info.value = kvmalloc(128 * sizeof(uint64_t), GFP_KERNEL);
  if (heap_simulation_info.value == NULL) {
    // printk(KERN_ERR "Failed to allocate memory.....\n");
    free_simulation_info(&stack_simulation_info, &heap_simulation_info,
                         &register_info);
    return 0;
  }
  //
  heap_simulation_info.taine = kvmalloc(128 * sizeof(char), GFP_KERNEL);
  if (heap_simulation_info.taine == NULL) {
    // printk(KERN_ERR "Failed to allocate memory.....\n");
    free_simulation_info(&stack_simulation_info, &heap_simulation_info,
                         &register_info);
    return 0;
  }
  //
  heap_simulation_info.unsure = kvmalloc(128 * sizeof(char), GFP_KERNEL);
  if (heap_simulation_info.unsure == NULL) {
    // printk(KERN_ERR "Failed to allocate memory.....\n");
    free_simulation_info(&stack_simulation_info, &heap_simulation_info,
                         &register_info);
    return 0;
  }

  if (disassemble_info->size > 0) {
    if (updata_register_taine_map(&disassemble_info->info_list[0],
                                  &register_map) == 0) {
      free_simulation_info(&stack_simulation_info, &heap_simulation_info,
                           &register_info);
      return 0;
    }
  }

  char flag = symbolic_execution(
      start_addr, end_addr, 1, 0, 0, disassemble_info, &register_info,
      &register_map, &stack_simulation_info, &heap_simulation_info);

  free_simulation_info(&stack_simulation_info, &heap_simulation_info,
                       &register_info);

  if (flag) {
    return 1;
  } else {
    return 0;
  }
}

char disassemble_code(char *start_offset, int size, uint64_t start_addr,
                      disassemble_code_info_t *disassemble_info) {
  DISASM infos;
  int len;
  char *end_offset = (char *)start_offset + size - 6;

  (void)memset(&infos, 0, sizeof(DISASM));
  infos.EIP = (UInt64)start_offset;
  infos.VirtualAddr = start_addr;
  int index = 0;

  while (!infos.Error) {
    infos.SecurityBlock = (int)end_offset - infos.EIP;
    if (infos.SecurityBlock <= 0 || index >= DIASM_CODE_SIZE) {
      break;
    }
    len = Disasm(&infos);
    switch (infos.Error) {
      case OUT_OF_BLOCK:
        // printk(KERN_INFO "disasm engine is not allowed to read more memory
        // \n");
        return 0;
        break;
      case UNKNOWN_OPCODE:
        // printk(KERN_INFO "%s\n", &infos.CompleteInstr);
        infos.EIP += 1;
        infos.VirtualAddr += 1;
        infos.Error = 0;
        return 0;
        break;
      default:
        infos.EIP += len;
        infos.VirtualAddr += len;
        memcpy(&(disassemble_info->info_list[index]), &infos, sizeof(DISASM));
        index++;
    }
  };
  infos.SecurityBlock += 6;
  Disasm(&infos);
  switch (infos.Error) {
    case OUT_OF_BLOCK:
      // printk(KERN_INFO "disasm engine is not allowed to read more memory
      // \n");
      return 0;
      break;
    case UNKNOWN_OPCODE:
      // printk(KERN_INFO "%s\n", &infos.CompleteInstr);
      infos.EIP += 1;
      infos.VirtualAddr += 1;
      infos.Error = 0;
      return 0;
      break;
    default:
      infos.EIP += len;
      infos.VirtualAddr += len;
      memcpy(&(disassemble_info->info_list[index]), &infos, sizeof(DISASM));
      index++;
      disassemble_info->size = index;
  }
  return 1;
}

void print_diasm_info(disassemble_code_info_t *disassemble_info) {
  int i = 0;
  for (; i < disassemble_info->size; ++i) {
    printk(KERN_INFO "%s\n", disassemble_info->info_list[i].CompleteInstr);
  }
}

uint32_t get_start_addr_offset(char *data, uint64_t vir_addr,
                               uint64_t cache_miss_addr) {
  // res
  uint32_t res = 0;
  // mem_offset1
  uint32_t mem_offset = 0;
  uint32_t i = 0;
  uint32_t len;
  DISASM infos;
  for (; i < 16; ++i) {
    // mem_offset
    if ((mem_offset & (0x1 << i)) > 0) {
      continue;
    }
    // tmp_mem_offsetmem_offset
    uint32_t tmp_mem_offset = 0;
    // data
    uint32_t current_offset = i;
    // 
    tmp_mem_offset += (0x1 << i);
    char jmp_while = 0;
    char *end_offset = data + i + 0x20;
    (void)memset(&infos, 0, sizeof(DISASM));
    infos.EIP = (UInt64)data + i;
    infos.VirtualAddr = vir_addr + i;
    while (!infos.Error) {
      if (jmp_while > 0) {
        break;
      }
      infos.SecurityBlock = (uint32_t)end_offset - infos.EIP;
      if (infos.SecurityBlock <= 0) {
        break;
      }
      len = Disasm(&infos);

      switch (infos.Error) {
        case OUT_OF_BLOCK:
          jmp_while = 1;
          break;
        case UNKNOWN_OPCODE:
          jmp_while = 1;
          break;
        // 
        default:
          infos.EIP += len;
          infos.VirtualAddr += len;
          current_offset += len;

          if (infos.VirtualAddr > cache_miss_addr || current_offset >= 0x20) {
            jmp_while = 1;
            break;
          } else if (infos.VirtualAddr == cache_miss_addr) {
            // 
            // 
            mem_offset |= tmp_mem_offset;
            // 
            res += (0x1 << i);
            jmp_while = 1;
          }

          if ((mem_offset & (0x1 << current_offset)) > 0) {
            // 
            // 
            mem_offset |= tmp_mem_offset;
            // 
            res += (0x1 << i);
            jmp_while = 1;
            break;
          }
          // 
          if (current_offset < 16) {
            tmp_mem_offset += 0x1 << current_offset;
          }

          break;
      }
    };
  }
  return res;
}
/**
 * @brief branchmissret
 *
 * @param data
 * @param cache_miss_addr
 * @param branch_miss_addr
 * @return true 
 * @return false 
 */
bool judge_ret_situation(char *data, uint64_t cache_miss_addr,
                         uint64_t branch_miss_addr) {
  DISASM infos;
  int len;
  char *end_offset = (char *)data + branch_miss_addr - cache_miss_addr + 20;

  (void)memset(&infos, 0, sizeof(DISASM));
  infos.EIP = (UInt64)data + branch_miss_addr - cache_miss_addr;
  infos.VirtualAddr = branch_miss_addr;
  int num = 0;

  while (!infos.Error) {
    infos.SecurityBlock = (int)end_offset - infos.EIP;
    if (infos.SecurityBlock <= 0) {
      break;
    }
    len = Disasm(&infos);
    switch (infos.Error) {
      case OUT_OF_BLOCK:
        // printk(KERN_INFO "disasm engine is not allowed to read more memory
        // \n");
        return false;
        break;
      case UNKNOWN_OPCODE:
        // printk(KERN_INFO "%s\n", &infos.CompleteInstr);
        infos.EIP += 1;
        infos.VirtualAddr += 1;
        infos.Error = 0;
        return false;
        break;
      default:
        infos.EIP += len;
        infos.VirtualAddr += len;
        num++;
        if (num > JUDGE_RET_STEP_SIZE) {
          break;
        }
        if (infos.Instruction.Mnemonic[0] == 'r' &&
            infos.Instruction.Mnemonic[1] == 'e') {
          return true;
        }
    }
  }
  return false;
}
/**
 * 
 */
char pebs_taine_analyze(struct task_struct *task,
                        unsigned long long int cache_miss_addr,
                        unsigned long long int branch_miss_addr,
                        register_info_t *start_info, register_info_t *end_info,
                        uint32_t pid) {
  // if (cache_miss_addr > branch_miss_addr) {
  //   return;
  // }
  // 
  struct mm_struct *mm = task->mm;
  char res_value = 0;
  //cache missbranch miss

  uint64_t sub_value = branch_miss_addr - cache_miss_addr;

  unsigned long code_size = sub_value + 6 + OVER_FOOT_SIZE + OVER_HEAD_SIZE;

  if (code_size <= 0 || code_size > 100 + OVER_FOOT_SIZE + OVER_HEAD_SIZE) {
    return res_value;
  }

  // 
  unsigned long nr_pages =
      (cache_miss_addr - OVER_HEAD_SIZE - code_size - 1) / PAGE_SIZE -
      (cache_miss_addr - OVER_HEAD_SIZE) / PAGE_SIZE + 1;

  if (nr_pages == 0) {
    return res_value;
  }

  // , kvmalloc
  struct page **pages = kvmalloc(nr_pages * PAGE_SIZE, GFP_KERNEL);
  if (pages == NULL) {
    return res_value;
  }

  // 1
  int *locked;

  int ret;
  // 
  // printk(KERN_INFO "cahce_miss_addr=%llx, nr_pages=%lu\n", cache_miss_addr,
  //        nr_pages);
  // printk(KERN_INFO "min_addr = %llx nr_pages= %lu pages
  // =%llx",min_addr,nr_pages,(uint64_t)pages);
  if (mm == NULL) {
    return res_value;
  }
  ret = get_user_pages_remote(mm, cache_miss_addr - OVER_HEAD_SIZE, nr_pages,
                              FOLL_WRITE | FOLL_FORCE, pages, NULL, locked);
  if (ret <= 0) {
    // printk(KERN_ERR "Failed to get user pages\n");
    kvfree(pages);
    return res_value;
  }
  char *data_with_information = vmalloc(code_size + PREFIX_SIZE);
  memset(data_with_information, 0, code_size + PREFIX_SIZE);
  // 

  if (data_with_information == NULL) {
    printk(KERN_ERR "Failed to allocate memory.....\n");
    int i = 0;
    for (; i < nr_pages; i++) {
      put_page(pages[i]);
    }
    kvfree(pages);
    return res_value;
  }

  char *data = data_with_information + PREFIX_SIZE;

  int i = 0;
  // for (; i < code_size; i++) {
  //   long long int val = *(data + i);
  //   printk(KERN_INFO "data initial val, address:%llx,val:%llx\n", (data + i),
  //          val);
  // }

  i = 0;
  unsigned long copied = 0;
  unsigned long remain = code_size;
  // 
  for (; i < nr_pages; i++) {
    // page_size
    unsigned long offset =
        (cache_miss_addr - OVER_HEAD_SIZE + copied) % PAGE_SIZE;
    // printk(KERN_INFO "i=%d. offset=%d.\n", i, offset);

    unsigned long len = min((unsigned long)PAGE_SIZE - offset, remain);
    // printk(KERN_INFO "i=%d. len=%d.\n", i, len);

    // 
    void *src = kmap(pages[i]) + offset;
    void *dst = data + copied;
    // printk(KERN_INFO "src=%llx;dst=%llx;\n", (unsigned long long int *)src,
    //        (unsigned long long int *)dst);

    memcpy(dst, src, len);
    kunmap(pages[i]);
    copied += len;
    remain -= len;
  }
  // printk(KERN_INFO "i=%d.\n", i);

  // i = 0;
  // for (; i < code_size; i++) {
  //   long long int val = *(data + i);
  //   // printk(KERN_INFO "Read data from user space, address:%llx,val:%llx\n",
  //   //        (data + i), val);
  // }

  disassemble_code_info_t *disassemble_info = NULL;
  disassemble_info = vmalloc(sizeof(disassemble_code_info_t));
  if (disassemble_info == NULL) {
    int i = 0;
    for (; i < nr_pages; i++) {
      put_page(pages[i]);
    }
    if (pages != NULL) {
      kvfree(pages);
    }
    if (data_with_information != NULL) {
      vfree(data_with_information);
    }
    return 0;
  }

  // disassemble_info
  if (disassemble_code(data + OVER_HEAD_SIZE,
                       code_size - OVER_FOOT_SIZE - OVER_HEAD_SIZE,
                       cache_miss_addr, disassemble_info)) {
    {
        // if (task->comm[0] == 's') {
        //   printk(KERN_INFO "-----------------------\n");
        //   printk(KERN_INFO
        //          "read exec file name %s start_addr=%llx end_addr =%llx \n",
        //          task->comm, cache_miss_addr, branch_miss_addr);
        //   print_diasm_info(disassemble_info);
        //   printk(KERN_INFO "-----------------------\n");
        // }

        // 
        // if (task->comm[0] == 's') {
        //   printk(KERN_INFO "-----------------------\n");
        //   printk(KERN_INFO
        //          "read exec file name %s start_addr=%llx end_addr =%llx \n",
        //          task->comm, cache_miss_addr, branch_miss_addr);
        //   char analyze_res =
        //       symbolic_execution_prepare(cache_miss_addr, branch_miss_addr +
        //       2,
        //                                  disassemble_info, start_info,
        //                                  end_info);
        //   if (analyze_res) {
        //   print_diasm_info(disassemble_info);
        //   printk(KERN_INFO "-----------------------\n");
        //   }
        //   // print_diasm_info(disassemble_info);
        //   // printk(KERN_INFO "-----------------------\n");
        // }
    } {
      // if (task->comm[0] == 's' && task->comm[1] == 'p') {
      //   printk(KERN_INFO "%s begin to analyze\n", task->comm);
      //   print_diasm_info(disassemble_info);
      // }
      // if (task->comm[0] == 's') {
      char analyze_res =
          symbolic_execution_prepare(cache_miss_addr, branch_miss_addr + 2,
                                     disassemble_info, start_info, end_info);
      if (analyze_res) {
        res_value = 1;
        // if (task->comm[0] == 's' && task->comm[1] == 'p') {
        //   printk("cache_miss_flag=%lx,branch_miss_flag=%lx",start_info->RFLAGS,end_info->RFLAGS);
        //   printk(KERN_INFO "%s analyze finish\n", task->comm);
        //   printk("----------------------------------------");
        // }
        // printk(KERN_INFO "-----------------------\n");
        // printk(KERN_INFO
        //        "read exec file name %s start_addr=%llx end_addr =%llx \n",
        //        task->comm, cache_miss_addr, branch_miss_addr);
        // print_diasm_info(disassemble_info);
        // printk(KERN_INFO "-----------------------\n");
        // 
        data_with_information[0] = 0;
        // 
        data_with_information[1] = branch_miss_addr - cache_miss_addr;
        // ret
        data_with_information[2] = 0;
        // 
        data_with_information[3] = 0;
        // pid
        *((UInt32 *)(data_with_information + 4)) = pid;
        // cache miss addr
        *((UInt64 *)(data_with_information + 8)) = cache_miss_addr;
        // retret
        *((UInt64 *)(data_with_information + 16)) = 0;
        // 
        memcpy(data_with_information + 24, task->comm, 16);
        // 
        // *((UInt32 *)(data_with_information + 40)) = get_start_addr_offset(
        //     data, cache_miss_addr - PREFIX_SIZE, cache_miss_addr);
        // branch missregister info
        // if (task->comm[0] == 's' && task->comm[1] == 'p') {
        //   printk(KERN_INFO "start_addr_offset = %d \n", *((UInt32
        //   *)(data_with_information + 40)));
        // }
        i = 0;
        for (; i < 18; ++i) {
          *((UInt64 *)(data_with_information + MEAASGE_INFO + i * 8)) =
              *(((UInt64 *)end_info) + i);
        }

        // bool ret_flag =
        //     judge_ret_situation(data, cache_miss_addr, branch_miss_addr);
        // if (ret_flag) {
        //   *((UInt32 *)(data_with_information + 12)) = 1;
        // } else {
        //   *((UInt32 *)(data_with_information + 12)) = 0;
        // }
        // if (task->comm[0] == 'c' ) {
        //   send_msg_by_mmap(data_with_information);
        //   // printk(KERN_INFO "name %s",task->comm);
        // }
        send_msg_by_mmap(data_with_information);
        // name code
        // name chrome
        // name clash-linux && task->comm[1] == 'h'

        // }
      }
    }
  }
  // 
  i = 0;
  for (; i < nr_pages; i++) {
    put_page(pages[i]);
  }
  kvfree(pages);
  vfree(data_with_information);

  vfree(disassemble_info);

  return res_value;
}
/**
 * @brief 
 *
 * @param target_pid
 * @param addr
 * @return Int32
 */
Int32 judge_kernel_or_user(uint64_t addr) {
  if (addr < 0xffff800000000000 && addr > 0) {
    return 1;
  } else {
    return 0;
  }
}

uint64_t ret_addr[100];
/**
 * @brief Get the data from ret object
 * 0 
 * 1 -1
 * @param target_pid
 * @param send_id
 * @param branch_miss_addr
 */
void get_data_from_ret(UInt32 target_pid, UInt64 send_id,
                       UInt64 branch_miss_addr) {
  int i;
  for (i = 0; i < 100; ++i) {
    if (ret_addr[i] == 0) {
      break;
    }
    if (ret_addr[i] == target_pid) {
      //
    }
  }
  //ret
  //
  if (judge_kernel_or_user(branch_miss_addr)) {
    char tmp[24];
    tmp[0] = 'r';
    tmp[1] = 'e';
    tmp[2] = 't';
    *((UInt32 *)(branch_miss_addr + 4)) = 1;
    *((UInt32 *)(branch_miss_addr + 8)) = target_pid;
    *((UInt32 *)(branch_miss_addr + 12)) = send_id;
    *((UInt64 *)(branch_miss_addr + 16)) = branch_miss_addr;
    send_msg_by_netlink(tmp, 24);
  }
  //
  else {
    if (virt_addr_valid(branch_miss_addr)) {
      char tmp[24];
      tmp[0] = 'r';
      tmp[1] = 'e';
      tmp[2] = 't';
      *((UInt32 *)(branch_miss_addr + 4)) = -1;
      *((UInt32 *)(branch_miss_addr + 8)) = target_pid;
      *((UInt32 *)(branch_miss_addr + 12)) = send_id;
      *((UInt64 *)(branch_miss_addr + 16)) = branch_miss_addr;
      send_msg_by_netlink(tmp, 24);
    } else {
      char tmp[24];
      tmp[0] = 'r';
      tmp[1] = 'e';
      tmp[2] = 't';
      *((UInt32 *)(branch_miss_addr + 4)) = -1;
      *((UInt32 *)(branch_miss_addr + 8)) = target_pid;
      *((UInt32 *)(branch_miss_addr + 12)) = send_id;
      *((UInt64 *)(branch_miss_addr + 16)) = branch_miss_addr;
      send_msg_by_netlink(tmp, 24);
    }
  }
}

void read_data(uint32_t target_pid, uint64_t send_id, uint64_t start_addr) {
  // printk(KERN_INFO "read data from %x to %llx at %llx\n", target_pid,
  // send_id,
  //        start_addr);
  struct pid *kpid = find_vpid((int32_t)target_pid);
  //
  const int addition_information_size = 24;
  if (kpid != NULL) {
    struct task_struct *task = pid_task(kpid, PIDTYPE_PID);
    if (task != NULL) {
      if (pid_alive(task) == 1) {
        // 
        // 
        if (task->comm[0] == 's' && task->comm[1] == 'p') {
          printk(KERN_INFO "spec begin to find spec other data\n");
        }

        struct mm_struct *mm = task->mm;
        if (mm != NULL) {
          unsigned long code_size = OVER_FOOT_SIZE;
          // 
          unsigned long nr_pages = (start_addr - code_size - 1) / PAGE_SIZE -
                                   (start_addr) / PAGE_SIZE + 1;

          // , kvmalloc
          struct page **pages = kvmalloc(nr_pages * PAGE_SIZE, GFP_KERNEL);
          if (pages == NULL) {
            printk(KERN_ERR "Failed to alloc pages\n");
            return;
          }
          // 1
          int *locked;
          // 
          // printk(KERN_INFO "nr_pages=%lu\n", nr_pages);

          int ret = get_user_pages_remote(mm, start_addr, nr_pages,
                                          FOLL_WRITE | FOLL_FORCE, pages, NULL,
                                          locked);
          if (ret <= 0) {
            // printk(KERN_ERR "Failed to get user pages\n");
            kvfree(pages);
            return;
          }
          char *data_with_information =
              vmalloc(code_size + addition_information_size);

          if (data_with_information == NULL) {
            printk(KERN_ERR "Failed to allocate memory.....\n");
            int i = 0;
            for (; i < nr_pages; i++) {
              put_page(pages[i]);
            }
            kvfree(pages);
            return;
          }
          char *data = data_with_information + addition_information_size;
          //
          {
            int i = 0;
            i = 0;
            unsigned long copied = 0;
            unsigned long remain = code_size;
            // 
            for (; i < nr_pages; i++) {
              // page_size
              unsigned long offset = (start_addr + copied) % PAGE_SIZE;

              unsigned long len =
                  min((unsigned long)PAGE_SIZE - offset, remain);
              // 
              void *src = kmap(pages[i]) + offset;
              void *dst = data + copied;

              memcpy(dst, src, len);
              kunmap(pages[i]);
              copied += len;
              remain -= len;
            }
          }
          int i = 0;
          for (; i < nr_pages; i++) {
            put_page(pages[i]);
          }
          kvfree(pages);

          data_with_information[0] = 's';
          data_with_information[1] = 'e';
          if (task->comm[0] == 's' && task->comm[1] == 'p') {
            data_with_information[2] = 'f';
          }
          *((u64 *)(data_with_information + 8)) = send_id;
          *((u64 *)(data_with_information + 16)) = start_addr;
          // send msg
          send_msg_by_netlink(data_with_information,
                              code_size + addition_information_size);
          vfree(data_with_information);
          return;
        }
      }
    }
  }
  // printk(KERN_INFO "pid%x is dead", target_pid);
  char message[addition_information_size];
  message[0] = 's';
  message[1] = 'e';
  *(u64 *)(message + 8) = send_id;
  *(u64 *)(message + 16) = 0;
  send_msg_by_netlink(message, addition_information_size);
  return;
}
// /**
//  * @brief 
//  *
//  * @param num
//  * @param num_str
//  * @return unsigned int
//  */
// unsigned int convert_num_to_string(int num, char *num_str) {
//   if (num == 0) {
//     num_str[0] = '0';
//     num_str[1] = '\0';
//     return 1;
//   }
//   int len = 0;
//   while (num != 0) {
//     num_str[len] = (num % 10) + '0';
//     num = num / 10;
//     ++len;
//   }
//   int front = 0;
//   int end = len - 1;
//   //
//   while (front < end) {
//     char tmp = num_str[front];
//     num_str[front] = num_str[end];
//     num_str[end] = tmp;
//     ++front;
//     --end;
//   }
//   num_str[len] = '\0';
//   return len;
// }

// void send_to_user_to_analyze(char *data, int size, uint64_t start_addr) {
//   //
//   char *send_to_user = (char *)vmalloc(2048);
//   if (send_to_user == NULL) {
//     printk(KERN_ERR "connot alloc mem");
//   }
//   UInt32 send_to_user_offset = 0;

//   //
//   convert_symbol_t *convert_symbol_arr =
//       (convert_symbol_t *)vmalloc(128 * sizeof(convert_symbol_t));
//   if (convert_symbol_arr == NULL) {
//     vfree(send_to_user);
//     printk(KERN_ERR "connot alloc mem");
//     return;
//   }
//   //
//   {
//     Int32 i = 0;
//     while (i < 128) {
//       convert_symbol_arr[i].symbol_str[0] = 'l';
//       char num_str[8];
//       convert_num_to_string(i, &(num_str[0]));
//       UInt32 num_str_len =
//           copy_string(&(convert_symbol_arr[i].symbol_str[1]), num_str);
//       convert_symbol_arr[i].symbol_str[num_str_len + 1] = '\0';
//       ++i;
//     }
//   }
//   UInt32 convert_symbol_arr_offset = 0;

//   //
//   single_ins_str_t *single_ins_str_arr =
//       (single_ins_str_t *)vmalloc(512 * sizeof(single_ins_str_t));
//   if (single_ins_str_arr == NULL) {
//     vfree(send_to_user);
//     vfree(convert_symbol_arr);
//     printk(KERN_ERR "connot alloc mem");
//     return;
//   }
//   memset(single_ins_str_arr, 0, 512 * sizeof(single_ins_str_t));
//   UInt32 single_ins_str_arr_offset = 0;

//   //
//   {
//     DISASM infos;
//     int len;
//     char *end_offset = (char *)start_offset + size;

//     (void)memset(&infos, 0, sizeof(DISASM));
//     infos.EIP = (UInt64)start_offset;
//     infos.VirtualAddr = start_addr;

//     while (!infos.Error) {
//       infos.SecurityBlock = (int)end_offset - infos.EIP;
//       if (infos.SecurityBlock <= 0) {
//         break;
//       }
//       len = Disasm(&infos);
//       switch (infos.Error) {
//         case OUT_OF_BLOCK:
//           break;
//         case UNKNOWN_OPCODE:
//           break;
//         default:
//           infos.EIP += len;
//           infos.VirtualAddr += len;
//           //
//       }
//     };
//   }

//   //single_ins_str_arr_offset

//   //
//   if (send_to_user_offset + 1 > 2048) {
//     printk(KERN_ERR "too long");
//     vfree(send_to_user);
//     vfree(convert_symbol_arr);
//     vfree(single_ins_str_arr);
//     return 0;
//   }

//   //
//   {
//     send_to_user[send_to_user_offset] = '\n';
//     send_msg(send_to_user, send_to_user_offset + 1);
//     vfree(send_to_user);
//     vfree(convert_symbol_arr);
//     vfree(single_ins_str_arr);
//     return 1;
//   }
// }
// /**
//  * @brief  '\0'   abc3
//  *
//  * @param dest
//  * @param source
//  * @return unsigned int
//  */
// unsigned int copy_string(char *dest, char *source) {
//   int i = 0;
//   for (; i < 40; ++i) {
//     if (source[i] == '\0') {
//       break;
//     }
//     dest[i] = source[i];
//   }
//   return i;
// }

// /**
//  * @brief 
//  *
//  */
// char tran_source_complete_str(DISASM *infos,
//                               single_ins_str_t *single_ins_str_arr,
//                               UInt32 *single_ins_str_arr_offset,
//                               convert_symbol_t *convert_symbol_arr,
//                               UInt32 *convert_symbol_arr_offset) {
//   //
//   if ((infos->Instruction.Category & 0x0000ffff) == 6) {
//     //ret
//     if (infos->Instruction.BranchType == 13) {
//       single_ins_str_arr[*single_ins_str_arr_offset].ins_addr =
//           infos->VirtualAddr;
//       single_ins_str_arr[*single_ins_str_arr_offset].ins_str_offset =
//           copy_string(single_ins_str_arr[*single_ins_str_arr_offset].ins_str,
//                       infos->CompleteInstr);
//     }
//     // jcc and call
//     else {
//       // 
//       if (infos->Operand1.OpType == 0x8040000) {
//         UInt64 jmp_addr = convert_string_to_num(infos->Operand1.OpMnemonic);
//         single_ins_str_arr[*single_ins_str_arr_offset].jmp_addr = jmp_addr;
//         convert_symbol_arr[*convert_symbol_arr_offset].symbol_addr =
//         jmp_addr;
//       }
//       // 
//       single_ins_str_arr[*single_ins_str_arr_offset].ins_addr =
//           infos->VirtualAddr;

//       UInt32 str_offset =
//           copy_string(single_ins_str_arr[*single_ins_str_arr_offset].ins_str,
//                       infos->Instruction.Mnemonic);
//       single_ins_str_arr[*single_ins_str_arr_offset].ins_str[str_offset]=' ';
//       str_offset =
//       copy_string(&(single_ins_str_arr[*single_ins_str_arr_offset].ins_str[str_offset+1]),
//                       convert_symbol_arr[*convert_symbol_arr_offset].symbol_str);

//       *convert_symbol_arr_offset = *convert_symbol_arr_offset + 1;
//     }
//   }
//   //
// }
