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
  //判断进程是否存活
  if (kill(_pid, 0) == -1) {
    return std::make_pair(-1, std::string(""));
  }
  //附加到目标进程上
  long ret = ptrace(PTRACE_ATTACH, _pid, NULL, NULL);
  printf("read_addr = %lx\n", _addr);
  uint64_t ret_addr = 0;
  if (ret != -1) {
    //中断地址原本的值
    printf("read_addr = %lx\n", _addr);
    uint64_t original_instr =
        ptrace(PTRACE_PEEKTEXT, _pid, (void *)_addr, NULL);
    printf("original_instr = %lx\n", original_instr);
    // int3
    uint64_t data_with_trap = (original_instr & 0xFFFFFFFFFFFFFF00) | 0xCC;
    printf("original_instr = %lx\n", data_with_trap);
    // //设置断点
    // ptrace(PTRACE_POKETEXT, _pid, (void *)_addr, (void *)data_with_trap);

    // printf("after set break point = %lx\n",
    //        ptrace(PTRACE_PEEKTEXT, _pid, (void *)_addr, NULL));

    // //恢复断点处的内容
    // ptrace(PTRACE_POKETEXT, _pid, (void *)_addr, (void *)original_instr);
    // printf("after restore break point = %lx\n",
    //        ptrace(PTRACE_PEEKTEXT, _pid, (void *)_addr, NULL));

    // bool break_point_hit = false;
    // //使用proc来判断目标进程是否进入中断状态
    // {
    //   PROCTAB *proc = openproc(PROC_FILLSTAT);
    //   //开始时间
    //   boost::chrono::high_resolution_clock::time_point start =
    //       boost::chrono::high_resolution_clock::now();
    //   if (proc != nullptr) {
    //     while (true) {
    //       //结束时间
    //       boost::chrono::high_resolution_clock::time_point end =
    //           boost::chrono::high_resolution_clock::now();
    //       boost::chrono::duration<double> duration =
    //           boost::chrono::duration_cast<boost::chrono::duration<double>>(
    //               end - start);
    //       //时间超出限制就终止
    //       if (duration.count() > 0.5) {
    //         break;
    //       }
    //       if (break_point_hit) {
    //         break;
    //       }
    //       proc_t proc_info;
    //       while (readproc(proc, &proc_info) != nullptr) {
    //         if (proc_info.tid == _pid) {
    //           // 找到目标进程，检查其状态是否为可中断等待状态
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
    //   //获取断点处的寄存器值
    //   ptrace(PTRACE_GETREGS, _pid, 0, &regs);
    //   ret_addr = ptrace(PTRACE_PEEKTEXT, _pid, (void *)(regs.rbp + 8), NULL);
    //   //恢复断点处的内容
    //   ptrace(PTRACE_POKETEXT, _pid, (void *)_addr, (void *)original_instr);
    //   //恢复rip
    //   regs.rip -= 1;
    //   ptrace(PTRACE_SETREGS, _pid, nullptr, &regs);
    //   //继续执行
    //   ptrace(PTRACE_CONT, _pid, nullptr, nullptr);
    // } else {
    //   //断点没有触发，恢复断点
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