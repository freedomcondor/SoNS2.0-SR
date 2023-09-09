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

option = {
	'dataFolder' : "/home/harry/code-mns2.0/SoNS2.0-SR/src/../../SoNS2.0-data/src/experiments/exp_1_simu_03_obstacle_avoidance_large_10d/data_simu/data",
	'sample_run'             : "run1",
	'SRFig_save'             : "exp_1_simu_03_obstacle_avoidance_large_10d_SRFig.pdf",
	'trackLog_save'          : "exp_1_simu_03_obstacle_avoidance_large_10d_trackLog.pdf",
	'SRFig_show'             : False,
	'trackLog_show'          : False,

	'main_ax_lim'            : [-0.2, 3],

	'split_right'            : True,
	'violin_ax_top_lim'      : [5.06, 5.4],

#------------------------------------------------
	'brain_marker'      :    '/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/brain-icon-small.svg',
	'key_frame' :  [0, 800] ,
	'overwrite_trackFig_log_foler' : 
		"/home/harry/code-mns2.0/SoNS2.0-SR/src/../../SoNS2.0-data/src/experiments/exp_1_simu_03_obstacle_avoidance_large_10d/data_simu/track_fig_logs"
	,

	'legend_obstacle'  : True,

	'x_lim'     :  [-4, 14]    ,
	'y_lim'     :  [-9, 9]        ,
	'z_lim'     :  [-8.0, 10.0]    ,
}

drawSRFig(option)
drawTrackLog(option)