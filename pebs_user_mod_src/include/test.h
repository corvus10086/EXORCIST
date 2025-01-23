#ifndef PEBS_USER_MOD_TEST
#define PEBS_USER_MOD_TEST
#include <cstring>
#include <iostream>
#include <string>
uint32_t get_start_addr_offset(const char *data, uint64_t vir_addr,
                               uint64_t cache_miss_addr);
#endif