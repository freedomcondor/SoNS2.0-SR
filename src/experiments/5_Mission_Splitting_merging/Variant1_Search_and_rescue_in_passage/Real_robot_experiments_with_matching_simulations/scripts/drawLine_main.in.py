drawDataFileName = "@CMAKE_SOURCE_DIR@/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

drawSRFigFileName = "@CMAKE_SOURCE_DIR@/scripts/drawSRFig.py"
#execfile(drawSRFigFileName)
exec(compile(open(drawSRFigFileName, "rb").read(), drawSRFigFileName, 'exec'))

logGeneratorFileName = "@CMAKE_SOURCE_DIR@/scripts/logReader/logReplayer.py"
exec(compile(open(logGeneratorFileName, "rb").read(), logGeneratorFileName, 'exec'))

drawTrackLogFileName = "@CMAKE_SOURCE_DIR@/scripts/drawTrackLogs.py"
exec(compile(open(drawTrackLogFileName, "rb").read(), drawTrackLogFileName, 'exec'))

cmake_source_dir         = "@CMAKE_SOURCE_DIR@"
cmake_current_source_dir = "@CMAKE_CURRENT_SOURCE_DIR@"
cmake_relative_dir       = cmake_current_source_dir.replace(cmake_source_dir, "").replace("/scripts", "")
#cmake_relative_dir starts with / and end with no /
dataFolder  = "@CMAKE_SoNS_DATA_PATH@" + cmake_relative_dir + "/"
dataFolder += "data_hw/data"

dataFolder2 = "@CMAKE_SoNS_DATA_PATH@/src/experiments/exp_0_hw_09_1d_switch_rescue/data_hw"

#doubleRight
dataFolder2= ""
dataFolder2+="@CMAKE_SoNS_DATA_PATH@/"
dataFolder2+="experiments/"
dataFolder2+="5_Mission_Splitting_merging/"
dataFolder2+="Variant2_Push_away_obstruction/"
dataFolder2+="Real_robot_experiments_with_matching_simulations/"
dataFolder2+="data_hw/data"

sample_run = "run1"
#sample_run = "run2"
#sample_run = "run3"
#sample_run = "run4"
#sample_run = "run5"

option = {
	'dataFolder'             : dataFolder,
	'sample_run'             : sample_run,

	'SRFig_save'             : "Mission5_Splitting_merging_Variant1_Search_and_rescue_Real_robot_Hardware-SRFig.pdf",
	'trackLog_save'          : "Mission5_Splitting_merging_Variant1_Search_and_rescue_Real_robot_Hardware-trackLog.pdf",

	'SRFig_show'             : False,
	'trackLog_show'          : False,

	'main_ax_lim'            : [-0.5, 6.5],

	#'split_right'            : True,
	#'violin_ax_top_lim'      : [2.3, 6.2],
	#'height_ratios'          : [1, 10],

	'double_right'           : True,
	'double_right_dataFolder': dataFolder2,

	'boxPlotValue_save'                  : "Mission5_Splitting_merging_Variant1_Search_and_rescue_Real_robot_Hardware.dat",
	'boxPlotValue_doubleRight_save'      : "Mission5_Splitting_merging_Variant2_Push_away_obstruction_Real_robot_Hardware.dat",
#------------------------------------------------
	'brain_marker'      :    '@CMAKE_SOURCE_DIR@/scripts/brain-icon-small.svg',
	'key_frame' :  [0] ,

	'key_frame_parent_index' :  [
		{}, # for key frame 0
		{
			'drone2'    :   'drone3'   ,
			'drone3'    :   'nil'      ,
			'pipuck1'   :   'drone3'  ,
			'pipuck2'   :   'drone2'  ,
			'pipuck3'   :   'pipuck6'  ,
			'pipuck4'   :   'drone2'  ,
			'pipuck5'   :   'pipuck6'  ,
			'pipuck6'   :   'drone3'  ,
		},
	] ,

	'x_lim'     :  [-3.5, 4.5]    ,
	'y_lim'     :  [-4, 4]    ,
	'z_lim'     :  [-1.0, 7.0]    ,
}


drawSRFig(option)
drawTrackLog(option)

dataFolder = "@CMAKE_SoNS_DATA_PATH@/src/experiments/exp_0_hw_08_split/data_simu/data"
dataFolder2 = "@CMAKE_SoNS_DATA_PATH@/src/experiments/exp_0_hw_09_1d_switch_rescue/data_simu/data"
sample_run = "run1"
