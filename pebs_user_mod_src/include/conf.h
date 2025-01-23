#ifndef PEBS_USER_MOD_CONF
#define PEBS_USER_MOD_CONF

#include <capstone/x86.h>

#include <cstdint>
#include <map>
#include <random>
#include <string>

#define NETLINK_TEST 30
#define MSG_SIZE 40
#define MAX_PAYLOAD 1024
#define THREAD_POOL_SIZE 8
#define MAX_ANALYZE_THREAD_SIZE 4
#define MAX_STATIC_STEP_SIZE 60
#define MAX_RET_WAIT_TIME 5
#define DEVICE_NAME "/dev/pebs_test_device"
#define MEMDEV_SIZE (1024 * 1024 * 4 * 6)

// 
#define OVER_FOOT_SIZE 200
// 
#define OVER_HEAD_SIZE 20
// 

#define MEAASGE_INFO (8 * 3 + 16 + 4)
#define OVER_HEAD_SIZE 20
#define PREFIX_SIZE (MEAASGE_INFO + sizeof(register_info_t))
// 
#define CACHE_BRANCHE_ADDR_ADDR_SUB_ADDR_MAX 16
// 
#define SINGLE_MESSAGE_BY_MMAP_SIZE                                          \
  (PREFIX_SIZE + CACHE_BRANCHE_ADDR_ADDR_SUB_ADDR_MAX + 6 + OVER_FOOT_SIZE + \
   OVER_HEAD_SIZE)
#define MAX_MESSAGE_NUM_SIZE ((MEMDEV_SIZE - 8) / SINGLE_MESSAGE_BY_MMAP_SIZE)

extern std::map<x86_reg, short> reg_size_map;
/**
 * @brief 
 *
 */
enum class taine_enum {
  taine1,
  taine2,
  taine3,
  not_a_tine,
};
/**
 * @brief 
 *
 */
enum class rflags {
  of,
  sf,
  zf,
  pf,
  cf,
  df,
  af,
};

/**
 * @brief 
 *
 */
enum class analyze_result {
  INVALID_INSTRUCTION,            //
  FIND_ATTACK,                    // 
  UNSURE_CONTROL_FOLW_JMP_BELOW,  // 
  UNSURE_CONTROL_FOLW_JMP_UP,     // 
  UNSUPPORT_INSTRUCTION,          // 
  NO_ATTACT,  // 
  CANNOT_FIND_NEXT_INSTRUCTION,  // 
  CONTINUE_ANALYZE,              // 
  RET_INSTRUCTION,               // 
  MAY_LEAK_FROM_CONTROL,         // 
  ALREADY_FIND_INIT_TAINE,       // 
  CALL_INSTRUCTION_WITH_TAINE,  // 
};
/**
 * @brief 
 *
 * @return taine_enum
 */
taine_enum add_taine_level(taine_enum);

/**
 * @brief 
 *
 * @param taine1
 * @param taine2
 * @return taine_enum
 */
taine_enum max_taine_level(taine_enum taine1, taine_enum taine2);
taine_enum max_taine_level(taine_enum taine1, taine_enum taine2,
                           taine_enum taine3);

// const std::map<taine_enum, std::string> taine_string_map = {
//     {taine_enum::not_a_tine, "not_a_taine"},
//     {taine_enum::taine1, "taine1"},
//     {taine_enum::taine2, "taine2"},
//     {taine_enum::taine3, "taine3"}};

std::string get_taine_string(taine_enum taine,
                             std::default_random_engine &random);
std::string get_taine_string(taine_enum taine,
                             std::default_random_engine &random,
                             std::uniform_int_distribution<int> &dist);
std::string get_symbol_str(std::default_random_engine &random);
std::string get_symbol_str(std::default_random_engine &random,
                           std::uniform_int_distribution<int> dist);

bool judge_opearter_same(cs_x86_op &op1, cs_x86_op &op2);
void distinct_taine_str(std::vector<std::string> &str_vec);
bool judge_call_func_mem(uint64_t pid, uint64_t jmp_addr);

typedef struct register_info {
  unsigned long long int RFLAGS;
  unsigned long long int RIP;
  unsigned long long int RAX;
  unsigned long long int RCX;
  unsigned long long int RDX;
  unsigned long long int RBX;
  unsigned long long int RSP;
  unsigned long long int RBP;
  unsigned long long int RSI;
  unsigned long long int RDI;
  unsigned long long int R8;
  unsigned long long int R9;
  unsigned long long int R10;
  unsigned long long int R11;
  unsigned long long int R12;
  unsigned long long int R13;
  unsigned long long int R14;
  unsigned long long int R15;
} register_info_t;

#endif