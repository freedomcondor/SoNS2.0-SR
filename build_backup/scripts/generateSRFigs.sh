#!/bin/bash
EXP_DIR=/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments
SCRIPT_PATH=scripts/drawLine.py

EXPERIMENT_LIST=( \
# mission 1 --------------------------------------------
#exp_0_hw_01_formation_1_2d_10p \
1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Real_robot_experiments_with_matching_simulations \
#exp_1_simu_01_formation_10d \
1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Large_scale_simulation_experiments \
# mission 2 --------------------------------------------
#exp_0_hw_02_obstacle_avoidance_small \
2_Mission_Global_local_goals/Variant1_Smaller_denser_obstacles/Real_robot_experiments_with_matching_simulations \
#exp_1_simu_02_obstacle_avoidance_small_10d \
2_Mission_Global_local_goals/Variant1_Smaller_denser_obstacles/Large_scale_simulation_experiments \
# mission 3 --------------------------------------------
#exp_0_hw_04_switch_line \
3_Mission_Collective_sensing_actuation/Real_robot_experiments_with_matching_simulations \
#exp_1_simu_04_switch_line \
3_Mission_Collective_sensing_actuation/Large_scale_simulation_experiments \
# mission 4 --------------------------------------------
#exp_0_hw_05_gate_switch \
4_Mission_Binary_decision/Real_robot_experiments_with_matching_simulations \
#scalablity scale 2 \  # run seperately later
# mission 5 --------------------------------------------
#exp_0_hw_08_split \
5_Mission_Splitting_merging/Variant1_Search_and_rescue_in_passage/Real_robot_experiments_with_matching_simulations \
# fault tolerance ------------------------
#exp_0_hw_07_fault_tolerance \
7_Fault_tolerance/Real_robot_experiments_with_matching_simulations \
# fault tolerance high-loss --------------
#exp_3_simu_02_fault_tolerance_33 \
7_Fault_tolerance/Large_scale_simulation_experiments/Variant1_One_third_chance_for_each_robot_to_fail \
# fault tolerance visual and comm loss ---
#exp_3_simu_03_fault_tolerance_communication \
7_Fault_tolerance/Large_scale_simulation_experiments/Variant4_Temporary_system-wide_communication_failure \
#exp_3_simu_04_fault_tolerance_visual \
7_Fault_tolerance/Large_scale_simulation_experiments/Variant3_Temporary_system-wide_vision_failure \
# other  --------------------------------------------
#exp_0_hw_03_obstacle_avoidance_large \
#exp_1_simu_03_obstacle_avoidance_large_10d \
)

LOG=logGeneratingSRFigs.log
echo "generating SR figures for manuscript" > $LOG

for exp_name in ${EXPERIMENT_LIST[@]}
do
	drawLinePyScript=$EXP_DIR/$exp_name/$SCRIPT_PATH
	echo "running" $drawLinePyScript
	echo "running" $drawLinePyScript "------------------------------------------------------------" >> $LOG
	python3 $drawLinePyScript >> $LOG
done

SPECIAL_LIST=( \
#exp_2_simu_scalability/scripts/drawLine_scale_2.py \
6_Scalability/Scalability_in_decision_making_mission/scripts/drawLine_scale_2.py \
#exp_2_simu_scalability/scripts/drawLine_scale_4.py \
6_Scalability/Scalability_in_decision_making_mission/scripts/drawLine_scale_4.py \
)

for script_name in ${SPECIAL_LIST[@]}
do
	drawLinePyScript=$EXP_DIR/$script_name
	echo "running" $drawLinePyScript
	echo "running" $drawLinePyScript "------------------------------------------------------------" >> $LOG
	python3 $drawLinePyScript >> $LOG
done
