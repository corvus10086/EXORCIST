#include "share_mem_tool.h"

#include <sys/mman.h>
#include <sys/types.h>

#include <cstdint>
#include <string>

bool share_mem_tool::init() {
  _fd = open(DEVICE_NAME, O_RDWR);
  if (_fd == -1) {
    perror("open");
    return false;
  }
  void *mapped_data =
      mmap(NULL, MEMDEV_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, _fd, 0);
  if (mapped_data == MAP_FAILED) {
    std::cerr << "Failed to mmap: " << strerror(errno) << std::endl;
    close(_fd);
    return false;
  }
  _data = (char *)mapped_data;
  std::cout << "mmap_addr = 0x" << std::hex << (uint64_t)_data << "\n";
  return true;
}

void share_mem_tool::destory() {
  if (_data != MAP_FAILED) {
    munmap(_data, MEMDEV_SIZE);
    _data = (char*)MAP_FAILED;
  }
  if (_fd != -1) {
    close(_fd);
    _fd =-1;
  }
  // std::cout << "destory share memory\n";
}

std::string share_mem_tool::read_data() {
  uint32_t write_index = *(uint32_t *)(_data + 0);
  uint32_t read_index = *(uint32_t *)(_data + 4);
  int max_mesage_size = SINGLE_MESSAGE_BY_MMAP_SIZE;
  int max_message_num_size = MAX_MESSAGE_NUM_SIZE;
  if ((read_index + 1) % max_message_num_size == write_index) {
    return std::string("");
  }
  *(uint32_t *)(_data + 4) = (read_index + 1) % max_message_num_size;
  return std::string(_data + 8 + (*(uint32_t *)(_data + 4)) * max_mesage_size,
                     max_mesage_size);
}