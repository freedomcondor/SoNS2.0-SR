drawDataFileName = "@CMAKE_SOURCE_DIR@/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

# -----------------------------
hw_or_simu = None

import sys
params = sys.argv
if len(sys.argv) >= 2 :
	if sys.argv[1] == "hw" :
		hw_or_simu = "hw"
	if sys.argv[1] == "simu" :
		hw_or_simu = "simu"

if hw_or_simu == None :
	print("please specify hw or simu")
	exit()
# -----------------------------
cmake_source_dir         = "@CMAKE_SOURCE_DIR@"
cmake_current_source_dir = "@CMAKE_CURRENT_SOURCE_DIR@"
cmake_relative_dir       = cmake_current_source_dir.replace(cmake_source_dir, "").replace("/scripts", "")
#cmake_relative_dir starts with / and end with no /
DATADIR  = "@CMAKE_SoNS_DATA_PATH@" + cmake_relative_dir + "/"
if hw_or_simu == "hw" :
	DATADIR+="data_hw/data"
else :
	DATADIR+="data_simu/data"
# -----------------------------

count = 0
for subFolder in getSubfolders(DATADIR) :
	# choose a specific run
	#if subFolder != DATADIR+ "/run1/" :
	#	continue

	count = count + 1
	data = readDataFrom(subFolder + "result_data.txt")
	dataLowerbound = readDataFrom(subFolder + "result_lowerbound_data.txt")
	data_minus_lowerbound = subtractLists(data, dataLowerbound)

	flag = False
	for value in data_minus_lowerbound :
		if value < -0.01 :
			drawData(data)
			drawData(dataLowerbound)
			drawData(data_minus_lowerbound)
			flag = True
			break
	if flag == True :
		break

#	data = readDataFrom(subFolder + "result_data.txt")
#	if data[120] > 1.3 :
#		print(subFolder)
#	drawData(data, "blue")
#	print("length: ", len(data), ":", subFolder)
#	drawData(readDataFrom(subFolder + "result_lowerbound_data.txt"), "red")

	#data = readDataFrom(subFolder + "result_SoNSNumber_data.txt")
	#if data[-1] > 1 :
	#	print("split:", subFolder)
	#drawData(data)
	'''
	for subFile in getSubfiles(subFolder + "result_each_robot_error_data") :
		data = readDataFrom(subFile)
		if data[115] < 0.2 :
			print(subFile)
		drawData(data)
	break
	'''

plt.show()