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
dataFolder += "data_simu/data"

option = {
	'dataFolder'             : dataFolder,
	'sample_run'             : "run1",

	'SRFig_save'             : "Mission3_Collective_sensing_actuation_Large_scale_Simulation-SRFig.pdf",
	'trackLog_save'          : "Mission3_Collective_sensing_actuation_Large_scale_Simulation-trackLog.pdf",

	'SRFig_show'             : False,
	'trackLog_show'          : False,

	'main_ax_lim'            : [-0.5, 7.5],

	'split_right'            : False,
	'violin_ax_top_lim'      : [9.5, 10],

	'cutTo'                  : 3500,

	'boxPlotValue_save'                  : "Mission3_Collective_sensing_actuation_Large_scale_Simulation.dat",

#------------------------------------------------
	'brain_marker'      :    '@CMAKE_SOURCE_DIR@/scripts/brain-icon-small.svg',
	#'key_frame' :  [0, 300, 2000] ,  # option 1
	'key_frame' :  [0, 500] ,

	'legend_obstacle'  : True,

	'x_lim'     :  [-12, 12]    ,
	'y_lim'     :  [-12, 12]        ,
	'z_lim'     :  [-4.0,8.0]    ,
}

drawSRFig(option)
drawTrackLog(option)
