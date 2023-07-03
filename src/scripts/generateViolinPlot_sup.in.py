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

	"@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_10_formation_1_2d_6p_group_start/data_hw/data",
	"@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_10_formation_1_2d_6p_group_start/data_simu/data",

	"@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_02_obstacle_avoidance_small/data_hw/data",
	"@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_02_obstacle_avoidance_small/data_simu/data",

	"@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_03_obstacle_avoidance_large/data_hw/data",
	"@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_03_obstacle_avoidance_large/data_simu/data",

	"@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_04_switch_line/data_hw/data",
	"@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_04_switch_line/data_simu/data",

	"@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_05_gate_switch/data_hw/data",
	"@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_05_gate_switch/data_simu/data",

	"@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_09_1d_switch_rescue/data_hw",
	"@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_09_1d_switch_rescue/data_simu/data",

	"@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_08_split/data_hw/data",
	"@CMAKE_MNS_DATA_PATH@/src/experiments/exp_0_hw_08_split/data_simu/data",
]

datas = []
index = 0
for folder in folders :
	print("reading : " + folder)
	data = readDataFromFolder(folder)
	datas.append(data)

	if index % 2 == 1 :
		U, p1 = mannwhitneyu(datas[index-1], datas[index])
		print("U = ", U)
		T, p1 = ttest_ind(datas[index-1], datas[index])
		print("T = ", T)

	index = index + 1

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