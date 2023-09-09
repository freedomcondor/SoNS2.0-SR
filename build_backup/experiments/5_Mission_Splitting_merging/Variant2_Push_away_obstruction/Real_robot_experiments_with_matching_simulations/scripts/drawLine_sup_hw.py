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

dataFolder = "/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_09_1d_switch_rescue/data_hw"
savePDFNameBase = "mission5_search_rescue_exp0_09_hw_"
sampleList = [
	"test_20220804_1_success_2" ,
	"test_20220804_2_success_3" ,
	"test_20220804_3_success_4" ,
	"test_20220804_4_success_5" ,
	"test_20220804_5_success_6" ,
]

#	"test_20220803_1_success_1" ,

#----------------------------------
track_option_base = {
	'brain_marker'      :    '/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/brain-icon-small.svg',

	'dataFolder'        :    dataFolder,
#	'sample_run'        :    sample_run,

#	'trackLog_save'     : savePDFNameBase + sample_run + ".pdf",
	'trackLog_show'     : False,

	'x_lim'     :  [-2.0, 3.0]    ,
	'y_lim'     :  [-2.5, 2.5]    ,
	'z_lim'     :  [-1.0, 4.0]    ,

	'showRobotName'     : False,

	'SRFig_show'        : False,
	'no_violin'         : True,
	'main_ax_lim'       : [-0.3, 3.0],
}

#----------------------------------
key_frame_list = {}
key_frame_parent_index_list = {}
x_lim_list = {}
y_lim_list = {}
z_lim_list = {}

key_frame_example = [0, 600]

#-----------------------------------------------------------
key_frame_list["test_20220803_1_success_1"] = [0, 700]
key_frame_parent_index_list["test_20220803_1_success_1"] = [
	{}, # for key frame 0
	{
		'drone3'    :   'nil',
		'pipuck1'   :   'nil',
		'pipuck3'   :   'pipuck4',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'pipuck4',
	},
	{
		'drone3'    :   'nil',
		'pipuck1'   :   'drone3',
		'pipuck3'   :   'drone3',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'drone3',
	},
]

key_frame_parent_index_list["test_20220804_1_success_2"] = [
	{}, # for key frame 0
	{
		'drone3'    :   'nil',
		'pipuck1'   :   'nil',
		'pipuck3'   :   'pipuck5',
		'pipuck4'   :   'pipuck5',
		'pipuck5'   :   'drone3',
	},
	{
		'drone3'    :   'nil',
		'pipuck1'   :   'drone3',
		'pipuck3'   :   'drone3',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'drone3',
	},
]

key_frame_parent_index_list["test_20220804_2_success_3"] = [
	{}, # for key frame 0
	{
		'drone3'    :   'nil',
		'pipuck1'   :   'nil',
		'pipuck3'   :   'pipuck5',
		'pipuck4'   :   'pipuck5',
		'pipuck5'   :   'drone3',
	},
	{
		'drone3'    :   'nil',
		'pipuck1'   :   'drone3',
		'pipuck3'   :   'drone3',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'drone3',
	},
]

key_frame_parent_index_list["test_20220804_3_success_4"] = [
	{}, # for key frame 0
	{
		'drone3'    :   'nil',
		'pipuck1'   :   'nil',
		'pipuck3'   :   'pipuck4',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'pipuck4',
	},
	{
		'drone3'    :   'nil',
		'pipuck1'   :   'drone3',
		'pipuck3'   :   'drone3',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'drone3',
	},
]

key_frame_parent_index_list["test_20220804_4_success_5"] = [
	{}, # for key frame 0
	{
		'drone3'    :   'nil',
		'pipuck1'   :   'nil',
		'pipuck3'   :   'pipuck5',
		'pipuck4'   :   'pipuck5',
		'pipuck5'   :   'drone3',
	},
	{
		'drone3'    :   'nil',
		'pipuck1'   :   'drone3',
		'pipuck3'   :   'drone3',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'drone3',
	},
]

key_frame_list["test_20220804_5_success_6"] = [0, 520]
key_frame_parent_index_list["test_20220804_5_success_6"] = [
	{}, # for key frame 0
	{
		'drone3'    :   'nil',
		'pipuck1'   :   'nil',
		'pipuck3'   :   'pipuck4',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'pipuck4',
	},
	{
		'drone3'    :   'nil',
		'pipuck1'   :   'drone3',
		'pipuck3'   :   'drone3',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'drone3',
	},
]

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
