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

dataFolder = "/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_07_fault_tolerance/data_hw/data"
#sample_run = "test_20220712_2_success_1"
#sample_run = "test_20220712_3_success_2"
#sample_run = "test_20220712_4_success_3"
#sample_run = "test_20220712_5_success_4"
#sample_run = "test_20220712_6_success_5"
sample_run = "test_20220712_7_success_6"

option = {
	'dataFolder'             : dataFolder,
	'sample_run'             : sample_run,
	'SRFig_save'             : "mission6_hw_exp_0_hw_07_fault_tolerance_SRFig.pdf",
	'trackLog_save'          : "mission6_hw_exp_0_hw_07_fault_tolerance_trackLog.pdf",
	'SRFig_show'             : False,
	'trackLog_show'          : False,
	'boxPlotValue_save'      : "mission6_hw_boxplot_exp_0_hw_07_fault_tolerance.dat",

	'main_ax_lim'            : [-0.5, 3.5],

#	'split_right'            : True,
#	'violin_ax_top_lim_from' : 5,
#	'violin_ax_top_lim_to'   : 5.5,

	'failure_place_holder'   : 0,

#------------------------------------------------
	'brain_marker'      :    '/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/brain-icon-small.svg',

	'key_frame' :  [0, 250, 950] ,

	'key_frame_parent_index' :  [
		{}, # for key frame 0
		{
			'drone2'    :   'nil'   ,
			'drone3'    :   'drone2'      ,
			'pipuck1'   :   'drone2'   ,
			'pipuck2'   :   'drone3'   ,
			'pipuck3'   :   'drone2'   ,
			'pipuck4'   :   'drone2'   ,
			'pipuck5'   :   'drone3'   ,
			'pipuck6'   :   'drone2'   ,
		},
		{
			'drone3'    :   'nil'      ,
			'pipuck3'   :   'drone3'   ,
			'pipuck1'   :   'pipuck3'   ,
		},
		{
			'drone3'    :   'nil'      ,
			'pipuck1'   :   'drone3'   ,
			'pipuck3'   :   'drone3'   ,
		},
	] ,

	'x_lim'     :  [-3.5, 4.5]           ,
	'y_lim'     :  [-4, 4]       ,
	'z_lim'     :  [-1.0, 7.0]         ,
}

drawSRFig(option)
drawTrackLog(option)

dataFolder = "/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_07_fault_tolerance/data_simu/data"
sample_run = "run1"

option = {
	'dataFolder'             : dataFolder,
	'sample_run'             : sample_run,
	'SRFig_save'             : "mission6_simu_exp_0_simu_07_fault_tolerance_SRFig.pdf",
	'SRFig_show'             : False,
	'trackLog_show'          : False,

	'main_ax_lim'            : [-0.5, 3.5],

#	'split_right'            : True,
#	'violin_ax_top_lim_from' : 5,
#	'violin_ax_top_lim_to'   : 5.5,

	'failure_place_holder'   : 0,
	'boxPlotValue_save'      : "mission6_simu_boxplot_exp_0_hw_07_fault_tolerance.dat",
}

drawSRFig(option)

