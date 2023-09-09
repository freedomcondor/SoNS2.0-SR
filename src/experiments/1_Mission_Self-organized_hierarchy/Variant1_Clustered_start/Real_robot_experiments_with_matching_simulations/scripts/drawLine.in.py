drawDataFileName = "@CMAKE_SOURCE_DIR@/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

DATADIR= ""
DATADIR+="@CMAKE_SoNS_DATA_PATH@/"
DATADIR+="experiments/"
DATADIR+="1_Mission_Self-organized_hierarchy/"
DATADIR+="Variant1_Clustered_start/"
DATADIR+="Real_robot_experiments_with_matching_simulations/"
DATADIR+="data_hw/data"

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