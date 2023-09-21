#!/bin/bash
source @CMAKE_SOURCE_DIR@/scripts/librun_threads.sh

# prepare base dir
#-----------------------------------------------------
cmake_source_dir="@CMAKE_SOURCE_DIR@"
cmake_current_source_dir="@CMAKE_CURRENT_SOURCE_DIR@"
cmake_relative_dir=${cmake_current_source_dir#$cmake_source_dir}
cmake_relative_dir=${cmake_relative_dir%"scripts"}
#cmake_relative_dir starts with / and end with /
DATADIRBase="@CMAKE_SoNS_DATA_PATH@"$cmake_relative_dir

TMPDIR=@CMAKE_BINARY_DIR@/eva_threads

# check parameters to see scale, if not provided, evaluate all scale
#-----------------------------------------------------
expParam=$1
expScale=None
if [[ "$expParam" == "scale_1" ]]; then
	expScale=1
fi
if [[ "$expParam" == "scale_2" ]]; then
	expScale=2
fi
if [[ "$expParam" == "scale_3" ]]; then
	expScale=3
fi
if [[ "$expParam" == "scale_4" ]]; then
	expScale=4
fi

list=""
if [[ "$expScale" == "None" ]]; then
	echo "scale not provided, evaluate for all scales."
	echo "If you want to evaluate for a specific scale, please specify scale by adding \"scale_1\", \"scale_2\", \"scale_3\", or \"scale_4\""
	list="1 2 3 4"
else
	echo "scale provided, evaluating $subFolder"
	list="$expScale"
fi

for i in $list; do
	echo $i

	DATADIR="$DATADIRBase"data_simu_scale_$i/data
	#THREADS_LOG_OUTPUT=`pwd`/threads_evaluator_output.txt
	#echo exp_01_formation start > $THREADS_LOG_OUTPUT # this is for run_single_threads to reset $THREADS_LOG_OUTPUT
	echo $DATADIR
	# start run number, run per thread, total threads
	run_threads 1 2 25\
		"lua @CMAKE_CURRENT_BINARY_DIR@/evaluator.lua scale_$i" \
		$DATADIR \
		$TMPDIR \
		"----" \
		true
done

