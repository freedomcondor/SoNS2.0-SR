#!/bin/bash
source /home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/librun_threads.sh

# prepare to run threads
#-----------------------------------------------------
DATADIR=""
DATADIR+=/media/harry/Expansion/Storage/SoNS2.0-data/
DATADIR+=experiments/
DATADIR+=1_Mission_Self-organized_hierarchy/
DATADIR+=Variant2_Scattered_start/
DATADIR+=Real_robot_experiments_with_matching_simulations/
DATADIR+=data_hw/data

TMPDIR=/home/harry/code-mns2.0/SoNS2.0-SR/build/eva_threads
#THREADS_LOG_OUTPUT=`pwd`/threads_evaluator_output.txt

#echo exp_01_formation start > $THREADS_LOG_OUTPUT # this is for run_single_threads to reset $THREADS_LOG_OUTPUT

echo $DATADIR

# start run number, run per thread, total threads
run_threads 1 1 5\
	"lua /home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Real_robot_experiments_with_matching_simulations/scripts/evaluator.lua" \
	$DATADIR \
	$TMPDIR \
	"----" \
	true
