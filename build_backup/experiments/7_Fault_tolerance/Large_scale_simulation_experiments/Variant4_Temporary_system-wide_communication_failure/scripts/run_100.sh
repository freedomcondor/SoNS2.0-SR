#!/bin/bash
source /home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/run_threads.sh

#DATADIR=/home/harry/code-mns2.0/SoNS2.0-SR/src/experiments/7_Fault_tolerance/Large_scale_simulation_experiments/Variant4_Temporary_system-wide_communication_failure/scripts/../data

DATADIR=/home/harry/code-mns2.0/SoNS2.0-SR/src/../../SoNS2.0-data/src/experiments/exp_3_simu_03_fault_tolerance_communication/data_simu_0.5s/data
#DATADIR=/home/harry/code-mns2.0/SoNS2.0-SR/src/../../SoNS2.0-data/src/experiments/exp_3_simu_03_fault_tolerance_communication/data_simu_1s/data
#DATADIR=/home/harry/code-mns2.0/SoNS2.0-SR/src/../../SoNS2.0-data/src/experiments/exp_3_simu_03_fault_tolerance_communication/data_simu_30s/data

TMPDIR=threads
#run 2 3 "python3 /home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/7_Fault_tolerance/Large_scale_simulation_experiments/Variant4_Temporary_system-wide_communication_failure/scripts/../run.py -l 50" $DATADIR
#run_single_thread 2 4 4 "python3 /home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/7_Fault_tolerance/Large_scale_simulation_experiments/Variant4_Temporary_system-wide_communication_failure/scripts/../run.py -l 60" $DATADIR

#start number, runs per thread, threads
#append "-l 30" to python3 to overwrite experiment length

if [ "$RUN_FLAG" != "false" ]; then
	run_threads 1 2 3 \
	            "python3 /home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/7_Fault_tolerance/Large_scale_simulation_experiments/Variant4_Temporary_system-wide_communication_failure/scripts/../run.py" \
	            $DATADIR \
	            $TMPDIR
else
	echo "skip run threads"
fi

if [ "$EVA_FLAG" != "false" ]; then
	echo "Evaluating"
	evaluate $DATADIR \
	         "lua /home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/7_Fault_tolerance/Large_scale_simulation_experiments/Variant4_Temporary_system-wide_communication_failure/scripts/evaluator.lua" #"result_data_.txt"
	#         "rm result_data.txt"
else
	echo "skip evaluating"
fi
