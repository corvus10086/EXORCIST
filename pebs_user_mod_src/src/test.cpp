#include "test.h"



#include "BeaEngine.h"
#include "basic_types.h"

uint32_t get_start_addr_offset(const char *data, uint64_t vir_addr,
                               uint64_t cache_miss_addr) {
  // res中存放正确的开始的偏移
  uint32_t res = 0;
  // mem_offset存放正确的全部偏移，第几位为1代表偏移这位已经被记录过了
  uint32_t mem_offset = 0;
  uint32_t i = 0;
  uint32_t len;
  DISASM infos;
  for (; i < 16; ++i) {
    // 如果mem_offset中存在已经记录过的偏移就直接跳过
    if ((mem_offset & (0x1 << i)) > 0) {
      continue;
    }
    // tmp_mem_offset存放当前测试的偏移情况，如果成功就与mem_offset进行合并
    uint32_t tmp_mem_offset = 0;
    // 记录当前的偏移
    uint32_t current_offset = i;
    // 先记录初始的偏移
    tmp_mem_offset += (0x1 << i);
    char jmp_while = 0;
    const char *end_offset = data + i + 0x20;
    (void)memset(&infos, 0, sizeof(DISASM));
    infos.EIP = (UInt64)data + i;
    infos.VirtualAddr = vir_addr + i;
    while (!infos.Error) {
      if (jmp_while > 0) {
        break;
      }
      infos.SecurityBlock = (UInt64)end_offset - infos.EIP;
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
        default:
          infos.EIP += len;
          infos.VirtualAddr += len;
          current_offset += len;
          if (infos.VirtualAddr > cache_miss_addr) {
            jmp_while = 1;
            break;
          } else if (infos.VirtualAddr == cache_miss_addr ||
                     current_offset >= 0x20) {
            // 找到一个正确的开始偏移
            // 记录当前初始偏移下的全部偏移
            mem_offset |= tmp_mem_offset;
            // 记录开始偏移
            res += (0x1 << i);
            jmp_while = 1;
          }
          if ((mem_offset & (0x1 << current_offset)) > 0) {
            // 找到一个正确的开始偏移
            // 记录当前初始偏移下的全部偏移
            mem_offset |= tmp_mem_offset;
            // 记录开始偏移
            res += (0x1 << i);
            jmp_while = 1;
            break;
          }
          // 记录当前的偏移
          if (current_offset < 16) {
            tmp_mem_offset += 0x1 << current_offset;
          }

          break;
      }
    };
  }
  return res;
}