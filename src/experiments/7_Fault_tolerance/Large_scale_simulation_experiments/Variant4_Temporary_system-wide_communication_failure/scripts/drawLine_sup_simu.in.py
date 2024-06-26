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

savePDFNameBase = "Mission7_Fault_tolerance_Variant4_communication_failure_Large_scale_Simulation_"

#----------------------------------
track_option_base = {
	'brain_marker'      :    '@CMAKE_SOURCE_DIR@/scripts/brain-icon-small.svg',

#	'dataFolder'        :    dataFolder,
#	'sample_run'        :    sample_run,

#	'trackLog_save'     : savePDFNameBase + sample_run + ".pdf",
	'trackLog_show'     : False,

	'x_lim'     :  [-12, 12],
	'y_lim'     :  [-12, 12],
	'z_lim'     :  [-4.0,8.0],

	'large_scale'       : True,

	'showRobotName'     : False,

	'colored_key_frame' : True,

	'SRFig_show'        : False,
#	'no_violin'         : True,
	'main_ax_lim'       : [-0.5, 7],
}

# -------- loss 0.5s ---------------------
track_option = track_option_base.copy()
dataFolder = dataFolderBase + "data_simu_0.5s/data"
sample_run = "run23"

# 23 14 43

track_option['dataFolder']    = dataFolder
track_option['sample_run']    = sample_run
track_option['trackLog_save'] = savePDFNameBase + "0.5s_" + sample_run + "_TrackLog.pdf"
track_option['key_frame']     = [0, 500]

drawTrackLog(track_option)
track_option['SRFig_save'] = savePDFNameBase + "0.5s_" + sample_run + "_ErrorLog.pdf"
drawSRFig(track_option)

# -------- loss 1s ---------------------
track_option = track_option_base.copy()
dataFolder = dataFolderBase + "data_simu_1s/data"
sample_run = "run14"

track_option['dataFolder']    = dataFolder
track_option['sample_run']    = sample_run
track_option['trackLog_save'] = savePDFNameBase + "1s_" + sample_run + "_TrackLog.pdf"
track_option['key_frame']     = [0, 500]

drawTrackLog(track_option)
track_option['SRFig_save'] = savePDFNameBase + "1s_" + sample_run + "_ErrorLog.pdf"
drawSRFig(track_option)

# -------- loss 30s ---------------------
track_option = track_option_base.copy()
dataFolder = dataFolderBase + "data_simu_30s/data"
sample_run = "run43"

track_option['dataFolder']    = dataFolder
track_option['sample_run']    = sample_run
track_option['trackLog_save'] = savePDFNameBase + "30s_" + sample_run + "_TrackLog.pdf"
track_option['key_frame']     = [0, 500]

drawTrackLog(track_option)
track_option['SRFig_save'] = savePDFNameBase + "30s_" + sample_run + "_ErrorLog.pdf"
drawSRFig(track_option)