#!/bin/bash
source @CMAKE_SOURCE_DIR@/scripts/librun_threads.sh

experiment_type=$1
if [[ $experiment_type == "0.5s" ]]; then
	echo "0.5s parameter given"
elif [[ $experiment_type == "1s" ]]; then
	echo "1s parameter given"
elif [[ $experiment_type == "30s" ]]; then
	echo "30s parameter given"
else
	echo "invalid parameters, please specify 0.5s, 1s, or 30s"
	exit
fi

# prepare to run threads
#-----------------------------------------------------
cmake_source_dir="@CMAKE_SOURCE_DIR@"
cmake_current_source_dir="@CMAKE_CURRENT_SOURCE_DIR@"
cmake_relative_dir=${cmake_current_source_dir#$cmake_source_dir}
cmake_relative_dir=${cmake_relative_dir%"scripts"}
#cmake_relative_dir starts with / and end with /
DATADIR="@CMAKE_SoNS_DATA_PATH@"$cmake_relative_dir
DATADIR+=data_simu_$experiment_type/data

TMPDIR=@CMAKE_BINARY_DIR@/eva_threads
#THREADS_LOG_OUTPUT=`pwd`/threads_evaluator_output.txt

#echo exp_01_formation start > $THREADS_LOG_OUTPUT # this is for run_single_threads to reset $THREADS_LOG_OUTPUT

echo $DATADIR

# start run number, run per thread, total threads
run_threads 1 2 25\
	"lua @CMAKE_CURRENT_BINARY_DIR@/evaluator.lua" \
	$DATADIR \
	$TMPDIR \
	"----" \
	true