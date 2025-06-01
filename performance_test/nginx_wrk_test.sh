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
if [ ! -d "./result/nginx_wrk_test" ]; then
    mkdir -p ./result/nginx_wrk_test
fi


OUTFILE="./result/nginx_wrk_test/results_$out_name.csv"

echo "Requests/sec,P95Latency"> $OUTFILE

loop_num=210
thread_num=20
connect_num=100
time=120

for ((i=1;i<=loop_num;i++)); do
    # Baseline
    result=$(wrk -t${thread_num} -c${connect_num} -d${time}s --latency http://localhost/)
    # echo "$result" 
    Requests_sec=$(echo "$result" |awk -F' ' '/Req\/Sec/  {print $2; exit}')
    P95Latency=$(echo "$result" |awk -F' ' '/99%/   {print $2; exit}')
    echo "${Requests_sec},${P95Latency}" >> $OUTFILE
    sync
    if ((i!=loop_num));then
        sleep 60
    fi
done

