#include <sys/types.h>
#include <unistd.h>

#include <boost/archive/basic_archive.hpp>
#include <boost/archive/text_oarchive.hpp>
#include <boost/asio.hpp>
#include <boost/asio/steady_timer.hpp>
#include <boost/bind/bind.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/thread.hpp>
#include <cctype>
#include <chrono>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <exception>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <iterator>
#include <memory>
#include <ostream>
#include <regex>
#include <sstream>
#include <string>
#include <thread>
#include <vector>

#include "async_analyze_code_tool.h"
#include "attack_share_mem.h"
#include "basic_types.h"
#include "conf.h"
#include "diasm_code_tool.h"
#include "full_diasm_info.h"
#include "get_info_by_ptrace.h"
#include "netlink_tool.h"
#include "share_mem_tool.h"
#include "state_symbol.h"
#include "static_analyze_tools.h"
#include "test.h"

// namespace fs = std::filesystem;

int array1_size = 16.0;
uint8_t unused1[64];
uint8_t array1[160] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
uint8_t unused2[64];
uint8_t array2[256 * 512];
uint8_t temp = 0; /* Used so compiler won't optimize out victim_function() */

void victim_function(size_t x) {
  if (x < array1_size) {
    temp &= array2[array1[x] * 512];
  }
}
// ok
void victim_function_v1(size_t x) {
  if (x < array1_size) {
    temp &= array2[array1[x]];
  }
}
// ok
void leakByteLocalFunction(uint8_t k) { temp &= array2[(k)]; }
void victim_function_v2(size_t x) {
  if (x < array1_size) {
    leakByteLocalFunction(array1[x]);
  }
}
__attribute__((noinline)) void leakByteNoinlineFunction(uint8_t k) {
  temp &= array2[(k)];
}
// ok
void victim_function_v3(size_t x) {
  if (x < array1_size) leakByteNoinlineFunction(array1[x]);
}
// ok
void victim_function_v4(size_t x) {
  if (x < array1_size) temp &= array2[array1[x << 1]];
}
// ok
void victim_function_v5(size_t x) {
  int i;
  if (x < array1_size) {
    for (i = x - 1; i >= 0; i--) {
      temp &= array2[array1[i]];
    }
  }
}
// ok
int array_size_mask = 15;
void victim_function_v6(size_t x) {
  if ((x & array_size_mask) == x) temp &= array2[array1[x]];
}
// ok
void victim_function_v7(size_t x) {
  static size_t last_x = 0;
  if (x == last_x) temp &= array2[array1[x]];
  if (x < array1_size) last_x = x;
}
// ok
void victim_function_v8(size_t x) {
  temp &= array2[array1[x < array1_size ? (x + 1) : 0]];
}
// ok
void victim_function_v9(size_t x, int *x_is_safe) {
  if (*x_is_safe) temp &= array2[array1[x]];
}
// ok
// 通过控制流泄露
void victim_function_v10(size_t x, uint8_t k) {
  if (x < array1_size) {
    if (array1[x] == k) temp &= array2[0];
  }
}
// ok
void victim_function_v11(size_t x) {
  if (x < array1_size) temp = memcmp(&temp, array2 + (array1[x]), 1);
}
// ok
void victim_function_v12(size_t x, size_t y) {
  if ((x + y) < array1_size) temp &= array2[array1[x + y]];
}
// 这个branch miss cache miss在 is_x_safe中需要获取栈上的返回地址才能识别
// 在编译器优化时会将条件分支转为setx指令，
// 而setx指令经过测试似乎不能引发branch miss 在测试时也没能在攻击时泄漏敏感信息
// 感觉有点奇怪，多次运行测试攻击的代码最多只能
// 猜测出第一个字母，并且还有错误
// 也就是说明sete的情况下在v13中没有引发branch miss？
//
// ret的情况下怎么判断
// branch miss后面多少个字节后面紧跟着一个ret，并且多次触发就找这个
//
//

int is_x_safe(size_t x) {
  if (x < array1_size) {
    return 1;
  }
  return 0;
}
void victim_function_v13(size_t x) {
  if (is_x_safe(x)) temp &= array2[array1[x]];
}
// ok
void victim_function_v14(size_t x) {
  if (x < array1_size) temp &= array2[array1[x ^ 255]];
}

//检测到
void victim_function_v15(size_t *x) {
  if (*x < array1_size) temp &= array2[array1[*x]];
}

void test_func21() {
  diasm_code_tool::ptr tool = std::make_shared<diasm_code_tool>();
  tool->diasm_code(((const uint8_t *)victim_function_v1), 100,
                   (uint64_t)victim_function_v1);
  std::string over_head_info = std::string(
      (char *)victim_function_v1,
      tool->get_diasm_info()[0x7].address - tool->get_diasm_info()[0].address);

  for (int i = 0; i < tool->get_size(); ++i) {
    std::cout << i << "\t0x" << std::hex << tool->get_diasm_info()[i].address
              << '\t' << tool->get_diasm_info()[i].mnemonic << "\t"
              << tool->get_diasm_info()[i].op_str << "\n";
  }
  std::cout << "size " << tool->get_size() << "\n";
  {
    full_diasm_info::ptr info = std::make_shared<full_diasm_info>();
    info->set_virtual_start_addr(tool->get_diasm_info()[0].address);
    info->set_over_head_info(over_head_info);
    info->set_start_offset(1);
    info->set_branch_miss_addr(tool->get_diasm_info()[0x7].address);
    info->set_cache_miss_addr(tool->get_diasm_info()[0x4].address);
    std::vector<diasm_code_tool::ptr> tmp;
    tmp.push_back(tool);
    info->set_diasm_code_ptr_vector(tmp);
    register_info_t reg_info;
    memset(&reg_info, 0, sizeof(reg_info));
    reg_info.RIP = tool->get_diasm_info()[7].address;
    reg_info.RFLAGS = 0x882;
    reg_info.RBP = 0x0000b46a48ecfbe8ll;
    reg_info.RSP = 0x0000b46a48ecfbe8ll;
    reg_info.RDI = 301526;
    reg_info.RAX = 20;
    info->set_branch_miss_register_info(reg_info);
    std::uniform_int_distribution<int> dist =
        std::uniform_int_distribution<int>(100000, 999999);
    static_analyze_tools tools(info, dist);

    auto res = tools.analyze();
    if (res.second == analyze_result::FIND_ATTACK) {
      std::cout << "func 1 find attack index = " << res.first.second << " \n";
    } else {
      std::cout << "func 1 no attack\n";
    }
  }
}
void test_func22() {
  diasm_code_tool::ptr tool = std::make_shared<diasm_code_tool>();
  tool->diasm_code(((const uint8_t *)victim_function_v2), 100,
                   (uint64_t)victim_function_v2);
  std::cout << "size " << tool->get_size() << "\n";
  for (int i = 0; i < tool->get_size(); ++i) {
    std::cout << i << "\t0x" << std::hex << tool->get_diasm_info()[i].address
              << '\t' << tool->get_diasm_info()[i].mnemonic << "\t"
              << tool->get_diasm_info()[i].op_str << "\n";
  }

  {
    diasm_code_tool::ptr tool1 = std::make_shared<diasm_code_tool>();
    tool1->diasm_code(((const uint8_t *)leakByteLocalFunction), 100,
                      (uint64_t)leakByteLocalFunction);
    std::cout << "size " << tool1->get_size() << "\n";
    for (int i = 0; i < tool1->get_size(); ++i) {
      std::cout << i << "\t0x" << std::hex << tool1->get_diasm_info()[i].address
                << '\t' << tool1->get_diasm_info()[i].mnemonic << "\t"
                << tool1->get_diasm_info()[i].op_str << "\n";
    }

    full_diasm_info::ptr info = std::make_shared<full_diasm_info>();
    {
      std::string over_head_info = std::string(
          (char *)victim_function_v2, tool->get_diasm_info()[0x8].address -
                                          tool->get_diasm_info()[0].address);
      info->set_virtual_start_addr(tool->get_diasm_info()[0].address);
      info->set_over_head_info(over_head_info);
      info->set_start_offset(1);
    }

    info->set_branch_miss_addr(tool->get_diasm_info()[0x8].address);
    info->set_cache_miss_addr(tool->get_diasm_info()[5].address);
    info->set_ret_addr(tool1->get_diasm_info()[8].address);
    std::vector<diasm_code_tool::ptr> tmp;
    tmp.push_back(tool);
    tmp.push_back(tool1);
    info->set_diasm_code_ptr_vector(tmp);
    register_info_t reg_info;
    memset(&reg_info, 0, sizeof(reg_info));
    reg_info.RIP = tool->get_diasm_info()[7].address;
    reg_info.RFLAGS = 0x882;
    // reg_info.RFLAGS = 0x8c2;
    reg_info.RBP = 0x0000b46a48ecfbe8ll;
    reg_info.RSP = 0x0000b46a48ecfbe8ll;
    reg_info.RDI = 301526;
    reg_info.RAX = 20;
    info->set_branch_miss_register_info(reg_info);

    std::uniform_int_distribution<int> dist =
        std::uniform_int_distribution<int>(100000, 999999);
    static_analyze_tools tools(info, dist);

    auto res = tools.analyze();
    if (res.second == analyze_result::FIND_ATTACK) {
      std::cout << "func 2 find attack index = " << res.first.second << " \n";
    } else {
      std::cout << "func 2 no attack\n";
    }
  }
}
void test_func23() {
  diasm_code_tool::ptr tool = std::make_shared<diasm_code_tool>();
  tool->diasm_code(((const uint8_t *)victim_function_v3), 100,
                   (uint64_t)victim_function_v3);
  std::cout << "size " << tool->get_size() << "\n";
  for (int i = 0; i < tool->get_size(); ++i) {
    std::cout << i << "\t0x" << std::hex << tool->get_diasm_info()[i].address
              << '\t' << tool->get_diasm_info()[i].mnemonic << "\t"
              << tool->get_diasm_info()[i].op_str << "\n";
  }

  {
    diasm_code_tool::ptr tool1 = std::make_shared<diasm_code_tool>();
    tool1->diasm_code(((const uint8_t *)leakByteNoinlineFunction), 100,
                      (uint64_t)leakByteNoinlineFunction);
    std::cout << "size " << tool1->get_size() << "\n";
    for (int i = 0; i < tool1->get_size(); ++i) {
      std::cout << i << "\t0x" << std::hex << tool1->get_diasm_info()[i].address
                << '\t' << tool1->get_diasm_info()[i].mnemonic << "\t"
                << tool1->get_diasm_info()[i].op_str << "\n";
    }

    full_diasm_info::ptr info = std::make_shared<full_diasm_info>();
    {
      std::string over_head_info = std::string(
          (char *)victim_function_v3, tool->get_diasm_info()[0x8].address -
                                          tool->get_diasm_info()[0].address);
      info->set_virtual_start_addr(tool->get_diasm_info()[0].address);
      info->set_over_head_info(over_head_info);
      info->set_start_offset(1);
    }
    info->set_branch_miss_addr(tool->get_diasm_info()[0x8].address);
    info->set_cache_miss_addr(tool->get_diasm_info()[5].address);
    info->set_ret_addr(tool1->get_diasm_info()[8].address);
    std::vector<diasm_code_tool::ptr> tmp;
    tmp.push_back(tool);
    tmp.push_back(tool1);
    info->set_diasm_code_ptr_vector(tmp);
    register_info_t reg_info;
    memset(&reg_info, 0, sizeof(reg_info));
    reg_info.RIP = tool->get_diasm_info()[7].address;
    reg_info.RFLAGS = 0x882;
    // reg_info.RFLAGS = 0x8c2;
    reg_info.RBP = 0x0000b46a48ecfbe8ll;
    reg_info.RSP = 0x0000b46a48ecfbe8ll;
    reg_info.RDI = 301526;
    reg_info.RAX = 20;
    info->set_branch_miss_register_info(reg_info);

    std::uniform_int_distribution<int> dist =
        std::uniform_int_distribution<int>(100000, 999999);
    static_analyze_tools tools(info, dist);

    auto res = tools.analyze();
    if (res.second == analyze_result::FIND_ATTACK) {
      std::cout << "func 3 find attack index = " << res.first.second << " \n";
    } else {
      std::cout << "func 3 no attack\n";
    }
  }
}
void test_func24() {
  diasm_code_tool::ptr tool = std::make_shared<diasm_code_tool>();
  tool->diasm_code(((const uint8_t *)victim_function_v4), 100,
                   (uint64_t)victim_function_v4);
  std::cout << "size " << tool->get_size() << "\n";
  for (int i = 0; i < tool->get_size(); ++i) {
    std::cout << i << "\t0x" << std::hex << tool->get_diasm_info()[i].address
              << '\t' << tool->get_diasm_info()[i].mnemonic << "\t"
              << tool->get_diasm_info()[i].op_str << "\n";
  }
  {
    full_diasm_info::ptr info = std::make_shared<full_diasm_info>();
    {
      std::string over_head_info = std::string(
          (char *)victim_function_v4, tool->get_diasm_info()[0x7].address -
                                          tool->get_diasm_info()[0].address);
      info->set_virtual_start_addr(tool->get_diasm_info()[0].address);
      info->set_over_head_info(over_head_info);
      info->set_start_offset(1);
    }
    info->set_branch_miss_addr(tool->get_diasm_info()[0x7].address);
    info->set_cache_miss_addr(tool->get_diasm_info()[0x4].address);
    std::vector<diasm_code_tool::ptr> tmp;
    tmp.push_back(tool);
    info->set_diasm_code_ptr_vector(tmp);
    register_info_t reg_info;
    memset(&reg_info, 0, sizeof(reg_info));
    reg_info.RIP = tool->get_diasm_info()[7].address;
    reg_info.RFLAGS = 0x882;
    reg_info.RBP = 0x0000b46a48ecfbe8ll;
    reg_info.RSP = 0x0000b46a48ecfbe8ll;
    reg_info.RDI = 301526;
    reg_info.RAX = 20;
    info->set_branch_miss_register_info(reg_info);
    std::uniform_int_distribution<int> dist =
        std::uniform_int_distribution<int>(100000, 999999);
    static_analyze_tools tools(info, dist);

    auto res = tools.analyze();
    if (res.second == analyze_result::FIND_ATTACK) {
      std::cout << "func 4 find attack index = " << res.first.second << " \n";
    } else {
      std::cout << "func 4 no attack\n";
    }
  }
}
void test_func25() {
  diasm_code_tool::ptr tool = std::make_shared<diasm_code_tool>();
  tool->diasm_code(((const uint8_t *)victim_function_v5), 100,
                   (uint64_t)victim_function_v5);
  std::cout << "size " << tool->get_size() << "\n";
  for (int i = 0; i < tool->get_size(); ++i) {
    std::cout << i << "\t0x" << std::hex << tool->get_diasm_info()[i].address
              << '\t' << tool->get_diasm_info()[i].mnemonic << "\t"
              << tool->get_diasm_info()[i].op_str << "\n";
  }
  {
    full_diasm_info::ptr info = std::make_shared<full_diasm_info>();
    {
      std::string over_head_info = std::string(
          (char *)victim_function_v5, tool->get_diasm_info()[0x8].address -
                                          tool->get_diasm_info()[0].address);
      info->set_virtual_start_addr(tool->get_diasm_info()[0].address);
      info->set_over_head_info(over_head_info);
      info->set_start_offset(1);
    }
    info->set_branch_miss_addr(tool->get_diasm_info()[0x7].address);
    info->set_cache_miss_addr(tool->get_diasm_info()[0x4].address);
    std::vector<diasm_code_tool::ptr> tmp;
    tmp.push_back(tool);
    info->set_diasm_code_ptr_vector(tmp);
    register_info_t reg_info;
    memset(&reg_info, 0, sizeof(reg_info));
    reg_info.RIP = tool->get_diasm_info()[7].address;
    reg_info.RFLAGS = 0x882;
    reg_info.RBP = 0x0000b46a48ecfbe8ll;
    reg_info.RSP = 0x0000b46a48ecfbe8ll;
    reg_info.RDI = 301526;
    reg_info.RAX = 20;
    info->set_branch_miss_register_info(reg_info);
    std::uniform_int_distribution<int> dist =
        std::uniform_int_distribution<int>(100000, 999999);
    static_analyze_tools tools(info, dist);

    auto res = tools.analyze();
    if (res.second == analyze_result::FIND_ATTACK) {
      std::cout << "func 5 find attack index = " << res.first.second << " \n";
    } else {
      std::cout << "func 5 no attack\n";
    }
  }
}
void test_func26() {
  diasm_code_tool::ptr tool = std::make_shared<diasm_code_tool>();
  tool->diasm_code(((const uint8_t *)victim_function_v6), 100,
                   (uint64_t)victim_function_v6);
  std::cout << "size " << tool->get_size() << "\n";
  for (int i = 0; i < tool->get_size(); ++i) {
    std::cout << i << "\t0x" << std::hex << tool->get_diasm_info()[i].address
              << '\t' << tool->get_diasm_info()[i].mnemonic << "\t"
              << tool->get_diasm_info()[i].op_str << "\n";
  }
  {
    full_diasm_info::ptr info = std::make_shared<full_diasm_info>();
    {
      std::string over_head_info = std::string(
          (char *)victim_function_v6, tool->get_diasm_info()[0x8].address -
                                          tool->get_diasm_info()[0].address);
      info->set_virtual_start_addr(tool->get_diasm_info()[0].address);
      info->set_over_head_info(over_head_info);
      info->set_start_offset(1);
    }
    info->set_branch_miss_addr(tool->get_diasm_info()[0x8].address);
    info->set_cache_miss_addr(tool->get_diasm_info()[0x4].address);
    std::vector<diasm_code_tool::ptr> tmp;
    tmp.push_back(tool);
    info->set_diasm_code_ptr_vector(tmp);
    register_info_t reg_info;
    memset(&reg_info, 0, sizeof(reg_info));
    reg_info.RIP = tool->get_diasm_info()[7].address;
    reg_info.RFLAGS = 0x882;
    reg_info.RBP = 0x0000b46a48ecfbe8ll;
    reg_info.RSP = 0x0000b46a48ecfbe8ll;
    reg_info.RDI = 301526;
    reg_info.RAX = 20;
    info->set_branch_miss_register_info(reg_info);
    std::uniform_int_distribution<int> dist =
        std::uniform_int_distribution<int>(100000, 999999);
    static_analyze_tools tools(info, dist);

    auto res = tools.analyze();
    if (res.second == analyze_result::FIND_ATTACK) {
      std::cout << "func 6 find attack index = " << res.first.second << " \n";
    } else {
      std::cout << "func 6 no attack\n";
    }
  }
}
void test_func27() {
  diasm_code_tool::ptr tool = std::make_shared<diasm_code_tool>();
  tool->diasm_code(((const uint8_t *)victim_function_v7), 100,
                   (uint64_t)victim_function_v7);
  std::cout << "size " << tool->get_size() << "\n";
  for (int i = 0; i < tool->get_size(); ++i) {
    std::cout << i << "\t0x" << std::hex << tool->get_diasm_info()[i].address
              << '\t' << tool->get_diasm_info()[i].mnemonic << "\t"
              << tool->get_diasm_info()[i].op_str << "\n";
  }
  {
    full_diasm_info::ptr info = std::make_shared<full_diasm_info>();
    {
      std::string over_head_info = std::string(
          (char *)victim_function_v7, tool->get_diasm_info()[0x6].address -
                                          tool->get_diasm_info()[0].address);
      info->set_virtual_start_addr(tool->get_diasm_info()[0].address);
      info->set_over_head_info(over_head_info);
      info->set_start_offset(1);
    }
    info->set_branch_miss_addr(tool->get_diasm_info()[0x6].address);
    info->set_cache_miss_addr(tool->get_diasm_info()[0x4].address);
    std::vector<diasm_code_tool::ptr> tmp;
    tmp.push_back(tool);
    info->set_diasm_code_ptr_vector(tmp);
    register_info_t reg_info;
    memset(&reg_info, 0, sizeof(reg_info));
    reg_info.RIP = tool->get_diasm_info()[7].address;
    reg_info.RFLAGS = 0x882;
    reg_info.RBP = 0x0000b46a48ecfbe8ll;
    reg_info.RSP = 0x0000b46a48ecfbe8ll;
    reg_info.RDI = 301526;
    reg_info.RAX = 20;
    info->set_branch_miss_register_info(reg_info);
    std::uniform_int_distribution<int> dist =
        std::uniform_int_distribution<int>(100000, 999999);
    static_analyze_tools tools(info, dist);

    auto res = tools.analyze();
    if (res.second == analyze_result::FIND_ATTACK) {
      std::cout << "func 7 find attack index = " << res.first.second << " \n";
    } else {
      std::cout << "func 7 no attack\n";
    }
  }
}
void test_func28() {
  diasm_code_tool::ptr tool = std::make_shared<diasm_code_tool>();
  tool->diasm_code(((const uint8_t *)victim_function_v8), 100,
                   (uint64_t)victim_function_v8);
  std::cout << "size " << tool->get_size() << "\n";
  for (int i = 0; i < tool->get_size(); ++i) {
    std::cout << i << "\t0x" << std::hex << tool->get_diasm_info()[i].address
              << '\t' << tool->get_diasm_info()[i].mnemonic << "\t"
              << tool->get_diasm_info()[i].op_str << "\n";
  }
  {
    full_diasm_info::ptr info = std::make_shared<full_diasm_info>();
    {
      std::string over_head_info = std::string(
          (char *)victim_function_v8, tool->get_diasm_info()[0x7].address -
                                          tool->get_diasm_info()[0].address);
      info->set_virtual_start_addr(tool->get_diasm_info()[0].address);
      info->set_over_head_info(over_head_info);
      info->set_start_offset(1);
    }
    info->set_branch_miss_addr(tool->get_diasm_info()[0x7].address);
    info->set_cache_miss_addr(tool->get_diasm_info()[0x4].address);
    std::vector<diasm_code_tool::ptr> tmp;
    tmp.push_back(tool);
    info->set_diasm_code_ptr_vector(tmp);
    register_info_t reg_info;
    memset(&reg_info, 0, sizeof(reg_info));
    reg_info.RIP = tool->get_diasm_info()[7].address;
    reg_info.RFLAGS = 0x882;
    reg_info.RBP = 0x0000b46a48ecfbe8ll;
    reg_info.RSP = 0x0000b46a48ecfbe8ll;
    reg_info.RDI = 301526;
    reg_info.RAX = 20;
    info->set_branch_miss_register_info(reg_info);
    std::uniform_int_distribution<int> dist =
        std::uniform_int_distribution<int>(100000, 999999);
    static_analyze_tools tools(info, dist);

    auto res = tools.analyze();
    if (res.second == analyze_result::FIND_ATTACK) {
      std::cout << "func 8 find attack index = " << res.first.second << " \n";
    } else {
      std::cout << "func 8 no attack\n";
    }
  }
}
void test_func29() {
  diasm_code_tool::ptr tool = std::make_shared<diasm_code_tool>();
  tool->diasm_code(((const uint8_t *)victim_function_v9), 100,
                   (uint64_t)victim_function_v9);
  std::cout << "size " << tool->get_size() << "\n";
  for (int i = 0; i < tool->get_size(); ++i) {
    std::cout << i << "\t0x" << std::hex << tool->get_diasm_info()[i].address
              << '\t' << tool->get_diasm_info()[i].mnemonic << "\t"
              << tool->get_diasm_info()[i].op_str << "\n";
  }
  {
    full_diasm_info::ptr info = std::make_shared<full_diasm_info>();
    {
      std::string over_head_info = std::string(
          (char *)victim_function_v9, tool->get_diasm_info()[0x8].address -
                                          tool->get_diasm_info()[0].address);
      info->set_virtual_start_addr(tool->get_diasm_info()[0].address);
      info->set_over_head_info(over_head_info);
      info->set_start_offset(1);
    }
    info->set_branch_miss_addr(tool->get_diasm_info()[0x8].address);
    info->set_cache_miss_addr(tool->get_diasm_info()[0x6].address);
    std::vector<diasm_code_tool::ptr> tmp;
    tmp.push_back(tool);
    info->set_diasm_code_ptr_vector(tmp);
    register_info_t reg_info;
    memset(&reg_info, 0, sizeof(reg_info));
    reg_info.RIP = tool->get_diasm_info()[7].address;
    reg_info.RFLAGS = 0x8c2;
    reg_info.RBP = 0x0000b46a48ecfbe8ll;
    reg_info.RSP = 0x0000b46a48ecfbe8ll;
    reg_info.RDI = 301526;
    reg_info.RAX = 20;
    info->set_branch_miss_register_info(reg_info);
    std::uniform_int_distribution<int> dist =
        std::uniform_int_distribution<int>(100000, 999999);
    static_analyze_tools tools(info, dist);

    auto res = tools.analyze();
    if (res.second == analyze_result::FIND_ATTACK) {
      std::cout << "func 9 find attack index = " << res.first.second << " \n";
    } else {
      std::cout << "func 9 no attack\n";
    }
  }
}
void test_func210() {
  diasm_code_tool::ptr tool = std::make_shared<diasm_code_tool>();
  tool->diasm_code(((const uint8_t *)victim_function_v10), 100,
                   (uint64_t)victim_function_v10);
  std::cout << "size " << tool->get_size() << "\n";
  for (int i = 0; i < tool->get_size(); ++i) {
    std::cout << i << "\t0x" << std::hex << tool->get_diasm_info()[i].address
              << '\t' << tool->get_diasm_info()[i].mnemonic << "\t"
              << tool->get_diasm_info()[i].op_str << "\n";
  }

  {
    full_diasm_info::ptr info = std::make_shared<full_diasm_info>();
    {
      std::string over_head_info = std::string(
          (char *)victim_function_v10, tool->get_diasm_info()[0x9].address -
                                           tool->get_diasm_info()[0].address);
      info->set_virtual_start_addr(tool->get_diasm_info()[0].address);
      info->set_over_head_info(over_head_info);
      info->set_start_offset(1);
    }
    info->set_branch_miss_addr(tool->get_diasm_info()[0x9].address);
    info->set_cache_miss_addr(tool->get_diasm_info()[6].address);
    // info->set_ret_addr(tool1->get_diasm_info()[8].address);
    std::vector<diasm_code_tool::ptr> tmp;
    tmp.push_back(tool);
    // tmp.push_back(tool1);
    info->set_diasm_code_ptr_vector(tmp);
    register_info_t reg_info;
    memset(&reg_info, 0, sizeof(reg_info));
    reg_info.RIP = tool->get_diasm_info()[7].address;
    reg_info.RFLAGS = 0x882;
    // reg_info.RFLAGS = 0x8c2;
    reg_info.RBP = 0x0000b46a48ecfbe8ll;
    reg_info.RSP = 0x0000b46a48ecfbe8ll;
    reg_info.RDI = 301526;
    reg_info.RAX = 20;
    info->set_branch_miss_register_info(reg_info);

    std::uniform_int_distribution<int> dist =
        std::uniform_int_distribution<int>(100000, 999999);
    static_analyze_tools tools(info, dist);

    auto res = tools.analyze();
    if (res.second == analyze_result::FIND_ATTACK) {
      std::cout << "func 10 find attack index = " << res.first.second << " \n";
    } else {
      std::cout << "func 10 no attack\n";
    }
  }
}
void test_func211() {
  diasm_code_tool::ptr tool = std::make_shared<diasm_code_tool>();
  tool->diasm_code(((const uint8_t *)victim_function_v11), 100,
                   (uint64_t)victim_function_v11);
  std::cout << "size " << tool->get_size() << "\n";
  for (int i = 0; i < tool->get_size(); ++i) {
    std::cout << i << "\t0x" << std::hex << tool->get_diasm_info()[i].address
              << '\t' << tool->get_diasm_info()[i].mnemonic << "\t"
              << tool->get_diasm_info()[i].op_str << "\n";
  }
  {
    full_diasm_info::ptr info = std::make_shared<full_diasm_info>();
    {
      std::string over_head_info = std::string(
          (char *)victim_function_v11, tool->get_diasm_info()[0x7].address -
                                           tool->get_diasm_info()[0].address);
      info->set_virtual_start_addr(tool->get_diasm_info()[0].address);
      info->set_over_head_info(over_head_info);
      info->set_start_offset(1);
    }
    info->set_branch_miss_addr(tool->get_diasm_info()[0x7].address);
    info->set_cache_miss_addr(tool->get_diasm_info()[0x4].address);
    std::vector<diasm_code_tool::ptr> tmp;
    tmp.push_back(tool);
    info->set_diasm_code_ptr_vector(tmp);
    register_info_t reg_info;
    memset(&reg_info, 0, sizeof(reg_info));
    reg_info.RIP = tool->get_diasm_info()[7].address;
    reg_info.RFLAGS = 0x882;
    reg_info.RBP = 0x0000b46a48ecfbe8ll;
    reg_info.RSP = 0x0000b46a48ecfbe8ll;
    reg_info.RDI = 301526;
    reg_info.RAX = 20;
    info->set_branch_miss_register_info(reg_info);
    std::uniform_int_distribution<int> dist =
        std::uniform_int_distribution<int>(100000, 999999);
    static_analyze_tools tools(info, dist);

    auto res = tools.analyze();
    if (res.second == analyze_result::FIND_ATTACK) {
      std::cout << "func 11 find attack index = " << res.first.second << " \n";
    } else {
      std::cout << "func 11 no attack\n";
    }
  }
}
void test_func212() {
  diasm_code_tool::ptr tool = std::make_shared<diasm_code_tool>();
  tool->diasm_code(((const uint8_t *)victim_function_v12), 100,
                   (uint64_t)victim_function_v12);
  std::cout << "size " << tool->get_size() << "\n";
  for (int i = 0; i < tool->get_size(); ++i) {
    std::cout << i << "\t0x" << std::hex << tool->get_diasm_info()[i].address
              << '\t' << tool->get_diasm_info()[i].mnemonic << "\t"
              << tool->get_diasm_info()[i].op_str << "\n";
  }
  {
    full_diasm_info::ptr info = std::make_shared<full_diasm_info>();
    {
      std::string over_head_info = std::string(
          (char *)victim_function_v12, tool->get_diasm_info()[0xb].address -
                                           tool->get_diasm_info()[0].address);
      info->set_virtual_start_addr(tool->get_diasm_info()[0].address);
      info->set_over_head_info(over_head_info);
      info->set_start_offset(1);
    }
    info->set_branch_miss_addr(tool->get_diasm_info()[0xb].address);
    info->set_cache_miss_addr(tool->get_diasm_info()[0x8].address);
    std::vector<diasm_code_tool::ptr> tmp;
    tmp.push_back(tool);
    info->set_diasm_code_ptr_vector(tmp);
    register_info_t reg_info;
    memset(&reg_info, 0, sizeof(reg_info));
    reg_info.RIP = tool->get_diasm_info()[7].address;
    reg_info.RFLAGS = 0x882;
    reg_info.RBP = 0x0000b46a48ecfbe8ll;
    reg_info.RSP = 0x0000b46a48ecfbe8ll;
    reg_info.RDI = 301526;
    reg_info.RAX = 20;
    info->set_branch_miss_register_info(reg_info);
    std::uniform_int_distribution<int> dist =
        std::uniform_int_distribution<int>(100000, 999999);
    static_analyze_tools tools(info, dist);

    auto res = tools.analyze();
    if (res.second == analyze_result::FIND_ATTACK) {
      std::cout << "func 12 find attack index = " << res.first.second << " \n";
    } else {
      std::cout << "func 12 no attack\n";
    }
  }
}
void test_func213() {
  diasm_code_tool::ptr tool = std::make_shared<diasm_code_tool>();
  tool->diasm_code(((const uint8_t *)is_x_safe), 100, (uint64_t)is_x_safe);
  std::cout << "size " << tool->get_size() << "\n";
  for (int i = 0; i < tool->get_size(); ++i) {
    std::cout << i << "\t0x" << std::hex << tool->get_diasm_info()[i].address
              << '\t' << tool->get_diasm_info()[i].mnemonic << "\t"
              << tool->get_diasm_info()[i].op_str << "\n";
  }

  {
    diasm_code_tool::ptr tool1 = std::make_shared<diasm_code_tool>();
    tool1->diasm_code(((const uint8_t *)victim_function_v13), 100,
                      (uint64_t)victim_function_v13);
    std::cout << "size " << tool1->get_size() << "\n";
    for (int i = 0; i < tool1->get_size(); ++i) {
      std::cout << i << "\t0x" << std::hex << tool1->get_diasm_info()[i].address
                << '\t' << tool1->get_diasm_info()[i].mnemonic << "\t"
                << tool1->get_diasm_info()[i].op_str << "\n";
    }

    full_diasm_info::ptr info = std::make_shared<full_diasm_info>();
    {
      std::string over_head_info = "";
      info->set_virtual_start_addr(tool->get_diasm_info()[0].address);
      info->set_over_head_info(over_head_info);
      info->set_start_offset(1);
    }
    info->set_branch_miss_addr(tool->get_diasm_info()[0x7].address);
    info->set_cache_miss_addr(tool->get_diasm_info()[4].address);
    info->set_ret_addr(tool1->get_diasm_info()[8].address);
    std::vector<diasm_code_tool::ptr> tmp;
    tmp.push_back(tool);
    tmp.push_back(tool1);
    info->set_diasm_code_ptr_vector(tmp);
    register_info_t reg_info;
    memset(&reg_info, 0, sizeof(reg_info));
    reg_info.RIP = tool->get_diasm_info()[7].address;
    reg_info.RFLAGS = 0x882;
    // reg_info.RFLAGS = 0x8c2;
    reg_info.RBP = 0x0000b46a48ecfbe8ll;
    reg_info.RSP = 0x0000b46a48ecfbe8ll;
    reg_info.RDI = 301526;
    reg_info.RAX = 20;
    info->set_branch_miss_register_info(reg_info);

    std::uniform_int_distribution<int> dist =
        std::uniform_int_distribution<int>(100000, 999999);
    static_analyze_tools tools(info, dist);
    auto res = tools.analyze();
    if (res.second == analyze_result::FIND_ATTACK) {
      std::cout << "func 13 find attack index = " << res.first.second << " \n";
    } else {
      std::cout << "func 13 no attack\n";
    }
  }
}
void test_func214() {
  diasm_code_tool::ptr tool = std::make_shared<diasm_code_tool>();
  tool->diasm_code(((const uint8_t *)victim_function_v14), 100,
                   (uint64_t)victim_function_v14);
  std::cout << "size " << tool->get_size() << "\n";
  for (int i = 0; i < tool->get_size(); ++i) {
    std::cout << i << "\t0x" << std::hex << tool->get_diasm_info()[i].address
              << '\t' << tool->get_diasm_info()[i].mnemonic << "\t"
              << tool->get_diasm_info()[i].op_str << "\n";
  }
  {
    full_diasm_info::ptr info = std::make_shared<full_diasm_info>();
    {
      std::string over_head_info = std::string(
          (char *)victim_function_v14, tool->get_diasm_info()[0x7].address -
                                           tool->get_diasm_info()[0].address);
      info->set_virtual_start_addr(tool->get_diasm_info()[0].address);
      info->set_over_head_info(over_head_info);
      info->set_start_offset(1);
    }
    info->set_branch_miss_addr(tool->get_diasm_info()[0x7].address);
    info->set_cache_miss_addr(tool->get_diasm_info()[0x4].address);
    std::vector<diasm_code_tool::ptr> tmp;
    tmp.push_back(tool);
    info->set_diasm_code_ptr_vector(tmp);
    register_info_t reg_info;
    memset(&reg_info, 0, sizeof(reg_info));
    reg_info.RIP = tool->get_diasm_info()[7].address;
    reg_info.RFLAGS = 0x882;
    reg_info.RBP = 0x0000b46a48ecfbe8ll;
    reg_info.RSP = 0x0000b46a48ecfbe8ll;
    reg_info.RDI = 301526;
    reg_info.RAX = 20;
    info->set_branch_miss_register_info(reg_info);
    std::uniform_int_distribution<int> dist =
        std::uniform_int_distribution<int>(100000, 999999);
    static_analyze_tools tools(info, dist);

    auto res = tools.analyze();
    if (res.second == analyze_result::FIND_ATTACK) {
      std::cout << "func 14 find attack index = " << res.first.second << " \n";
    } else {
      std::cout << "func 14 no attack\n";
    }
  }
}
void test_func215() {
  diasm_code_tool::ptr tool = std::make_shared<diasm_code_tool>();
  tool->diasm_code(((const uint8_t *)victim_function_v15), 100,
                   (uint64_t)victim_function_v15);
  std::cout << "size " << tool->get_size() << "\n";
  for (int i = 0; i < tool->get_size(); ++i) {
    std::cout << i << "\t0x" << std::hex << tool->get_diasm_info()[i].address
              << '\t' << tool->get_diasm_info()[i].mnemonic << "\t"
              << tool->get_diasm_info()[i].op_str << "\n";
  }
  {
    full_diasm_info::ptr info = std::make_shared<full_diasm_info>();
    {
      std::string over_head_info = std::string(
          (char *)victim_function_v15, tool->get_diasm_info()[0x9].address -
                                           tool->get_diasm_info()[0].address);
      info->set_virtual_start_addr(tool->get_diasm_info()[0].address);
      info->set_over_head_info(over_head_info);
      info->set_start_offset(1);
    }
    info->set_branch_miss_addr(tool->get_diasm_info()[0x9].address);
    info->set_cache_miss_addr(tool->get_diasm_info()[0x6].address);
    std::vector<diasm_code_tool::ptr> tmp;
    tmp.push_back(tool);
    info->set_diasm_code_ptr_vector(tmp);
    register_info_t reg_info;
    memset(&reg_info, 0, sizeof(reg_info));
    reg_info.RIP = tool->get_diasm_info()[7].address;
    reg_info.RFLAGS = 0x882;
    reg_info.RBP = 0x0000b46a48ecfbe8ll;
    reg_info.RSP = 0x0000b46a48ecfbe8ll;
    reg_info.RDI = 301526;
    reg_info.RAX = 20;
    info->set_branch_miss_register_info(reg_info);
    std::uniform_int_distribution<int> dist =
        std::uniform_int_distribution<int>(100000, 999999);
    static_analyze_tools tools(info, dist);

    auto res = tools.analyze();
    if (res.second == analyze_result::FIND_ATTACK) {
      std::cout << "func 15 find attack index = " << res.first.second << " \n";
    } else {
      std::cout << "func 15 no attack\n";
    }
  }
}
void test_analyze_func() {
  diasm_code_tool::ptr tool = std::make_shared<diasm_code_tool>();
  tool->diasm_code(((const uint8_t *)victim_function_v1), 100,
                   (uint64_t)victim_function_v1);
  std::string over_head_info = std::string(
      (char *)victim_function_v1,
      tool->get_diasm_info()[0x7].address - tool->get_diasm_info()[0].address);

  for (int i = 0; i < tool->get_size(); ++i) {
    std::cout << i << "\t0x" << std::hex << tool->get_diasm_info()[i].address
              << '\t' << tool->get_diasm_info()[i].mnemonic << "\t"
              << tool->get_diasm_info()[i].op_str << "\n";
  }
  std::cout << "size " << tool->get_size() << "\n";
  {
    full_diasm_info::ptr info = std::make_shared<full_diasm_info>();
    info->set_virtual_start_addr(tool->get_diasm_info()[0].address);
    info->set_over_head_info(over_head_info);
    info->set_start_offset(1);
    info->set_branch_miss_addr(tool->get_diasm_info()[0x7].address);
    info->set_cache_miss_addr(tool->get_diasm_info()[0x4].address);
    std::vector<diasm_code_tool::ptr> tmp;
    tmp.push_back(tool);
    info->set_diasm_code_ptr_vector(tmp);
    register_info_t reg_info;
    memset(&reg_info, 0, sizeof(reg_info));
    reg_info.RIP = tool->get_diasm_info()[7].address;
    reg_info.RFLAGS = 0x882;
    reg_info.RBP = 0x0000b46a48ecfbe8ll;
    reg_info.RSP = 0x0000b46a48ecfbe8ll;
    reg_info.RDI = 301526;
    reg_info.RAX = 20;
    info->set_branch_miss_register_info(reg_info);
    std::uniform_int_distribution<int> dist =
        std::uniform_int_distribution<int>(100000, 999999);
    static_analyze_tools tools(info, dist);

    auto res = tools.analyze();
    if (res.second == analyze_result::FIND_ATTACK) {
      std::cout << "func 1 find attack index = " << res.first.second << " \n";
    } else {
      std::cout << "func 1 no attack\n";
    }
  }
}
void test_func3() {
  //
  netlink_tool::ptr net_link_tool_pt = std::make_shared<netlink_tool>(getpid());
  share_mem_tool::ptr share_mem_tool_ptr = std::make_shared<share_mem_tool>();
  if (!share_mem_tool_ptr->init()) {
    std::cout << "fail init share_mem";
    return;
  }
  char data[32];
  data[0] = 't';
  // *((uint64_t *)(data + 8)) = 0xffffffff55cc66cc;
  // *((uint32_t *)(data + 16)) = 0xffff0000;
  // *((uint64_t *)(data + 24)) = 0x6699336655886699;
  net_link_tool_pt->send_message(std::string(data, 32));
  std::string test = share_mem_tool_ptr->read_data();
  if (test.length() != 0) {
    full_diasm_info info;
    info.analyze_recy_data(test);
  }

  // std::string tmp = net_link_tool_pt->recieve_message();
  // net_link_tool_pt->destory();
  // full_diasm_info tmp_tool = full_diasm_info();
  // tmp_tool.analyze_recy_data(tmp);
}
void test_func4() {
  get_info_by_ptrace test(188078, 0x5583ce2ca22a);
  test.get_info();
}
void test_func5() {
  std::regex taine_pattern("#symbol[0-9]{6}#");
  std::smatch match_result;

  std::string str = "#symbol218388# + #symbol579509#";
  std::string::const_iterator iterStart = str.begin();
  std::string::const_iterator iterEnd = str.end();

  while (std::regex_search(iterStart, iterEnd, match_result, taine_pattern)) {
    // 记录从符号中找到的符号
    std::cout << match_result[0] << "\n";
    iterStart = match_result[0].second;
  }
}
void test_func6() {
  std::default_random_engine random;
  state_symbol test1 =
      state_symbol(get_symbol_str(random), 8,
                   {get_taine_string(taine_enum::taine1, random)});

  state_symbol test4 = state_symbol(get_symbol_str(random), 8);
  state_symbol test2 =
      state_symbol(get_symbol_str(random), 8,
                   {get_taine_string(taine_enum::taine1, random)});
  state_symbol test5 = state_symbol(get_symbol_str(random), 8);
  state_symbol test3 = test1 + test2;
  auto test = test3.judge_taine_same(test1);
  auto copy = test3;

  std::cout << test3.to_string() << "\n";
}
void test_func7() {
  std::string path =
      "/home/corvus/code/pebs_all/pebs_user_mod_src/build/tmp_diasmfile/"
      "save_diasm_info/diasm_info119233.dat";
  // std::string path =
  //     "/home/corvus/code/pebs_all/pebs_user_mod_src/build/tmp_diasmfile/"
  //     "save_diasm_info/64/v13/gcc/diasm_info154845.dat";
  full_diasm_info::ptr test;
  std::ifstream ifs(path);
  boost::archive::text_iarchive ia(ifs);
  ia >> test;
  ifs.close();
  std::cout << test->get_diasm_string_stream().str() << "\n";
  // std::cout << test->get_branch_miss_addr_reg_info_str().str() << "\n";

  // auto name = test->get_exec_file_name();
  // if (name[0] == 's' & name[1] == 'p' && name[2] == 'e') {
  //   std::cout<<"ensure\n";
  // } else {
  //   std::cout<<"unensure\n";
  // }
  // test->set_start_offset(51727);
  // std::cout << test->get_diasm_string_stream().str();
  std::uniform_int_distribution<int> dist =
      std::uniform_int_distribution<int>(100000, 999999);
  // for (int i = 0; i < 1000; ++i) {
  // test->_judge_addr_is_mem_map[0x56505bd48060] = true;
  static_analyze_tools tools(test, dist);
  boost::this_thread::sleep_for(boost::chrono::milliseconds(20));
  auto res = tools.analyze();

  if (res.second == analyze_result::FIND_ATTACK) {
    std::cout << "find attack index = " << res.first.second << "\n";
  } else {
    std::cout << "no attack\n";
  }
}
void test_func8() {
  std::filesystem::path folderPath =
      "/home/corvus/code/pebs_all/pebs_user_mod_src/build/tmp_diasmfile/"
      "save_diasm_info/";
  // 检查文件夹是否存在
  if (!std::filesystem::exists(folderPath) ||
      !std::filesystem::is_directory(folderPath)) {
    std::cerr << "Folder does not exist." << std::endl;
    return;
  }

  // 遍历文件夹中的所有文件
  for (const auto &entry : std::filesystem::directory_iterator(folderPath)) {
    std::cout << entry.path().filename() << std::endl;
    std::string path =
        "/home/corvus/code/pebs_all/pebs_user_mod_src/build/tmp_diasmfile/"
        "save_diasm_info/";
    path += entry.path().filename();
    full_diasm_info::ptr test;
    std::ifstream ifs(path);
    boost::archive::text_iarchive ia(ifs);
    ia >> test;
    ifs.close();
    // std::cout << test->get_diasm_string_stream().str();
    std::uniform_int_distribution<int> dist =
        std::uniform_int_distribution<int>(100000, 999999);
    // for (int i = 0; i < 1000; ++i) {
    static_analyze_tools tools(test, dist);
    boost::this_thread::sleep_for(boost::chrono::milliseconds(20));
    auto res = tools.analyze();

    if (res.second == analyze_result::FIND_ATTACK) {
      std::cout << "find attack index = " << res.first.second << "\n";
    } else {
      std::cout << "no attack\n";
    }
  }
}
void test_func9() {
  std::string path =
      "/home/corvus/code/pebs_all/pebs_user_mod_src/build/tmp_diasmfile/"
      "save_diasm_info/diasm_info468022.dat";
  full_diasm_info::ptr test;
  std::ifstream ifs(path);
  boost::archive::text_iarchive ia(ifs);
  ia >> test;
  ifs.close();
  for (int i = 0; i < 1024; ++i) {
    uint32_t start_offset = get_start_addr_offset(
        test->get_over_head_info().c_str(), test->get_virtual_start_addr(),
        test->get_cache_miss_addr());
    std::cout << start_offset << "\n";
  }

  // }
}
void test_func10() {
  test_func21();
  test_func22();
  test_func23();
  test_func24();
  test_func25();
  test_func26();
  test_func27();
  test_func28();
  test_func29();
  test_func210();
  test_func211();
  test_func212();
  test_func213();
  test_func214();
  test_func215();
}
void test_func11() {
  // 获取开始时间点
  auto start = std::chrono::high_resolution_clock::now();

  // 模拟一些工作
  std::this_thread::sleep_for(std::chrono::milliseconds(500));

  // 获取结束时间点
  auto end = std::chrono::high_resolution_clock::now();

  // 计算持续时间
  std::chrono::duration<double, std::milli> duration = end - start;

  // 比较持续时间是否大于400毫秒
  if (duration.count() > 400.0) {
    std::cout << "代码执行时间超过400毫秒: " << duration.count() << " 毫秒"
              << std::endl;
  } else {
    std::cout << "代码执行时间不超过400毫秒: " << duration.count() << " 毫秒"
              << std::endl;
  }
}
void test_func12() {
  for (int folder_index = 1; folder_index <= 15; ++folder_index) {
    std::stringstream cl_folder_path_stream;
    cl_folder_path_stream
        << "/home/corvus/code/pebs_all/pebs_user_mod_src/build/"
           "tmp_diasmfile/"
        << "save_diasm_info/64/v" << folder_index << "/clang/";
    std::stringstream gcc_folder_path_stream;
    gcc_folder_path_stream
        << "/home/corvus/code/pebs_all/pebs_user_mod_src/build/"
           "tmp_diasmfile/"
        << "save_diasm_info/64/v" << folder_index << "/gcc/";

    std::filesystem::path folderPath_cl = cl_folder_path_stream.str();
    std::filesystem::path folderPath_gcc = gcc_folder_path_stream.str();
    if (!std::filesystem::exists(folderPath_cl) ||
        !std::filesystem::is_directory(folderPath_cl)) {
      std::cerr << "Folder does not exist." << std::endl;
      return;
    }
    if (!std::filesystem::exists(folderPath_gcc) ||
        !std::filesystem::is_directory(folderPath_gcc)) {
      std::cerr << "Folder does not exist." << std::endl;
      return;
    }
    for (const auto &entry :
         std::filesystem::directory_iterator(folderPath_cl)) {
      std::string path = cl_folder_path_stream.str();
      path += entry.path().filename();
      std::cout << path << std::endl;

      full_diasm_info::ptr test;
      std::ifstream ifs(path);
      boost::archive::text_iarchive ia(ifs);
      ia >> test;
      ifs.close();
      // std::cout << test->get_diasm_string_stream().str();
      std::uniform_int_distribution<int> dist =
          std::uniform_int_distribution<int>(100000, 999999);
      // for (int i = 0; i < 1000; ++i) {
      static_analyze_tools tools(test, dist);
      boost::this_thread::sleep_for(boost::chrono::milliseconds(20));
      auto res = tools.analyze();

      if (res.second == analyze_result::FIND_ATTACK) {
        std::cout << "find attack index = " << res.first.second << "\n";
      } else {
        std::cout << "no attack\n";
      }
    }
    for (const auto &entry :
         std::filesystem::directory_iterator(folderPath_gcc)) {
      std::string path = gcc_folder_path_stream.str();
      path += entry.path().filename();
      std::cout << path << std::endl;

      full_diasm_info::ptr test;
      std::ifstream ifs(path);
      boost::archive::text_iarchive ia(ifs);
      ia >> test;
      ifs.close();
      // std::cout << test->get_diasm_string_stream().str();
      std::uniform_int_distribution<int> dist =
          std::uniform_int_distribution<int>(100000, 999999);
      // for (int i = 0; i < 1000; ++i) {
      static_analyze_tools tools(test, dist);
      boost::this_thread::sleep_for(boost::chrono::milliseconds(20));
      auto res = tools.analyze();

      if (res.second == analyze_result::FIND_ATTACK) {
        std::cout << "find attack index = " << res.first.second << "\n";
      } else {
        std::cout << "no attack\n";
      }
    }
  }
  for (int folder_index = 2; folder_index <= 3; ++folder_index) {
    std::stringstream cl_folder_path_stream;
    cl_folder_path_stream
        << "/home/corvus/code/pebs_all/pebs_user_mod_src/build/"
           "tmp_diasmfile/"
        << "save_diasm_info/64/v" << folder_index << "_change1/clang/";
    std::stringstream gcc_folder_path_stream;
    gcc_folder_path_stream
        << "/home/corvus/code/pebs_all/pebs_user_mod_src/build/"
           "tmp_diasmfile/"
        << "save_diasm_info/64/v" << folder_index << "_change1/gcc/";

    std::filesystem::path folderPath_cl = cl_folder_path_stream.str();
    std::filesystem::path folderPath_gcc = gcc_folder_path_stream.str();
    if (!std::filesystem::exists(folderPath_cl) ||
        !std::filesystem::is_directory(folderPath_cl)) {
      std::cerr << "Folder does not exist." << std::endl;
      return;
    }
    if (!std::filesystem::exists(folderPath_gcc) ||
        !std::filesystem::is_directory(folderPath_gcc)) {
      std::cerr << "Folder does not exist." << std::endl;
      return;
    }
    for (const auto &entry :
         std::filesystem::directory_iterator(folderPath_cl)) {
      std::string path = cl_folder_path_stream.str();
      path += entry.path().filename();
      std::cout << path << std::endl;

      full_diasm_info::ptr test;
      std::ifstream ifs(path);
      boost::archive::text_iarchive ia(ifs);
      ia >> test;
      ifs.close();
      // std::cout << test->get_diasm_string_stream().str();
      std::uniform_int_distribution<int> dist =
          std::uniform_int_distribution<int>(100000, 999999);
      // for (int i = 0; i < 1000; ++i) {
      static_analyze_tools tools(test, dist);
      boost::this_thread::sleep_for(boost::chrono::milliseconds(20));
      auto res = tools.analyze();

      if (res.second == analyze_result::FIND_ATTACK) {
        std::cout << "find attack index = " << res.first.second << "\n";
      } else {
        std::cout << "no attack\n";
      }
    }
    for (const auto &entry :
         std::filesystem::directory_iterator(folderPath_gcc)) {
      std::string path = gcc_folder_path_stream.str();
      path += entry.path().filename();
      std::cout << path << std::endl;

      full_diasm_info::ptr test;
      std::ifstream ifs(path);
      boost::archive::text_iarchive ia(ifs);
      ia >> test;
      ifs.close();
      // std::cout << test->get_diasm_string_stream().str();
      std::uniform_int_distribution<int> dist =
          std::uniform_int_distribution<int>(100000, 999999);
      // for (int i = 0; i < 1000; ++i) {
      static_analyze_tools tools(test, dist);
      boost::this_thread::sleep_for(boost::chrono::milliseconds(20));
      auto res = tools.analyze();

      if (res.second == analyze_result::FIND_ATTACK) {
        std::cout << "find attack index = " << res.first.second << "\n";
      } else {
        std::cout << "no attack\n";
      }
    }
  }
  for (int folder_index = 2; folder_index <= 3; ++folder_index) {
    std::stringstream cl_folder_path_stream;
    cl_folder_path_stream
        << "/home/corvus/code/pebs_all/pebs_user_mod_src/build/"
           "tmp_diasmfile/"
        << "save_diasm_info/64/v" << folder_index << "_change/clang/";
    std::stringstream gcc_folder_path_stream;
    gcc_folder_path_stream
        << "/home/corvus/code/pebs_all/pebs_user_mod_src/build/"
           "tmp_diasmfile/"
        << "save_diasm_info/64/v" << folder_index << "_change/gcc/";

    std::filesystem::path folderPath_cl = cl_folder_path_stream.str();
    std::filesystem::path folderPath_gcc = gcc_folder_path_stream.str();
    if (!std::filesystem::exists(folderPath_cl) ||
        !std::filesystem::is_directory(folderPath_cl)) {
      std::cerr << "Folder does not exist." << std::endl;
      return;
    }
    if (!std::filesystem::exists(folderPath_gcc) ||
        !std::filesystem::is_directory(folderPath_gcc)) {
      std::cerr << "Folder does not exist." << std::endl;
      return;
    }
    for (const auto &entry :
         std::filesystem::directory_iterator(folderPath_cl)) {
      std::string path = cl_folder_path_stream.str();
      path += entry.path().filename();
      std::cout << path << std::endl;

      full_diasm_info::ptr test;
      std::ifstream ifs(path);
      boost::archive::text_iarchive ia(ifs);
      ia >> test;
      ifs.close();
      // std::cout << test->get_diasm_string_stream().str();
      std::uniform_int_distribution<int> dist =
          std::uniform_int_distribution<int>(100000, 999999);
      // for (int i = 0; i < 1000; ++i) {
      static_analyze_tools tools(test, dist);
      boost::this_thread::sleep_for(boost::chrono::milliseconds(20));
      auto res = tools.analyze();

      if (res.second == analyze_result::FIND_ATTACK) {
        std::cout << "find attack index = " << res.first.second << "\n";
      } else {
        std::cout << "no attack\n";
      }
    }
    for (const auto &entry :
         std::filesystem::directory_iterator(folderPath_gcc)) {
      std::string path = gcc_folder_path_stream.str();
      path += entry.path().filename();
      std::cout << path << std::endl;

      full_diasm_info::ptr test;
      std::ifstream ifs(path);
      boost::archive::text_iarchive ia(ifs);
      ia >> test;
      ifs.close();
      // std::cout << test->get_diasm_string_stream().str();
      std::uniform_int_distribution<int> dist =
          std::uniform_int_distribution<int>(100000, 999999);
      // for (int i = 0; i < 1000; ++i) {
      static_analyze_tools tools(test, dist);
      boost::this_thread::sleep_for(boost::chrono::milliseconds(20));
      auto res = tools.analyze();

      if (res.second == analyze_result::FIND_ATTACK) {
        std::cout << "find attack index = " << res.first.second << "\n";
      } else {
        std::cout << "no attack\n";
      }
    }
  }
  {
    std::string path =
        "/home/corvus/code/pebs_all/pebs_user_mod_src/build/tmp_diasmfile/"
        "save_diasm_info/chrome.dat";
    std::cout << path << std::endl;

    full_diasm_info::ptr test;
    std::ifstream ifs(path);
    boost::archive::text_iarchive ia(ifs);
    ia >> test;
    ifs.close();
    // std::cout << test->get_diasm_string_stream().str();
    std::uniform_int_distribution<int> dist =
        std::uniform_int_distribution<int>(100000, 999999);
    // for (int i = 0; i < 1000; ++i) {
    static_analyze_tools tools(test, dist);
    boost::this_thread::sleep_for(boost::chrono::milliseconds(20));
    auto res = tools.analyze();

    if (res.second == analyze_result::FIND_ATTACK) {
      std::cout << "find attack index = " << res.first.second << "\n";
    } else {
      std::cout << "no attack\n";
    }
  }
}
void test_func13() {
  std::string exec_file_path;
  uint64_t pid = 210221;
  // 获取可执行文件的路径
  {
    std::stringstream path;
    char exe_path[256];

    path << "/proc/" << pid << "/exe";
    size_t len = readlink(path.str().c_str(), exe_path, sizeof(exe_path) - 1);
    if (len == -1) {
      std::cout << "err\n";
      return;
    }
    exe_path[len] = '\0';
    exec_file_path = exe_path;
    std::cout << exec_file_path << "\n";
  }
  // 获取可执行文件的装载信息
  uint64_t load_addr;
  {
    std::stringstream path;
    path << "/proc/" << pid << "/maps";
    std::ifstream file(path.str());
    if (!file.is_open()) {
      std::cerr << "Failed to open the file." << std::endl;
      return;
    }
    std::string line;
    // 逐行读取文件内容并输出到控制台
    std::getline(file, line);
    file.close();
    int end = line.find('-');
    std::string addr_str = line.substr(0, end);
    load_addr = std::stoull(addr_str, 0, 16);
  }
  // 获取可执行文件的plt信息
  {
    std::map<uint64_t, std::string> res;
    std::stringstream result;
    std::array<char, 128> buffer;
    std::stringstream exec;
    exec << "objdump -D --section=.plt " << exec_file_path << " |grep '@plt>:'";
    FILE *pipe = popen(exec.str().c_str(), "r");

    if (!pipe) {
      throw std::runtime_error("popen() failed!");
    }
    // 从 pipe 中读取命令的输出
    while (fgets(buffer.data(), buffer.size(), pipe) != nullptr) {
      result << buffer.data();
    }
    pclose(pipe);
    std::string line;
    while (std::getline(result, line)) {
      // std::cout << line << std::endl;
      int end = line.find(' ');
      std::string addr_str = line.substr(0, end);
      uint64_t addr = std::stoull(addr_str, 0, 16);
      std::string name = line.substr(end + 1, line.length());
      res[addr] = name;
    }
  }
}
void test_func14() {
  // auto share_mem_key = ftok(SHARE_MEM_NAME, SHARE_MEM_ID);
  // if (share_mem_key == -1) {
  //   perror("ftok error");
  //   return;
  // }
  // int shmId = shmget(share_mem_key, 4096, IPC_CREAT | 0600);
  // if (shmId == -1) {
  //   perror("shmget error");
  //   return;
  // }
  // uint64_t *addr = (uint64_t *)shmat(shmId, NULL, SHM_RDONLY);
  // if ((int64_t)addr != -1) {
  //   auto tmp = *addr;
  //   auto tmp1 = *(addr + 1);
  //   shmdt(addr);
  //   std::cout << tmp << "\n";
  //   std::cout << tmp1 << "\n";

  // } else {
  //   std::cout << "error \n";
  // }
  // int sh = shmctl(shmId, IPC_RMID, NULL);
  // if (sh == -1) {
  //   perror("shmctl error");
  //   return;
  // }
  auto test = std::make_shared<attack_share_mem>();
  if (test->effect) {
    auto test1 = test->read_data();
    std::chrono::duration<double, std::milli> use_time =
        std::chrono::high_resolution_clock::now() - test1.first;
    std::cout << use_time.count() << "\n";
    std::cout << test1.second << "\n";
  } else {
    std::cout << "fail\n";
  }
}
/**
 * @brief 程序入口
 * @return int
 */
int main(int argc, char *argv[]) {
  netlink_tool::ptr net_link_tool_pt = NULL;
  async_analyze_code_tool::ptr analyze_code_tool_ptr = NULL;
  std::string text;
  share_mem_tool::ptr share_mem_tool_ptr = nullptr;

  while (true) {
    // try {
    //   if (analyze_code_tool_ptr != nullptr) {
    //     if (analyze_code_tool_ptr->get_analyze_except_ptr() != nullptr) {
    //       std::rethrow_exception(
    //           analyze_code_tool_ptr->get_analyze_except_ptr());
    //     }
    //     if (analyze_code_tool_ptr->get_recv_except_ptr() != nullptr) {
    //       std::rethrow_exception(analyze_code_tool_ptr->get_recv_except_ptr());
    //     }
    //   }
    // } catch (std::exception &e) {
    //   std::cout << e.what();
    //   if (net_link_tool_pt != NULL) {
    //     net_link_tool_pt->send_message("s");
    //     net_link_tool_pt->destory();
    //   }
    //   break;
    // }

    std::getline(std::cin, text, '\n');
    if (text == "start") {
      //初始化net_link_tool_pt analyze_code_tool_ptr recv_thread
      {
        if (net_link_tool_pt == NULL) {
          net_link_tool_pt = std::make_shared<netlink_tool>(getpid());
          if (!net_link_tool_pt->effective()) {
            std::cout << "netlink_tool_ptr inti fail\n";
            return 0;
          }
        }
        if (share_mem_tool_ptr == NULL) {
          share_mem_tool_ptr = std::make_shared<share_mem_tool>();
          if (!share_mem_tool_ptr->init()) {
            std::cout << "share_mem_tool_ptr inti fail\n";
            return 0;
          }
        }
        if (analyze_code_tool_ptr == NULL) {
          analyze_code_tool_ptr = std::make_shared<async_analyze_code_tool>(
              net_link_tool_pt, share_mem_tool_ptr);
        }
      }
      //向内核发送消息表示准备开始
      try {
        net_link_tool_pt->send_message("r");
        analyze_code_tool_ptr->start_recv_thread();
        analyze_code_tool_ptr->start_analyze_data();
      } catch (std::runtime_error e) {
        std::cout << e.what() << "\n";
        break;
      }
    } else if (text == "stop") {
      try {
        if (net_link_tool_pt != NULL) {
          net_link_tool_pt->send_message("s");
        } else {
          net_link_tool_pt = std::make_shared<netlink_tool>(getpid());
          if (net_link_tool_pt->effective()) {
            net_link_tool_pt->send_message("s");
            net_link_tool_pt->destory();
          }
        }
      } catch (std::runtime_error e) {
        std::cout << e.what() << "\n";
        break;
      }
      break;
    } else if (text == "test") {
      test_func7();
    } else {
      std::cout << "error input"
                << "\n";
    }
  }
  if (analyze_code_tool_ptr != NULL) {
    std::this_thread::sleep_for(std::chrono::seconds(10));
    analyze_code_tool_ptr->stop_recv_thread();
    analyze_code_tool_ptr->stop_analyze_data();
  }

  return 0;
}
