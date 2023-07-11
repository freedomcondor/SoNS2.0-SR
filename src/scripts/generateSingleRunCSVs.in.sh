CURRENT_DIR=`pwd`

COPY_PY="@CMAKE_SOURCE_DIR@/scripts/csvgenerator/prepend_line.py"

RUN_DIR=$1
echo RUN_DIR = $RUN_DIR
# RUN_DIR has to end with /

mkdir csvs
cd $RUN_DIR
for LOG_FILE in * ; do
	input_file=$LOG_FILE
	output_file=../csvs/${LOG_FILE%.*}.csv
	echo $input_file
	echo $output_file
	python3 $COPY_PY $input_file $output_file
done

cd $CURRENT_DIR