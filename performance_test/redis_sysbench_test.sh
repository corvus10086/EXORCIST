#!/bin/bash

if [ $# -lt 1 ]; then
    echo 'no effect input'
    exit
fi
# echo $1;

if [[ "$1" == "--no" || "$1" == "-n" ]]; then
    out_name='no_exorcist'
elif [[ "$1" == "--have" || "$1" == "-h" ]]; then
    out_name='have_exorcist'
else  
    echo 'no effect input'
    exit
fi

#如果文件夹不存在，创建文件夹
if [ ! -d "./result/redis_sysbench_test" ]; then
    mkdir -p ./result/redis_sysbench_test
fi


OUTFILE="./result/redis_sysbench_test/results_$out_name.csv"

# echo "SET_RPS,SET_P999,GET_RPS,GET_P999"> $OUTFILE
echo "SET_RPS,GET_RPS"> $OUTFILE
loop_num=20
password=230311
client_num=50
request_num=1000000

for ((i=1;i<=loop_num;i++)); do
    # 运行测试（Baseline）
    result=$(redis-benchmark -t get,set -c ${client_num} -n ${request_num} -a ${password})

    # echo "${result}"
    # 提取 SET 吞吐量
    SET_RPS=$(echo "${result}"|awk '/====== SET ======/ {flag=1; next} /======/ {flag=0} flag && /requests per second/ {print $1; exit}')

    # # 提取 SET P99.9 延迟
    # SET_P999=$(echo "${result}"|awk '/====== SET ======/ {in_set=1; next} /======/ {in_set=0} in_set && /^[[:space:]]*99\.9[0-9]?%/ {print $3; exit}')

    # 提取 GET 吞吐量
    GET_RPS=$(echo "${result}"|awk '/====== GET ======/ {flag=1; next}  /======/ {flag=0} flag && /requests per second/ {print $1; exit}')

    # # 提取 GET P99.9 延迟
    # GET_P999=$(echo "${result}"|awk '/====== GET ======/ {in_get=1; next} /======/ {in_get=0} in_get && /^[[:space:]]*99\.9[0-9]?%/ {print $3; exit}')
       
    # echo "${SET_RPS},${SET_P999},${GET_RPS},${GET_P999}" >> $OUTFILE
    echo "${SET_RPS},${GET_RPS}" >> $OUTFILE
done