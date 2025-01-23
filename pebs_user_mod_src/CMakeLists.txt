cmake_minimum_required(VERSION 3.0.0)
PROJECT(pebs)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

SET(CMAKE_BUILD_TYPE "Debug")




aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/src SRC_LIST)

aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/src/static_analyze SRC_LIST)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include/static_analyze)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include/beaengine)

add_definitions(-DBOOST_BIND_GLOBAL_PLACEHOLDERS)

list(REMOVE_ITEM SRC_LIST ${CMAKE_CURRENT_SOURCE_DIR}/src/async_simple_test.cpp)

link_directories(${CMAKE_CURRENT_SOURCE_DIR}/lib)

# add_executable(pebs_user_mod ${SEC_LIST})

# add_executable(async_simple_test ${CMAKE_CURRENT_SOURCE_DIR}/src/async_simple_test.cpp)

# if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND CMAKE_SYSTEM_NAME MATCHES "Windows") # mingw-w64
#     target_link_libraries(coro_io_example wsock32 ws2_32)
# endif()

find_package(SymEngine REQUIRED)
include_directories(${SYMENGINE_INCLUDE_DIRS})

# find_package(retdec 5.0 REQUIRED)
# include_directories(${RETDEC_INCLUDE_DIRS})

find_package(Boost COMPONENTS regex system thread coroutine serialization REQUIRED)
if(Boost_FOUND)
    include_directories(${Boost_INCLUDE_DIRS})
    
    MESSAGE( STATUS "Boost_INCLUDE_DIRS = ${Boost_INCLUDE_DIRS}.")
    MESSAGE( STATUS "Boost_LIBRARIES = ${Boost_LIBRARIES}.")
    MESSAGE( STATUS "Boost_LIB_VERSION = ${Boost_LIB_VERSION}.")
    # MESSAGE( STATUS "SRC_LIST = ${SRC_LIST}.")

    add_executable(pebs_user_mod ${SRC_LIST})
    target_link_libraries (pebs_user_mod ${Boost_LIBRARIES})
    
endif()

target_link_libraries (pebs_user_mod ${SYMENGINE_LIBRARIES} capstone procps BeaEngine_s_d_l)






