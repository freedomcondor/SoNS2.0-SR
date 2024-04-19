drawDataFileName = "@CMAKE_SOURCE_DIR@/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

drawSRFigFileName = "@CMAKE_SOURCE_DIR@/scripts/drawSRFig.py"
#execfile(drawSRFigFileName)
exec(compile(open(drawSRFigFileName, "rb").read(), drawSRFigFileName, 'exec'))

logGeneratorFileName = "@CMAKE_SOURCE_DIR@/scripts/logReader/logReplayer.py"
exec(compile(open(logGeneratorFileName, "rb").read(), logGeneratorFileName, 'exec'))

drawTrackLogFileName = "@CMAKE_SOURCE_DIR@/scripts/drawTrackLogs.py"
exec(compile(open(drawTrackLogFileName, "rb").read(), drawTrackLogFileName, 'exec'))

# parameters
#-----------------------------------------------------------------------------------------
scale_2_flag = False
scale_4_flag = False
params = sys.argv
if len(sys.argv) >= 2 :
	if sys.argv[1] == "scale_2" :
		scale_2_flag = True
		print("Scale_2 provided, generating scale_2")
	if sys.argv[1] == "scale_4" :
		scale_4_flag = True
		print("Scale_4 provided, generating scale_4")

if scale_2_flag == False and scale_4_flag == False :
	scale_2_flag = True
	scale_4_flag = True
	print("Scale not provided, generating both scale_2 and scale_4")
	print("To specify a scale, add \"scale_2\" or \"scale_4\"")

# Base folder
#-----------------------------------------------------------------------------------------
cmake_source_dir         = "@CMAKE_SOURCE_DIR@"
cmake_current_source_dir = "@CMAKE_CURRENT_SOURCE_DIR@"
cmake_relative_dir       = cmake_current_source_dir.replace(cmake_source_dir, "").replace("/scripts", "")
#cmake_relative_dir starts with / and end with no /
DATADIRBase  = "@CMAKE_SoNS_DATA_PATH@" + cmake_relative_dir + "/"

#-----------------------------------------------------------------------------------------
# Scale 2
#-----------------------------------------------------------------------------------------

DATADIR = DATADIRBase + "data_simu_scale_2/data"
option_scale_2 = {
	'dataFolder'             : DATADIR,
	'sample_run'             : "run1",

	'SRFig_save'             : "Mission4_Binary_decision_Large_scale_Scalability_scale_2_Simulation-SRFig.pdf",
	'trackLog_save'          : "Mission4_Binary_decision_Large_scale_Scalability_scale_2_Simulation-trackLog.pdf",

	'SRFig_show'             : False,
	'trackLog_show'          : False,

	'main_ax_lim'            : [-0.5, 7],

	'split_right'            : False,
	'violin_ax_top_lim'      : [9.5, 10],

	'boxPlotValue_save'      : "Mission4_Binary_decision_Large_scale_Scalability_scale_2_Simulation.dat",

#------------------------------------------------
	'brain_marker'      :    '@CMAKE_SOURCE_DIR@/scripts/brain-icon-small.svg',
	#'key_frame' :  [0, 300, 2000] ,  # option 1
	'key_frame' :  [0, 600] ,
	'overwrite_trackFig_log_foler' : 
		"@CMAKE_SoNS_DATA_PATH@" + cmake_relative_dir + "/data_simu_scale_2/track_fig_logs_scale_2"
	,

	'legend_obstacle'  : True,

	'x_lim'     :  [-12, 12]    ,
	'y_lim'     :  [-12, 12]        ,
	'z_lim'     :  [-4.0,8.0]    ,
}

if scale_2_flag == True :
	drawSRFig(option_scale_2)
	drawTrackLog(option_scale_2)

#-----------------------------------------------------------------------------------------
# Scale 4
#-----------------------------------------------------------------------------------------

DATADIR = DATADIRBase + "data_simu_scale_4/data"
option_scale_4 = {
	'dataFolder'             : DATADIR,
	'sample_run'             : "run1",

	'SRFig_save'             : "Mission6_Scalability_decision_making_Scale_4_Simulation-SRFig.pdf",
	'trackLog_save'          : "Mission6_Scalability_decision_making_Scale_4_Simulation-trackLog.pdf",

	'SRFig_show'             : False,
	'trackLog_show'          : False,

	'main_ax_lim'            : [-0.5, 13],

	'split_right'            : False,
	'violin_ax_top_lim'      : [17.5, 19.5],
	'boxPlotValue_save'      : "Mission6_Scalability_decision_making_Scale_4_Simulation.dat",

#------------------------------------------------
	'brain_marker'      :    '@CMAKE_SOURCE_DIR@/scripts/brain-icon-small.svg',
	#'key_frame' :  [0, 300, 2000] ,  # option 1
	'key_frame' :  [0, 1200] ,
	'overwrite_trackFig_log_foler' : 
		"@CMAKE_SoNS_DATA_PATH@" + cmake_relative_dir + "/data_simu_scale_4/track_fig_logs_scale_4"
	,

	'figsize'          : [10, 10],
	'legend_obstacle'  : True,

	'x_lim'     :  [-15,   20]   ,
	'y_lim'     :  [-17.5, 17.5] ,
	'z_lim'     :  [-10.0, 25.0] ,
}

if scale_4_flag == True :
	drawSRFig(option_scale_4)
	drawTrackLog(option_scale_4)
