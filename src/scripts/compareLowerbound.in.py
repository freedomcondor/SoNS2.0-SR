drawDataFileName = "@CMAKE_SOURCE_DIR@/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

# read cmd parameters
import sys
shortName = sys.argv[1]
experimentPath = sys.argv[2]

DATADIR  = "@CMAKE_SoNS_DATA_PATH@/experiments/" + experimentPath + "/"

print("searching in " + DATADIR)
minimumInAllRun = 0
for subFolder in getSubfolders(DATADIR) :
	runName = subFolder.split('/')[-2]
	fileName = shortName + "_" + runName + ".pdf"

	data = readDataFrom(subFolder + "result_data.txt")
	dataLowerbound = readDataFrom(subFolder + "result_lowerbound_data.txt")
	data_minus_lowerbound = subtractLists(data, dataLowerbound)

	minimum = 0
	for value in data_minus_lowerbound :
		if value < minimum :
			minimum = value

	if minimum < 0 :
		if minimum < minimumInAllRun :
			minimumInAllRun = minimum

		print("In " + runName + ", value drop to ", minimum)
		fig = plt.figure()
		ax1 = fig.add_subplot(211)
		ax2 = fig.add_subplot(212)

		drawDataInSubplot(data, ax1)
		drawDataInSubplot(dataLowerbound, ax1)
		drawDataInSubplot(data_minus_lowerbound, ax1)

		for subFile in getSubfiles(subFolder + "result_each_robot_lowerbound_data") :
			drawDataInSubplot(readDataFrom(subFile), ax2, "red")
		for subFile in getSubfiles(subFolder + "result_each_robot_error_data") :
			drawDataInSubplot(readDataFrom(subFile), ax2)

		plt.savefig(fileName)

print("minimum in all the runs: ", minimumInAllRun)