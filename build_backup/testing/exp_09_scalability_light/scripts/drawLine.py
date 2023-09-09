drawDataFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

legend = []
for subfolder in getSubfolders("/home/harry/code-mns2.0/SoNS2.0-SR/src/testing/exp_09_scalability_light/scripts/../data") :
	#legend.append(subfolder)
	data = readDataFrom(subfolder + "result_data.txt")
	if data[2430] > 5:
		print("wrong case: ", subfolder)
	drawData(data)
#plt.legend(legend)

#drawData(readDataFrom("result_data.txt"))

plt.show()
