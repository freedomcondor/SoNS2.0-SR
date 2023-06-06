#!/bin/bash
source @CMAKE_SOURCE_DIR@/scripts/run_threads.sh

#DATADIR=@CMAKE_CURRENT_SOURCE_DIR@/../data
#DATADIR=/Users/harry/Desktop/exp_0_hw_07_fault_tolerance/data_hw/data
#DATADIR=@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_07_fault_tolerance/data_hw/data
DATADIR=@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_07_fault_tolerance/data_simu/data
TMPDIR=threads
#run 2 3 "python3 @CMAKE_CURRENT_BINARY_DIR@/../run.py -l 50" $DATADIR
#run_single_thread 2 4 4 "python3 @CMAKE_CURRENT_BINARY_DIR@/../run.py -l 60" $DATADIR

#start number, runs per thread, threads
#append "-l 30" to python3 to overwrite experiment length

if [ "$RUN_FLAG" != "false" ]; then
	run_threads 1 2 3 \
	            "python3 @CMAKE_CURRENT_BINARY_DIR@/../run.py" \
	            $DATADIR \
	            $TMPDIR
else
	echo "skip run threads"
fi

if [ "$EVA_FLAG" != "false" ]; then
	echo "Evaluating"
	evaluate $DATADIR \
	         "lua @CMAKE_CURRENT_BINARY_DIR@/evaluator.lua" "result__data.txt"
	#         "lua @CMAKE_CURRENT_BINARY_DIR@/evaluator.lua"
	#         "rm result_data.txt"
else
	echo "skip evaluating"
fi