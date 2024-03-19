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

#doubleRight
dataFolder2= ""
dataFolder2+="@CMAKE_SoNS_DATA_PATH@/"
dataFolder2+="experiments/"
dataFolder2+="2_Mission_Global_local_goals/"
dataFolder2+="Variant2_Larger_less_dense_obstacles/"
dataFolder2+="Large_scale_simulation_experiments/"
dataFolder2+="data_simu/data"

option = {
	'dataFolder'             : dataFolder,
	'sample_run'             : "run1",
	'SRFig_save'             : "Mission2_Obstacle_avoidance_Variant1_Smaller_denser_obstacles_Large_scale_Simulation-SRFig.pdf",
	'trackLog_save'          : "Mission2_Obstacle_avoidance_Variant1_Smaller_denser_obstacles_Large_scale_Simulation-trackLog.pdf",
	'SRFig_show'             : False,
	'trackLog_show'          : False,

	'main_ax_lim'            : [-0.2, 3],

	'split_right'            : False,
	'violin_ax_top_lim'      : [5.18, 5.21],
	'height_ratios'          : [1, 8],

	'double_right'           : True,
	'double_right_dataFolder': dataFolder2,

	'boxPlotValue_save'                  : "Mission2_Obstacle_avoidance_Variant1_Smaller_denser_obstacles_Large_scale_Simulation.dat",
	'boxPlotValue_doubleRight_save'      : "Mission2_Obstacle_avoidance_Variant2_Larger_less_dense_obstacles_Large_scale_Simulation.dat",

#------------------------------------------------
	'brain_marker'      :    '@CMAKE_SOURCE_DIR@/scripts/brain-icon-small.svg',
	'key_frame' :  [0, 800] ,

	'legend_obstacle'  : True,

	'x_lim'     :  [-4, 14]    ,
	'y_lim'     :  [-9, 9]        ,
	'z_lim'     :  [-8.0, 10.0]    ,
}

drawSRFig(option)
drawTrackLog(option)