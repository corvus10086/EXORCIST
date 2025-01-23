#ifndef ASYNC_ANALYZE_CODE
#define ASYNC_ANALYZE_CODE

#include <linux/netlink.h>

#include <boost/random.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/thread/pthread/mutex.hpp>
#include <boost/thread.hpp>
#include <cstddef>
#include <cstdint>
#include <exception>
#include <memory>
#include <mutex>
#include <queue>
#include <string>
#include <vector>

#include "conf.h"
#include "netlink_tool.h"
#include "share_mem_tool.h"
#include "attack_share_mem.h"

class async_analyze_code_tool {
 public:
  /**
   * @brief 
   *
   */
  typedef std::shared_ptr<async_analyze_code_tool> ptr;

  /**
   * @brief 
   *
   * @param ptr
   */
  async_analyze_code_tool(netlink_tool::ptr net_ptr,
                          share_mem_tool::ptr mem_ptr)
      : _netlink_tool_ptr(net_ptr), _share_mem_tool_ptr(mem_ptr) {
    for (int i = 0; i < MAX_ANALYZE_THREAD_SIZE; ++i) {
      _thread_random_range.push_back(std::uniform_int_distribution<int>(
          (i + 1) * 100000, (i + 2) * 100000 - 1));
    }
    _attack_share_mem_ptr = std::make_shared<attack_share_mem>();
  }

  /**
   * @brief 
   *
   */
  ~async_analyze_code_tool() {}

  /**
   * @brief 
   *
   * @param code
   */
  void insert_code(std::string &code);

  /**
   * @brief 
   *
   */
  void start_recv_thread();
  /**
   * @brief 
   *
   */
  void stop_recv_thread();
  /**
   * @brief 
   *
   */
  void start_analyze_data();
  /**
   * @brief
   *
   */
  void stop_analyze_data();
  /**
   * @brief 
   *
   * @return std::exception_ptr
   */
  std::exception_ptr get_recv_except_ptr() { return _recv_except_ptr; }
  /**
   * @brief 
   *
   * @return std::exception_ptr
   */
  std::exception_ptr get_analyze_except_ptr() { return _analyze_except_ptr; }

  class thread_recv_data_struct {
   public:
    typedef std::shared_ptr<async_analyze_code_tool::thread_recv_data_struct>
        ptr;
    //
    std::vector<std::string> _message;
    //
    boost::condition_variable _condition;
    boost::mutex _mutex;
    // 
    // boost::mutex _access_mutex;
    int _num = 0;
  };

 private:
  /**
   * @brief 
   *
   */
   boost::mutex _mutex;
   boost::mutex _random_mutex;
   boost::mutex _random_range_mutex;

   boost::mutex _thread_code_map_mutex;

   attack_share_mem::ptr _attack_share_mem_ptr;
   /**
    * @brief 
    *
    */
   std::queue<std::string> _code_queue;
   /**
    * @brief 
    *
    */
   std::map<std::uint64_t, thread_recv_data_struct::ptr> _thread_code_map;

   /**
    * @brief 
    *
    */
   netlink_tool::ptr _netlink_tool_ptr = nullptr;

   /**
    * @brief 
    *
    */
   share_mem_tool::ptr _share_mem_tool_ptr = nullptr;
   /**
    * @brief 
    *
    */
   boost::thread _recv_by_netlink_thread;
   /**
    * @brief 
    *
    */
   boost::thread _recy_by_mmap_thread;
   /**
    * @brief 
    *
    */
   boost::thread _analyze_thread[MAX_ANALYZE_THREAD_SIZE];
   /**
    * @brief 
    *
    */
   std::exception_ptr _recv_except_ptr = nullptr;
   std::exception_ptr _recv_mmap_except_ptr = nullptr;
   /**
    * @brief 
    *
    */
   std::exception_ptr _analyze_except_ptr = nullptr;
   bool _thread_analyzr_data_should_stop = false;
   /**
    * @brief 
    *
    * @return true
    * @return false
    */
   bool load_code(std::uniform_int_distribution<int> &dist, uint64_t thread_id);
   /**
    * @brief 
    *
    */
   void thread_recv_data_by_netlink();
   void thread_recv_data_by_mmap();
   /**
    * @brief 
    *
    */
   void thread_analyze_data();

   /**
    * @brief 
    *
    * @param code
    */
   void analyze(std::string &code, std::uniform_int_distribution<int> &dist,
                uint64_t thread_id);
   std::vector<std::uniform_int_distribution<int>> _thread_random_range;
   boost::random::mt19937 _gen;
  
};

#endif