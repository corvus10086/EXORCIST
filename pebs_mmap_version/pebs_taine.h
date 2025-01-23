/*
 * @Date: 2023-07-12 13:53:42
 * @LastEditors: liuchang chang.liu@zhejianglab.com
 * @LastEditTime: 2023-07-12 16:29:54
 * @FilePath: /pebs/src/pebs_taine.h
 */
#ifndef PEBS_TAINE_H
#define PEBS_TAINE_H
#include <linux/fs.h>
#include <linux/highmem.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/mm.h>
#include <linux/mm_types.h>
#include <linux/sched.h>
#include <linux/sched/signal.h>
#include <linux/sched/task.h>
#include <linux/uaccess.h>

#include "pebs_pub.h"
#include "pebs_taine_tool.h"

// typedef struct convert_symbol{
//     unsigned long long int symbol_addr;
//     char symbol_str[8];
// } convert_symbol_t;

// typedef struct single_ins_str{
//     unsigned long long int ins_addr;
//     unsigned long long int jmp_addr;
//     int ins_str_offset;
//     char isLabel;
//     char ins_str[50];

// } single_ins_str_t;
char pebs_taine_analyze(struct task_struct* task,
                        unsigned long long int start_addr,
                        unsigned long long int end_addr,
                        register_info_t* start_info, register_info_t* end_info,
                        uint32_t pid);

// void send_to_user_to_analyze(char* data, int size,uint64_t start_addr);
// unsigned int copy_string(char *dest, char *source);

void read_data(uint32_t target_pid, uint64_t send_id, uint64_t start_addr);
char insert_and_search_analyze_list(uint32_t pid, uint64_t start_addr,
                                    uint64_t end_addr);
void free_taine_analyze_list(void);
char alloc_taine_analyze_list(void);

#endif