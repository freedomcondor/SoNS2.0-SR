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
DATADIR+=data_simu/data

#-----------------------------------------------------
# prepare to run threads
CODEDIR=$DATADIR/../code
TMPDIR=@CMAKE_BINARY_DIR@/threads
#THREADS_LOG_OUTPUT=`pwd`/threads_output.txt

run_per_thread=5
number_threads=10
argos_multi_threads=4

# start run number, run per thread, total threads
run_threads 1 $run_per_thread $number_threads\
	"python3 @CMAKE_CURRENT_BINARY_DIR@/../run.py -m $argos_multi_threads" \
	$DATADIR \
	$TMPDIR \
	": do not check"

cp -r @CMAKE_CURRENT_BINARY_DIR@/../simu_code $CODEDIR