CURRENT_DIR=`pwd`

EXPS_DIR="/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/"
COPY_PY="/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/csvgenerator/prepend_line.py"

echo $EXPS_DIR

# looping experiments
for EXP_DIR in "$EXPS_DIR"*/ ; do
	echo $EXP_DIR
	# looping data_hw/data and data_simu/data
	cd $EXP_DIR
	#for DATA_SET_NAME in data_hw data_simu data_simu*; do
	for DATA_SET_NAME in data_simu* data_hw*; do
		echo checking $DATA_SET_NAME
		# skipping data_hw and data_simu for the second round
		#if [ "$DATA_SET_NAME" == "data_hw" ] || [ "$DATA_SET_NAME" == "data_simu" ]; then 
		#	echo skipping $DATA_SET_NAME
		#	continue
		#fi

		if [ ! -d "$EXP_DIR"$DATA_SET_NAME ]; then
			echo doesn\'t exist: "$EXP_DIR"$DATA_SET_NAME
			continue
		fi
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
