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
		    flierprops = dict(markerfacecolor=color, markeredgecolor=color, marker='.', markersize='1'),
		    medianprops = dict(color=color),
		    patch_artist=True
		) 

		ax.set_xticks([25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275])
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
#           folder + "/other/backups/outdated_data_simus/data_simu_1000-1300",

folder = "/media/harry/Expansion/Storage/SoNS2.0-data/src/experiments/exp_2_simu_scalability_analyze"

folders = [folder + "/data_simu_1-750",
           folder + "/data_simu_751-999",
           folder + "/data_simu_1000-1299",
           folder + "/data_simu_1300-1500",
#           folder + "/data_simu_1501-1800",
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
comms = []
cut_left_comms = []

#-------------------------------------------------------------
# calculation cost (calc time per step)
times = []
cut_left_times = []

#-------------------------------------------------------------
#  read data of position errors and converge time and recruit time
scales = []
errors = []
smoothed_errors = []
converges = []
recruits = []
step_mean_errors = []

all_scales_above_25 = []
experiment_cut_scales = []
experiment_cut_converges = []

cut_left_scales = []
cut_left_errors = []
cut_left_smoothed_errors = []
cut_left_converges = []
cut_left_recruits = []
cut_left_step_mean_errors = []

for folder in folders :
	for subfolder in getSubfolders(folder) :
		# -- read communication
		scale, comm = readCommOrTimeData(subfolder + "result_comm_data.txt")
		comms.append(comm)
		# -- read time
		scale, time = readCommOrTimeData(subfolder + "result_time_data.txt")
		time = time * 2.35
		times.append(time)
		# -- read error and converge time
		scale, error, smoothed_error, converge, recruit = readFormationData(subfolder + "result_formation_data.txt")
		scales.append(scale)
		errors.append(error)

		# -- read step errors from result_data
		step_errors = readDataFrom(subfolder + "result_data.txt")
		mean = np.mean(np.array(step_errors))
		step_mean_errors.append(mean)

		'''
		if smoothed_error > 0.12 :
			print("smoothed error > 0.12: ", subfolder)

		if recruit / 5 > 100 :
			print("recruit > 100: ", subfolder)
		'''

		smoothed_errors.append(smoothed_error)
		converges.append(converge / 5)
		recruits.append(recruit / 5)

		# compare with experiment length
		n_drone = scale / 5
		experiment_length = 2500
		if n_drone > 25 :
			experiment_length = n_drone * 100 + (n_drone - 25) * 100
			all_scales_above_25.append(scale)
		if converge > experiment_length :
			experiment_cut_scales.append(scale)
			experiment_cut_converges.append(converge / 5)
		else :
			cut_left_scales.append(scale)
			cut_left_comms.append(comm)
			cut_left_times.append(time)
			cut_left_errors.append(error)
			cut_left_smoothed_errors.append(smoothed_error)
			cut_left_converges.append(converge / 5)
			cut_left_recruits.append(recruit / 5)
			cut_left_step_mean_errors.append(mean)

show_cut = True
#show_cut = False
#-------------------------------------------------------------
# communication amount
'''
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
'''

 # boxplot data
if show_cut == True :
	boxplot_25_scales(comm_ax, cut_left_scales, cut_left_comms)
else :
	boxplot_25_scales(comm_ax, scales, comms, "red")
comm_ax.set_ylim([0, 1000])
#comm_ax.set_title("Number of messages per robot per step")
comm_ax.set_xlabel('Scale: number of robots', fontsize=fontsize)
comm_ax.set_ylabel('Communication cost: Number of bytes per robot per step', fontsize=fontsize)
comm_ax.tick_params(axis='x', labelsize=fontsize)
comm_ax.tick_params(axis='y', labelsize=fontsize)

#-------------------------------------------------------------
# calculation cost (calc time per step)
'''
scales = []
times = []

for folder in folders :
	for subfolder in getSubfolders(folder) :
		scale, time = readCommOrTimeData(subfolder + "result_time_data.txt")
		scales.append(scale)
		times.append(time)

		if time > 0.6 :
			print("calculation cost > 0.6: ", subfolder)
'''

if show_cut == True :
	boxplot_25_scales(time_ax, cut_left_scales, cut_left_times)
else :
	boxplot_25_scales(time_ax, scales, times, "red")
time_ax.set_ylim([0, 1.5 * 2.35])
#time_ax.set_title("calculation cost per step (s)")

time_ax.set_xlabel('Scale: number of robots', fontsize=fontsize)
time_ax.set_ylabel('Calculation cost: CPU cycles per robot per step (10^6)', fontsize=fontsize)
time_ax.tick_params(axis='x', labelsize=fontsize)
time_ax.tick_params(axis='y', labelsize=fontsize)

#-------------------------------------------------------------
# position errors
#boxplot_25_scales(error_ax, scales, errors)
if show_cut == True :
	boxplot_25_scales(error_ax, cut_left_scales, cut_left_step_mean_errors, "green")
	boxplot_25_scales(error_ax, cut_left_scales, cut_left_smoothed_errors)
else :
	boxplot_25_scales(error_ax, scales, smoothed_errors, "red")
	boxplot_25_scales(error_ax, scales, step_mean_errors, "green")
#error_ax.set_ylim([0, 0.50])
error_ax.set_ylim([0, 4.50])
#error_ax.set_title("position errors")

error_ax.set_xlabel('Scale: number of robots', fontsize=fontsize)
error_ax.set_ylabel('Position error (m)', fontsize=fontsize)
error_ax.tick_params(axis='x', labelsize=fontsize)
error_ax.tick_params(axis='y', labelsize=fontsize)
#-------------------------------------------------------------
# converge time and recruit time
if show_cut == True :
	handle1 = boxplot_25_scales(converge_ax, cut_left_scales, cut_left_converges)
else :
	handle1 = boxplot_25_scales(converge_ax, scales, converges, "red")
#handle2 = boxplot_25_scales(converge_ax, scales, recruits, 'red')
#converge_ax.set_ylim([0, 600])
converge_ax.set_ylim([0, 1600])
#converge_ax.set_title("converge and recruit time")

converge_ax.set_xlabel('Scale: number of robots', fontsize=fontsize)
converge_ax.set_ylabel('Converge time (s)', fontsize=fontsize)
converge_ax.tick_params(axis='x', labelsize=fontsize)
converge_ax.tick_params(axis='y', labelsize=fontsize)

print("all_scales_above_25 = ", len(all_scales_above_25))
print("cut = ", len(experiment_cut_scales))

scale_index = {}
for i in range(0, len(experiment_cut_scales)) :
	if experiment_cut_scales[i] in scale_index :
		scale_index[experiment_cut_scales[i]] = scale_index[experiment_cut_scales[i]] + 1
	else :
		scale_index[experiment_cut_scales[i]] = 1

for key in scale_index :
	print(key, scale_index[key])


'''
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

'''
axs[1, 2].scatter(scales, recruits, color="red")
axs[1, 2].set_title("zoom in of recruit time")
'''

# draw a line to show experiment length
x = []
y = []
for i in range(1, 50) :
	scale = i * 5
	experiment_length = 2500
	if i > 25 :
		experiment_length = i * 100 + (i - 25) * 100

	x.append(scale)
	y.append(experiment_length / 5)
'''
#converge_ax.scatter(experiment_cut_scales, experiment_cut_converges,
converge_ax.scatter(cut_line_scales, cut_line_experiment_length,
#                    marker=".",
                    s=4,
                    c="red"
                   )
'''
converge_ax.plot(x, y, "red")

if show_cut == True :
	plt.savefig("exp_2_scalability_analyze_cutted.pdf")
else :
	plt.savefig("exp_2_scalability_analyze_all.pdf")
plt.show()
