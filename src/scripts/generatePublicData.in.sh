ORIGIN_DIR=`pwd`

raw_exps_dir="@CMAKE_MNS_DATA_PATH@/src/experiments"
public_dir="@CMAKE_PUB_DATA_PATH@"

# check public data exists or not
if [ ! -d "$public_dir" ]; then
	echo doesn\'t exist: $public_dir, creating
	mkdir $public_dir
fi

#-----------------------------------------------------------------------------------
copy_run() {
	# all parameter folder ends with /
	input_run_folder=$1
	output_run_folder=$2
	#run_folder_name=$3
	#echo "        $run_folder_name"
	begin_folder=`pwd`

	# copy csvs
	cp -r "$input_run_folder"csvs "$output_run_folder"experiment_data
	# copy results
	mkdir -p "$output_run_folder"error_measurements
	cp "$input_run_folder"result_data.txt "$output_run_folder"error_measurements/error.csv
	if [ -d "$input_run_folder"result_each_robot_error ]; then
		mkdir -p "$output_run_folder"error_measurements/error_per_robot
		cd "$input_run_folder"result_each_robot_error
		for error_per_robot_txt in * ; do
			cp $error_per_robot_txt "$output_run_folder"error_measurements/error_per_robot/${error_per_robot_txt%.*}.csv
		done
		cd $begin_folder
	fi
	# copy failure_robots.txt and formationSwitch
	if [ -f "$input_run_folder"failure_robots.txt ]; then
		cp "$input_run_folder"failure_robots.txt "$output_run_folder"_failed_robots.txt
	fi
	if [ -f "$input_run_folder"formationSwitch.txt ]; then
		cp "$input_run_folder"formationSwitch.txt "$output_run_folder"_timesteps_target_SoNS_change.txt
	fi

	: '
	# copy video
	cd $input_run_folder
	for each_video in *.mp4; do
		if [ -e $each_video ]; then
			mkdir -p "$output_run_folder"videos
			cp $each_video "$output_run_folder"videos
		fi
	done
	cd $begin_folder
	'

	# copy code
	#if [ -d "$input_run_folder"hw ]; then
	#	cp -r "$input_run_folder"hw "$output_run_folder"code_hw
	#fi
	#if [ -e "$input_run_folder"vns.argos ]; then
	#	mkdir -p "$output_run_folder"code_simu
	#	cp "$input_run_folder"vns.argos "$output_run_folder"code_simu
	#	if [ -d "$input_run_folder"../../code_and_output/simu ]; then
	#		cp -r "$input_run_folder"../../code_and_output/simu "$output_run_folder"code_simu
	#	fi
	#fi

}

#-----------------------------------------------------------------------------------
# list of experiments and their public names
exp_folder_lists=(
	"exp_0_hw_01_formation_1_2d_10p    mission1_hw_exp_formation_scatter"
	"exp_0_hw_05_gate_switch           mission4_hw_exp_gate_switch"
)

copy_exp_folder() {
	input_folder=$1
	output_folder=$2
	echo copying from $input_folder to $output_folder
	mkdir -p $public_dir/$output_folder
	cd $raw_exps_dir/$input_folder
	# check mp4 exists and copy
	#cp *.mp4 $public_dir/$output_folder
	# iterate all data sets
	for data_set_name in data_simu* data_hw*; do
		if [ ! -d $raw_exps_dir/$input_folder/$data_set_name ]; then
			continue
		fi

		# determine data set name
		case $data_set_name in
			data_simu )
				output_data_set_name="simulation_experiments" ;;
			data_hw )
				output_data_set_name="real_robots_experiments" ;;
			data_simu_drone_failure )
				output_data_set_name="simulation_experiments_aerial_robot_failure" ;;
			data_simu_pipuck_failure )
				output_data_set_name="simulation_experiments_ground_robot_failure" ;;
			data_simu_0.5s )
				output_data_set_name="simulation_experiments_0.5s_failure" ;;
			data_simu_1s )
				output_data_set_name="simulation_experiments_1s_failure" ;;
			data_simu_30s )
				output_data_set_name="simulation_experiments_30s_failure" ;;
			data_simu_scale_1 )
				output_data_set_name="simulation_experiments_35robots" ;;
			data_simu_scale_2 )
				output_data_set_name="simulation_experiments_65robots" ;;
			data_simu_scale_3 )
				output_data_set_name="simulation_experiments_95robots" ;;
			data_simu_scale_4 )
				output_data_set_name="simulation_experiments_125robots" ;;
			* )
				echo "unknown data set name: "$data_set_name
				output_data_set_name=$data_set_name
		esac

		# exp_0_hw_09 hw don't have data
		if [ -d $raw_exps_dir/$input_folder/$data_set_name ]; then
			data_set_name=$data_set_name/data
		fi

		echo "    copying $data_set_name"
		echo "         to $output_data_set_name" 

		mkdir -p $public_dir/$output_folder/$output_data_set_name
		cd $raw_exps_dir/$input_folder/$data_set_name
		i=0
		for run_folder in */; do
			((i=i+1))
			output_run_folder=$public_dir/$output_folder/$output_data_set_name/$run_folder
			if [[ $run_folder != run* ]]; then
				echo "            " $run_folder is not run*, renaming to run$i
				output_run_folder=$public_dir/$output_folder/$output_data_set_name/run$i/
			fi

			mkdir -p $output_run_folder
			copy_run $raw_exps_dir/$input_folder/$data_set_name/$run_folder $output_run_folder #$run_folder
		done
	done
}
#-----------------------------------------------------------------------------------
# list of data sets and their public names
data_set_lists=(
	"exp_0_hw_01_formation_1_2d_10p/data_hw/data    1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Real_robots_experiments"
	"exp_0_hw_01_formation_1_2d_10p/data_simu/data  1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Simulation_experiments/12robots"
	"exp_1_simu_01_formation_10d/data_simu/data     1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Simulation_experiments/50robots"

	"exp_0_hw_10_formation_1_2d_6p_group_start/data_hw/data     1_Mission_Self-organized_hierarchy/Variant1_Clustered_start/Real_robots_experiments"
	"exp_0_hw_10_formation_1_2d_6p_group_start/data_simu/data   1_Mission_Self-organized_hierarchy/Variant1_Clustered_start/Simulation_experiments/8robots"
	"exp_1_simu_10_formation_10d_group_start/data_simu/data     1_Mission_Self-organized_hierarchy/Variant1_Clustered_start/Simulation_experiments/50robots"

	"exp_0_hw_02_obstacle_avoidance_small/data_hw/data          2_Mission_Global_local_goals/Variant1_Smaller_denser_obstacles/Real_robots_experiments"
	"exp_0_hw_02_obstacle_avoidance_small/data_simu/data        2_Mission_Global_local_goals/Variant1_Smaller_denser_obstacles/Simulation_experiments/8robots"
	"exp_1_simu_02_obstacle_avoidance_small_10d/data_simu/data  2_Mission_Global_local_goals/Variant1_Smaller_denser_obstacles/Simulation_experiments/50robots"

	"exp_0_hw_03_obstacle_avoidance_large/data_hw/data          2_Mission_Global_local_goals/Variant2_Larger_less_dense_obstacles/Real_robots_experiments"
	"exp_0_hw_03_obstacle_avoidance_large/data_simu/data        2_Mission_Global_local_goals/Variant2_Larger_less_dense_obstacles/Simulation_experiments/8robots"
	"exp_1_simu_03_obstacle_avoidance_large_10d/data_simu/data  2_Mission_Global_local_goals/Variant2_Larger_less_dense_obstacles/Simulation_experiments/50robots"

	"exp_0_hw_04_switch_line/data_hw/data                       3_Mission_Collective_sensing_actuation/Real_robots_experiments"
	"exp_0_hw_04_switch_line/data_simu/data                     3_Mission_Collective_sensing_actuation/Simulation_experiments/8robots"
	"exp_1_simu_04_switch_line/data_simu/data                   3_Mission_Collective_sensing_actuation/Simulation_experiments/50robots"

	"exp_0_hw_05_gate_switch/data_hw/data                       4_Mission_Binary_decision/Real_robots_experiments"
	"exp_0_hw_05_gate_switch/data_simu/data                     4_Mission_Binary_decision/Simulation_experiments/8robots"
	"exp_2_simu_scalability/data_simu_scale_2/data              4_Mission_Binary_decision/Simulation_experiments/65robots"

	"exp_0_hw_08_split/data_hw/data                    5_Mission_Splitting_merging/Variant1_Search_and_rescue_in_passage/Real_robots_experiments"
	"exp_0_hw_08_split/data_simu/data                  5_Mission_Splitting_merging/Variant1_Search_and_rescue_in_passage/Simulation_experiments/8robots"
	"exp_1_simu_08_split/data_simu/data                5_Mission_Splitting_merging/Variant1_Search_and_rescue_in_passage/Simulation_experiments/50robots"

	"exp_0_hw_09_1d_switch_rescue/data_hw              5_Mission_Splitting_merging/Variant2_Push_away_obstruction/Real_robots_experiments"
	"exp_0_hw_09_1d_switch_rescue/data_simu/data       5_Mission_Splitting_merging/Variant2_Push_away_obstruction/Simulation_experiments/5robots"

	"exp_2_simu_scalability/data_simu_scale_1/data     6_Scalability/Scalability_in_decision_making_mission/35robots"
	"exp_2_simu_scalability/data_simu_scale_2/data     6_Scalability/Scalability_in_decision_making_mission/65robots"
	"exp_2_simu_scalability/data_simu_scale_3/data     6_Scalability/Scalability_in_decision_making_mission/95robots"
	"exp_2_simu_scalability/data_simu_scale_4/data     6_Scalability/Scalability_in_decision_making_mission/125robots"

#----------------------------

	# -- remove fault tolerance data hw is moved to special run list
	"exp_0_hw_07_fault_tolerance/data_simu/data                       7_Fault_tolerance/Simulation_experiments/8robots"

	"exp_3_simu_02_fault_tolerance_33/data_simu/data                  7_Fault_tolerance/Simulation_experiments/50robots/Variant1_One_third_chance_for_each_robot_to_fail"
	"exp_3_simu_02_fault_tolerance_33/data_simu_drone_failure/data    7_Fault_tolerance/Simulation_experiments/50robots/Variants_additional/One_third_chance_for_each_aerial_robot_to_fail"
	"exp_3_simu_02_fault_tolerance_33/data_simu_pipuck_failure/data   7_Fault_tolerance/Simulation_experiments/50robots/Variants_additional/One_third_chance_for_each_ground_robot_to_fail"

	"exp_3_simu_01_fault_tolerance_66/data_simu/data                  7_Fault_tolerance/Simulation_experiments/50robots/Variant2_Two_thirds_chance_for_each_robot_to_fail"
	"exp_3_simu_01_fault_tolerance_66/data_simu_drone_failure/data    7_Fault_tolerance/Simulation_experiments/50robots/Variants_additional/Two_thirds_chance_for_each_aerial_robot_to_fail"
	"exp_3_simu_01_fault_tolerance_66/data_simu_pipuck_failure/data   7_Fault_tolerance/Simulation_experiments/50robots/Variants_additional/Two_thirds_chance_for_each_ground_robot_to_fail"

	"exp_3_simu_04_fault_tolerance_visual/data_simu_0.5s/data         7_Fault_tolerance/Simulation_experiments/50robots/Variant3_Temporary_system-wide_vision_failure/0.5s_failure"
	"exp_3_simu_04_fault_tolerance_visual/data_simu_1s/data           7_Fault_tolerance/Simulation_experiments/50robots/Variant3_Temporary_system-wide_vision_failure/1s_failure"
	"exp_3_simu_04_fault_tolerance_visual/data_simu_30s/data          7_Fault_tolerance/Simulation_experiments/50robots/Variant3_Temporary_system-wide_vision_failure/30s_failure"

	"exp_3_simu_03_fault_tolerance_communication/data_simu_0.5s/data  7_Fault_tolerance/Simulation_experiments/50robots/Variant4_Temporary_system-wide_communication_failure/0.5s_failure"
	"exp_3_simu_03_fault_tolerance_communication/data_simu_1s/data    7_Fault_tolerance/Simulation_experiments/50robots/Variant4_Temporary_system-wide_communication_failure/1s_failure"
	"exp_3_simu_03_fault_tolerance_communication/data_simu_30s/data   7_Fault_tolerance/Simulation_experiments/50robots/Variant4_Temporary_system-wide_communication_failure/30s_failure"

#	#-- remove this one "exp_0_hw_06_formation_1_3d_14p/data_simu/data        8_Demos/Simulation_of_the_real_robot_demo_with_17robots_with_3drone"
)

#	"exp_0_hw_07_fault_tolerance/data_hw/data                         7_Fault_tolerance/Real_robots_experiments"

special_run_list=(
	"exp_0_hw_07_fault_tolerance/datas_substitute/1_non_brain_drone_failure  8_Demos/Real_robots_with_failure_and_substitution/Non_brain_aerial_robot_failure"
	"exp_0_hw_07_fault_tolerance/datas_substitute/2_brain_drone_failure      8_Demos/Real_robots_with_failure_and_substitution/Brain_aerial_robot_failure"
	"exp_0_hw_07_fault_tolerance/datas_substitute/3_pipuck_failure           8_Demos/Real_robots_with_failure_and_substitution/Ground_robot_failure"

	"exp_0_hw_07_fault_tolerance/data_hw/data/test_20220712_2_success_1     7_Fault_tolerance/Real_robots_experiments/run1_3robots_failed"
	"exp_0_hw_07_fault_tolerance/data_hw/data/test_20220712_3_success_2     7_Fault_tolerance/Real_robots_experiments/run2_2robots_failed"
	"exp_0_hw_07_fault_tolerance/data_hw/data/test_20220712_4_success_3     7_Fault_tolerance/Real_robots_experiments/run3_4robots_failed"
	"exp_0_hw_07_fault_tolerance/data_hw/data/test_20220712_6_success_5     7_Fault_tolerance/Real_robots_experiments/run4_3robots_failed"
	"exp_0_hw_07_fault_tolerance/data_hw/data/test_20220712_7_success_6     7_Fault_tolerance/Real_robots_experiments/run5_4robots_failed"
)

special_readme_list=(
	7_Fault_tolerance/Real_robots_experiments
	8_Demos/Real_robots_with_failure_and_substitution
)

copy_data_set_folder() {
	input_data_set_folder=$1
	output_data_set_folder=$2
	echo "---------------------------------------------"
	echo "copying from $input_data_set_folder"
	echo "          to $output_data_set_folder"

	if [ ! -d $raw_exps_dir/$input_data_set_folder ]; then
		echo "[Waring]: input data set doesn't exist, skipped: $public_dir/$output_data_set_folder"
		return
	fi

	mkdir -p $public_dir/$output_data_set_folder
	cd $raw_exps_dir/$input_data_set_folder
	i=0
	for run_folder in */; do
		echo -n "        $run_folder   "
		((i=i+1))
		output_run_folder=$public_dir/$output_data_set_folder/$run_folder
		if [[ $run_folder != run* ]]; then
			echo is not run*, renaming to run$i
			output_run_folder=$public_dir/$output_data_set_folder/run$i/
		fi

		mkdir -p $output_run_folder
		copy_run $raw_exps_dir/$input_data_set_folder/$run_folder $output_run_folder #$run_folder
	done
	echo "copy data set done"
}
#-----------------------------------------------------------------------------------

for i in ${!data_set_lists[@]}; do
	read -a exp_tuple <<< ${data_set_lists[$i]}
	copy_data_set_folder ${exp_tuple[0]} ${exp_tuple[1]}
done

for i in ${!special_run_list[@]}; do
	read -a exp_tuple <<< ${special_run_list[$i]}
	mkdir -p $public_dir/${exp_tuple[1]}/
	copy_run $raw_exps_dir/${exp_tuple[0]}/ $public_dir/${exp_tuple[1]}/
done

# copy README
cp @CMAKE_SOURCE_DIR@/scripts/public_data_readmes/Root_readme.txt $public_dir/README
for i in ${!data_set_lists[@]}; do
	read -a exp_tuple <<< ${data_set_lists[$i]}
	cp @CMAKE_SOURCE_DIR@/scripts/public_data_readmes/Data_set_readme.txt $public_dir/${exp_tuple[1]}/README
done

for i in ${!special_readme_list[@]}; do
	cp @CMAKE_SOURCE_DIR@/scripts/public_data_readmes/Data_set_readme.txt $public_dir/${special_readme_list[$i]}/README
done

cd $ORIGIN_DIR