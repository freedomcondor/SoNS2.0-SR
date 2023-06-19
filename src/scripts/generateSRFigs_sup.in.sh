#!/bin/bash
EXP_DIR=@CMAKE_BINARY_DIR@/experiments
SCRIPT_HW_PATH=scripts/drawLine_sup_hw.py
SCRIPT_SIMU_PATH=scripts/drawLine_sup_simu.py

EXPERIMENT_LIST=( \
# mission 1
exp_0_hw_01_formation_1_2d_10p \
#exp_1_simu_01_formation_10d \
# mission 2
#exp_0_hw_02_obstacle_avoidance_small \
#exp_1_simu_02_obstacle_avoidance_small_10d \
# mission 3
#exp_0_hw_04_switch_line \
#exp_1_simu_04_switch_line \
# mission 4
#exp_0_hw_05_gate_switch \
#scalablity scale 2 \  # run seperately later
# mission 5
#exp_0_hw_08_split \
# fault tolerance
#exp_0_hw_07_fault_tolerance \
# fault tolerance high-loss
#exp_3_simu_02_fault_tolerance_33 \
# fault tolerance visual and comm loss
#exp_3_simu_03_fault_tolerance_communication \
#exp_3_simu_04_fault_tolerance_visual \
# other 
#exp_0_hw_03_obstacle_avoidance_large \
#exp_1_simu_03_obstacle_avoidance_large_10d \
)

for exp_name in ${EXPERIMENT_LIST[@]}
do
	drawLinePyScript=$EXP_DIR/$exp_name/$SCRIPT_HW_PATH
	echo "running" $drawLinePyScript
	python3 $drawLinePyScript

	drawLinePyScript=$EXP_DIR/$exp_name/$SCRIPT_SIMU_PATH
	echo "running" $drawLinePyScript
	python3 $drawLinePyScript
done

#SPECIAL_LIST=( \
#exp_2_simu_scalability/scripts/drawLine_scale_2.py \
#exp_2_simu_scalability/scripts/drawLine_scale_4.py \
#)

#for script_name in ${SPECIAL_LIST[@]}
#do
#	drawLinePyScript=$EXP_DIR/$script_name
#	echo "running" $drawLinePyScript
#	python3 $drawLinePyScript
#done