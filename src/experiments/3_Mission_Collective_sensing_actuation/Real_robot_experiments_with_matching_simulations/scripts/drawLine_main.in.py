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

#sample_run = "run1"
#sample_run = "run2"
sample_run = "run3"
#sample_run = "run4"
#sample_run = "run5"

option = {
	'dataFolder'             : dataFolder,
	'sample_run'             : sample_run,

	'SRFig_save'             : "Mission3_Collective_sensing_actuation_Real_robot_Hardware-SRFig.pdf",
	'trackLog_save'          : "Mission3_Collective_sensing_actuation_Real_robot_Hardware-trackLog.pdf",

	'SRFig_show'             : False,
	'trackLog_show'          : False,

	'main_ax_lim'            : [-0.5, 3.5],

#	'split_right'            : True,
#	'violin_ax_top_lim_from' : 5,
#	'violin_ax_top_lim_to'   : 5.5,

	'boxPlotValue_save'                  : "Mission3_Collective_sensing_actuation_Real_robot_Hardware.dat",

#------------------------------------------------
	'brain_marker'      :    '@CMAKE_SOURCE_DIR@/scripts/brain-icon-small.svg',

	'key_frame' :  [0, 400, 1000] ,

	'key_frame_parent_index' :  [
		{}, # for key frame 0
		{
			'drone2'    :   'drone4'   ,
			'drone4'    :   'nil'      ,
			'pipuck2'   :   'drone4'   ,
			'pipuck4'   :   'drone2'   ,
			'pipuck5'   :   'drone4'   ,
			'pipuck7'   :   'drone2'   ,
			'pipuck8'   :   'drone4'   ,
			'pipuck9'   :   'drone4'   ,
		},
		{
			'drone2'    :   'drone4'   ,
			'drone4'    :   'nil'      ,
			'pipuck2'   :   'pipuck5'  ,
			'pipuck4'   :   'drone4'   ,
			'pipuck5'   :   'drone4'   ,
			'pipuck7'   :   'pipuck8'  ,
			'pipuck8'   :   'pipuck2'  ,
			'pipuck9'   :   'pipuck7'  ,
		},
		{
			'drone2'    :   'drone4'   ,
			'drone4'    :   'nil'      ,
			'pipuck2'   :   'drone4'   ,
			'pipuck4'   :   'drone4'   ,
			'pipuck5'   :   'drone4'   ,
			'pipuck7'   :   'drone2'   ,
			'pipuck8'   :   'drone2'   ,
			'pipuck9'   :   'drone4'   ,
		},
	] ,

	'x_lim'     :  [-4, 4.5]           ,
	'y_lim'     :  [-4.25, 4.25]       ,
	'z_lim'     :  [-1.0, 7.5]         ,
}

drawSRFig(option)
drawTrackLog(option)
