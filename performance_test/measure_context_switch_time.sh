#!/bin/bash

if (( $# != 1 )); then
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
if [ ! -d "./result/context_switch_time" ]; then
    mkdir -p ./result/context_switch_time
fi


OUTFILE="./result/context_switch_time/lat_ctx_2proc_results_$out_name.csv"

# echo $OUTFILE
echo "StackSize(KB),16,32,64,128,256,512,1024" > $OUTFILE

stacks=(16 32 64 128 256 512 1024)

loop_num=200

for ((i=1;i<=loop_num;i++)); do
  # sum=0
  # echo "Running: Procs=2 Stack=${s}k ..."
  echo -n "us," >> ${OUTFILE}

  for s in "${stacks[@]}"; do
    raw=$(taskset -c 0 ~/app/lmbench-3.0-a9/bin/x86_64-linux-gnu/lat_ctx 2 64 2>&1 | awk 'NR==3 {print $2}')
    # 
    result=$(echo $raw | tr -d ',' | tr -cd '0-9.')
    # sum=$(echo "$sum + $result" | bc)
    if ((s!=1024)); then
      echo -n "${result}," >> ${OUTFILE}
    else
      echo "${result}" >> ${OUTFILE}
    fi
  done
  # avg=$(echo "scale=2; $sum / $loop_num" | bc)
  # echo "$s,$avg" >> $OUTFILE
  if ((i!=loop_num));then
    sleep 60
  fi
  
done

echo "All done. Results saved in $OUTFILE"

