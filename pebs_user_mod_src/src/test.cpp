#include "test.h"



#include "BeaEngine.h"
#include "basic_types.h"

uint32_t get_start_addr_offset(const char *data, uint64_t vir_addr,
                               uint64_t cache_miss_addr) {
  // res
  uint32_t res = 0;
  // mem_offset，1
  uint32_t mem_offset = 0;
  uint32_t i = 0;
  uint32_t len;
  DISASM infos;
  for (; i < 16; ++i) {
    // mem_offset
    if ((mem_offset & (0x1 << i)) > 0) {
      continue;
    }
    // tmp_mem_offset，mem_offset
    uint32_t tmp_mem_offset = 0;
    // 
    uint32_t current_offset = i;
    // 
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