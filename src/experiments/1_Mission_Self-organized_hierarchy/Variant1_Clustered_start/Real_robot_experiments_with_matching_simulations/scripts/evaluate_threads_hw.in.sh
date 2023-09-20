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
DATADIR+=data_hw/data

TMPDIR=@CMAKE_BINARY_DIR@/eva_threads
#THREADS_LOG_OUTPUT=`pwd`/threads_evaluator_output.txt

#echo exp_01_formation start > $THREADS_LOG_OUTPUT # this is for run_single_threads to reset $THREADS_LOG_OUTPUT

echo $DATADIR

# start run number, run per thread, total threads
run_threads 1 1 5\
	"lua @CMAKE_CURRENT_BINARY_DIR@/evaluator.lua hardware" \
	$DATADIR \
	$TMPDIR \
	"----" \
	true