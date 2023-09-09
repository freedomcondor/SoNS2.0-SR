drawDataFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

drawSRFigFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/drawSRFig.py"
#execfile(drawSRFigFileName)
exec(compile(open(drawSRFigFileName, "rb").read(), drawSRFigFileName, 'exec'))

logGeneratorFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/logReader/logReplayer.py"
exec(compile(open(logGeneratorFileName, "rb").read(), logGeneratorFileName, 'exec'))

drawTrackLogFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/drawTrackLogs.py"
exec(compile(open(drawTrackLogFileName, "rb").read(), drawTrackLogFileName, 'exec'))

dataFolder= ""
dataFolder+="/media/harry/Expansion/Storage/SoNS2.0-data/"
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

dataFolder2 = "/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_10_formation_1_2d_6p_group_start/data_hw/data"

option = {
	'dataFolder'             : dataFolder,
	'sample_run'             : sample_run,
	'SRFig_save'             : "mission1_hw_exp_0_hw_01_formation_1_2d_10p_SRFig.pdf",
	'trackLog_save'          : "mission1_hw_exp_0_hw_01_formation_1_2d_10p_trackLog.pdf",
	'SRFig_show'             : False,
	'trackLog_show'          : False,

	'boxPlotValue_save'      : "mission1_hw_boxplot1_exp_0_hw_01_formation_1_2d_10p.dat",

	'main_ax_lim'            : [-0.2, 2],

	'split_right'            : True,
	#'violin_ax_top_lim'      : [5.75, 6],
	'violin_ax_top_lim'      : [2.3, 6.2],
	#'height_ratios'          : [1, 10],

#	'double_right'           : True,
	'double_right'           : False,
	'double_right_dataFolder': dataFolder2,
	'boxPlotValue_doubleRight_save'      : "mission1_hw_boxplot2_exp_0_hw_10_formation_1_2d_6p_group_start.dat",
#------------------------------------------------
	'brain_marker'      :    '/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/brain-icon-small.svg',
	'key_frame' :  [0] ,

	'key_frame_parent_index' :  [
		{}, # for key frame 0
		{
			'drone2'    :   'drone4'   ,
			'drone4'    :   'nil'      ,
			'pipuck1'   :   'drone4'  ,
			'pipuck2'   :   'drone2'  ,
			'pipuck4'   :   'drone2'  ,
			'pipuck5'   :   'drone2'  ,
			'pipuck6'   :   'drone4'  ,
			'pipuck7'   :   'drone4'   ,
			'pipuck8'   :   'drone4'   ,
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

dataFolder = "/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_01_formation_1_2d_10p/data_simu/data"

sample_run = "run1"

dataFolder2 = "/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_10_formation_1_2d_6p_group_start/data_simu/data"

option = {
	'dataFolder'             : dataFolder,
	'sample_run'             : sample_run,
	'SRFig_save'             : "mission1_simu_exp_0_hw_01_formation_1_2d_10p_SRFig.pdf",
	'SRFig_show'             : False,
	'boxPlotValue_save'      : "mission1_simu_boxplot1_exp_0_hw_01_formation_1_2d_10p.dat",

	'main_ax_lim'            : [-0.2, 3.2],

	'split_right'            : True,
	#'violin_ax_top_lim'      : [5.75, 6],
	'violin_ax_top_lim'      : [2.3, 6.2],
	#'height_ratios'          : [1, 10],

	'double_right'           : True,
	'double_right_dataFolder': dataFolder2,
	'boxPlotValue_doubleRight_save'      : "mission1_simu_boxplot2_exp_0_hw_10_formation_1_2d_6p_group_start.dat",
}

drawSRFig(option)
