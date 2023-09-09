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

dataFolder = "/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_3_simu_04_fault_tolerance_visual/data_simu_30s/data"
sample_run = "run1"

dataFolder1 = "/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_3_simu_04_fault_tolerance_visual/data_simu_0.5s/data"
dataFolder2 = "/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_3_simu_04_fault_tolerance_visual/data_simu_1s/data"
dataFolder3 = "/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_3_simu_04_fault_tolerance_visual/data_simu_30s/data"

#dataFolder = "/home/harry/code-mns2.0/SoNS2.0-SR/src/../../test_data/data3"
#dataFolder1 = "/home/harry/code-mns2.0/SoNS2.0-SR/src/../../test_data/data1"
#dataFolder2 = "/home/harry/code-mns2.0/SoNS2.0-SR/src/../../test_data/data2"
#dataFolder3 = "/home/harry/code-mns2.0/SoNS2.0-SR/src/../../test_data/data3"

option = {
	'dataFolder'             : dataFolder,
	'sample_run'             : sample_run,
	'SRFig_save'             : "mission7_visual_failure_exp_3_simu_04_fault_tolerance_visual_SRFig.pdf",
	'trackLog_save'          : "mission7_visual_failure_exp_3_simu_04_fault_tolerance_visual_trackLog.pdf",
	'SRFig_show'             : False,
	'trackLog_show'          : False,

	'main_ax_lim'            : [-0.5, 7.5],

	'split_right'            : True,
	'violin_ax_top_lim'      : [9.5, 10.5],
	'height_ratios'          : [1, 8],

	'failure_place_holder'   : 0,

	'triple_right'           : True,
	'triple_right_dataFolder1':  dataFolder1,
	'triple_right_dataFolder2':  dataFolder2,
	'triple_right_dataFolder3':  dataFolder3,
}
#------------------------------------------------
'''
	#'key_frame' :  [0, 250, 950] ,
	'key_frame' :  [0, 500] ,

	'overwrite_trackFig_log_foler' : 
		"/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_3_simu_04_fault_tolerance_visual/track_fig_logs/logs"
	,

	'legend_obstacle'  : True,

	'x_lim'     :  [-12, 12]    ,
	'y_lim'     :  [-12, 12]        ,
	'z_lim'     :  [-4.0,8.0]    ,
}
'''

drawSRFig(option)
#drawTrackLog(option)


