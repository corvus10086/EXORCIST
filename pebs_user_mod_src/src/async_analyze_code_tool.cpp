#include "async_analyze_code_tool.h"

#include <bits/types/FILE.h>
#include <bits/types/time_t.h>
#include <sys/types.h>
#include <unistd.h>

#include <boost/bind/bind.hpp>
#include <boost/chrono/duration.hpp>
#include <boost/function/function_fwd.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/thread/detail/thread.hpp>
#include <boost/thread/lock_guard.hpp>
#include <boost/thread/pthread/mutex.hpp>
#include <boost/thread/pthread/thread_data.hpp>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <exception>
#include <fstream>
#include <iostream>
#include <map>
#include <memory>
#include <sstream>
#include <string>
#include <vector>

#include "conf.h"
#include "full_diasm_info.h"
#include "static_analyze_tools.h"
/**
 * @brief 对接受到的数据进行分析
 *
 * @param 反汇编代码
 * @param netlink_tool的智能指针，在这里仅能使用send函数
 */
// using namespace boost::placeholders;
std::map<analyze_result, std::string> analyze_result_to_string_map = {
    {analyze_result::CANNOT_FIND_NEXT_INSTRUCTION, "cannot_find_instruction/"},
    {analyze_result::FIND_ATTACK, "find_attack/"},
    {analyze_result::INVALID_INSTRUCTION, "invalid_instruction/"},
    {analyze_result::NO_ATTACT, "no_attack/"},
    {analyze_result::UNSUPPORT_INSTRUCTION, "unsupport_instruction/"}};

void async_analyze_code_tool::analyze(std::string &code,
                                      std::uniform_int_distribution<int> &dist,
                                      uint64_t thread_id) {
  try {
    // 这里获取完整的反汇编信息
    full_diasm_info::ptr info = std::make_shared<full_diasm_info>();
    // 这里会卡一下等待获取完整的数据
    if (!info->get_full_diasm_code(code, _thread_code_map,
                                   _thread_code_map_mutex, thread_id,
                                   _netlink_tool_ptr)) {
      return;
    }
    // std::cout << "get_full_diasm_code_finish" << std::endl;stop
    // 进行静态分析并对结果进行分类
    // std::string diasm_file_name =
    // "./tmp_diasmfile/save_diasm_info/diasm_info" +
    //                               std::to_string(thread_id) + ".dat";
    // std::ofstream ofs(diasm_file_name);
    // boost::archive::text_oarchive oa(ofs);
    // oa << info;

    static_analyze_tools tools(info, dist);
    auto res = tools.analyze();

    // if (info->get_exec_file_name()[0] == 's' &&
    //     info->get_exec_file_name()[1] == 'p' &&
    //     info->get_exec_file_name()[2] == 'e' &&
    //     info->get_exec_file_name()[3] == 'c' &&
    //     info->get_exec_file_name()[4] == '_' &&
    //     res.second != analyze_result::FIND_ATTACK) {
    //   std::string diasm_file_name =
    //       "./tmp_diasmfile/save_diasm_info/diasm_info" +
    //       std::to_string(thread_id) + ".dat";
    //   std::ofstream ofs(diasm_file_name);
    //   boost::archive::text_oarchive oa(ofs);
    //   oa << info;
    // }

    // // std::cout << analyze_result_to_string_map[res.second] << "\n";
    if (res.second == analyze_result::FIND_ATTACK) {
      auto name = info->get_exec_file_name();
      std::cout << name
                // << "\n"
          ;
      // if (name[0] == 's' & name[1] == 'p' && name[2] == 'e') {
      //   // std::cout << "analyze finish ";
      //   if (_attack_share_mem_ptr->effect) {
      //     auto attack_info = _attack_share_mem_ptr->read_data();
      //     std::chrono::duration<double, std::milli> use_time =
      //         std::chrono::high_resolution_clock::now() - attack_info.first;
      //     std::cout
      //         // << "analyze use time = "
      //         << std::dec << use_time.count();
      //               // << "ms event num = " << std::dec << attack_info.second;
      //   }
      //   std::cout << "\n";
      // }
      std::string tmp_file_name = "./tmp_diasmfile/" +
                                  analyze_result_to_string_map[res.second] +
                                  std::to_string(thread_id) + ".s";

      std::ofstream file(tmp_file_name, std::ios::out | std::ios::trunc);
      if (!file) {
        std::cout << "connot open file\n";
      } else {
        if (res.second == analyze_result::FIND_ATTACK) {
          uint64_t tmp;
          for (int i = 0; i < info->get_diasm_info().size(); ++i) {
            if (info->get_diasm_info()[i] == res.first.first) {
              tmp = i;
              break;
            }
          }
          file << "taine3 location = " << tmp << " index = " << res.first.second
               << "\n";
          file << info->get_diasm_string_stream().str();
          file.close();

          // 直接序列化
          std::string diasm_file_name =
              "./tmp_diasmfile/save_diasm_info/diasm_info" +
              std::to_string(thread_id) + ".dat";
          std::ofstream ofs(diasm_file_name);
          boost::archive::text_oarchive oa(ofs);
          oa << info;
        }
      }
    }

  } catch (...) {
    _analyze_except_ptr = std::current_exception();
  }
}
// 从队列中取出数据并分析
bool async_analyze_code_tool::load_code(
    std::uniform_int_distribution<int> &dist, uint64_t thread_id) {
  std::string code;
  {
    boost::mutex::scoped_lock lock(_mutex);
    if (!_code_queue.empty()) {
      code = _code_queue.front();
      _code_queue.pop();
    }
  }
  if (code != "") {
    analyze(code, dist, thread_id);
    return true;
  }
  return false;
}
/**
 * @brief 向队列中插入数据
 *
 * @param code
 */
inline void async_analyze_code_tool::insert_code(std::string &code) {
  boost::mutex::scoped_lock lock(_mutex);
  _code_queue.push(code);
  // if (_code_queue.size() % 100 == 0) {
  //   std::cout << "_code_queue.size = " << _code_queue.size() << "\n";
  // }
  // uint32_t pid = *((uint32_t *)(code.c_str() + 4));
  // if ((code.c_str()[24]) == 's' && (code.c_str()[25]) == 'p' &&
  //     (code.c_str()[26]) == 'e') {
  //   if (_attack_share_mem_ptr->effect) {
  //     auto attack_info = _attack_share_mem_ptr->read_data();
  //     std::chrono::duration<double, std::milli> use_time =
  //         std::chrono::high_resolution_clock::now() - attack_info.first;
  //     std::cout << "receive use time = " << std::dec << use_time.count()
  //               << "ms event num = " << std::dec << attack_info.second << "\n";
  //   }
  // }
}
void async_analyze_code_tool::start_recv_thread() {
  std::cout << "start recv data thread\n";
  //
  _recv_by_netlink_thread = boost::thread(
      boost::bind(&async_analyze_code_tool::thread_recv_data_by_netlink, this));
  //
  _recy_by_mmap_thread = boost::thread(
      boost::bind(&async_analyze_code_tool::thread_recv_data_by_mmap, this));
}
void async_analyze_code_tool::thread_recv_data_by_netlink() {
  std::cout << "start recv data by netlink\n";
  try {
    while (true) {
      boost::this_thread::interruption_point();
      // netlink释放后就停止接受数据的进程
      if (!_netlink_tool_ptr->effective()) {
        std::cout << "netlink_has_already_exit" << std::endl;
        break;
      }
      //这里会被阻塞,接受到数据才会继续执行
      std::string tmp = _netlink_tool_ptr->recieve_message();
      //接受到停止消息后释放掉netlink_tool
      if (tmp.c_str()[0] == 'e' && tmp.c_str()[1] == 'x') {
        std::cout << "recv_thread_exit." << std::endl;
        _netlink_tool_ptr->destory();
        break;
      }
      //返回的是查询数据
      else if (tmp.c_str()[0] == 's' && tmp.c_str()[1] == 'e') {
        uint64_t thread_id = *((uint64_t *)(tmp.c_str() + 8));
        if (tmp.c_str()[2] == 'f') {
          std::cout << "receive spec data\n";
        }
        boost::lock_guard<boost::mutex> lock(_thread_code_map_mutex);
        if (_thread_code_map.count(thread_id)) {
          if (tmp.c_str()[2] == 'f') {
            std::cout << "spec data prepare to insert, thread_id = " << std::dec
                      << thread_id << "\n";
          }
          _thread_code_map[thread_id]->_message.push_back(tmp);
          //如果获取数量足够就唤醒线程

          if (_thread_code_map[thread_id]->_num != 0 &&
              _thread_code_map[thread_id]->_message.size() ==
                  _thread_code_map[thread_id]->_num) {
            _thread_code_map[thread_id]->_condition.notify_all();
          }
        }

      } else {
        std::cout << "unknow message." << std::endl;
        break;
      }
    }
  } catch (...) {
    _recv_except_ptr = std::current_exception();
    _netlink_tool_ptr->destory();
    std::cout << "recv_thread_exit." << std::endl;
  }
}
void async_analyze_code_tool::thread_recv_data_by_mmap() {
  std::cout << "start recv data by mmap\n";
  auto start_time = std::chrono::high_resolution_clock::now();
  uint64_t num = 0;
  bool need_insert = false;
  try {
    while (true) {
      {
        // ++num;
        // auto end_time = std::chrono::high_resolution_clock::now();
        // std::chrono::duration<double, std::milli> use_time =
        //     end_time - start_time;
        // if (num % 500 == 0) {
        //   std::cout << "insert 500 use time:" << std::dec << use_time.count()
        //             << " insert speed = " << num * 1000 / use_time.count()
        //             << "\n";
        //   num = 0;
        //   start_time = std::chrono::high_resolution_clock::now();
        // }
      }

      boost::this_thread::interruption_point();
      std::string tmp = _share_mem_tool_ptr->read_data();
      uint64_t sleep_time = 0;
      if (tmp.length() < 2) {
        if (sleep_time <= 100) {
          sleep_time += 10;
        }
      } else {
        if (!need_insert) {
          auto end_time = std::chrono::high_resolution_clock::now();
          std::chrono::duration<double, std::milli> use_time =
              end_time - start_time;
          if (use_time.count() > 3000) {
            std::cout << "begin to insert" << std::endl;
            need_insert = true;
          }
        } else {
          insert_code(tmp);
        }
        sleep_time = 0;
      }
      boost::this_thread::sleep_for(boost::chrono::milliseconds(sleep_time));
    }
  } catch (...) {
    _recv_mmap_except_ptr = std::current_exception();
    _share_mem_tool_ptr->destory();
    std::cout << "recv_thread_by_mmap_exit." << std::endl;
  }
}
void async_analyze_code_tool::start_analyze_data() {
  std::cout << "start analyze data thread\n";
  for (int i = 0; i < MAX_ANALYZE_THREAD_SIZE; ++i) {
    _analyze_thread[i] = boost::thread(
        boost::bind(&async_analyze_code_tool::thread_analyze_data, this));
  }
}
void async_analyze_code_tool::thread_analyze_data() {
  try {
    int sleep_time = 0;
    std::uniform_int_distribution<int> dist;
    // 这里获取当前线程使用的随机数范围
    // 还需要生成线程的独立id
    {
      boost::lock_guard<boost::mutex> lock(_random_range_mutex);
      dist = _thread_random_range.back();
      _thread_random_range.pop_back();
    }
    uint64_t thread_id;
    std::default_random_engine random;
    random.seed(time(0));
    // uint64_t num = 0;
    // auto start_time = std::chrono::high_resolution_clock::now();
    while (!_thread_analyzr_data_should_stop) {
      // 计时用代码
      {
        // ++num;
        // auto this_time = std::chrono::high_resolution_clock::now();
        // std::chrono::duration<double, std::milli> use_time =
        //     this_time - start_time;
        // if (num % 50 == 0) {
        //   std::cout << "analyze 50 use time :" << std::dec <<
        //   use_time.count()
        //             << " analyze speed = " << num * 1000 / use_time.count()
        //             << "\n";
        //   num = 0;
        //   start_time = std::chrono::high_resolution_clock::now();
        // }
      }
      // 每次循环生成一个唯一的id
      thread_id = dist(random);
      boost::this_thread::interruption_point();
      if (load_code(dist, thread_id)) {
        sleep_time = 10;
      } else if (sleep_time <= 500) {
        sleep_time += 100;
      }
      if (sleep_time > 0) {
        boost::this_thread::sleep_for(boost::chrono::milliseconds(sleep_time));
      }
    }
  } catch (...) {
    std::cout << "analyze_thread_exit." << std::endl;
  }
}
void async_analyze_code_tool::stop_recv_thread() {
  std::cout << "stop_recv_thread_start" << std::endl;
  if (_recv_by_netlink_thread.joinable()) {
    _recv_by_netlink_thread.interrupt();
    _recv_by_netlink_thread.join();
  }
  if (_recy_by_mmap_thread.joinable()) {
    _recy_by_mmap_thread.interrupt();
    _recy_by_mmap_thread.join();
  }
  _share_mem_tool_ptr->destory();
  //应该在停止接受数据的进程后释放netlink
  _netlink_tool_ptr->destory();
  std::cout << "stop_recv_thread_finish" << std::endl;
}
void async_analyze_code_tool::stop_analyze_data() {
  std::cout << "stop_analyze_thread_start" << std::endl;
  _thread_analyzr_data_should_stop = true;
  for (int i = 0; i < MAX_ANALYZE_THREAD_SIZE; ++i) {
    if (_analyze_thread[i].joinable()) {
      _analyze_thread[i].interrupt();
      _analyze_thread[i].join();
    }
  }
  std::cout << "stop_analyze_thread_finish" << std::endl;
}
