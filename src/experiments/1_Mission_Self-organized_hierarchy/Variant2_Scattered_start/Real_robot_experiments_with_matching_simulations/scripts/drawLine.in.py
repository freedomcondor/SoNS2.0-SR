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

DATADIR =""
DATADIR+="@CMAKE_SoNS_DATA_PATH@/"
DATADIR+="experiments/"
DATADIR+="1_Mission_Self-organized_hierarchy/"
DATADIR+="Variant2_Scattered_start/"
DATADIR+="Real_robot_experiments_with_matching_simulations/"
if hw_or_simu == "hw" :
	DATADIR+="data_hw/data"
else :
	DATADIR+="data_simu/data"

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

	for subFile in getSubfiles(subFolder + "result_each_robot_error") :
		data = readDataFrom(subFile)
		if data[115] < 0.2 :
			print(subFile)
		drawData(data)
	break
	'''

plt.show()