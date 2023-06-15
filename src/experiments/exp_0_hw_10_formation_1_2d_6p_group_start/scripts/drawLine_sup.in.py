drawDataFileName = "@CMAKE_SOURCE_DIR@/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

drawSRFigFileName = "@CMAKE_SOURCE_DIR@/scripts/drawSRFig_sup.py"
#execfile(drawSRFigFileName)
exec(compile(open(drawSRFigFileName, "rb").read(), drawSRFigFileName, 'exec'))

logGeneratorFileName = "@CMAKE_SOURCE_DIR@/scripts/logReader/logReplayer.py"
exec(compile(open(logGeneratorFileName, "rb").read(), logGeneratorFileName, 'exec'))

drawTrackLogFileName = "@CMAKE_SOURCE_DIR@/scripts/drawTrackLogs_sup.py"
exec(compile(open(drawTrackLogFileName, "rb").read(), drawTrackLogFileName, 'exec'))

dataFolder = "@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_10_formation_1_2d_6p_group_start/data_hw/data"
savePDFNameBase = "sup_test_exp10_"
sampleList = [
	"test_20220720_1_success_1",
	"test_20220720_2_success_2",
	"test_20220720_3_success_3",
	"test_20220720_4_success_4",
	"test_20220720_5_success_5",
]

#----------------------------------
track_option_base = {
	'brain_marker'      :    '@CMAKE_SOURCE_DIR@/scripts/brain-icon-small.svg',

	'dataFolder'        :    dataFolder,
#	'sample_run'        :    sample_run,

#	'trackLog_save'     : savePDFNameBase + sample_run + ".pdf",
	'trackLog_show'     : False,

	'x_lim'             :    [-2.5, 2.5],
	'y_lim'             :    [-2.5, 2.5],
	'z_lim'             :    [-1.0, 4.0],

	'showRobotName'     : False,
}

#----------------------------------
key_frame_list = {}
key_frame_parent_index_list = {}
x_lim_list = {}
y_lim_list = {}
z_lim_list = {}

key_frame_example = [0]

key_frame_parent_index_list["test_20220720_1_success_1"] = [
	{}, # key frame 0
	{
		'drone2'    :   'drone3'   ,
		'drone3'    :   'nil'      ,
		'pipuck1'   :   'drone3'  ,
		'pipuck2'   :   'drone3'  ,
		'pipuck3'   :   'drone3'  ,
		'pipuck4'   :   'drone2'   ,
		'pipuck5'   :   'drone3'  ,
		'pipuck6'   :   'drone2'  ,
	},
]

key_frame_parent_index_list["test_20220720_2_success_2"] = [
	{}, # key frame 0
	{
		'drone2'    :   'drone3'   ,
		'drone3'    :   'nil'      ,
		'pipuck1'   :   'drone3'  ,
		'pipuck2'   :   'drone3'  ,
		'pipuck3'   :   'drone3'  ,
		'pipuck4'   :   'drone2'   ,
		'pipuck5'   :   'drone3'  ,
		'pipuck6'   :   'drone2'  ,
	},
]

key_frame_parent_index_list["test_20220720_3_success_3"] = [
	{}, # key frame 0
	{
		'drone2'    :   'drone3'   ,
		'drone3'    :   'nil'      ,
		'pipuck1'   :   'drone3'  ,
		'pipuck2'   :   'drone2'  ,
		'pipuck3'   :   'drone3'  ,
		'pipuck4'   :   'drone2'   ,
		'pipuck5'   :   'drone3'  ,
		'pipuck6'   :   'drone3'  ,
	},
]

key_frame_parent_index_list["test_20220720_4_success_4"] = [
	{}, # key frame 0
	{
		'drone2'    :   'drone3'   ,
		'drone3'    :   'nil'      ,
		'pipuck1'   :   'drone3'  ,
		'pipuck2'   :   'drone2'  ,
		'pipuck3'   :   'drone3'  ,
		'pipuck4'   :   'drone3'   ,
		'pipuck5'   :   'drone2'  ,
		'pipuck6'   :   'drone3'  ,
	},
]

key_frame_parent_index_list["test_20220720_5_success_5"] = [
	{}, # key frame 0
	{
		'drone2'    :   'drone3'   ,
		'drone3'    :   'nil'      ,
		'pipuck1'   :   'drone3'  ,
		'pipuck2'   :   'drone2'  ,
		'pipuck3'   :   'drone3'  ,
		'pipuck4'   :   'drone3'   ,
		'pipuck5'   :   'drone2'  ,
		'pipuck6'   :   'drone3'  ,
	},
]

#-----------------------------------------------------------
for sample_run in sampleList :
	track_option = track_option_base.copy()
	track_option['sample_run'] = sample_run
	track_option['trackLog_save'] = savePDFNameBase + sample_run + ".pdf"
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
