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

dataFolder = "@CMAKE_SoNS_DATA_PATH@/src/experiments/exp_0_hw_01_formation_1_2d_10p/data_hw/data"
savePDFNameBase = "mission1_scattered_positions_exp0_01_hw_"
sampleList = [
	"test_20220621_6_success_1",
	"test_20220621_7_success_2",
	"test_20220621_8_success_3",
	"test_20220621_9_success_4",
	"test_20220621_10_success_5",
]

#----------------------------------
track_option_base = {
	'brain_marker'      :    '@CMAKE_SOURCE_DIR@/scripts/brain-icon-small.svg',

	'dataFolder'        :    dataFolder,
#	'sample_run'        :    sample_run,

#	'trackLog_save'     : savePDFNameBase + sample_run + ".pdf",
	'trackLog_show'     : False,

	'x_lim'             :    [-1.5, 3.5],
	'y_lim'             :    [-2.5, 2.5],
	'z_lim'             :    [-1.0, 3.0],

	'showRobotName'     : False,

	'SRFig_show'        : False,
	'no_violin'         : True,
	'main_ax_lim'            : [-0.2, 3],
}

#----------------------------------
key_frame_list = {}
key_frame_parent_index_list = {}
x_lim_list = {}
y_lim_list = {}
z_lim_list = {}

key_frame_example = [0]
parent_index_example = [
	{}, # for key frame 0
	{
		'drone2'    :   'nil'   ,
		'drone4'    :   'drone2'      ,
		'pipuck1'   :   'drone4'  ,
		'pipuck2'   :   'pipuck1'  ,
		'pipuck4'   :   'pipuck2'  ,
		'pipuck5'   :   'pipuck4'  ,
		'pipuck6'   :   'pipuck5'  ,
		'pipuck7'   :   'pipuck6'   ,
		'pipuck8'   :   'pipuck7'   ,
		'pipuck9'   :   'pipuck8'  ,
		'pipuck10'  :   'pipuck9'  ,
		'pipuck11'  :   'pipuck10'  ,
	},
]

#-----------------------------------------------------------
key_frame_list["test_20220621_6_success_1"] = key_frame_example
key_frame_parent_index_list["test_20220621_6_success_1"] = [
	{}, # key frame 0
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck1'   :   'drone4'  ,
		'pipuck2'   :   'drone2'  ,
		'pipuck4'   :   'drone4'  ,
		'pipuck5'   :   'drone2'  ,
		'pipuck6'   :   'drone2'  ,
		'pipuck7'   :   'drone2'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone4'  ,
		'pipuck10'  :   'drone2'  ,
		'pipuck11'  :   'drone4'  ,
	},
]

key_frame_list["test_20220621_7_success_2"] = key_frame_example
key_frame_parent_index_list["test_20220621_7_success_2"] = [
	{}, # key frame 0
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck1'   :   'drone4'  ,
		'pipuck2'   :   'drone2'  ,
		'pipuck4'   :   'drone4'  ,
		'pipuck5'   :   'drone2'  ,
		'pipuck6'   :   'drone2'  ,
		'pipuck7'   :   'drone2'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone4'  ,
		'pipuck10'  :   'drone2'  ,
		'pipuck11'  :   'drone4'  ,
	},
]

key_frame_list["test_20220621_8_success_3"] = key_frame_example
key_frame_parent_index_list["test_20220621_8_success_3"] = [
	{}, # key frame 0
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck1'   :   'drone4'  ,
		'pipuck2'   :   'drone2'  ,
		'pipuck4'   :   'drone2'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck6'   :   'drone2'  ,
		'pipuck7'   :   'drone4'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone2'  ,
		'pipuck10'  :   'drone2'  ,
		'pipuck11'  :   'drone4'  ,
	},
]

key_frame_list["test_20220621_9_success_4"] = key_frame_example
key_frame_parent_index_list["test_20220621_9_success_4"] = [
	{}, # key frame 0
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
]

key_frame_list["test_20220621_10_success_5"] = key_frame_example
key_frame_parent_index_list["test_20220621_10_success_5"] = [
	{}, # key frame 0
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck1'   :   'drone2'  ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone4'  ,
		'pipuck5'   :   'drone2'  ,
		'pipuck6'   :   'drone4'  ,
		'pipuck7'   :   'drone4'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone2'  ,
		'pipuck10'  :   'drone2'  ,
		'pipuck11'  :   'drone2'  ,
	},
]

x_lim_list["test_20220621_6_success_1"] = [-2, 3]

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
