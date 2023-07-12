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

dataFolder = "@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_02_obstacle_avoidance_small/data_hw/data"
savePDFNameBase = "mission2_small_obstacle_exp0_02_hw_"
sampleList = [
	"test_20220622_success_1",
	"test_20220622_success_2",
	"test_20220622_success_3",
	"test_20220622_success_5",
	"test_20220623_success_1",
]

#	"test_20220622_success_4_ULB",
#	"test_20220623_success_0",
#	"test_20220623_success_2",

#----------------------------------
track_option_base = {
	'brain_marker'      :    '@CMAKE_SOURCE_DIR@/scripts/brain-icon-small.svg',

	'dataFolder'        :    dataFolder,
#	'sample_run'        :    sample_run,

#	'trackLog_save'     : savePDFNameBase + sample_run + ".pdf",
	'trackLog_show'     : False,

	'x_lim'     :  [-4, 4.5]           ,
	'y_lim'     :  [-4.25, 4.25]       ,
	'z_lim'     :  [-1.0, 7.5]         ,

	'showRobotName'     : False,

	'SRFig_show'        : False,
	'no_violin'         : True,
	'main_ax_lim'            : [-0.1, 3],
}

#----------------------------------
key_frame_list = {}
key_frame_parent_index_list = {}
x_lim_list = {}
y_lim_list = {}
z_lim_list = {}

key_frame_example = [0, 400]
parent_index_example = [
	{}, # for key frame 0
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone4'  ,
		'pipuck5'   :   'drone2'  ,
		'pipuck7'   :   'drone2'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone4'  ,
	},
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone4'  ,
		'pipuck5'   :   'drone2'  ,
		'pipuck7'   :   'drone2'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone4'  ,
	},
]

#-----------------------------------------------------------
key_frame_list["test_20220622_success_1"] = key_frame_example
key_frame_parent_index_list["test_20220622_success_1"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone2'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck7'   :   'drone4'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone2'  ,
	},
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone2'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck7'   :   'drone4'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone2'  ,
	},
]

key_frame_list["test_20220622_success_2"] = key_frame_example
key_frame_parent_index_list["test_20220622_success_2"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone2'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck7'   :   'drone4'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone2'  ,
	},
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone2'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck7'   :   'drone4'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone2'  ,
	},
]

key_frame_list["test_20220622_success_3"] = key_frame_example
key_frame_parent_index_list["test_20220622_success_3"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone2'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck7'   :   'drone4'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone2'  ,
	},
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone2'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck7'   :   'drone4'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone2'  ,
	},
]

key_frame_list["test_20220622_success_4_ULB"] = key_frame_example
key_frame_parent_index_list["test_20220622_success_4_ULB"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone4'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck7'   :   'drone4'   ,
		'pipuck8'   :   'drone2'   ,
		'pipuck9'   :   'drone2'  ,
	},
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone4'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck7'   :   'drone4'   ,
		'pipuck8'   :   'drone2'   ,
		'pipuck9'   :   'drone2'  ,
	},
]

key_frame_list["test_20220622_success_5"] = key_frame_example
key_frame_parent_index_list["test_20220622_success_5"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone2'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck7'   :   'drone4'   ,
		'pipuck8'   :   'drone2'   ,
		'pipuck9'   :   'drone4'  ,
	},
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone2'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck7'   :   'drone4'   ,
		'pipuck8'   :   'drone2'   ,
		'pipuck9'   :   'drone4'  ,
	},
]

x_lim_list["test_20220623_success_0"] = [-3.50, 5.00]
key_frame_list["test_20220623_success_0"] = key_frame_example
key_frame_parent_index_list["test_20220623_success_0"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone4'  ,
		'pipuck5'   :   'drone2'  ,
		'pipuck7'   :   'drone4'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone2'  ,
	},
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone4'  ,
		'pipuck5'   :   'drone2'  ,
		'pipuck7'   :   'drone4'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone2'  ,
	},
]

key_frame_list["test_20220623_success_1"] = key_frame_example
key_frame_parent_index_list["test_20220623_success_1"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone4'  ,
		'pipuck5'   :   'drone2'  ,
		'pipuck7'   :   'drone2'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone4'  ,
	},
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone4'  ,
		'pipuck5'   :   'drone2'  ,
		'pipuck7'   :   'drone2'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone4'  ,
	},
]

key_frame_list["test_20220623_success_2"] = key_frame_example
key_frame_parent_index_list["test_20220623_success_2"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone2'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck7'   :   'drone4'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone2'  ,
	},
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone2'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck7'   :   'drone4'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone2'  ,
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