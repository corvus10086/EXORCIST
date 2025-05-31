#ifndef PEBS_BUFFER
#define PEBS_BUFFER
#include "pebs_pub.h"

int alloc_ring_buffer(void);

void free_ring_buffer(void);

void write_ring_buffer(int cpu_id,unsigned int pid, unsigned long long int start_addr,
                       unsigned long long int end_addr,
                       register_info_t* start_info, register_info_t* end_info,char is_find);

// int find_ring_buffer(unsigned int pid, unsigned long long int start_addr,
//                        unsigned long long int end_addr);

unsigned char read_ring_buffer(unsigned int ring_buffer_id, unsigned int* pid,
                               unsigned long long int* start_addr,
                               unsigned long long int* end_addr,
                               register_info_t* start_info,
                               register_info_t* end_info);

void print_buffer_data(unsigned int ring_buffer_id);

#endif
