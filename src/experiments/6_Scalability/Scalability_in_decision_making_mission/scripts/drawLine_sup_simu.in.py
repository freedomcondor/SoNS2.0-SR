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
dataFolderBase  = "@CMAKE_SoNS_DATA_PATH@" + cmake_relative_dir + "/"

savePDFNameBase = "Mission6_Scalability_in_decision_making_Simulation_"

#----------------------------------
track_option_base = {
	'brain_marker'      :    '@CMAKE_SOURCE_DIR@/scripts/brain-icon-small.svg',

#	'dataFolder'        :    dataFolder,
#	'sample_run'        :    sample_run,

#	'trackLog_save'     : savePDFNameBase + sample_run + ".pdf",
	'trackLog_show'     : False,

#	'x_lim'             :    [-2.5, 2.5],
#	'y_lim'             :    [-2.5, 2.5],
#	'z_lim'             :    [-1.0, 4.0],

	'showRobotName'     : False,

	'colored_key_frame' : True,

	'SRFig_show'        : False,
	'no_violin'         : True,
#	'main_ax_lim'            : [-0.2, 3],
}

# -------- scale 1 ---------------------
track_option = track_option_base.copy()
dataFolder = dataFolderBase + "data_simu_scale_1/data"
sample_run = "run3"

#'3 19 2 47'

track_option['dataFolder']    = dataFolder
track_option['sample_run']    = sample_run
track_option['trackLog_save'] = savePDFNameBase + "scale1_7drones_" + sample_run + "_TrackLog.pdf"
track_option['key_frame']     = [0, 450]
track_option['x_lim'] = [-8, 8]
track_option['y_lim'] = [-8, 8]
track_option['z_lim'] = [-3.0,5.0]

track_option['main_ax_lim'] = [-0.5, 13]

drawTrackLog(track_option)
track_option['SRFig_save'] = savePDFNameBase + "scale1_7drones_" + sample_run + "_ErrorLog.pdf"
drawSRFig(track_option)

# -------- scale 2 ---------------------
track_option = track_option_base.copy()
dataFolder = dataFolderBase + "data_simu_scale_2/data"
sample_run = "run19"

#'3 19 2 47'

track_option['dataFolder']    = dataFolder
track_option['sample_run']    = sample_run
track_option['trackLog_save'] = savePDFNameBase + "scale2_13drones_" + sample_run + "_TrackLog.pdf"
track_option['key_frame']     = [0, 600]

track_option['x_lim'] = [-12, 12]
track_option['y_lim'] = [-12, 12]
track_option['z_lim'] = [-4.0,8.0]

track_option['main_ax_lim'] = [-0.5, 13]

drawTrackLog(track_option)
track_option['SRFig_save'] = savePDFNameBase + "scale2_13drones_" + sample_run + "_ErrorLog.pdf"
drawSRFig(track_option)

# -------- scale 3 ---------------------
track_option = track_option_base.copy()
dataFolder = dataFolderBase + "data_simu_scale_3/data"
sample_run = "run2"

#'3 19 2 47'

track_option['dataFolder']    = dataFolder
track_option['sample_run']    = sample_run
track_option['trackLog_save'] = savePDFNameBase + "scale3_19drones_" + sample_run + "_TrackLog.pdf"
track_option['key_frame']     = [0, 900]

track_option['x_lim'] = [-15,   20]
track_option['y_lim'] = [-17.5, 17.5]
track_option['z_lim'] = [-10.0, 25.0]

track_option['figsize'] = [10, 10]

track_option['main_ax_lim'] = [-0.5, 13]

drawTrackLog(track_option)
track_option['SRFig_save'] = savePDFNameBase + "scale3_19drones_" + sample_run + "_ErrorLog.pdf"
drawSRFig(track_option)

# -------- scale 4 ---------------------
track_option = track_option_base.copy()
dataFolder = dataFolderBase + "data_simu_scale_4/data"
sample_run = "run47"

#'3 19 2 47'

track_option['dataFolder']    = dataFolder
track_option['sample_run']    = sample_run
track_option['trackLog_save'] = savePDFNameBase + "scale4_25drones_" + sample_run + "_TrackLog.pdf"
track_option['key_frame']     = [0, 1200]

track_option['x_lim'] = [-15,   20]
track_option['y_lim'] = [-17.5, 17.5]
track_option['z_lim'] = [-10.0, 25.0]

track_option['figsize'] = [10, 10]

track_option['main_ax_lim'] = [-0.5, 13]

drawTrackLog(track_option)
track_option['SRFig_save'] = savePDFNameBase + "scale4_25drones_" + sample_run + "_ErrorLog.pdf"
drawSRFig(track_option)