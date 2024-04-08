#!/bin/bash
EXP_DIR=@CMAKE_BINARY_DIR@/experiments

python3 $EXP_DIR/1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Large_scale_simulation_experiments/scripts/drawLine_main.py > M1V2L.output 2>&1 &
python3 $EXP_DIR/1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Real_robot_experiments_with_matching_simulations/scripts/drawLine_main.py > M1V2R.output 2>&1 &
python3 $EXP_DIR/2_Mission_Global_local_goals/Variant1_Smaller_denser_obstacles/Large_scale_simulation_experiments/scripts/drawLine_main.py > M2V1L.output 2>&1 &
python3 $EXP_DIR/2_Mission_Global_local_goals/Variant1_Smaller_denser_obstacles/Real_robot_experiments_with_matching_simulations/scripts/drawLine_main.py > M2V1R.output 2>&1 &
python3 $EXP_DIR/3_Mission_Collective_sensing_actuation/Large_scale_simulation_experiments/scripts/drawLine_main.py > M3L.output 2>&1 &
python3 $EXP_DIR/3_Mission_Collective_sensing_actuation/Real_robot_experiments_with_matching_simulations/scripts/drawLine_main.py > M3R.output 2>&1 &
python3 $EXP_DIR/4_Mission_Binary_decision/Real_robot_experiments_with_matching_simulations/scripts/drawLine_main.py > M4R.output 2>&1 &
python3 $EXP_DIR/5_Mission_Splitting_merging/Variant1_Search_and_rescue_in_passage/Large_scale_simulation_experiments/scripts/drawLine_main.py > M5V1L.output 2>&1 &
python3 $EXP_DIR/5_Mission_Splitting_merging/Variant1_Search_and_rescue_in_passage/Real_robot_experiments_with_matching_simulations/scripts/drawLine_main.py > M5V1R.output 2>&1 &
python3 $EXP_DIR/6_Scalability/Scalability_in_SoNS_establishment_mission/scripts/drawLine_main.py > M6ES.output 2>&1 &
python3 $EXP_DIR/6_Scalability/Scalability_in_decision_making_mission/scripts/drawLine_main.py > M6DE.output 2>&1 &
python3 $EXP_DIR/7_Fault_tolerance/Large_scale_simulation_experiments/Variant1_One_third_chance_for_each_robot_to_fail/scripts/drawLine_main.py > M7LV1.output 2>&1 &
python3 $EXP_DIR/7_Fault_tolerance/Large_scale_simulation_experiments/Variant3_Temporary_system-wide_vision_failure/scripts/drawLine_main.py > M7LV3.output 2>&1 &
python3 $EXP_DIR/7_Fault_tolerance/Large_scale_simulation_experiments/Variant4_Temporary_system-wide_communication_failure/scripts/drawLine_main.py > M7LV4.output 2>&1 &
python3 $EXP_DIR/7_Fault_tolerance/Real_robot_experiments_with_matching_simulations/scripts/drawLine_main.py > M7R.output 2>&1 &
