drawDataFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

drawSRFigFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/drawSRFig_sup.py"
#execfile(drawSRFigFileName)
exec(compile(open(drawSRFigFileName, "rb").read(), drawSRFigFileName, 'exec'))

logGeneratorFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/logReader/logReplayer.py"
exec(compile(open(logGeneratorFileName, "rb").read(), logGeneratorFileName, 'exec'))

drawTrackLogFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/drawTrackLogs_sup.py"
exec(compile(open(drawTrackLogFileName, "rb").read(), drawTrackLogFileName, 'exec'))

#dataFolder = "/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_2_simu_scalability_analyze/data_simu/data"
dataFolder = "/media/harry/Expansion/Storage/SoNS2.0-data/../scalability_analyze_data/data_simu_1-750"
savePDFNameBase = "mission6_scalability_formation_analyze_"
sampleList = [
#	"run150",  # 5
#	"run300",  # 10
#	"run450",  # 15
#	"run600",  # 20
#	"run750",  # 25
	"run210",  # 7
	"run390",  # 13
	"run570",  # 19
	"run750",  # 25
]

#----------------------------------
track_option_base = {
	'brain_marker'      :    '/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/brain-icon-small.svg',

	'dataFolder'        :    dataFolder,
#	'sample_run'        :    sample_run,

#	'trackLog_save'     : savePDFNameBase + sample_run + ".pdf",
	'trackLog_show'     : False,

	'x_lim'             :    [-8, 8],
	'y_lim'             :    [-8, 8],
	'z_lim'             :    [-1.0, 7.0],

	'showRobotName'     : False,

	'colored_key_frame' : True,

	'SRFig_show'        : False,
	'no_violin'         : True,
	'main_ax_lim'       : [-0.5, 6],
}

#----------------------------------
key_frame_list = {}
key_frame_parent_index_list = {}
x_lim_list = {}
y_lim_list = {}
z_lim_list = {}

key_frame_example = [0]

#-----------------------------------------------------------
for sample_run in sampleList :
	track_option = track_option_base.copy()
	track_option['sample_run'] = sample_run
	track_option['trackLog_save'] = savePDFNameBase + sample_run + "_TrackLog.pdf"
	if sample_run in key_frame_list:
		track_option['key_frame'] = key_frame_list[sample_run]
	else :
		track_option['key_frame'] = key_frame_example
	if sample_run in key_frame_parent_index_list :
		track_option['key_frame_parent_index'] = key_frame_parent_index_list[sample_run]

	if sample_run in x_lim_list :
		track_option['x_lim'] = x_lim_list[sample_run]
	if sample_run in y_lim_list :
		track_option['y_lim'] = y_lim_list[sample_run]
	if sample_run in z_lim_list :
		track_option['z_lim'] = z_lim_list[sample_run]

	drawTrackLog(track_option)

	track_option['SRFig_save'] = savePDFNameBase + sample_run + "_ErrorLog.pdf"
	drawSRFig(track_option)