drawDataFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

legend = []
for subfolder in getSubfolders("/home/harry/code-mns2.0/SoNS2.0-SR/src/testing/exp_0_hw_00_demo_1_2d_4p/scripts/../data") :
	legend.append(subfolder)
	drawData(readDataFrom(subfolder + "result_data.txt"))
plt.legend(legend)

#drawData(readDataFrom("result_data.txt"))

plt.show()
