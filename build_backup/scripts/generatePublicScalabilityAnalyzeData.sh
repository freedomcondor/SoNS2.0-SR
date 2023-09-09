COPY_PY="/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/csvgenerator/prepend_line.py"
COPY_TIME_PY="/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/csvgenerator/prepend_time_line.py"

ORIGIN_DIR=`pwd`

raw_exps_dir="/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_2_simu_scalability_analyze"
#public_dir="/media/harry/Expansion/Storage/SoNS2.0-public-data"
public_dir="/media/harry/Expansion/Storage/SoNS2.0-data/../Scalability_in_SoNS_establishment_mission"

mkdir -p $public_dir

copy_run () {
	inputFolder=$1
	outputFolder=$2

	echo "copying from $inputFolder"
	echo "          to $outputFolder"

	mkdir -p $outputFolder

	#copy result_data.txt to error.csv
	mkdir -p $outputFolder/error_measurements
	cp $inputFolder/result_data.txt $outputFolder/error_measurements
	mv $outputFolder/error_measurements/result_data.txt $outputFolder/error_measurements/error.csv

	mkdir -p $outputFolder/experiment_data
	mkdir -p $outputFolder/communication_measurements
	mkdir -p $outputFolder/computation_time_measurements
	CURRENT_DIR=`pwd`
	# go into logs
	cd $inputFolder/logs
	#copy logs/*.log to experiment_data/*.csv
	for LOG_FILE in *.log ; do
		input_file=$inputFolder/logs/$LOG_FILE
		output_file=$outputFolder/experiment_data/${LOG_FILE%.*}.csv
		python3 $COPY_PY $input_file $output_file
	done
	#copy logs/*.comm_dat to communication_measurements/*.csv
	for LOG_FILE in *.comm_dat ; do
		input_file=$inputFolder/logs/$LOG_FILE
		output_file=$outputFolder/communication_measurements/${LOG_FILE%.*}.csv
		cp $input_file $output_file
	done
	#copy logs/*.time_dat to computation_time_measurements/*.csv
	for LOG_FILE in *.time_dat ; do
		input_file=$inputFolder/logs/$LOG_FILE
		output_file=$outputFolder/computation_time_measurements/${LOG_FILE%.*}.csv
		python3 $COPY_TIME_PY $input_file $output_file
	done
	cd $CURRENT_DIR
}

for data_set in $raw_exps_dir/data_simu*; do
	for runFolder in $data_set/*; do
#		echo $runFolder
		folderLastName=${runFolder##*/}

		# get run number and calculate robot number
		runNumber=`echo $folderLastName | grep -Eo '[0-9]+$'`
		droneNumber=$((($runNumber-1)/30+1))
		robotNumber=$(($droneNumber*5))
		targetFolderSet=${robotNumber}robots
		outputFolder=$public_dir/$targetFolderSet/$folderLastName

		copy_run $runFolder $outputFolder
	done
done

cd $ORIGIN_DIR
