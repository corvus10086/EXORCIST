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

// 向后读取的字节数
#define OVER_FOOT_SIZE 200
// 向前读取的字节数
#define OVER_HEAD_SIZE 20
// 传递消息的前缀大小
// 第0个字节描述消息类型
// 第1个字节表示branch miss addr与cache miss_addr的插值
// 2表示是否是一个ret类型
// 3保留
// 4-7个字节表示pid
// 8-15个字节表示cache miss addr
// 16-23表示ret的addr
// 24-39表示进程的可执行文件名称
// 40-43表示指令可能开始地址相对与start_addr的偏移
#define MEAASGE_INFO (8 * 3 + 16 + 4)
#define OVER_HEAD_SIZE 20
#define PREFIX_SIZE (MEAASGE_INFO + sizeof(register_info_t))
// cache_miss与branch_miss插值的最大值
#define CACHE_BRANCHE_ADDR_ADDR_SUB_ADDR_MAX 16
// 通过mmap传递消息的总大小
#define SINGLE_MESSAGE_BY_MMAP_SIZE                                          \
  (PREFIX_SIZE + CACHE_BRANCHE_ADDR_ADDR_SUB_ADDR_MAX + 6 + OVER_FOOT_SIZE + \
   OVER_HEAD_SIZE)
#define MAX_MESSAGE_NUM_SIZE ((MEMDEV_SIZE - 8) / SINGLE_MESSAGE_BY_MMAP_SIZE)

extern std::map<x86_reg, short> reg_size_map;
/**
 * @brief 污点类型种类
 *
 */
enum class taine_enum {
  taine1,
  taine2,
  taine3,
  not_a_tine,
};
/**
 * @brief 使用到的rflag类型
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
 * @brief 单步指令分析后可能产生的结果
 *
 */
enum class analyze_result {
  INVALID_INSTRUCTION,            // 无效的指令
  FIND_ATTACK,                    // 发现一个攻击
  UNSURE_CONTROL_FOLW_JMP_BELOW,  // 未确定的控制流跳转目的向下
  UNSURE_CONTROL_FOLW_JMP_UP,     // 未确定的控制流跳转目的向上
  UNSUPPORT_INSTRUCTION,          // 未支持的指令
  NO_ATTACT,  // 发现一些内存屏障指令，直接报没有攻击
  CANNOT_FIND_NEXT_INSTRUCTION,  // 跳转地址是一个未知的地址
  CONTINUE_ANALYZE,              // 继续分析
  RET_INSTRUCTION,               // ret指令的情况下判断
  MAY_LEAK_FROM_CONTROL,         // 可能通过控制流泄露
  ALREADY_FIND_INIT_TAINE,       // 已经找到初始污点
  CALL_INSTRUCTION_WITH_TAINE,  // call指令并且能够是直接call一个地址
};
/**
 * @brief 将污点等级提高一级
 *
 * @return taine_enum
 */
taine_enum add_taine_level(taine_enum);

/**
 * @brief 获取传入参数中最大的taine
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