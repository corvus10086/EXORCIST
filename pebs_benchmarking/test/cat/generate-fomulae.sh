#!/bin/bash
#
TIMEOUT=60

KAIBYO="java -jar $DAT3M_HOME/kaibyo/target/kaibyo-2.0.7-jar-with-dependencies.jar -input"
CAT="-cat "$DAT3M_HOME/cat/inorder.cat
FLAGS="-secret secret -branch_speculation -branch_speculation_error"

LOGFOLDER=./output/logs/kaibyo-$(date +%Y-%m-%d_%H:%M)
mkdir -p $LOGFOLDER


for version in v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15
do
    # Some benchmarks require loop unrolling
    if [[ $version = v5 ]]; then
        FLAGS+=" -unroll 2";
    fi
    mkdir $LOGFOLDER/$version
    for level in 0 1 2 3 
    do
        log=$LOGFOLDER/$version/spec-cl-o$level.log
        (timeout $TIMEOUT $KAIBYO ../../src_copy/$version/spec_cl_o$level.s $CAT $FLAGS -entry victim_function) > $log 2>> $log

        log=$LOGFOLDER/$version/spec-gcc-o$level.log
        (timeout $TIMEOUT $KAIBYO ../../src_copy/$version/spec_gcc_o$level.s $CAT $FLAGS -entry victim_function) > $log 2>> $log
    done

    
done