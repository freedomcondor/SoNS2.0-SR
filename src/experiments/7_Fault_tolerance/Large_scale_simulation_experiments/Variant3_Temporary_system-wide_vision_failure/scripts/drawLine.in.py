drawDataFileName = "@CMAKE_SOURCE_DIR@/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

# -----------------------------
data_set = None

import sys
params = sys.argv
if len(sys.argv) >= 2 :
	if sys.argv[1] == "data_simu_0.5s" :
		data_set = "data_simu_0.5s"
	if sys.argv[1] == "data_simu_1s" :
		data_set = "data_simu_1s"
	if sys.argv[1] == "data_simu_30s" :
		data_set = "data_simu_30s"

if data_set == None :
	print("please specify data set: data_simu_0.5s, data_simu_1s, or data_simu_30s")
	exit()
# -----------------------------
cmake_source_dir         = "@CMAKE_SOURCE_DIR@"
cmake_current_source_dir = "@CMAKE_CURRENT_SOURCE_DIR@"
cmake_relative_dir       = cmake_current_source_dir.replace(cmake_source_dir, "").replace("/scripts", "")
#cmake_relative_dir starts with / and end with no /
DATADIR  = "@CMAKE_SoNS_DATA_PATH@" + cmake_relative_dir + "/"
DATADIR+= data_set + "/data"

# -----------------------------
for subFolder in getSubfolders(DATADIR) :
	# choose a specific run
	#if subFolder != DATADIR+ "/run1/" :
	#	continue

	data = readDataFrom(subFolder + "result_data.txt")
#	if data[120] > 1.3 :
#		print(subFolder)
	drawData(data)
	drawData(readDataFrom(subFolder + "result_lowerbound_data.txt"))

	# check no splits
	data = readDataFrom(subFolder + "result_SoNSNumber_data.txt")
	if data[-1] > 1 :
		print("split:", subFolder)
	drawData(data)

	# check all the robots are successfully generated by initial random positions
	filelist = getSubfilesWithoutPaths(subFolder + "logs")
	robotCount = 0
	for file in filelist :
		if file.startswith("drone") or file.startswith("pipuck") :
			robotCount = robotCount + 1
	if robotCount != 65 :
		print("robots incomplete: ", robotCount, subFolder)	

	'''
	for subFile in getSubfiles(subFolder + "result_each_robot_error_data") :
		data = readDataFrom(subFile)
		if data[115] < 0.2 :
			print(subFile)
		drawData(data)
	break
	'''

plt.show()