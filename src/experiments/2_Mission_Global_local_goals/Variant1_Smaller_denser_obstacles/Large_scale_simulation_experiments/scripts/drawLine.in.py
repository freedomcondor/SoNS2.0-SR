drawDataFileName = "@CMAKE_SOURCE_DIR@/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

DATADIR= ""
DATADIR+="@CMAKE_SoNS_DATA_PATH@/"
DATADIR+="experiments/"
DATADIR+="2_Mission_Global_local_goals/"
DATADIR+="Variant1_Smaller_denser_obstacles/"
DATADIR+="Large_scale_simulation_experiments/"
DATADIR+="data_simu/data"

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