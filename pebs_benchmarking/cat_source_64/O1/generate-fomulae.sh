#!/bin/bash

TIMEOUT=60
TOOL=$1
KAIBYO="java -jar $DAT3M_HOME/kaibyo/target/kaibyo-2.0.7-jar-with-dependencies.jar -input"
CAT="-cat "$DAT3M_HOME/cat/inorder.cat
FLAGS="-secret secretarray -branch_speculation -branch_speculation_error"

LOGFOLDER=$DAT3M_HOME/output/logs/kaibyo-$(date +%Y-%m-%d_%H:%M)
rm -r $DAT3M_HOME/output/*.smt2
mkdir -p $LOGFOLDER

for version in v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15
do
    # Some benchmarks require loop unrolling
    if [[ $version = v5 ]]; then
        FLAGS+=" -unroll 2";
    fi
    
    log=$LOGFOLDER/spectre-pht_$TOOL-$version.log
    (timeout $TIMEOUT $KAIBYO ./spectre-pht_$TOOL.s $CAT $FLAGS -entry victim_function_$version) > $log 2>> $log

done