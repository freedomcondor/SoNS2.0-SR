ORIGIN_DIR=`pwd`

raw_exps_dir="@CMAKE_MNS_DATA_PATH@/src/experiments"
public_dir="@CMAKE_PUB_DATA_PATH@"

# check public data exists or not
if [ ! -d "$public_dir" ]; then
	echo doesn\'t exist: $public_dir, creating
	mkdir $public_dir
fi

# list of experiments and their public names
lists=(
	"exp_0_hw_01_formation_1_2d_10p    mission1_hw_exp_formation_scatter"
#	"exp_0_hw_05_gate_switch           mission4_hw_exp_gate_switch"
	"exp_3_simu_01_fault_tolerance_66  mission5_hw_exp_fault_tolerance"
)

copy_run() {
	# all parameter folder ends with /
	input_run_folder=$1
	output_run_folder=$2
	#run_folder_name=$3
	#echo "        $run_folder_name"

	# copy csvs
	cp -r "$input_run_folder"csvs "$output_run_folder"experiment_data
	# copy results
	mkdir -p "$output_run_folder"error_measurements
	#cp -r "$input_run_folder"result* "$output_run_folder"analyze_and_results
	#cp -r "$input_run_folder"*.txt "$output_run_folder"analyze_and_results
	cp "$input_run_folder"result_data.txt "$output_run_folder"error_measurements/error.txt
	if [ -d "$input_run_folder"result_each_robot_error ]; then
		cp -r "$input_run_folder"result_each_robot_error "$output_run_folder"error_measurements/error_per_robot
	fi
	# copy video
	if [ -e "$input_run_folder"video_ceiling_fast.mp4 ]; then
		mkdir -p "$output_run_folder"videos
		cp "$input_run_folder"*.mp4 "$output_run_folder"videos
	fi

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

for i in ${!lists[@]}; do
	read -a exp_tuple <<< ${lists[$i]}
	copy_exp_folder ${exp_tuple[0]} ${exp_tuple[1]}

done

cd $ORIGIN_DIR