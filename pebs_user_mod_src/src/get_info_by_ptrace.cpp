#include "get_info_by_ptrace.h"

#include <proc/readproc.h>
#include <sys/ptrace.h>
#include <sys/user.h>
#include <sys/wait.h>

#include <boost/chrono.hpp>
#include <cstddef>
#include <cstdint>
#include <cstring>
#include <utility>

std::pair<uint32_t, std::string> get_info_by_ptrace::get_info() {
  //
  if (kill(_pid, 0) == -1) {
    return std::make_pair(-1, std::string(""));
  }
  //
  long ret = ptrace(PTRACE_ATTACH, _pid, NULL, NULL);
  printf("read_addr = %lx\n", _addr);
  uint64_t ret_addr = 0;
  if (ret != -1) {
    //
    printf("read_addr = %lx\n", _addr);
    uint64_t original_instr =
        ptrace(PTRACE_PEEKTEXT, _pid, (void *)_addr, NULL);
    printf("original_instr = %lx\n", original_instr);
    // int3
    uint64_t data_with_trap = (original_instr & 0xFFFFFFFFFFFFFF00) | 0xCC;
    printf("original_instr = %lx\n", data_with_trap);
    // //
    // ptrace(PTRACE_POKETEXT, _pid, (void *)_addr, (void *)data_with_trap);

    // printf("after set break point = %lx\n",
    //        ptrace(PTRACE_PEEKTEXT, _pid, (void *)_addr, NULL));

    // //
    // ptrace(PTRACE_POKETEXT, _pid, (void *)_addr, (void *)original_instr);
    // printf("after restore break point = %lx\n",
    //        ptrace(PTRACE_PEEKTEXT, _pid, (void *)_addr, NULL));

    // bool break_point_hit = false;
    // //proc
    // {
    //   PROCTAB *proc = openproc(PROC_FILLSTAT);
    //   //
    //   boost::chrono::high_resolution_clock::time_point start =
    //       boost::chrono::high_resolution_clock::now();
    //   if (proc != nullptr) {
    //     while (true) {
    //       //
    //       boost::chrono::high_resolution_clock::time_point end =
    //           boost::chrono::high_resolution_clock::now();
    //       boost::chrono::duration<double> duration =
    //           boost::chrono::duration_cast<boost::chrono::duration<double>>(
    //               end - start);
    //       //
    //       if (duration.count() > 0.5) {
    //         break;
    //       }
    //       if (break_point_hit) {
    //         break;
    //       }
    //       proc_t proc_info;
    //       while (readproc(proc, &proc_info) != nullptr) {
    //         if (proc_info.tid == _pid) {
    //           // 
    //           if (proc_info.state == 'S') {
    //             break_point_hit = true;
    //           }
    //           break;
    //         }
    //       }
    //     }
    //     closeproc(proc);
    //   }
    // }
    // struct user_regs_struct regs;
    // if (break_point_hit) {
    //   //
    //   ptrace(PTRACE_GETREGS, _pid, 0, &regs);
    //   ret_addr = ptrace(PTRACE_PEEKTEXT, _pid, (void *)(regs.rbp + 8), NULL);
    //   //
    //   ptrace(PTRACE_POKETEXT, _pid, (void *)_addr, (void *)original_instr);
    //   //rip
    //   regs.rip -= 1;
    //   ptrace(PTRACE_SETREGS, _pid, nullptr, &regs);
    //   //
    //   ptrace(PTRACE_CONT, _pid, nullptr, nullptr);
    // } else {
    //   //
    //   ptrace(PTRACE_POKETEXT, _pid, (void *)_addr, (void *)original_instr);
    // }

    // if (ret_addr != 0) {
    //   char data[104];
    //   for (int i = 0; i < 13; ++i) {
    //     uint64_t word =
    //         ptrace(PTRACE_PEEKTEXT, _pid, (void *)(ret_addr + i), NULL);
    //     std::memcpy(data + i * sizeof(uint64_t), &word, sizeof(uint64_t));
    //   }
    //   ret = ptrace(PTRACE_DETACH, _pid, NULL, NULL);
    //   return std::make_pair(1, std::string(data, 104));
    // }
  } else {
    printf("attach error");
  }
  ret = ptrace(PTRACE_DETACH, _pid, NULL, NULL);
  return std::make_pair(-1, std::string(""));
}