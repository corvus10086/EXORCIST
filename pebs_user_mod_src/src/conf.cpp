#include "conf.h"

#include <capstone/x86.h>

#include <cstdint>
#include <fstream>
#include <memory>
#include <random>
#include <sstream>
#include <utility>

taine_enum add_taine_level(taine_enum taine) {
  switch (taine) {
    case taine_enum::taine1: {
      return taine_enum::taine2;
    }
    case taine_enum::taine2: {
      return taine_enum::taine3;
    }
    case taine_enum::taine3: {
      return taine_enum::taine3;
    }
    case taine_enum::not_a_tine: {
      return taine_enum::taine1;
    }
  }
  return taine_enum::not_a_tine;
}
taine_enum max_taine_level(taine_enum taine1, taine_enum taine2) {
  if (taine1 == taine_enum::taine3 || taine2 == taine_enum::taine3) {
    return taine_enum::taine3;
  }
  if (taine1 == taine_enum::taine2 || taine2 == taine_enum::taine2) {
    return taine_enum::taine2;
  }
  if (taine1 == taine_enum::taine1 || taine2 == taine_enum::taine1) {
    return taine_enum::taine1;
  }
  return taine_enum::not_a_tine;
}
taine_enum max_taine_level(taine_enum taine1, taine_enum taine2,
                           taine_enum taine3) {
  if (taine1 == taine_enum::taine3 || taine2 == taine_enum::taine3 ||
      taine3 == taine_enum::taine3) {
    return taine_enum::taine3;
  }
  if (taine1 == taine_enum::taine2 || taine2 == taine_enum::taine2 ||
      taine3 == taine_enum::taine2) {
    return taine_enum::taine2;
  }
  if (taine1 == taine_enum::taine1 || taine2 == taine_enum::taine1 ||
      taine3 == taine_enum::taine1) {
    return taine_enum::taine1;
  }
  return taine_enum::not_a_tine;
}
std::string get_taine_string(taine_enum taine,
                             std::default_random_engine &random) {
  std::stringstream stream;
  stream << "#taine";
  std::uniform_int_distribution<int> dist(100000, 999999);
  int random_number = dist(random);
  stream << random_number;
  switch (taine) {
    case taine_enum::taine1: {
      stream << 1 << "#";
      break;
    }
    case taine_enum::taine2: {
      stream << 2 << "#";
      break;
    }
    case taine_enum::taine3: {
      stream << 3 << "#";
      break;
    }
    case taine_enum::not_a_tine: {
      stream << 0 << "#";
      break;
    }
  }
  return stream.str();
}
std::string get_taine_string(taine_enum taine,
                             std::default_random_engine &random,
                             std::uniform_int_distribution<int> &dist) {
  std::stringstream stream;
  stream << "#taine";
  int random_number = dist(random);
  stream << random_number;
  switch (taine) {
    case taine_enum::taine1: {
      stream << 1 << "#";
      break;
    }
    case taine_enum::taine2: {
      stream << 2 << "#";
      break;
    }
    case taine_enum::taine3: {
      stream << 3 << "#";
      break;
    }
    case taine_enum::not_a_tine: {
      stream << 0 << "#";
      break;
    }
  }
  return stream.str();
}
std::string get_symbol_str(std::default_random_engine &random) {
  std::stringstream stream;
  stream << "#symbol";
  std::uniform_int_distribution<int> dist(100000, 999999);
  int random_number = dist(random);
  stream << random_number << "#";
  return stream.str();
}
std::string get_symbol_str(std::default_random_engine &random,
                           std::uniform_int_distribution<int> dist) {
  std::stringstream stream;
  stream << "#symbol";
  int random_number = dist(random);
  stream << random_number << "#";
  return stream.str();
}
bool judge_opearter_same(cs_x86_op &op1, cs_x86_op &op2) {
  if (op1.type == op2.type) {
    switch (op1.type) {
      case X86_OP_INVALID: {
        return false;
      }
      case X86_OP_REG: {
        if (op1.reg == op2.reg) {
          return true;
        }
        return false;
      }
      case X86_OP_IMM: {
        return false;
      }
      case X86_OP_MEM: {
        if (op1.mem.base == op2.mem.base && op1.mem.disp == op2.mem.disp &&
            op1.mem.index == op2.mem.index && op1.mem.scale == op2.mem.scale) {
          return true;
        }
        return false;
      } break;
    }
  }
  return false;
}

void distinct_taine_str(std::vector<std::string> &str_vec) {
  std::sort(str_vec.begin(), str_vec.end());
  str_vec.erase(std::unique(str_vec.begin(), str_vec.end()), str_vec.end());
}

std::map<x86_reg, short> reg_size_map = {
    {X86_REG_RAX, 8}, {X86_REG_RCX, 8},  {X86_REG_RDX, 8},  {X86_REG_RBX, 8},
    {X86_REG_EAX, 4}, {X86_REG_ECX, 4},  {X86_REG_EDX, 4},  {X86_REG_EBX, 4},
    {X86_REG_AX, 2},  {X86_REG_CX, 2},   {X86_REG_DX, 2},   {X86_REG_BX, 2},
    {X86_REG_AH, 1},  {X86_REG_CH, 1},   {X86_REG_DH, 1},   {X86_REG_BH, 1},
    {X86_REG_AL, 1},  {X86_REG_CL, 1},   {X86_REG_DL, 1},   {X86_REG_BL, 1},
    {X86_REG_R8, 8},  {X86_REG_R8D, 4},  {X86_REG_R8W, 2},  {X86_REG_R8B, 1},
    {X86_REG_R9, 8},  {X86_REG_R9D, 4},  {X86_REG_R9W, 2},  {X86_REG_R9B, 1},
    {X86_REG_R10, 8}, {X86_REG_R10D, 4}, {X86_REG_R10W, 2}, {X86_REG_R10B, 1},
    {X86_REG_R11, 8}, {X86_REG_R11D, 4}, {X86_REG_R11W, 2}, {X86_REG_R11B, 1},
    {X86_REG_R12, 8}, {X86_REG_R12D, 4}, {X86_REG_R12W, 2}, {X86_REG_R12B, 1},
    {X86_REG_R13, 8}, {X86_REG_R13D, 4}, {X86_REG_R13W, 2}, {X86_REG_R13B, 1},
    {X86_REG_R14, 8}, {X86_REG_R14D, 4}, {X86_REG_R14W, 2}, {X86_REG_R14B, 1},
    {X86_REG_R15, 8}, {X86_REG_R15D, 4}, {X86_REG_R15W, 2}, {X86_REG_R15B, 1},
    {X86_REG_RBP, 8}, {X86_REG_EBP, 4},  {X86_REG_BP, 2},   {X86_REG_BPL, 1},
    {X86_REG_RSP, 8}, {X86_REG_ESP, 4},  {X86_REG_SP, 2},   {X86_REG_SPL, 1},
    {X86_REG_RSI, 8}, {X86_REG_ESI, 4},  {X86_REG_SI, 2},   {X86_REG_SIL, 1},
    {X86_REG_RDI, 8}, {X86_REG_EDI, 4},  {X86_REG_DI, 2},   {X86_REG_DIL, 1},
};

bool judge_call_func_mem(uint64_t pid,uint64_t jmp_addr) {
  std::string exec_file_path;
  // 
  {
    std::stringstream path;
    char exe_path[256];
    path << "/proc/" << pid << "/exe";
    size_t len = readlink(path.str().c_str(), exe_path, sizeof(exe_path) - 1);
    if (len == -1) {
      return false;
    }
    exe_path[len] = '\0';
    exec_file_path = exe_path;
    // std::cout << exec_file_path << "\n";
  }
  uint64_t load_addr;
  // 
  {
    std::stringstream path;
    path << "/proc/" << pid << "/maps";
    std::ifstream file(path.str());
    if (!file.is_open()) {
      return false;;
    }
    std::string line;
    // 
    std::getline(file, line);
    file.close();
    int end = line.find('-');
    std::string addr_str = line.substr(0, end);
    load_addr = std::stoull(addr_str, 0, 16);
  }
  // plt
  std::map<uint64_t, std::string> plt_info;
  {
    std::stringstream result;
    std::array<char, 128> buffer;
    std::stringstream exec;
    exec << "objdump -D --section=.plt " << exec_file_path << " |grep '@plt>:'";
    FILE *pipe = popen(exec.str().c_str(), "r");

    if (!pipe) {
      throw std::runtime_error("popen() failed!");
    }
    //  pipe 
    while (fgets(buffer.data(), buffer.size(), pipe) != nullptr) {
      result << buffer.data();
    }
    pclose(pipe);
    std::string line;
    while (std::getline(result, line)) {
      // std::cout << line << std::endl;
      int end = line.find(' ');
      std::string addr_str = line.substr(0, end);
      if (addr_str.length() < 15) {
        break;
      }
      uint64_t addr = std::stoull(addr_str, 0, 16);
      std::string name = line.substr(end + 1, line.length());
      plt_info[addr] = name;
    }
  }
  auto addr = jmp_addr - load_addr;
  if (plt_info.count(addr)) {
    std::string plt_func_str = plt_info[addr];
    if (plt_func_str.find("memcpy") || plt_func_str.find("memcmp")) {
      // std::cout << "call func is memcpy or memcmp\n";
      return true;
    }
  }
  return false;
}