#ifndef ATTACK_SHARE_MEM
#define ATTACK_SHARE_MEM

#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/types.h>

#include <chrono>
#include <cstdint>
#include <memory>
#include <utility>
#define SHARE_MEM_NAME "/home/corvus/code/pebs_all"
#define SHARE_MEM_ID (684)

class attack_share_mem {
 public:
  typedef std::shared_ptr<attack_share_mem> ptr;
  attack_share_mem() {
    _share_mem_key = ftok(SHARE_MEM_NAME, SHARE_MEM_ID);
    if (_share_mem_key == -1) {
      perror("ftok error");
      return;
    }
    _shmId = shmget(_share_mem_key, 4096, IPC_CREAT | 0600);
    if (_shmId == -1) {
      perror("shmget error");
      return;
    }
    _addr = (uint64_t *)shmat(_shmId, NULL, SHM_RDONLY);
    if ((int64_t)_addr == -1) {
      return;
    }
    effect = true;
  }
  std::pair<std::chrono::system_clock::time_point, uint64_t> read_data() {
    auto test = std::chrono::system_clock::from_time_t(*_addr) +
                std::chrono::microseconds(*(_addr + 1));
    return std::make_pair(test, *(_addr + 2));
  }
  ~attack_share_mem() {
    if (effect) {
      shmdt(_addr);
    }
  }
  bool effect = false;

 private:
  key_t _share_mem_key;
  int _shmId;
  uint64_t *_addr;
};

#endif