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
	"exp_0_hw_05_gate_switch           mission4_hw_exp_gate_switch"
)

copy_run() {
	# all parameter folder ends with /
	input_run_folder=$1
	output_run_folder=$2
	run_folder_name=$3
	echo "        $run_folder_name"

	# copy csvs
	cp -r "$input_run_folder"csvs $output_run_folder
	# copy results
	mkdir -p "$output_run_folder"analyze_and_results
	cp -r "$input_run_folder"result* "$output_run_folder"analyze_and_results
	cp -r "$input_run_folder"*.txt "$output_run_folder"analyze_and_results
	# copy video
	if [ -f "$input_run_folder"*.mp4 ]; then
		mkdir -p "$output_run_folder"videos
		cp "$input_run_folder"*.mp4 "$output_run_folder"videos
	fi

	# copy code
	if [ -d "$input_run_folder"hw ]; then
		cp -r "$input_run_folder"hw "$output_run_folder"code_hw
	fi
	if [ -e "$input_run_folder"vns.argos ]; then
		mkdir -p "$output_run_folder"code_simu
		cp "$input_run_folder"vns.argos "$output_run_folder"code_simu
		if [ -d "$input_run_folder"../../code_and_output/simu ]; then
			cp -r "$input_run_folder"../../code_and_output/simu "$output_run_folder"code_simu
		fi
	fi
}

copy_exp_folder() {
	input_folder=$1
	output_folder=$2
	echo copying from $input_folder to $output_folder
	mkdir -p $public_dir/$output_folder
	cd $raw_exps_dir/$input_folder
	for data_set_name in data_simu* data_hw*; do
		if [ ! -d $raw_exps_dir/$input_folder/$data_set_name ]; then
			continue
		fi
		echo "    copying $data_set_name"

		output_data_set_name=$data_set_name
		# exp_0_hw_09 hw don't have data
		if [ -d $raw_exps_dir/$input_folder/$data_set_name ]; then
			data_set_name=$data_set_name/data
		fi

		mkdir -p $public_dir/$output_folder/$output_data_set_name
		cd $raw_exps_dir/$input_folder/$data_set_name
		for run_folder in */; do
			mkdir -p $public_dir/$output_folder/$output_data_set_name/$run_folder
			copy_run $raw_exps_dir/$input_folder/$data_set_name/$run_folder $public_dir/$output_folder/$output_data_set_name/$run_folder $run_folder
		done
	done
}

for i in ${!lists[@]}; do
	read -a exp_tuple <<< ${lists[$i]}
	copy_exp_folder ${exp_tuple[0]} ${exp_tuple[1]}

done

cd $ORIGIN_DIR