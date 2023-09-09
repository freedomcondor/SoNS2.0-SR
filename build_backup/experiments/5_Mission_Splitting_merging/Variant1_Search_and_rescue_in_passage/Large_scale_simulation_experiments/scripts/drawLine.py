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
	'dataFolder' : "/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_1_simu_08_split/data_simu/data",
	'sample_run'             : "run1",
	'SRFig_save'             : "exp_1_simu_08_split_SRFig.pdf",
	'trackLog_save'          : "exp_1_simu_08_split_trackLog.pdf",
	'SRFig_show'             : False,
	'trackLog_show'          : False,

	'main_ax_lim'            : [-0.2, 2.00],

	'split_right'            : True,
	'violin_ax_top_lim'      : [4.2, 4.4],

#------------------------------------------------
	'brain_marker'      :    '/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/brain-icon-small.svg',
	'key_frame' :  [0] ,
#	'overwrite_trackFig_log_foler' : 
#		"/home/harry/code-mns2.0/SoNS2.0-SR/src/../../SoNS2.0-data/src/experiments/exp_1_simu_08_split/data_simu/track_fig_logs"
#	,

	'x_lim'     :  [-4, 6]    ,
	'y_lim'     :  [-5, 5]        ,
	'z_lim'     :  [-1.0, 9.0]    ,
}

drawSRFig(option)
drawTrackLog(option)
