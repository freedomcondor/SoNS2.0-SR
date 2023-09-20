drawDataFileName = "@CMAKE_SOURCE_DIR@/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

cmake_source_dir         = "@CMAKE_SOURCE_DIR@"
cmake_current_source_dir = "@CMAKE_CURRENT_SOURCE_DIR@"
cmake_relative_dir       = cmake_current_source_dir.replace(cmake_source_dir, "")
#cmake_relative_dir starts with / and end with no /
DATADIR  = "@CMAKE_SoNS_DATA_PATH@" + cmake_relative_dir + "/"
DATADIR += "data_simu/data"

for subFolder in getSubfolders(DATADIR) :
	data = readDataFrom(subFolder + "result_data.txt")
	drawData(data)
	drawData(readDataFrom(subFolder + "result_lowerbound_data.txt"))

	'''
	if subFolder != DATADIR+ "/run1/" :
		continue
	for subFile in getSubfiles(subFolder + "result_each_robot_error") :
		drawData(readDataFrom(subFile))
	break
	'''

plt.show()