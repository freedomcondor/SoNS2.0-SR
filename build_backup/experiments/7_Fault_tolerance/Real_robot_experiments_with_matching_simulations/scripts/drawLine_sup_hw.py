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

dataFolder = "/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_07_fault_tolerance/data_hw/data"
savePDFNameBase = "mission7_fault_tolerance_exp07_hw_"
sampleList = [
	"test_20220712_2_success_1",
	"test_20220712_3_success_2",
	"test_20220712_4_success_3",
	"test_20220712_6_success_5",
	"test_20220712_7_success_6",
]

#	"test_20220712_5_success_4",

#----------------------------------
track_option_base = {
	'brain_marker'      :    '/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/brain-icon-small.svg',

	'dataFolder'        :    dataFolder,
#	'sample_run'        :    sample_run,

#	'trackLog_save'     : savePDFNameBase + sample_run + ".pdf",
	'trackLog_show'     : False,

	'x_lim'     :  [-3.5, 4.5]           ,
	'y_lim'     :  [-4, 4]       ,
	'z_lim'     :  [-1.0, 7.0]         ,

	'showRobotName'     : False,

	'SRFig_show'        : False,
	'no_violin'         : True,
	'main_ax_lim'       : [-0.5, 3.5],
}

#----------------------------------
key_frame_list = {}
key_frame_parent_index_list = {}
x_lim_list = {}
y_lim_list = {}
z_lim_list = {}

#key_frame_example = [0, 250, 950]
key_frame_example = [0, 250, 1000]

#-----------------------------------------------------------
key_frame_parent_index_list["test_20220712_2_success_1"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'nil',
		'drone3'    :   'drone2',
		'pipuck1'   :   'drone2',
		'pipuck2'   :   'drone3',
		'pipuck3'   :   'drone2',
		'pipuck4'   :   'drone2',
		'pipuck5'   :   'drone2',
		'pipuck6'   :   'drone3',
	},
	{
#		'drone2'    :   'nil',
		'drone3'    :   'nil',
		'pipuck1'   :   'nil',
		'pipuck2'   :   'nil',
		'pipuck3'   :   'drone3',
		'pipuck4'   :   'pipuck3',
		'pipuck5'   :   'pipuck4',
		'pipuck6'   :   'drone3',
	},
	{
		'drone2'    :   'nil',
		'drone3'    :   'nil',
		'pipuck1'   :   'nil',
		'pipuck2'   :   'nil',
		'pipuck3'   :   'drone3',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'nil',
		'pipuck6'   :   'drone3',
	},
]

key_frame_list["test_20220712_3_success_2"] =  [0, 250, 1300]
key_frame_parent_index_list["test_20220712_3_success_2"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'nil',
		'drone3'    :   'drone2',
		'pipuck1'   :   'drone2',
		'pipuck2'   :   'drone3',
		'pipuck3'   :   'drone2',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'drone2',
		'pipuck6'   :   'drone2',
	},
	{
		'drone2'    :   'nil',
		'drone3'    :   'drone2',
#		'pipuck1'   :   'nil',
		'pipuck2'   :   'pipuck5',
		'pipuck3'   :   'drone2',
		'pipuck4'   :   'drone2',
		'pipuck5'   :   'pipuck3',
#		'pipuck6'   :   'drone3',
	},
	{
		'drone2'    :   'nil',
		'drone3'    :   'drone2',
		'pipuck1'   :   'nil',
		'pipuck2'   :   'drone2',
		'pipuck3'   :   'drone2',
		'pipuck4'   :   'drone2',
		'pipuck5'   :   'drone2',
		'pipuck6'   :   'nil',
	},
]

key_frame_list["test_20220712_4_success_3"] =  [0, 250, 1000]
key_frame_parent_index_list["test_20220712_4_success_3"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'nil',
		'drone3'    :   'drone2',
		'pipuck1'   :   'drone2',
		'pipuck2'   :   'drone3',
		'pipuck3'   :   'drone2',
		'pipuck4'   :   'drone2',
		'pipuck5'   :   'drone2',
		'pipuck6'   :   'drone3',
	},
	{},
	{},
]

key_frame_list["test_20220712_5_success_4"] =  [0, 250, 1100]
key_frame_parent_index_list["test_20220712_5_success_4"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'nil',
		'drone3'    :   'drone2',
		'pipuck1'   :   'drone2',
		'pipuck2'   :   'drone3',
		'pipuck3'   :   'drone2',
		'pipuck4'   :   'drone2',
		'pipuck5'   :   'drone2',
		'pipuck6'   :   'drone3',
	},
	{
		'drone2'    :   'nil',
		'drone3'    :   'drone2',
#		'pipuck1'   :   'nil',
		'pipuck2'   :   'drone2',
		'pipuck3'   :   'pipuck5',
		'pipuck4'   :   'drone2',
		'pipuck5'   :   'pipuck6',
		'pipuck6'   :   'pipuck4',
	},
	{
		'drone2'    :   'nil',
		'drone3'    :   'drone2',
#		'pipuck1'   :   'nil',
		'pipuck2'   :   'drone2',
		'pipuck3'   :   'drone2',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'drone2',
		'pipuck6'   :   'drone2',
	},
]

key_frame_parent_index_list["test_20220712_6_success_5"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'nil',
		'drone3'    :   'drone2',
		'pipuck1'   :   'drone2',
		'pipuck2'   :   'drone2',
		'pipuck3'   :   'drone3',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'drone2',
		'pipuck6'   :   'drone2',
	},
	{
		'drone2'    :   'nil',
#		'drone3'    :   'drone2',
		'pipuck1'   :   'pipuck6',
#		'pipuck2'   :   'drone2',
		'pipuck3'   :   'drone2',
#		'pipuck4'   :   'drone2',
#		'pipuck5'   :   'pipuck6',
		'pipuck6'   :   'drone2',
	},
	{
		'drone2'    :   'nil',
#		'drone3'    :   'drone2',
		'pipuck1'   :   'drone2',
#		'pipuck2'   :   'drone2',
		'pipuck3'   :   'drone2',
#		'pipuck4'   :   'drone3',
#		'pipuck5'   :   'drone2',
		'pipuck6'   :   'drone2',
	},
]

key_frame_parent_index_list["test_20220712_7_success_6"] = [
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
