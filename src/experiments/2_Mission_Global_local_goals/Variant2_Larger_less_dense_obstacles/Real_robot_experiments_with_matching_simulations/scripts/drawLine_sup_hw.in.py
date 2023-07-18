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

dataFolder = "@CMAKE_SoNS_DATA_PATH@/src/experiments/exp_0_hw_03_obstacle_avoidance_large/data_hw/data"
savePDFNameBase = "mission2_large_obstacles_exp0_03_hw_"
sampleList = [
	"test_20220624_1_success_2",
	"test_20220624_2_success_3",
	"test_20220624_3_success_4",
	"test_20220624_4_success_5",
	"test_20220627_1_success_6",
]

#----------------------------------
track_option_base = {
	'brain_marker'      :    '@CMAKE_SOURCE_DIR@/scripts/brain-icon-small.svg',

	'dataFolder'        :    dataFolder,
#	'sample_run'        :    sample_run,

#	'trackLog_save'     : savePDFNameBase + sample_run + ".pdf",
	'trackLog_show'     : False,

	'x_lim'     :  [-4, 5]           ,
	'y_lim'     :  [-4.5, 4.5]       ,
	'z_lim'     :  [-1.0, 8]         ,

	'showRobotName'     : False,

	'SRFig_show'        : False,
	'no_violin'         : True,
	'main_ax_lim'            : [-0.2, 2],
}

#----------------------------------
key_frame_list = {}
key_frame_parent_index_list = {}
x_lim_list = {}
y_lim_list = {}
z_lim_list = {}

key_frame_example = [0, 400]

#-----------------------------------------------------------
key_frame_list["test_20220624_1_success_2"] = key_frame_example
key_frame_parent_index_list["test_20220624_1_success_2"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone4'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck7'   :   'drone2'   ,
		'pipuck8'   :   'drone2'   ,
		'pipuck9'   :   'drone4'  ,
	},
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone4'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck7'   :   'drone2'   ,
		'pipuck8'   :   'drone2'   ,
		'pipuck9'   :   'drone4'  ,
	},
]

key_frame_list["test_20220624_2_success_3"] = key_frame_example
key_frame_parent_index_list["test_20220624_2_success_3"] = [
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

key_frame_list["test_20220624_3_success_4"] = key_frame_example
key_frame_parent_index_list["test_20220624_3_success_4"] = [
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

key_frame_list["test_20220624_4_success_5"] = key_frame_example
key_frame_parent_index_list["test_20220624_4_success_5"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone4'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck7'   :   'drone2'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone2'  ,
	},
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone4'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck7'   :   'drone2'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone2'  ,
	},
]

key_frame_list["test_20220627_1_success_6"] = key_frame_example
key_frame_parent_index_list["test_20220627_1_success_6"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone4'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck7'   :   'drone2'   ,
		'pipuck8'   :   'drone4'   ,
		'pipuck9'   :   'drone2'  ,
	},
	{
		'drone2'    :   'drone4'   ,
		'drone4'    :   'nil'      ,
		'pipuck2'   :   'drone4'  ,
		'pipuck4'   :   'drone4'  ,
		'pipuck5'   :   'drone4'  ,
		'pipuck7'   :   'drone2'   ,
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