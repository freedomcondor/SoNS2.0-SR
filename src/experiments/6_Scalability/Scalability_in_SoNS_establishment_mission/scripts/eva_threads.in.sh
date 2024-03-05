#!/bin/bash
source @CMAKE_SOURCE_DIR@/scripts/librun_threads.sh

# prepare to run threads
#-----------------------------------------------------
cmake_source_dir="@CMAKE_SOURCE_DIR@"
cmake_current_source_dir="@CMAKE_CURRENT_SOURCE_DIR@"
cmake_relative_dir=${cmake_current_source_dir#$cmake_source_dir}
cmake_relative_dir=${cmake_relative_dir%"scripts"}
#cmake_relative_dir starts with / and end with /
DATADIR="@CMAKE_SoNS_DATA_PATH@"$cmake_relative_dir
DATADIR+=data_simu_1-750
#DATADIR+=data_simu_751-999
#DATADIR+=data_simu_1000-1299
#DATADIR+=data_simu_1300-1500

DATADIR="/home/harry/Desktop/scalability_logs"

# prepare to run threads
#-----------------------------------------------------
#DATADIR=/home/harry/Desktop/scalability_logs
TMPDIR=@CMAKE_BINARY_DIR@/eva_threads

#THREADS_LOG_OUTPUT=`pwd`/threads_evaluator_output.txt

#echo exp_01_formation start > $THREADS_LOG_OUTPUT # this is for run_single_threads to reset $THREADS_LOG_OUTPUT

#run_threads 1 25 30\
#run_threads 751 10 25\
#run_threads 1000 10 30\
#run_threads 1300 7 30\

# start run number, run per thread, total threads
run_threads 1 25 30\
	"lua @CMAKE_CURRENT_BINARY_DIR@/evaluator_brain_time_and_comm.lua" \
	$DATADIR \
	$TMPDIR \
	"----" \
	true