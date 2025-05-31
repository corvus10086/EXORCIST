#!/bin/bash

if (( $# != 2 )); then
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


USER="root"
PASS="230311"
TABLES=10
TABLE_SIZE=100000
THREADS=20
TIME=120

if [[ $2 == '--clean'||$2 == '-c' ]]; then
    sysbench oltp_read_write \
        --db-driver=mysql \
        --mysql-user=$USER \
        --mysql-password=$PASS \
        --tables=$TABLES \
        --table-size=$TABLE_SIZE \
        cleanup
    exit
elif [[ $2 == '--init'||$2 == '-i' ]]; then
    sysbench oltp_read_write \
        --db-driver=mysql \
        --mysql-user=$USER \
        --mysql-password=$PASS \
        --tables=$TABLES \
        --table-size=$TABLE_SIZE \
        prepare
    exit
elif [[ $2 == '--test'||$2 == '-t' ]]; then
    #如果文件夹不存在，创建文件夹
    if [ ! -d "./result/mysql_sysbench_test" ]; then
    mkdir -p ./result/mysql_sysbench_test
    fi
    OUTFILE="./result/mysql_sysbench_test/results_$out_name.csv"
    echo "TPS,QPS,P95(ms)" > "$OUTFILE"
    loop_num=200
    for ((i=1;i<=loop_num;i++)); do
        # 运行测试（Baseline）
        result=$(sysbench oltp_read_write \
            --db-driver=mysql \
            --mysql-user=$USER \
            --mysql-password=$PASS \
            --tables=$TABLES \
            --table-size=$TABLE_SIZE \
            --threads=$THREADS \
            --time=$TIME \
            --report-interval=10 \
            run)
        # echo "$result" 
        TPS=$(echo "$result" |awk -F' ' '/transactions:/  {print $3; exit}'| tr -d '(')
        # TPS_SUM=$(echo"$TPS_SUM+$TPS"|bc)
        QPS=$(echo "$result" |awk -F' ' '/queries:/   {print $3; exit}'| tr -d '(')
        # QPS_SUM=$(echo"$QPS_SUM+$QPS"|bc)
        P95=$(echo "$result" |awk -F' ' '/95th percentile:/   {print $3; exit}')
        # P95_SUM=$(echo"$P95_SUM+$P95"|bc)
        # echo "$TPS,$QPS,$P95"
        echo "$TPS,$QPS,$P95" >> $OUTFILE
        sync
        if ((i!=loop_num));then
        sleep 60
        fi
    done

else  
    echo 'no effect input'
    exit
fi


