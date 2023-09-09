drawDataFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

for subfolder in getSubfolders("/home/harry/code-mns2.0/SoNS2.0-SR/src/experiments/7_Fault_tolerance/Large_scale_simulation_experiments/Variant2_Two_thirds_chance_for_each_robot_to_fail/scripts/../data") :
	drawData(readDataFrom(subfolder + "result_data.txt"))

#drawData(readDataFrom("result_data.txt"))

plt.show()
