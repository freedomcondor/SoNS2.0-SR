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

cmake_source_dir         = "@CMAKE_SOURCE_DIR@"
cmake_current_source_dir = "@CMAKE_CURRENT_SOURCE_DIR@"
cmake_relative_dir       = cmake_current_source_dir.replace(cmake_source_dir, "").replace("/scripts", "")
#cmake_relative_dir starts with / and end with no /
dataFolder  = "@CMAKE_SoNS_DATA_PATH@" + cmake_relative_dir + "/"
dataFolder += "data_hw/data"

savePDFNameBase = "Mission4_Binary_decision_Real_robot_Hardware_"
sampleList = [
	"run1",
	"run2",
	"run3",
	"run4",
	"run5",
]

#----------------------------------
track_option_base = {
	'brain_marker'      :    '@CMAKE_SOURCE_DIR@/scripts/brain-icon-small.svg',

	'dataFolder'        :    dataFolder,
#	'sample_run'        :    sample_run,

#	'trackLog_save'     : savePDFNameBase + sample_run + ".pdf",
	'trackLog_show'     : False,

	'x_lim'     :  [-3.5, 4.5]    ,
	'y_lim'     :  [-4, 4]        ,
	'z_lim'     :  [-1.0, 7.0]    ,

	'showRobotName'     : False,

	'colored_key_frame' : True,

	'SRFig_show'        : False,
	'no_violin'         : True,
	'main_ax_lim'       : [-0.3, 4.0],
}

#----------------------------------
key_frame_list = {}
key_frame_parent_index_list = {}
x_lim_list = {}
y_lim_list = {}
z_lim_list = {}

key_frame_example = [0, 300, 1200]

#-----------------------------------------------------------
key_frame_list["run1"] = [0, 300, 1100]
key_frame_parent_index_list["run1"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'drone4',
		'drone4'    :   'nil',
		'pipuck2'   :   'drone4',
		'pipuck4'   :   'drone4',
		'pipuck5'   :   'drone2',
		'pipuck7'   :   'drone4',
		'pipuck8'   :   'drone2',
		'pipuck9'   :   'drone4',
	},
	{
		'drone2'    :   'nil',
		'drone4'    :   'drone2',
		'pipuck2'   :   'drone2',
		'pipuck4'   :   'drone2',
		'pipuck5'   :   'drone2',
		'pipuck7'   :   'drone4',
		'pipuck8'   :   'drone2',
		'pipuck9'   :   'drone4',
	},
	{
		'drone2'    :   'nil',
		'drone4'    :   'drone2',
		'pipuck2'   :   'drone2',
		'pipuck4'   :   'drone2',
		'pipuck5'   :   'drone2',
		'pipuck7'   :   'drone4',
		'pipuck8'   :   'drone4',
		'pipuck9'   :   'drone4',
	},
]


key_frame_list["run2"] = key_frame_example
key_frame_parent_index_list["run2"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'nil',
		'drone3'    :   'drone2',
		'pipuck2'   :   'drone2',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'drone2',
		'pipuck7'   :   'drone2',
		'pipuck8'   :   'drone3',
		'pipuck9'   :   'drone2',
	},
	{
		'drone2'    :   'nil',
		'drone3'    :   'drone2',
		'pipuck2'   :   'drone2',
		'pipuck4'   :   'drone2',
		'pipuck5'   :   'drone2',
		'pipuck7'   :   'drone3',
		'pipuck8'   :   'drone3',
		'pipuck9'   :   'drone2',
	},
	{
		'drone2'    :   'nil',
		'drone3'    :   'drone2',
		'pipuck2'   :   'drone2',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'drone2',
		'pipuck7'   :   'drone3',
		'pipuck8'   :   'drone3',
		'pipuck9'   :   'drone2',
	},
]

key_frame_list["run3"] = key_frame_example
key_frame_parent_index_list["run3"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'nil',
		'drone3'    :   'drone2',
		'pipuck2'   :   'drone2',
		'pipuck4'   :   'drone2',
		'pipuck5'   :   'drone3',
		'pipuck7'   :   'drone2',
		'pipuck8'   :   'drone2',
		'pipuck9'   :   'drone3',
	},
	{
		'drone2'    :   'drone3',
		'drone3'    :   'nil',
		'pipuck2'   :   'drone3',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'drone3',
		'pipuck7'   :   'drone2',
		'pipuck8'   :   'drone2',
		'pipuck9'   :   'drone3',
	},
	{
		'drone2'    :   'drone3',
		'drone3'    :   'nil',
		'pipuck2'   :   'drone3',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'drone2',
		'pipuck7'   :   'drone2',
		'pipuck8'   :   'drone2',
		'pipuck9'   :   'drone3',
	},
]

key_frame_list["run4"] = key_frame_example
key_frame_parent_index_list["run4"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'nil',
		'drone3'    :   'drone2',
		'pipuck2'   :   'drone2',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'drone2',
		'pipuck7'   :   'drone2',
		'pipuck8'   :   'drone3',
		'pipuck9'   :   'drone2',
	},
	{
		'drone2'    :   'drone3',
		'drone3'    :   'nil',
		'pipuck2'   :   'drone3',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'drone2',
		'pipuck7'   :   'drone3',
		'pipuck8'   :   'drone3',
		'pipuck9'   :   'drone2',
	},
	{
		'drone2'    :   'drone3',
		'drone3'    :   'nil',
		'pipuck2'   :   'drone3',
		'pipuck4'   :   'drone2',
		'pipuck5'   :   'drone2',
		'pipuck7'   :   'drone3',
		'pipuck8'   :   'drone3',
		'pipuck9'   :   'drone2',
	},
]

key_frame_list["run5"] = key_frame_example
key_frame_parent_index_list["run5"] = [
	{}, # for key frame 0
	{
		'drone2'    :   'nil',
		'drone3'    :   'drone2',
		'pipuck3'   :   'drone2',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'drone3',
		'pipuck7'   :   'drone2',
		'pipuck8'   :   'drone2',
		'pipuck9'   :   'drone2',
	},
	{
		'drone2'    :   'nil',
		'drone3'    :   'drone2',
		'pipuck3'   :   'drone2',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'drone3',
		'pipuck7'   :   'drone2',
		'pipuck8'   :   'drone2',
		'pipuck9'   :   'drone2',
	},
	{
		'drone2'    :   'nil',
		'drone3'    :   'drone2',
		'pipuck3'   :   'drone3',
		'pipuck4'   :   'drone3',
		'pipuck5'   :   'drone3',
		'pipuck7'   :   'drone2',
		'pipuck8'   :   'drone2',
		'pipuck9'   :   'drone2',
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