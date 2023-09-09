#!/bin/bash
source @CMAKE_SOURCE_DIR@/scripts/librun_threads.sh

# prepare to run threads
#-----------------------------------------------------
DATADIR=""
DATADIR+=@CMAKE_SoNS_DATA_PATH@/
DATADIR+=experiments/
DATADIR+=1_Mission_Self-organized_hierarchy/
DATADIR+=Variant1_Clustered_start/
DATADIR+=Real_robot_experiments_with_matching_simulations/
DATADIR+=data_simu/data

TMPDIR=@CMAKE_BINARY_DIR@/eva_threads
#THREADS_LOG_OUTPUT=`pwd`/threads_evaluator_output.txt

#echo exp_01_formation start > $THREADS_LOG_OUTPUT # this is for run_single_threads to reset $THREADS_LOG_OUTPUT

echo $DATADIR

# start run number, run per thread, total threads
run_threads 1 5 12\
	"lua @CMAKE_CURRENT_BINARY_DIR@/evaluator.lua" \
	$DATADIR \
	$TMPDIR \
	"----" \
	true