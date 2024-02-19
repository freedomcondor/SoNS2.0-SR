drawDataFileName = "@CMAKE_SOURCE_DIR@/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

import string

def readParentChildrenNumberTimeDataFrom(filename) :
	file = open(filename,"r")

	brain_childrenNumbers_drone = []
	brain_times_drone = []
	brain_childrenNumbers_pipuck = []
	brain_times_pipuck = []
	nonBrain_childrenNumbers_drone = []
	nonBrain_times_drone = []
	nonBrain_childrenNumbers_pipuck = []
	nonBrain_times_pipuck = []

	for line in file :
		lineList = line.strip().split(" ")
		parentNumber = float(lineList[0])
		robotName = lineList[3]
		robotType = robotName.rstrip(string.digits)
		if parentNumber == 1 and robotType == "drone":
			nonBrain_childrenNumbers_drone.append(float(lineList[1]) - 0.15)
			nonBrain_times_drone.append(float(lineList[2]))
		elif parentNumber == 1 and robotType == "pipuck":
			nonBrain_childrenNumbers_pipuck.append(float(lineList[1]) - 0.05)
			nonBrain_times_pipuck.append(float(lineList[2]))
		elif parentNumber == 0 and robotType == "drone":
			brain_childrenNumbers_drone.append(float(lineList[1]) + 0.05)
			brain_times_drone.append(float(lineList[2]))
		elif parentNumber == 0 and robotType == "pipuck":
			brain_childrenNumbers_pipuck.append(float(lineList[1]) + 0.15)
			brain_times_pipuck.append(float(lineList[2]))

	file.close()

	return brain_childrenNumbers_drone,\
	       brain_times_drone,\
	       brain_childrenNumbers_pipuck,\
	       brain_times_pipuck,\
	       nonBrain_childrenNumbers_drone,\
	       nonBrain_times_drone,\
	       nonBrain_childrenNumbers_pipuck,\
	       nonBrain_times_pipuck,\

# -----------------------------
cmake_source_dir         = "@CMAKE_SOURCE_DIR@"
cmake_current_source_dir = "@CMAKE_CURRENT_SOURCE_DIR@"
cmake_relative_dir       = cmake_current_source_dir.replace(cmake_source_dir, "").replace("/scripts", "")
#cmake_relative_dir starts with / and end with no /
DATADIR  = "@CMAKE_SoNS_DATA_PATH@" + cmake_relative_dir + "/"
DATADIR += "data_simu_1-750"

#DATADIR="/home/harry/Desktop/scalability_logs"

total_brain_childrenNumbers_drone = []
total_brain_times_drone = []
total_brain_childrenNumbers_pipuck = []
total_brain_times_pipuck = []
total_nonBrain_childrenNumbers_drone = []
total_nonBrain_times_drone = []
total_nonBrain_childrenNumbers_pipuck = []
total_nonBrain_times_pipuck = []
for subfolder in getSubfolders(DATADIR) :
	brain_childrenNumbers_drone,\
	brain_times_drone,\
	brain_childrenNumbers_pipuck,\
	brain_times_pipuck,\
	nonBrain_childrenNumbers_drone,\
	nonBrain_times_drone,\
	nonBrain_childrenNumbers_pipuck,\
	nonBrain_times_pipuck = readParentChildrenNumberTimeDataFrom(subfolder + "parent_children_number_time.txt")

	total_brain_childrenNumbers_drone += brain_childrenNumbers_drone
	total_brain_times_drone           += brain_times_drone
	total_brain_childrenNumbers_pipuck += brain_childrenNumbers_pipuck
	total_brain_times_pipuck           += brain_times_pipuck
	total_nonBrain_childrenNumbers_drone += nonBrain_childrenNumbers_drone
	total_nonBrain_times_drone        += nonBrain_times_drone
	total_nonBrain_childrenNumbers_pipuck += nonBrain_childrenNumbers_pipuck
	total_nonBrain_times_pipuck        += nonBrain_times_pipuck


plt.scatter(total_nonBrain_childrenNumbers_drone, total_nonBrain_times_drone, color="b")
plt.scatter(total_nonBrain_childrenNumbers_pipuck, total_nonBrain_times_pipuck, color="r")
plt.scatter(total_brain_childrenNumbers_drone, total_brain_times_drone, color="g")
plt.scatter(total_brain_childrenNumbers_pipuck, total_brain_times_pipuck, color="black")
plt.show()


