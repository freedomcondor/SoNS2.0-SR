drawDataFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

from scipy.stats import mannwhitneyu
from scipy.stats import ttest_ind 

import numpy as np
from statsmodels.graphics.gofplots import qqplot_2samples
import statsmodels.api as sm

from matplotlib.ticker import FormatStrFormatter

def readDataFromFolderWithCut(dataFolder) :
	boxdata = []
	for subFolder in getSubfolders(dataFolder) :
		# calc cut time
		origin_single_data = readDataFrom(subFolder + "result_data.txt")
		length = len(origin_single_data)
		tail_data = origin_single_data[length-20:]
		end_error = sum(tail_data) / len(tail_data)
		cut_time = 0
		for i in range(0, length) :
			if origin_single_data[i] < end_error :
				cut_time = i
				break

		for subFile in getSubfiles(subFolder + "result_each_robot_error") :
			origin_each_robot_data = readDataFrom(subFile)
			boxdata = boxdata + origin_each_robot_data[cut_time:]

	return boxdata

def readDataFromFolder(dataFolder) :
	boxdata = []
	for subFolder in getSubfolders(dataFolder) :
		for subFile in getSubfiles(subFolder + "result_each_robot_error") :
			boxdata = boxdata + readDataFrom(subFile)
#		boxdata = readDataFrom(subFolder + "result_data.txt")
	return boxdata


# set font and style for violin plot (both top and bottom if existed)
def set_violin_font(violin, color) :
	for line in [violin['cbars'], violin['cmins'], violin['cmeans'], violin['cmaxes']] :
		line.set_linewidth(0.8) # used to be 1.5
	for line in [violin['cbars'], violin['cmins'], violin['cmaxes']] :
		line.set_facecolor(color)
		line.set_edgecolor(color)
	for line in [violin['cmeans']] :
		line.set_facecolor(color)
		line.set_edgecolor(color)
	for pc in violin['bodies']:
		pc.set_facecolor(color)
		pc.set_edgecolor(color)

folder_pairs = [
	[
		"/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_01_formation_1_2d_10p/data_hw/data",
		"/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_01_formation_1_2d_10p/data_simu/data",
		"SoNS Establishing\n(scattered)",
		[0, 1.0]
	],
	[
		"/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_10_formation_1_2d_6p_group_start/data_hw/data",
		"/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_10_formation_1_2d_6p_group_start/data_simu/data",
		"SoNS Establishing\n(clustered)",
		[0, 0.5]
	],
	[
		"/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_02_obstacle_avoidance_small/data_hw/data",
		"/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_02_obstacle_avoidance_small/data_simu/data",
		"Obstacle Avoidance\n(smaller obstacles)",
		[0, 2.5]
	],
	[
		"/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_03_obstacle_avoidance_large/data_hw/data",
		"/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_03_obstacle_avoidance_large/data_simu/data",
		"Obstacle Avoidance\n(larger obstacles)",
		[0, 2.5]
	],
	[
		"/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_04_switch_line/data_hw/data",
		"/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_04_switch_line/data_simu/data",
		"Through the Funnel",
	],
	[
		"/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_05_gate_switch/data_hw/data",
		"/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_05_gate_switch/data_simu/data",
		"Choosing Gates",
	],
	[
		"/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_08_split/data_hw/data",
		"/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_08_split/data_simu/data",
		"Search and Rescue\n(split and searching)",
	],
	[
		"/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_09_1d_switch_rescue/data_hw",
		"/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_0_hw_09_1d_switch_rescue/data_simu/data",
		"Search and Rescue\n(moving the circle)",
	],
]

datas_left = []
positions_left = []
datas_right = []
positions_right = []

tick_index = []
tick_label = []

offset = 0.15
distance = 1
index = 0

index_number = 0
f = open('violin_compares.dat', "w")
for folder_pair in folder_pairs :
	index = index + distance
	index_number = index_number + 1

	tick_index.append(index+offset)
	tick_label.append(folder_pair[2])

	print("reading : " + folder_pair[0])
	data_left = readDataFromFolder(folder_pair[0])
	if index_number == 1 or index_number == 2 :
		data_left = readDataFromFolderWithCut(folder_pair[0])
	datas_left.append(data_left)
	positions_left.append(index - offset)

	print("reading : " + folder_pair[1])
	data_right = readDataFromFolder(folder_pair[1])
	if index_number == 1 or index_number == 2 :
		data_right = readDataFromFolderWithCut(folder_pair[1])
	datas_right.append(data_right)
	positions_right.append(index + offset)

	U, p1 = mannwhitneyu(data_left, data_right)
	print("U = ", U)
	T, p1 = ttest_ind(data_left, data_right)
	print("T = ", T)

	f.write("{}\n".format(folder_pair[2]))
	f.write("\tU = {}\n".format(U))
	f.write("\tT = {}\n".format(T))

	'''
	if True :
		pp_left  = sm.ProbPlot(np.array(data_left))
		pp_right = sm.ProbPlot(np.array(data_right))
		qqplot_2samples(pp_left, pp_right)
	'''

f.close()

# draw qq plot ---------------------------------------------------------------------
fig, axs = plt.subplots(2, 4, figsize=(10,5.5))
fig.subplots_adjust(
	top=0.9,
	bottom=0.1,
	left=0.075,
	right=0.975,
	hspace=0.700,
	wspace=0.400
)
for i in range(0, 8) :
	axs_i = int(i / 4)
	axs_j = i % 4

	pp_left  = sm.ProbPlot(np.array(datas_left[i]))
	pp_right = sm.ProbPlot(np.array(datas_right[i]))
	qqplot_2samples(
		pp_left,
		pp_right,
		ax=axs[axs_i, axs_j],
		xlabel="hardware",
		ylabel="simulation",
		line="45"
	)

	axs[axs_i, axs_j].set_title(folder_pairs[i][2])
	axs[axs_i, axs_j].xaxis.set_major_formatter(FormatStrFormatter('%.2f'))
	axs[axs_i, axs_j].yaxis.set_major_formatter(FormatStrFormatter('%.2f'))

	if len(folder_pairs[i]) == 4 :
		axs[axs_i, axs_j].set_xlim(folder_pairs[i][3])

plt.show()
fig.savefig("qqplot.pdf")

# draw violin plot ---------------------------------------------------------------------
fig, ax = plt.subplots(1, 1)
fig.subplots_adjust(
	top=0.945,
	bottom=0.265,
)

violin_return_left  = ax.violinplot(datas_left, positions=positions_left, widths=0.3, showmeans=True)
violin_return_right = ax.violinplot(datas_right, positions=positions_right, widths=0.3, showmeans=True)

set_violin_font(violin_return_left, "blue")
set_violin_font(violin_return_right, "red")

ax.set_xticks(tick_index)
ax.set_xticklabels(tick_label, rotation=60, ha='right')
# set ticks size
tick_label_size = 8
ax.yaxis.set_tick_params(labelsize=tick_label_size)
ax.xaxis.set_tick_params(labelsize=tick_label_size)

legend_handles = [violin_return_left['bodies'][0],
                  violin_return_right['bodies'][0]]
legend_labels = ['hardware',
                 'simulation']

ax.legend(legend_handles, 
          legend_labels,
    loc="upper right",
    fontsize="small",
)

fig.savefig("violin_compares.pdf")

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
