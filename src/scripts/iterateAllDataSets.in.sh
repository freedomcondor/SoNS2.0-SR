data_set_lists=(
#----
	"M1V1Rsimu   1_Mission_Self-organized_hierarchy/Variant1_Clustered_start/Real_robot_experiments_with_matching_simulations/data_simu/data"
	"M1V1Rhw     1_Mission_Self-organized_hierarchy/Variant1_Clustered_start/Real_robot_experiments_with_matching_simulations/data_hw/data"
	"M1V1L       1_Mission_Self-organized_hierarchy/Variant1_Clustered_start/Large_scale_simulation_experiments/data_simu/data"
	"M1V2Rsimu   1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Real_robot_experiments_with_matching_simulations/data_simu/data"
	"M1V2Rhw     1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Real_robot_experiments_with_matching_simulations/data_hw/data"
	"M1V2L       1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Large_scale_simulation_experiments/data_simu/data"
#----
	"M2V1Rsimu   2_Mission_Global_local_goals/Variant1_Smaller_denser_obstacles/Real_robot_experiments_with_matching_simulations/data_simu/data"
	"M2V1Rhw     2_Mission_Global_local_goals/Variant1_Smaller_denser_obstacles/Real_robot_experiments_with_matching_simulations/data_hw/data"
	"M2V1L       2_Mission_Global_local_goals/Variant1_Smaller_denser_obstacles/Large_scale_simulation_experiments/data_simu/data"
	"M2V2Rsimu   2_Mission_Global_local_goals/Variant2_Larger_less_dense_obstacles/Real_robot_experiments_with_matching_simulations/data_simu/data"
	"M2V2Rhw     2_Mission_Global_local_goals/Variant2_Larger_less_dense_obstacles/Real_robot_experiments_with_matching_simulations/data_hw/data"
	"M2V2L       2_Mission_Global_local_goals/Variant2_Larger_less_dense_obstacles/Large_scale_simulation_experiments/data_simu/data"
#----
	"M3Rsimu     3_Mission_Collective_sensing_actuation/Real_robot_experiments_with_matching_simulations/data_simu/data"
	"M3Rhw       3_Mission_Collective_sensing_actuation/Real_robot_experiments_with_matching_simulations/data_hw/data"
	"M3L         3_Mission_Collective_sensing_actuation/Large_scale_simulation_experiments/data_simu/data"
#----
	"M4Rsimu     4_Mission_Binary_decision/Real_robot_experiments_with_matching_simulations/data_simu/data"
	"M4Rhw       4_Mission_Binary_decision/Real_robot_experiments_with_matching_simulations/data_hw/data"
#----
	"M5V1Rsimu   5_Mission_Splitting_merging/Variant1_Search_and_rescue_in_passage/Real_robot_experiments_with_matching_simulations/data_simu/data"
	"M5V1Rhw     5_Mission_Splitting_merging/Variant1_Search_and_rescue_in_passage/Real_robot_experiments_with_matching_simulations/data_hw/data"
	"M5V1L       5_Mission_Splitting_merging/Variant1_Search_and_rescue_in_passage/Large_scale_simulation_experiments/data_simu/data"
	"M5V2Rsimu   5_Mission_Splitting_merging/Variant2_Push_away_obstruction/Real_robot_experiments_with_matching_simulations/data_simu/data"
	"M5V2Rhw     5_Mission_Splitting_merging/Variant2_Push_away_obstruction/Real_robot_experiments_with_matching_simulations/data_hw/data"
#----
    "M6DeS1      6_Scalability/Scalability_in_decision_making_mission/data_simu_scale_1/data"
    "M6DeS2      6_Scalability/Scalability_in_decision_making_mission/data_simu_scale_2/data"
    "M6DeS3      6_Scalability/Scalability_in_decision_making_mission/data_simu_scale_3/data"
    "M6DeS4      6_Scalability/Scalability_in_decision_making_mission/data_simu_scale_4/data"
#----
    "M6Es1_750     6_Scalability/Scalability_in_SoNS_establishment_mission/data_simu_1-750"
    "M6Es751_999   6_Scalability/Scalability_in_SoNS_establishment_mission/data_simu_751-999"
    "M6Es1000_1299 6_Scalability/Scalability_in_SoNS_establishment_mission/data_simu_1000-1299"
    "M6Es1300_1500 6_Scalability/Scalability_in_SoNS_establishment_mission/data_simu_1300-1500"
#----
	"M7Rsimu     7_Fault_tolerance/Real_robot_experiments_with_matching_simulations/data_simu/data"
	"M7Rhw       7_Fault_tolerance/Real_robot_experiments_with_matching_simulations/data_hw/data"
	"M7LV1       7_Fault_tolerance/Large_scale_simulation_experiments/Variant1_One_third_chance_for_each_robot_to_fail/data_simu/data"
	"M7LV2       7_Fault_tolerance/Large_scale_simulation_experiments/Variant2_Two_thirds_chance_for_each_robot_to_fail/data_simu/data"
	"M7LV3s05    7_Fault_tolerance/Large_scale_simulation_experiments/Variant3_Temporary_system-wide_vision_failure/data_simu_0.5s/data"
	"M7LV3s1     7_Fault_tolerance/Large_scale_simulation_experiments/Variant3_Temporary_system-wide_vision_failure/data_simu_1s/data"
	"M7LV3s30    7_Fault_tolerance/Large_scale_simulation_experiments/Variant3_Temporary_system-wide_vision_failure/data_simu_30s/data"
	"M7LV4s05    7_Fault_tolerance/Large_scale_simulation_experiments/Variant4_Temporary_system-wide_communication_failure/data_simu_0.5s/data"
	"M7LV4s1     7_Fault_tolerance/Large_scale_simulation_experiments/Variant4_Temporary_system-wide_communication_failure/data_simu_1s/data"
	"M7LV4s30    7_Fault_tolerance/Large_scale_simulation_experiments/Variant4_Temporary_system-wide_communication_failure/data_simu_30s/data"
)

for i in ${!data_set_lists[@]}; do
	read -a exp_tuple <<< ${data_set_lists[$i]}
	python3 @CMAKE_CURRENT_BINARY_DIR@/compareLowerbound.py ${exp_tuple[0]} ${exp_tuple[1]} > ${exp_tuple[0]}.output 2>&1 &
done

wait
echo "-------------------------------"
echo "Iterations finish"
