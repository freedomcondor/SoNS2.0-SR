#!/bin/bashEXP_DIR
EXP_DIR=@CMAKE_BINARY_DIR@/experiments

python3 $EXP_DIR/1_Mission_Self-organized_hierarchy/Variant1_Clustered_start/Large_scale_simulation_experiments/scripts/drawLine_sup_simu.py > M1V1L.output 2>&1 &
python3 $EXP_DIR/1_Mission_Self-organized_hierarchy/Variant1_Clustered_start/Real_robot_experiments_with_matching_simulations/scripts/drawLine_sup_hw.py > M1V1Rhw.output 2>&1 &
python3 $EXP_DIR/1_Mission_Self-organized_hierarchy/Variant1_Clustered_start/Real_robot_experiments_with_matching_simulations/scripts/drawLine_sup_simu.py > M1V1Rsimu.output 2>&1 &
python3 $EXP_DIR/1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Large_scale_simulation_experiments/scripts/drawLine_sup_simu.py > M1V2L.output 2>&1 &
python3 $EXP_DIR/1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Real_robot_experiments_with_matching_simulations/scripts/drawLine_sup_hw.py > M1V2Rhw.output 2>&1 &
python3 $EXP_DIR/1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Real_robot_experiments_with_matching_simulations/scripts/drawLine_sup_simu.py > M1V2Rsimu.output 2>&1 &

python3 $EXP_DIR/2_Mission_Global_local_goals/Variant1_Smaller_denser_obstacles/Large_scale_simulation_experiments/scripts/drawLine_sup_simu.py > M2V1L.output 2>&1 &
python3 $EXP_DIR/2_Mission_Global_local_goals/Variant1_Smaller_denser_obstacles/Real_robot_experiments_with_matching_simulations/scripts/drawLine_sup_hw.py > M2V1Rhw.output 2>&1 &
python3 $EXP_DIR/2_Mission_Global_local_goals/Variant1_Smaller_denser_obstacles/Real_robot_experiments_with_matching_simulations/scripts/drawLine_sup_simu.py > M2V1Rsimu.output 2>&1 &
python3 $EXP_DIR/2_Mission_Global_local_goals/Variant2_Larger_less_dense_obstacles/Large_scale_simulation_experiments/scripts/drawLine_sup_simu.py > M2V2L.output 2>&1 &
python3 $EXP_DIR/2_Mission_Global_local_goals/Variant2_Larger_less_dense_obstacles/Real_robot_experiments_with_matching_simulations/scripts/drawLine_sup_hw.py > M2V2Rhw.output 2>&1 &
python3 $EXP_DIR/2_Mission_Global_local_goals/Variant2_Larger_less_dense_obstacles/Real_robot_experiments_with_matching_simulations/scripts/drawLine_sup_simu.py > M2V2Rsimu.output 2>&1 &

python3 $EXP_DIR/3_Mission_Collective_sensing_actuation/Large_scale_simulation_experiments/scripts/drawLine_sup_simu.py > M3L.output 2>&1 &
python3 $EXP_DIR/3_Mission_Collective_sensing_actuation/Real_robot_experiments_with_matching_simulations/scripts/drawLine_sup_hw.py > M3Rhw.output 2>&1 &
python3 $EXP_DIR/3_Mission_Collective_sensing_actuation/Real_robot_experiments_with_matching_simulations/scripts/drawLine_sup_simu.py > M3Rsimu.output 2>&1 &

python3 $EXP_DIR/4_Mission_Binary_decision/Real_robot_experiments_with_matching_simulations/scripts/drawLine_sup_hw.py > M4Rhw.output 2>&1 &
python3 $EXP_DIR/4_Mission_Binary_decision/Real_robot_experiments_with_matching_simulations/scripts/drawLine_sup_simu.py > M4Rsimu.output 2>&1 &

python3 $EXP_DIR/5_Mission_Splitting_merging/Variant1_Search_and_rescue_in_passage/Large_scale_simulation_experiments/scripts/drawLine_sup_simu.py > M5V1L.output 2>&1 &
python3 $EXP_DIR/5_Mission_Splitting_merging/Variant1_Search_and_rescue_in_passage/Real_robot_experiments_with_matching_simulations/scripts/drawLine_sup_hw.py > M5V1Rhw.output 2>&1 &
python3 $EXP_DIR/5_Mission_Splitting_merging/Variant1_Search_and_rescue_in_passage/Real_robot_experiments_with_matching_simulations/scripts/drawLine_sup_simu.py > M5V1Rsimu.output 2>&1 &
python3 $EXP_DIR/5_Mission_Splitting_merging/Variant2_Push_away_obstruction/Real_robot_experiments_with_matching_simulations/scripts/drawLine_sup_hw.py > M5V2Rhw.output 2>&1 &
python3 $EXP_DIR/5_Mission_Splitting_merging/Variant2_Push_away_obstruction/Real_robot_experiments_with_matching_simulations/scripts/drawLine_sup_simu.py > M5V2Rsimu.output 2>&1 &

python3 $EXP_DIR/6_Scalability/Scalability_in_SoNS_establishment_mission/scripts/drawLine_sup_simu.py > M6ES.output 2>&1 &
python3 $EXP_DIR/6_Scalability/Scalability_in_decision_making_mission/scripts/drawLine_sup_simu.py > M6DE.output 2>&1 &

python3 $EXP_DIR/7_Fault_tolerance/Large_scale_simulation_experiments/Variant1_One_third_chance_for_each_robot_to_fail/scripts/drawLine_sup_simu.py > M7LV1.output 2>&1 &
python3 $EXP_DIR/7_Fault_tolerance/Large_scale_simulation_experiments/Variant2_Two_thirds_chance_for_each_robot_to_fail/scripts/drawLine_sup_simu.py > M7LV2.output 2>&1 &
python3 $EXP_DIR/7_Fault_tolerance/Large_scale_simulation_experiments/Variant3_Temporary_system-wide_vision_failure/scripts/drawLine_sup_simu.py > M7LV3.output 2>&1 &
python3 $EXP_DIR/7_Fault_tolerance/Large_scale_simulation_experiments/Variant4_Temporary_system-wide_communication_failure/scripts/drawLine_sup_simu.py > M7LV4.output 2>&1 &
python3 $EXP_DIR/7_Fault_tolerance/Real_robot_experiments_with_matching_simulations/scripts/drawLine_sup_hw.py > M7Rhw.output 2>&1 &
python3 $EXP_DIR/7_Fault_tolerance/Real_robot_experiments_with_matching_simulations/scripts/drawLine_sup_simu.py > M7Rsimu.output 2>&1 &
