CURRENT_DIR=`pwd`

EXPS_DIR="@CMAKE_MNS_DATA_PATH@/src/experiments/"
COPY_PY="@CMAKE_SOURCE_DIR@/scripts/csvgenerator/prepend_line.py"

echo $EXPS_DIR

# looping experiments
for EXP_DIR in "$EXPS_DIR"*/ ; do
	echo $EXP_DIR
	# looping data_hw/data and data_simu/data
	for DATA_SET_NAME in data_hw data_simu ; do
		# check data_hw/data or data_hw
		if [ -d "$EXP_DIR"$DATA_SET_NAME/data ]; then
			DATA_SET_NAME=$DATA_SET_NAME/data
		fi
		DATA_SET="$EXP_DIR"$DATA_SET_NAME
		echo "    "$DATA_SET
		# looping runs
		for RUN_DIR in $DATA_SET/*/ ; do
			echo "        "$RUN_DIR
			mkdir "$RUN_DIR"csvs
			cd "$RUN_DIR"logs
			for LOG_FILE in * ; do
				input_file="$RUN_DIR"logs/$LOG_FILE
				output_file="$RUN_DIR"csvs/${LOG_FILE%.*}.csv
				python3 $COPY_PY $input_file $output_file
			done
		done
	done
done

cd $CURRENT_DIR