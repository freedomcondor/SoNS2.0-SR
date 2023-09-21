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
dataFolderBase  = "@CMAKE_SoNS_DATA_PATH@" + cmake_relative_dir + "/"

dataFolder = dataFolderBase + "data_simu_30s/data"
sample_run = "run1"

dataFolder1 = dataFolderBase + "data_simu_0.5s/data"
dataFolder2 = dataFolderBase + "data_simu_1s/data"
dataFolder3 = dataFolderBase + "data_simu_30s/data"

option = {
	'dataFolder'             : dataFolder,
	'sample_run'             : sample_run,

	'SRFig_save'             : "Mission7_Fault_tolerance_Variant3_vision_failure_Large_scale_Simulation-SRFig.pdf",
	'trackLog_save'          : "Mission7_Fault_tolerance_Variant3_vision_failure_Large_scale_Simulation-trackLog.pdf",

	'SRFig_show'             : False,
	'trackLog_show'          : False,

	'main_ax_lim'            : [-0.5, 7.5],

	'split_right'            : False,
	'violin_ax_top_lim'      : [9.5, 10.5],
	'height_ratios'          : [1, 8],

	'failure_place_holder'   : 0,

	'triple_right'           : True,
	'triple_right_dataFolder1':  dataFolder1,
	'triple_right_dataFolder2':  dataFolder2,
	'triple_right_dataFolder3':  dataFolder3,

	'boxPlotValue_save'      : "Mission7_Fault_tolerance_Variant3_vision_failure_Large_scale_Simulation.dat",
}

drawSRFig(option)


