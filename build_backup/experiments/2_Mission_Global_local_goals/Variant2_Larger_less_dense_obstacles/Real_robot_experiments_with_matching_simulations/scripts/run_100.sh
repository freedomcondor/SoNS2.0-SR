#!/bin/bash
source /home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/run_threads.sh

#DATADIR=/home/harry/code-mns2.0/SoNS2.0-SR/src/experiments/2_Mission_Global_local_goals/Variant2_Larger_less_dense_obstacles/Real_robot_experiments_with_matching_simulations/scripts/../data
DATADIR=/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_03_obstacle_avoidance_large/data_hw/data
#DATADIR=/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_03_obstacle_avoidance_large/data_simu/data

TMPDIR=threads
#THREADS_LOG_OUTPUT="/home/harry/code/SoNS2.0-SR/build/out.log"

#run 2 3 "python3 /home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/2_Mission_Global_local_goals/Variant2_Larger_less_dense_obstacles/Real_robot_experiments_with_matching_simulations/scripts/../run.py -l 50" $DATADIR
#run_single_thread 2 4 4 "python3 /home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/2_Mission_Global_local_goals/Variant2_Larger_less_dense_obstacles/Real_robot_experiments_with_matching_simulations/scripts/../run.py -l 60" $DATADIR

#start number, runs per thread, threads
#append "-l 30" to python3 to overwrite experiment length

if [ "$RUN_FLAG" != "false" ]; then
	run_threads 1 2 3 \
	            "python3 /home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/2_Mission_Global_local_goals/Variant2_Larger_less_dense_obstacles/Real_robot_experiments_with_matching_simulations/scripts/../run.py" \
	            $DATADIR \
	            $TMPDIR
else
	echo "skip run threads" >> $THREADS_LOG_OUTPUT
fi

if [ "$EVA_FLAG" != "false" ]; then
	echo "Evaluating" >> $THREADS_LOG_OUTPUT
	evaluate $DATADIR \
	         "lua /home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/2_Mission_Global_local_goals/Variant2_Larger_less_dense_obstacles/Real_robot_experiments_with_matching_simulations/scripts/evaluator.lua"
	#         "rm result_data.txt"
else
	echo "skip evaluating" >> $THREADS_LOG_OUTPUT
fi
