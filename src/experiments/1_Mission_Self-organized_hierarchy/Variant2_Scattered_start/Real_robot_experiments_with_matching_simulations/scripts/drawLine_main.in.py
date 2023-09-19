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

dataFolder ="@CMAKE_SoNS_DATA_PATH@/"
dataFolder+="experiments/"
dataFolder+="1_Mission_Self-organized_hierarchy/"
dataFolder+="Variant2_Scattered_start/"
dataFolder+="Real_robot_experiments_with_matching_simulations/"
dataFolder+="data_hw/data"

#sample_run = "run1"
#sample_run = "run2"
#sample_run = "run3"
sample_run = "run4"
#sample_run = "run5"

dataFolder2 ="@CMAKE_SoNS_DATA_PATH@/"
dataFolder2+="experiments/"
dataFolder2+="1_Mission_Self-organized_hierarchy/"
dataFolder2+="Variant1_Clustered_start/"
dataFolder2+="Real_robot_experiments_with_matching_simulations/"
dataFolder2+="data_hw/data"

option = {
	'dataFolder'             : dataFolder,
	'sample_run'             : sample_run,
	'SRFig_save'             : "Mission1_Self-organized_hirarchy_Variant2_Scattered_start.pdf",
	'trackLog_save'          : "Mission1_Self-organized_hirarchy_Variant2_Scattered_start-trackLog.pdf",
	'SRFig_show'             : False,
	'trackLog_show'          : False,

	'boxPlotValue_save'      : "Mission1_Self-organized_hirarchy_Variant2_Scattered_start.dat",

	'main_ax_lim'            : [-0.2, 1.5],

	'split_right'            : False,

	'double_right'           : True,
	'double_right_dataFolder': dataFolder2,
	'boxPlotValue_doubleRight_save'      : "Mission1_Self-organized_hirarchy_Variant1_clustered_start.dat",
#------------------------------------------------
	'brain_marker'      :    '@CMAKE_SOURCE_DIR@/scripts/brain-icon-small.svg',
	'key_frame' :  [0] ,

	'key_frame_parent_index' :  [
		{}, # for key frame 0
		{
			'drone2'    :   'drone4'  ,
			'drone4'    :   'nil'     ,
			'pipuck1'   :   'drone4'  ,
			'pipuck2'   :   'drone2'  ,
			'pipuck4'   :   'drone2'  ,
			'pipuck5'   :   'drone2'  ,
			'pipuck6'   :   'drone4'  ,
			'pipuck7'   :   'drone4'  ,
			'pipuck8'   :   'drone4'  ,
			'pipuck9'   :   'drone4'  ,
			'pipuck10'  :   'drone2'  ,
			'pipuck11'  :   'drone2'  ,
		},
	] ,

	'x_lim'     :  [-1.5, 3.5]    ,
	'y_lim'     :  [-2.5, 2.5]    ,
	'z_lim'     :  [-1.0, 3.0]    ,
}

drawSRFig(option)
drawTrackLog(option)
