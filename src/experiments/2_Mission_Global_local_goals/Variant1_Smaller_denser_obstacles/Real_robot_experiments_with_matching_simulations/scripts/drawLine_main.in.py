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

dataFolder= ""
dataFolder+="@CMAKE_SoNS_DATA_PATH@/"
dataFolder+="experiments/"
dataFolder+="2_Mission_Global_local_goals/"
dataFolder+="Variant1_Smaller_denser_obstacles/"
dataFolder+="Real_robot_experiments_with_matching_simulations/"
dataFolder+="data_hw/data"

#sample_run = "run1"
#sample_run = "run2"
#sample_run = "run3"
#sample_run = "run4"
sample_run = "run5"

#doubleRight
dataFolder2= ""
dataFolder2+="@CMAKE_SoNS_DATA_PATH@/"
dataFolder2+="experiments/"
dataFolder2+="2_Mission_Global_local_goals/"
dataFolder2+="Variant2_Larger_less_dense_obstacles/"
dataFolder2+="Real_robot_experiments_with_matching_simulations/"
dataFolder2+="data_hw/data"

option = {
	'dataFolder'             : dataFolder,
	'sample_run'             : sample_run,
	'SRFig_save'             : "Mission2_Obstacle_avoidance_Variant1_Smaller_denser_obstacles_Real_robot_Hardware-SRFig.pdf",
	'trackLog_save'          : "Mission2_Obstacle_avoidance_Variant1_Smaller_denser_obstacles_Real_robot_Hardware-trackLog.pdf",
	'SRFig_show'             : False,
	'trackLog_show'          : False,

	'main_ax_lim'            : [-0.1, 2],

	'split_right'            : False,
	'violin_ax_top_lim'      : [3.4, 4.1],
	'height_ratios'          : [1, 3],

	'double_right'           : True,
	'double_right_dataFolder': dataFolder2,

	'boxPlotValue_save'                  : "Mission2_Obstacle_avoidance_Variant1_Smaller_denser_obstacles_Real_robot_Hardware.dat",
	'boxPlotValue_doubleRight_save'      : "Mission2_Obstacle_avoidance_Variant2_Larger_less_dense_obstacles_Real_robot_hardware.dat",

#------------------------------------------------
	'brain_marker'      :    '@CMAKE_SOURCE_DIR@/scripts/brain-icon-small.svg',
	'key_frame' :  [0, 400] ,

	'key_frame_parent_index' :  [
		{}, # for key frame 0
		{
			'drone2'    :   'drone4'   ,
			'drone4'    :   'nil'      ,
			'pipuck2'   :   'drone4'  ,
			'pipuck4'   :   'drone4'  ,
			'pipuck5'   :   'drone2'  ,
			'pipuck7'   :   'drone2'   ,
			'pipuck8'   :   'drone4'   ,
			'pipuck9'   :   'drone4'  ,
		},
		{
			'drone2'    :   'drone4'   ,
			'drone4'    :   'nil'      ,
			'pipuck2'   :   'drone4'  ,
			'pipuck4'   :   'drone4'  ,
			'pipuck5'   :   'drone2'  ,
			'pipuck7'   :   'drone2'   ,
			'pipuck8'   :   'drone4'   ,
			'pipuck9'   :   'drone4'  ,
		},
	] ,

	'x_lim'     :  [-4, 4.5]           ,
	'y_lim'     :  [-4.25, 4.25]       ,
	'z_lim'     :  [-1.0, 7.5]         ,
}

drawSRFig(option)
drawTrackLog(option)