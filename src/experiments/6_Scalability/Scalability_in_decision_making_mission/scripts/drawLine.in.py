drawDataFileName = "@CMAKE_SOURCE_DIR@/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

# -----------------------------
expScale = None

import sys
params = sys.argv
if len(sys.argv) >= 2 :
	if sys.argv[1] == "scale_1" :
		expScale= "1"
	if sys.argv[1] == "scale_2" :
		expScale= "2"
	if sys.argv[1] == "scale_3" :
		expScale= "3"
	if sys.argv[1] == "scale_4" :
		expScale= "4"

if expScale == None :
	print("please specify a scale by adding \"scale_1\", \"scale_2\", \"scale_3\", or \"scale_4\"")
	exit()
# -----------------------------
cmake_source_dir         = "@CMAKE_SOURCE_DIR@"
cmake_current_source_dir = "@CMAKE_CURRENT_SOURCE_DIR@"
cmake_relative_dir       = cmake_current_source_dir.replace(cmake_source_dir, "").replace("/scripts", "")
#cmake_relative_dir starts with / and end with no /
DATADIR  = "@CMAKE_SoNS_DATA_PATH@" + cmake_relative_dir + "/"
DATADIR+="data_simu_scale_" + expScale + "/data"
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
	'''
	for subFile in getSubfiles(subFolder + "result_each_robot_error_data") :
		data = readDataFrom(subFile)
		if data[115] < 0.2 :
			print(subFile)
		drawData(data)
	break
	'''

plt.show()