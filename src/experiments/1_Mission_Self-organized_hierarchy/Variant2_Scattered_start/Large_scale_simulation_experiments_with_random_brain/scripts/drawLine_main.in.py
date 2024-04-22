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

dataFolder2 ="@CMAKE_SoNS_DATA_PATH@/"
dataFolder2+="experiments/"
dataFolder2+="1_Mission_Self-organized_hierarchy/"
dataFolder2+="Variant1_Clustered_start/"
dataFolder2+="Large_scale_simulation_experiments/"
dataFolder2+="data_simu/data"

option = {
	'dataFolder'             : dataFolder,
	'sample_run'             : "run1",
	'SRFig_save'             : "Mission1_Self-organized_hirarchy_Variant2_Scattered_start_Large_scale_Simulation.pdf",
	'trackLog_save'          : "Mission1_Self-organized_hirarchy_Variant2_Scattered_start_Large_scale_Simulation-trackLog.pdf",
	'SRFig_show'             : False,
	'trackLog_show'          : False,

	'boxPlotValue_save'      : "Mission1_Self-organized_hirarchy_Variant2_Scattered_start_Large_scale_Simulation.dat",

	'main_ax_lim'            : [-0.2, 2.50],

	'split_right'            : False,
	'violin_ax_top_lim'      : [2.80, 5.6],

	'double_right'           : True,
	'double_right_dataFolder': dataFolder2,
	'boxPlotValue_doubleRight_save'      : "Mission1_Self-organized_hirarchy_Variant1_clustered_start_Large_scale_Simulation.dat",

#------------------------------------------------
	'brain_marker'      :    '@CMAKE_SOURCE_DIR@/scripts/brain-icon-small.svg',
	'key_frame' :  [0] ,

	'x_lim'     :  [-3, 5]    ,
	'y_lim'     :  [-4, 4]        ,
	'z_lim'     :  [-1.0, 7.0]    ,
}

drawSRFig(option)
drawTrackLog(option)