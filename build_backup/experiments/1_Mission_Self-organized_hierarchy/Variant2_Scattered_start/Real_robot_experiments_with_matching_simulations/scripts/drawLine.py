drawDataFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

DATADIR= ""
DATADIR+="/media/harry/Expansion/Storage/SoNS2.0-data/"
DATADIR+="experiments/"
DATADIR+="1_Mission_Self-organized_hierarchy/"
DATADIR+="Variant2_Scattered_start/"
DATADIR+="Real_robot_experiments_with_matching_simulations/"
DATADIR+="data_hw/data"

for subFolder in getSubfolders(DATADIR) :
	data = readDataFrom(subFolder + "result_data.txt")
	if data[115] > 2 :
		print(subFolder)
	drawData(data)
	drawData(readDataFrom(subFolder + "result_lowerbound_data.txt"))

plt.show()
