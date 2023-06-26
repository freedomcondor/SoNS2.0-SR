drawDataFileName = "@CMAKE_SOURCE_DIR@/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

from scipy.stats import mannwhitneyu
from scipy.stats import ttest_ind 

def readDataFromFolder(dataFolder) :
	boxdata = []
	for subFolder in getSubfolders(dataFolder) :
		for subFile in getSubfiles(subFolder + "result_each_robot_error") :
			boxdata = boxdata + readDataFrom(subFile)
	return boxdata

folders = [
	"@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_01_formation_1_2d_10p/data_hw/data",
	"@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_01_formation_1_2d_10p/data_simu/data",
]

datas = []
for folder in folders :
	data = readDataFromFolder(folder)
	datas.append(data)

U, p1 = mannwhitneyu(datas[0], datas[1])
print("U = ", U)
T, p1 = ttest_ind(datas[0], datas[1])
print("T = ", T)

fig, ax = plt.subplots(1, 1)

'''
color = 'blue'
box_return = ax.boxplot(
    datas,
#    positions=positions,
#    widths=2.0,
    boxprops = dict(facecolor=color, color=color),
    capprops = dict(color=color),
    whiskerprops = dict(color=color),
    flierprops = dict(markerfacecolor=color, markeredgecolor=color, marker='.'),
    medianprops = dict(color=color),
    patch_artist=True
) 
'''

violin_return = ax.violinplot(datas, widths=0.3, showmeans=True)

plt.show()