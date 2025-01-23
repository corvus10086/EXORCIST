#ifndef PEBS_PUB
#define PEBS_PUB

// #define uint64_t unsigned long long int
// #define int64_t long long int
// #define uint32_t unsigned long int
// #define int32_t long int
// #define int8_t unsigned char

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

typedef struct pebs_record {
  unsigned int record_format;
  unsigned int record_size;
  unsigned long long int address;
  unsigned long long int counters_type;
  unsigned long long int tsc;
//   unsigned long long int memory_access_addr;
//   unsigned long long int memory_auxiliary_info;
//   unsigned long long int memory_access_latency;
//   unsigned long long int tsx;
  register_info_t register_info;
} pebs_record_t;







#endif