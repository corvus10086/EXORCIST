#include "full_diasm_info.h"

#include <bitset>
#include <capstone/capstone.h>
#include <capstone/mips.h>
#include <capstone/x86.h>
#include <sys/types.h>

#include <boost/chrono.hpp>
#include <boost/chrono/duration.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/thread.hpp>
#include <boost/thread/lock_types.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/thread/pthread/mutex.hpp>
#include <boost/thread/xtime.hpp>
#include <cstddef>
#include <cstdint>
#include <cstring>
#include <fstream>
#include <memory>
#include <sstream>
#include <string>
#include <utility>
#include <vector>

#include "async_analyze_code_tool.h"
#include "conf.h"
#include "diasm_code_tool.h"
#include "test.h"

bool full_diasm_info::get_full_diasm_code(
    const std::string code_info,
    std::map<std::uint64_t,
             async_analyze_code_tool::thread_recv_data_struct::ptr>
        &thread_code_map,
    boost::mutex &thread_code_map_mutex, uint64_t thread_id,
    netlink_tool::ptr netlink_tool_ptr) {
  // 暂停当前线程，等待获取到ret返回位置的函数再唤醒
  if (analyze_recy_data(code_info)) {
    std::cout << "need to get ret addr" << std::endl;
    // get_ret_info(thread_code_map, thread_id, netlink_tool_ptr);
  }

  diasm_code_tool::ptr main_code_info_ptr =
      std::make_shared<diasm_code_tool>(_is_32);

  // 对数据进行反汇编
  main_code_info_ptr->diasm_code(
      (const uint8_t *)(code_info.c_str() + PREFIX_SIZE + OVER_HEAD_SIZE),
      code_info.length() - PREFIX_SIZE - OVER_HEAD_SIZE, _cache_miss_addr);
  if (main_code_info_ptr->get_size() <= 0) {
    return false;
  }
  _diasm_code_ptr_vector.push_back(main_code_info_ptr);
  // 保存前缀信息,保存信息到
  _over_head_info =
      std::string(code_info.c_str() + PREFIX_SIZE,
                  OVER_HEAD_SIZE + _branch_miss_addr - _cache_miss_addr);

  int send_mess_num = 0;
  //这里要获取jmp call 以及条件跳转的全部代码
  if (netlink_tool_ptr != nullptr) {
    get_jmp_info(main_code_info_ptr, thread_code_map, thread_code_map_mutex,
                 thread_id, netlink_tool_ptr);
  }
  return true;
}
std::stringstream full_diasm_info::get_branch_miss_addr_reg_info_str() {
  std::stringstream res;
  res << "rflags = " << std::bitset<64>(_branch_miss_register_info.RFLAGS)
      << "\n";
  res << std::hex << "rax = " << _branch_miss_register_info.RAX;
  res << std::hex << " rcx = " << _branch_miss_register_info.RCX;
  res << std::hex << " rdx = " << _branch_miss_register_info.RDX << "\n";
  res << std::hex << "rbx = " << _branch_miss_register_info.RBX;
  res << std::hex << " rsi = " << _branch_miss_register_info.RSI;
  res << std::hex << " rdi = " << _branch_miss_register_info.RDI << "\n";
  return res;
}

bool full_diasm_info::analyze_recy_data(const std::string &code_info) {
  char sub_value = *(code_info.c_str() + 1);
  char is_ret_stiuation = *(code_info.c_str() + 2);
  _is_32 = *(code_info.c_str() + 3);
  _target_thread_pid = *((uint32_t *)(code_info.c_str() + 4));
  _cache_miss_addr = *((uint64_t *)(code_info.c_str() + 8));
  _ret_addr = *((uint64_t *)(code_info.c_str() + 16));
  _branch_miss_addr = _cache_miss_addr + sub_value;
  _virtual_start_addr = _cache_miss_addr - OVER_HEAD_SIZE;
  // _start_offset = *((uint32_t *)(code_info.c_str() + 40));
  // _start_offset = get_start_addr_offset(_over_head_info.c_str(),
  //                                       _virtual_start_addr,
  //                                       _cache_miss_addr);
  int end_index = 0;

  for (; end_index < 16; ++end_index) {
    if (code_info[24 + end_index] == 0) {
      break;
    }
  }
  _exec_file_name = std::string(code_info.c_str() + 24, end_index);

  uint64_t *_branch_miss_register_info_addr =
      (uint64_t *)&_branch_miss_register_info;
  for (int i = 0; i < 18; ++i) {
    *(_branch_miss_register_info_addr + i) =
        *(uint64_t *)(code_info.c_str() + MEAASGE_INFO + i * 8);
  }
  if (is_ret_stiuation != 0) {
    return true;
  } else {
    return false;
  }
}

std::stringstream full_diasm_info::get_diasm_string_stream() {
  std::stringstream res;
  res << "target_thread_pid=" << _target_thread_pid << " is 32=" << _is_32
      << "\n";
  res << "exec_file_name=" << _exec_file_name << "\n";
  res << "cache_miss_addr="
      << "0x" << std::hex << _cache_miss_addr << "\n";
  res << "branch_miss_addr="
      << "0x" << std::hex << _branch_miss_addr << "\n";
  for (auto x : _diasm_code_ptr_vector) {
    for (int i = 0; i < x->get_size(); ++i) {
      res << "0x" << std::hex << x->get_diasm_info()[i].address << "\t"
          << x->get_diasm_info()[i].mnemonic << "\t"
          << x->get_diasm_info()[i].op_str << "\n";
    }
    res << "\n\n";
  }
  return res;
}

void full_diasm_info::get_jmp_info(
    diasm_code_tool::ptr main_code_info_ptr,
    std::map<std::uint64_t,
             async_analyze_code_tool::thread_recv_data_struct::ptr>
        &thread_code_map,
    boost::mutex &thread_code_map_mutex, unsigned long thread_id,
    netlink_tool::ptr netlink_tool_ptr) {
  int send_mess_num = 0;
  // 获取代码的结束地址
  uint64_t end_addr = -1;
  int branch_miss_index = 0;
  for (; branch_miss_index < main_code_info_ptr->get_size();
       ++branch_miss_index) {
    if (main_code_info_ptr->get_diasm_info()[branch_miss_index].address >=
        _branch_miss_addr) {
      break;
    }
  }
  for (int i = branch_miss_index + 2; i < main_code_info_ptr->get_size(); ++i) {
    if (main_code_info_ptr->get_diasm_info()[i].mnemonic[0] == 'r' &&
        main_code_info_ptr->get_diasm_info()[i].mnemonic[1] == 'e' &&
        main_code_info_ptr->get_diasm_info()[i].mnemonic[2] == 't') {
      end_addr = main_code_info_ptr->get_diasm_info()[i].address;
      break;
    }
  }
  if (end_addr < 0) {
    end_addr =
        main_code_info_ptr->get_diasm_info()[main_code_info_ptr->get_size() - 1]
            .address;
  }

  std::vector<std::string> message_list;

  // 获取跳转地址的数据
  for (int i = 1; i < main_code_info_ptr->get_size(); ++i) {
    if (i >= 20) {
      if (_exec_file_name[0] == 's' && _exec_file_name[1] == 'p' &&
          _exec_file_name[2] == 'e') {
        // std::cout << "sepc send mess fail by i\n";
      }
      break;
    }
    if (send_mess_num >= 1) {
      if (_exec_file_name[0] == 's' && _exec_file_name[1] == 'p' &&
          _exec_file_name[2] == 'e') {
        // std::cout << "sepc send mess fail by send_mess_num\n";
      }
      break;
    }
    if (main_code_info_ptr->get_diasm_info()[i].address == end_addr) {
      break;
    }
    // branch_miss之前的东西不关注
    if (main_code_info_ptr->get_diasm_info()[i].address <= _branch_miss_addr) {
      continue;
    }

    if ((main_code_info_ptr->get_diasm_info()[i].mnemonic[0] == 'c' &&
         main_code_info_ptr->get_diasm_info()[i].mnemonic[1] == 'a' &&
         main_code_info_ptr->get_diasm_info()[i].mnemonic[2] == 'l' &&
         main_code_info_ptr->get_diasm_info()[i].mnemonic[3] == 'l') ||
        (main_code_info_ptr->get_diasm_info()[i].mnemonic[0] == 'j' &&
         main_code_info_ptr->get_diasm_info()[i].mnemonic[1] == 'm' &&
         main_code_info_ptr->get_diasm_info()[i].mnemonic[2] == 'p')) {
      // 仅获取call相关的指令
      // 需要进一步获取指令
      // 先看地址是否在范围内
      // 不在范围内就去获取新的二进制数据
      // 记录发送消息的次数
      if (main_code_info_ptr->get_diasm_info()[i]
              .detail->x86.operands[0]
              .type == X86_OP_IMM) {
        uint64_t jmp_addr =
            main_code_info_ptr->get_diasm_info()[i].detail->x86.operands[0].imm;
        if (jmp_addr > _cache_miss_addr && jmp_addr < end_addr) {
          // 跳转地址在范围内
          break;
        }
        // 检测是否是一个使用动态库函数的跳转
        // if (main_code_info_ptr->get_diasm_info()[i].mnemonic[0] == 'c' &&
        //      main_code_info_ptr->get_diasm_info()[i].mnemonic[1] == 'a' &&
        //      main_code_info_ptr->get_diasm_info()[i].mnemonic[2] == 'l' &&
        //      main_code_info_ptr->get_diasm_info()[i].mnemonic[3] == 'l') {
        //   ++send_mess_num;
        //   // 获取可执行文件的路径
        //   std::string exec_file_path;
        //   {
        //     std::stringstream path;
        //     char exe_path[256];
        //     path << "/proc/" << _target_thread_pid << "/exe";
        //     size_t len =
        //         readlink(path.str().c_str(), exe_path, sizeof(exe_path) - 1);
        //     if (len == -1) {
        //       std::cout << "err\n";
        //       break;
        //     }
        //     exe_path[len] = '\0';
        //     exec_file_path = exe_path;
        //     // std::cout << exec_file_path << "\n";
        //   }
        //   // 获取程序的加载地址
        //   uint64_t load_addr;
        //   {
        //     std::stringstream path;
        //     path << "/proc/" << _target_thread_pid << "/maps";
        //     std::ifstream file(path.str());
        //     if (!file.is_open()) {
        //       std::cerr << "Failed to open the file." << std::endl;
        //       break;
        //     }
        //     std::string line;
        //     // 逐行读取文件内容并输出到控制台
        //     std::getline(file, line);
        //     file.close();
        //     int end = line.find('-');
        //     std::string addr_str = line.substr(0, end);
        //     load_addr = std::stoull(addr_str, 0, 16);

        //   }
        //   // 获取程序的plt信息
        //   std::map<uint64_t, std::string> plt_info;
        //   {
        //     std::stringstream result;
        //     std::array<char, 128> buffer;
        //     std::stringstream exec;
        //     exec << "objdump -D --section=.plt " << exec_file_path
        //          << " |grep '@plt>:'";
        //     FILE *pipe = popen(exec.str().c_str(), "r");

        //     if (!pipe) {
        //       throw std::runtime_error("popen() failed!");
        //     }
        //     // 从 pipe 中读取命令的输出
        //     while (fgets(buffer.data(), buffer.size(), pipe) != nullptr) {
        //       result << buffer.data();
        //     }
        //     pclose(pipe);
        //     std::string line;
        //     while (std::getline(result, line)) {
        //       // std::cout << line << std::endl;
        //       int end = line.find(' ');
        //       std::string addr_str = line.substr(0, end);
        //       if (addr_str.length() < 15) {
        //         break;
        //       }
        //       uint64_t addr = std::stoull(addr_str, 0, 16);
        //       std::string name = line.substr(end + 1, line.length());
        //       plt_info[addr] = name;
        //     }
        //   }
        //   auto addr = jmp_addr - load_addr;
        //   if (plt_info.count(addr)) {
        //     std::string plt_func_str = plt_info[addr];
        //     if (plt_func_str.find("memcpy") || plt_func_str.find("memcmp")) {
        //       // std::cout << "call func is memcpy or memcmp\n";
        //       _judge_addr_is_mem_map[jmp_addr] = true;
        //       break;
        //     }
        //   }
        // }
        // 需要从其他地方获取地址
        {
          if (_exec_file_name[0] == 's' && _exec_file_name[1] == 'p' &&
              _exec_file_name[2] == 'e') {
            std::cout << "sepc send mess to kernel\n";
          }
          //从内核获取
          //这里向内核发送一条消息
          ++send_mess_num;
          char message[32];
          // 第一个字节表示类型
          message[0] = 'g';
          // 第二个字节表示接受数据的id
          *((uint64_t *)(message + 8)) = thread_id;
          // 第三的字节表示要获取数据的线程id
          *((uint32_t *)(message + 16)) = _target_thread_pid;
          // 第四个字节表示要获取数据的地址
          *((uint64_t *)(message + 24)) = jmp_addr;
          message_list.push_back(std::string(message, 32));
        }
      }
    }
  }

  if (send_mess_num > 0) {
    //表示需要获取数据
    //在这里创建同步用的类
    //这个类放在thread_code_map中，有一个唯一的id来标识

    {
      // 锁住thread_code_map
      boost::lock_guard<boost::mutex> lock(thread_code_map_mutex);
      // 创建一个用于接受数据的结构
      thread_code_map[thread_id] =
          std::make_shared<async_analyze_code_tool::thread_recv_data_struct>();
      // 设置需要接受的消息数量
      thread_code_map[thread_id]->_num = send_mess_num;
      // 等待数量设置好后再发送消息
      for (auto message : message_list) {
        netlink_tool_ptr->send_message(message);
      }
    }
    //睡眠等待接受消息的进程唤醒此进程
    {
      boost::unique_lock<boost::mutex> lock(thread_code_map[thread_id]->_mutex);
      thread_code_map[thread_id]->_condition.wait_for(
          lock, boost::chrono::seconds(1));
      lock.unlock();
    }

    //对接受数据的类上一个互斥锁，防止出问题
    {
      boost::lock_guard<boost::mutex> lock(thread_code_map_mutex);
      if (thread_code_map[thread_id]->_message.size() > 0) {
        // if (_exec_file_name[0] == 's' && _exec_file_name[1] == 'p' &&
        //     _exec_file_name[2] == 'e') {
        //   std::cout << "sepc get full num = " << std::dec
        //             << thread_code_map[thread_id]->_message.size() << "\n";
        // }
        for (auto x : thread_code_map[thread_id]->_message) {
          // if (_exec_file_name[0] == 's' && _exec_file_name[1] == 'p' &&
          //     _exec_file_name[2] == 'e') {
          //   std::cout << "sepc get message size = " << std::dec << x.length()
          //             << "\n";
          // }
          diasm_code_tool::ptr sub_code_info_ptr =
              std::make_shared<diasm_code_tool>(_is_32);
          uint64_t start_addr = *((uint64_t *)(x.c_str() + 16));
          if (start_addr != 0) {
            sub_code_info_ptr->diasm_code((const uint8_t *)(x.c_str() + 24),
                                          x.length() - 24, start_addr);
            if (sub_code_info_ptr->get_size() > 0) {
              _diasm_code_ptr_vector.push_back(sub_code_info_ptr);
              if (_exec_file_name[0] == 's' && _exec_file_name[1] == 'p' &&
                  _exec_file_name[2] == 'e') {
                std::cout << "spec recv data diasm secc size = " << std::dec
                          << sub_code_info_ptr->get_size() << "\n";
              }
            } else {
              if (_exec_file_name[0] == 's' && _exec_file_name[1] == 'p' &&
                  _exec_file_name[2] == 'e') {
                std::cout << "spec recv data diasm fail\n";
              }
            }
          }
        }
      }
      //回收同步用的类
      thread_code_map.erase(thread_id);
    }
  }
}

void full_diasm_info::get_ret_info(
    std::map<std::uint64_t,
             async_analyze_code_tool::thread_recv_data_struct::ptr>
        &thread_code_map,
    unsigned long thread_id, netlink_tool::ptr netlink_tool_ptr) {}
