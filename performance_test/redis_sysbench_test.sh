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

#
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
    # Baseline
    result=$(redis-benchmark -t get,set -c ${client_num} -n ${request_num} -a ${password})

    # echo "${result}"
    #  SET 
    SET_RPS=$(echo "${result}"|awk '/====== SET ======/ {flag=1; next} /======/ {flag=0} flag && /requests per second/ {print $1; exit}')

    # #  SET P99.9 
    # SET_P999=$(echo "${result}"|awk '/====== SET ======/ {in_set=1; next} /======/ {in_set=0} in_set && /^[[:space:]]*99\.9[0-9]?%/ {print $3; exit}')

    #  GET 
    GET_RPS=$(echo "${result}"|awk '/====== GET ======/ {flag=1; next}  /======/ {flag=0} flag && /requests per second/ {print $1; exit}')

    # #  GET P99.9 
    # GET_P999=$(echo "${result}"|awk '/====== GET ======/ {in_get=1; next} /======/ {in_get=0} in_get && /^[[:space:]]*99\.9[0-9]?%/ {print $3; exit}')
       
    # echo "${SET_RPS},${SET_P999},${GET_RPS},${GET_P999}" >> $OUTFILE
    echo "${SET_RPS},${GET_RPS}" >> $OUTFILE
done