drawDataFileName = "@CMAKE_SOURCE_DIR@/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

cmake_source_dir         = "@CMAKE_SOURCE_DIR@"
cmake_current_source_dir = "@CMAKE_CURRENT_SOURCE_DIR@"
cmake_relative_dir       = cmake_current_source_dir.replace(cmake_source_dir, "").replace("/scripts", "")
#cmake_relative_dir starts with / and end with no /
DATADIR  = "@CMAKE_SoNS_DATA_PATH@" + cmake_relative_dir + "/"
DATADIR += "data_simu/data"

count = 0
for subFolder in getSubfolders(DATADIR) :
	count = count + 1
	data = readDataFrom(subFolder + "result_data.txt")
	dataLowerbound = readDataFrom(subFolder + "result_lowerbound_data.txt")
	data_minus_lowerbound = subtractLists(data, dataLowerbound)

	flag = False
	for value in data_minus_lowerbound :
		if value < -0.1:
			drawData(data)
			drawData(dataLowerbound)
			drawData(data_minus_lowerbound)
			flag = True
			break
	if flag == True :
		break

	# check no splits
#	data = readDataFrom(subFolder + "result_SoNSNumber_data.txt")
#	if data[-1] > 1 :
#		print("split:", subFolder)
#	drawData(data, "green")

	# check all the robots are successfully generated by initial random positions
	if len(getSubfiles(subFolder + "logs")) != 50 :
		print("robots incomplete: ", len(getSubfiles(subFolder + "logs")), subFolder)

	'''
	if subFolder != DATADIR+ "/run1/" :
		continue
	for subFile in getSubfiles(subFolder + "result_each_robot_error_data") :
		drawData(readDataFrom(subFile))
	break
	'''

plt.show()