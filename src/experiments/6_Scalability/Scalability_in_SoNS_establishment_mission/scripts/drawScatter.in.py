drawDataFileName = "@CMAKE_SOURCE_DIR@/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

from matplotlib.ticker import FormatStrFormatter

def readCommOrTimeData(fileName) :
	file = open(fileName,"r")
	for line in file :
		splits = line.split(' ')
	file.close()
	return float(splits[0]), float(splits[1])

def readFormationData(fileName) :
	file = open(fileName,"r")
	for line in file :
		splits = line.split(' ')
	file.close()
	return float(splits[0]), float(splits[1]), float(splits[2]), float(splits[3]), float(splits[4])
	'''
	return float(splits[0]),\  # scale
	       float(splits[1]),\  # averaged error
	       float(splits[2]),\  # averaged smooth error
	       float(splits[3]),\  # converge step
	       float(splits[4])   # recruit step
	'''
def boxplot_25_scales(ax, scales, values, color='b') :
	datas = []
	positions = []

	i = 0
	for value in values :
		scale = scales[i]

		if scale not in positions :
			positions.append(scale)
			datas.append([])

		idx = positions.index(scale)
		datas[idx].append(value)
		i = i + 1

	#boxplot = False 
	boxplot = True 
	if boxplot == True :
		box_return = ax.boxplot(
		    datas,
		    positions=positions,
		    widths=2.0,
		    boxprops = dict(facecolor=color, color=color),
		    capprops = dict(color=color),
		    whiskerprops = dict(color=color),
		    flierprops = dict(markerfacecolor=color, markeredgecolor=color, marker='.'),
		    medianprops = dict(color=color),
		    patch_artist=True
		) 

		ax.set_xticks([25, 50, 75, 100, 125, 150, 175, 200, 225])
		ax.xaxis.set_major_formatter(FormatStrFormatter('%d'))
		#ax.set_xticklabels(["hi", "hi"])

		return box_return
	else :
		#violin_return = ax.violinplot(datas, showmeans=True)
		violin_return = ax.violinplot(datas, positions=positions, widths=3, showmeans=True)
		violin_returns = [violin_return]

		ax.set_xticks([5, 10, 15, 20, 25],[25, 50, 75, 100, 125])
		#ax.set_xticks([5, 10, 15, 20, 25])
		#ax.set_xticks([25, 50, 75, 100, 125])

		# set font and style for violin plot (both top and bottom if existed)
		for violin in violin_returns :
			for line in [violin['cbars'], violin['cmins'], violin['cmeans'], violin['cmaxes']] :
				line.set_linewidth(0.8) # used to be 1.5
			for line in [violin['cbars'], violin['cmins'], violin['cmaxes']] :
				line.set_facecolor('grey')
				line.set_edgecolor('grey')
			for line in [violin['cmeans']] :
				line.set_facecolor(color)
				line.set_edgecolor(color)
			for pc in violin['bodies']:
				pc.set_facecolor(color)
				pc.set_edgecolor(color)
	
		return violin_return

#----------------------------------------------------------------------------------
#folder = "@CMAKE_CURRENT_SOURCE_DIR@/../data"
#folder = "/home/harry/code/SoNS2.0-SR/build/threads_finish"
#folder = "@CMAKE_SOURCE_DIR@/../../SoNS2.0-data/src/experiments/exp_2_simu_scalability_analyze/data_simu/data"
#folder = "@CMAKE_BINARY_DIR@/data_simu_scalability_analyze_1-450"

folders = ["/media/harry/Expansion/Storage/scalability_analyze_data/data_simu_1-750",
           "/media/harry/Expansion/Storage/scalability_analyze_data/data_simu_751-999",
           "/media/harry/Expansion/Storage/scalability_analyze_data/data_simu_1000-1299-first",
           "/media/harry/Expansion/Storage/scalability_analyze_data/data_simu_1300-1500",
          ]

'''
fig, axs = plt.subplots(2, 2)
comm_ax = axs[0, 0]
time_ax = axs[0, 1]
error_ax = axs[1, 0]
converge_ax = axs[1, 1]
'''
fig = plt.figure(constrained_layout=True)
updown = fig.add_gridspec(2,1)
up = updown[0].subgridspec(1,2)
down = updown[1].subgridspec(1,3)

error_ax = fig.add_subplot(up[1])
comm_ax = fig.add_subplot(down[0])
time_ax = fig.add_subplot(down[1])
converge_ax = fig.add_subplot(down[2])

fontsize = 5
#-------------------------------------------------------------
# communication amount
 # get data
scales = []
comms = []

for folder in folders :
	for subfolder in getSubfolders(folder) :
		scale, comm = readCommOrTimeData(subfolder + "result_comm_data.txt")
		scales.append(scale)
		comms.append(comm)

		if comm > 650 :
			print("communication amount > 650: ", subfolder)

 # boxplot data
boxplot_25_scales(comm_ax, scales, comms)
comm_ax.set_ylim([0, 1000])
#comm_ax.set_title("Number of messages per robot per step")
comm_ax.set_xlabel('Scale: number of robots', fontsize=fontsize)
comm_ax.set_ylabel('Communication cost: Number of bytes per robot per step', fontsize=fontsize)
comm_ax.tick_params(axis='x', labelsize=fontsize)
comm_ax.tick_params(axis='y', labelsize=fontsize)

#-------------------------------------------------------------
# calculation cost (calc time per step)
scales = []
times = []

for folder in folders :
	for subfolder in getSubfolders(folder) :
		scale, time = readCommOrTimeData(subfolder + "result_time_data.txt")
		scales.append(scale)
		times.append(time)

		if time > 0.6 :
			print("calculation cost > 0.6: ", subfolder)

boxplot_25_scales(time_ax, scales, times)
#time_ax.set_ylim([0, 1.5])
time_ax.set_ylim([0, 2.0])
#time_ax.set_title("calculation cost per step (s)")

time_ax.set_xlabel('Scale: number of robots', fontsize=fontsize)
time_ax.set_ylabel('Calculation cost: CPU time per robot per step (s)', fontsize=fontsize)
time_ax.tick_params(axis='x', labelsize=fontsize)
time_ax.tick_params(axis='y', labelsize=fontsize)
#-------------------------------------------------------------
#  read data of position errors and converge time and recruit time
scales = []
errors = []
smoothed_errors = []
converges = []
recruits = []
for folder in folders :
	for subfolder in getSubfolders(folder) :
		scale, error, smoothed_error, converge, recruit = readFormationData(subfolder + "result_formation_data.txt")
		scales.append(scale)
		errors.append(error)
		if smoothed_error > 0.12 :
			print("smoothed error > 0.12: ", subfolder)

		if recruit / 5 > 100 :
			print("recruit > 100: ", subfolder)

		smoothed_errors.append(smoothed_error)
		converges.append(converge / 5)
		recruits.append(recruit / 5)

#-------------------------------------------------------------
# position errors
#boxplot_25_scales(error_ax, scales, errors)
#boxplot_25_scales(error_ax, scales, smoothed_errors, "red")
boxplot_25_scales(error_ax, scales, smoothed_errors)
error_ax.set_ylim([0, 0.50])
#error_ax.set_title("position errors")

error_ax.set_xlabel('Scale: number of robots', fontsize=fontsize)
error_ax.set_ylabel('Position error (m)', fontsize=fontsize)
error_ax.tick_params(axis='x', labelsize=fontsize)
error_ax.tick_params(axis='y', labelsize=fontsize)
#-------------------------------------------------------------
# converge time and recruit time
handle1 = boxplot_25_scales(converge_ax, scales, converges)
handle2 = boxplot_25_scales(converge_ax, scales, recruits, 'red')
#converge_ax.set_ylim([0, 600])
converge_ax.set_ylim([0, 1300])
#converge_ax.set_title("converge and recruit time")

converge_ax.set_xlabel('Scale: number of robots', fontsize=fontsize)
converge_ax.set_ylabel('Converge time (s)', fontsize=fontsize)
converge_ax.tick_params(axis='x', labelsize=fontsize)
converge_ax.tick_params(axis='y', labelsize=fontsize)

if 'bodies' in handle1 :
	converge_ax.legend([handle1['bodies'][0],
	                    handle2['bodies'][1]],
	                   ['formation converge time',
	                    'SoNS establishment time'],
	    loc="upper left",
	    fontsize="xx-small"
	)
else :
	converge_ax.legend([handle1['boxes'][0],
	                    handle2['boxes'][1]],
	                   ['formation converge time',
	                    'SoNS establishment time'],
	    loc="upper left",
	    fontsize="xx-small"
	)

'''
axs[1, 2].scatter(scales, recruits, color="red")
axs[1, 2].set_title("zoom in of recruit time")
'''

#plt.savefig("exp_2_scalability_analyze.pdf")
plt.show()
