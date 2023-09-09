import statistics
# scipy.mean is deprecated
#import scipy
#from scipy import stats
import math
#from brokenaxes import brokenaxes
from matplotlib.ticker import FormatStrFormatter

def drawSRFig(option) :
	dataFolder = option['dataFolder']

	main_ax = None
	violin_ax = None
	violin_ax_top = None
	violin2_ax = None
	violin2_ax_top = None
	violin3_ax = None
	violin3_ax_top = None

	hspace = 0.05
	wspace = 0.3
	wspace_fig_size_scalar = 1/wspace
	margin = 0
	main_ratio_x_component = 7
	main_ratio_y_component = 4

	height_ratios = [1, 8]
	if 'height_ratios' in option :
		height_ratios = option['height_ratios']
	top_ratio_y_scalar = (height_ratios[0] + height_ratios[1]) / height_ratios[1]

	option['split_right'] = False # in last version we do not need to split right
	
	if ('no_violin' in option and option['no_violin'] == True) :
		fig, ax = plt.subplots(1, 1, figsize=(main_ratio_x_component, main_ratio_y_component))
		main_ax = ax

	elif ('split_right'  not in option or option['split_right']  != True) and \
	     ('double_right' not in option or option['double_right'] != True) and \
	     ('triple_right' not in option or option['triple_right'] != True) :
		# 2 subfigures
		fig, axs = plt.subplots(1, 2, gridspec_kw={'width_ratios': [main_ratio_x_component, 1]}, figsize=(margin+main_ratio_x_component+1*(1+wspace*wspace_fig_size_scalar), main_ratio_y_component))
		fig.subplots_adjust(hspace=hspace, wspace=wspace)  # adjust space between axes

		main_ax = axs[0]
		violin_ax = axs[1]

	elif ('split_right'  not in option or  option['split_right']  != True) and \
	     ('double_right'     in option and option['double_right'] == True) :
		# 3 subfigures
		fig, axs = plt.subplots(1, 3, gridspec_kw={'width_ratios': [main_ratio_x_component, 1, 1]}, figsize=(margin+main_ratio_x_component+2*(1+wspace*wspace_fig_size_scalar), main_ratio_y_component))
		fig.subplots_adjust(hspace=hspace, wspace=wspace)  # adjust space between axes

		main_ax = axs[0]
		violin_ax = axs[1]
		violin2_ax = axs[2]

	elif ('split_right'  not in option or  option['split_right']  != True) and \
	     ('triple_right'     in option and option['triple_right'] == True) :
		# 4 subfigures
		fig, axs = plt.subplots(1, 4, gridspec_kw={'width_ratios': [main_ratio_x_component, 1, 1, 1]}, figsize=(margin+main_ratio_x_component+3*(1+wspace*wspace_fig_size_scalar), main_ratio_y_component))
		fig.subplots_adjust(hspace=hspace, wspace=wspace)  # adjust space between axes

		main_ax = axs[0]
		violin_ax = axs[1]
		violin2_ax = axs[2]
		violin3_ax = axs[3]

	elif ('split_right'      in option and option['split_right']  == True) and \
	     ('double_right' not in option or  option['double_right'] != True) and \
	     ('triple_right' not in option or  option['triple_right'] != True) :
		# 4 subfigures


		fig, axs = plt.subplots(2, 2, gridspec_kw={'width_ratios': [main_ratio_x_component, 1], 'height_ratios': height_ratios}, figsize=(margin+main_ratio_x_component+1*(1+wspace*wspace_fig_size_scalar), main_ratio_y_component*top_ratio_y_scalar))
		fig.subplots_adjust(hspace=hspace, wspace=wspace)  # adjust space between axes

		axs[0,0].axis('off')
		main_ax = axs[1,0]
		violin_ax = axs[1,1]
		violin_ax_top = axs[0,1]

	elif ('split_right'  in option and option['split_right']  == True) and \
	     ('double_right' in option and option['double_right'] == True) :
		# 6 subfigures
		height_ratios = [1, 8]
		if 'height_ratios' in option :
			height_ratios = option['height_ratios']

		fig, axs = plt.subplots(2, 3, gridspec_kw={'width_ratios': [main_ratio_x_component, 1, 1], 'height_ratios': height_ratios}, figsize=(margin+main_ratio_x_component+2*(1+wspace*wspace_fig_size_scalar), main_ratio_y_component*top_ratio_y_scalar))
		fig.subplots_adjust(hspace=hspace, wspace=wspace)  # adjust space between axes

		axs[0,0].axis('off')
		main_ax = axs[1,0]
		violin_ax = axs[1,1]
		violin_ax_top = axs[0,1]
		violin2_ax = axs[1,2]
		violin2_ax_top = axs[0,2]
	

	elif ('split_right'  in option and option['split_right']  == True) and \
	     ('triple_right' in option and option['triple_right'] == True) :
		# 6 subfigures
		height_ratios = [1, 8]
		if 'height_ratios' in option :
			height_ratios = option['height_ratios']

		fig, axs = plt.subplots(2, 4, gridspec_kw={'width_ratios': [main_ratio_x_component, 1, 1, 1], 'height_ratios': height_ratios}, figsize=(margin+main_ratio_x_component+3*(1+wspace*wspace_fig_size_scalar), main_ratio_y_component*top_ratio_y_scalar))
		fig.subplots_adjust(hspace=hspace, wspace=wspace)  # adjust space between axes

		axs[0,0].axis('off')
		main_ax = axs[1,0]
		violin_ax = axs[1,1]
		violin_ax_top = axs[0,1]
		violin2_ax = axs[1,2]
		violin2_ax_top = axs[0,2]
		violin3_ax = axs[1,3]
		violin3_ax_top = axs[0,3]

	# draw slides between the break
	if violin_ax_top != None :
		violin_ax_top.spines.bottom.set_visible(False)
		violin_ax.spines.top.set_visible(False)

		violin_ax_top.xaxis.tick_top()
		violin_ax_top.tick_params(labeltop=False)  # don't put tick labels at the top
		violin_ax_top.tick_params(labelbottom=False)  # don't put tick labels at the top
		violin_ax.tick_params(labeltop=False)  # don't put tick labels at the top
		violin_ax.tick_params(labelbottom=False)  # don't put tick labels at the top

		d = .5  # proportion of vertical to horizontal extent of the slanted line
		kwargs = dict(marker=[(-1, -d), (1, d)], markersize=12,
		              linestyle="none", color='k', mec='k', mew=1, clip_on=False)
		violin_ax_top.plot([0, 1, 0.5], [0, 0, 0], transform=violin_ax_top.transAxes, **kwargs)
		violin_ax.plot(    [0, 1, 0.5], [1, 1, 1], transform=    violin_ax.transAxes, **kwargs)

	if violin2_ax_top != None :
		violin2_ax_top.spines.bottom.set_visible(False)
		violin2_ax.spines.top.set_visible(False)

		violin2_ax_top.xaxis.tick_top()
		violin2_ax_top.xaxis.tick_top()
		violin2_ax_top.tick_params(labeltop=False)  # don't put tick labels at the top
		violin2_ax_top.tick_params(labelbottom=False)  # don't put tick labels at the top
		violin2_ax.tick_params(labeltop=False)  # don't put tick labels at the top
		violin2_ax.tick_params(labelbottom=False)  # don't put tick labels at the top
		violin2_ax.xaxis.tick_bottom()

		d = .5  # proportion of vertical to horizontal extent of the slanted line
		kwargs = dict(marker=[(-1, -d), (1, d)], markersize=12,
		              linestyle="none", color='k', mec='k', mew=1, clip_on=False)
		violin2_ax_top.plot([0, 1, 0.5], [0, 0, 0], transform=violin2_ax_top.transAxes, **kwargs)
		violin2_ax.plot(    [0, 1, 0.5], [1, 1, 1], transform=    violin2_ax.transAxes, **kwargs)
	
	if violin3_ax_top != None :
		violin3_ax_top.spines.bottom.set_visible(False)
		violin3_ax.spines.top.set_visible(False)

		violin3_ax_top.xaxis.tick_top()
		violin3_ax_top.xaxis.tick_top()
		violin3_ax_top.tick_params(labeltop=False)  # don't put tick labels at the top
		violin3_ax_top.tick_params(labelbottom=False)  # don't put tick labels at the top
		violin3_ax.tick_params(labeltop=False)  # don't put tick labels at the top
		violin3_ax.tick_params(labelbottom=False)  # don't put tick labels at the top
		violin3_ax.xaxis.tick_bottom()

		d = .5  # proportion of vertical to horizontal extent of the slanted line
		kwargs = dict(marker=[(-1, -d), (1, d)], markersize=12,
		              linestyle="none", color='k', mec='k', mew=1, clip_on=False)
		violin3_ax_top.plot([0, 1, 0.5], [0, 0, 0], transform=violin3_ax_top.transAxes, **kwargs)
		violin3_ax.plot(    [0, 1, 0.5], [1, 1, 1], transform=    violin3_ax.transAxes, **kwargs)

	# set main lim
	main_ax.set_ylim(option['main_ax_lim'])
	if violin_ax != None :
		violin_ax.set_ylim(option['main_ax_lim'])
	if violin2_ax != None:
		violin2_ax.set_ylim(option['main_ax_lim'])
	if violin3_ax != None:
		violin3_ax.set_ylim(option['main_ax_lim'])

	plt.rcParams["font.family"] = "Arial"
	label_font = "Arial Black"
	main_ax.set_xlabel('Time (s)', fontname=label_font, )
	main_ax.set_ylabel('Error $E$ (m)', fontname=label_font)
	# rotate ticks
	main_ax.set_yticklabels(main_ax.get_yticks(), rotation = 45)
	# set ticks size
	tick_label_size = 8
	main_ax.yaxis.set_tick_params(labelsize=tick_label_size)
	main_ax.xaxis.set_tick_params(labelsize=tick_label_size)
	# set digits after .
	main_ax.yaxis.set_major_formatter(FormatStrFormatter('%.2f'))
	# set right x lim and tick
	if violin_ax != None :
		violin_ax.set_ylabel('Error $E$ (m)', fontname=label_font)
		violin_ax.set_xlabel('All trials', fontname=label_font)
		violin_ax.set_xlim([0.7, 1.3])
		violin_ax.set_xticks([1])
		#violin_ax.set_yticks([])
		violin_ax.set_yticklabels(main_ax.get_yticks(), rotation = 45)
		violin_ax.yaxis.set_tick_params(labelsize=tick_label_size)
		violin_ax.yaxis.set_major_formatter(FormatStrFormatter('%.2f'))
	if violin2_ax != None :
		violin2_ax.set_ylabel('Error $E$ (m)', fontname=label_font)
		violin2_ax.set_xlabel('All trials', fontname=label_font)
		violin2_ax.set_xlim([0.7, 1.3])
		violin2_ax.set_xticks([1])
		#violin2_ax.set_yticks([])
		violin2_ax.set_yticklabels(main_ax.get_yticks(), rotation = 45)
		violin2_ax.yaxis.set_tick_params(labelsize=tick_label_size)
		violin2_ax.yaxis.set_major_formatter(FormatStrFormatter('%.2f'))
	if violin3_ax != None :
		violin3_ax.set_ylabel('Error $E$ (m)', fontname=label_font)
		violin3_ax.set_xlabel('All trials', fontname=label_font)
		violin3_ax.set_xlim([0.7, 1.3])
		violin3_ax.set_xticks([1])
		#violin3_ax.set_yticks([])
		violin3_ax.set_yticklabels(main_ax.get_yticks(), rotation = 45)
		violin3_ax.yaxis.set_tick_params(labelsize=tick_label_size)
		violin3_ax.yaxis.set_major_formatter(FormatStrFormatter('%.2f'))
	if violin_ax_top != None :
		violin_ax_top.set_xlim([0.7, 1.3])
		violin_ax_top.set_xticks([])
		violin_ax_top.set_yticks([])
		#violin_ax_top.set_yticklabels(violin_ax_top.get_yticks(), rotation = 45) # do this later after setmaxvalue
		violin_ax_top.yaxis.set_tick_params(labelsize=tick_label_size)
		#violin_ax_top.yaxis.set_major_formatter(FormatStrFormatter('%.2f')) # do this later after set maxvalue
	if violin2_ax_top != None :
		violin2_ax_top.set_xlim([0.7, 1.3])
		violin2_ax_top.set_xticks([])
		violin2_ax_top.set_yticks([])
		violin2_ax_top.yaxis.set_tick_params(labelsize=tick_label_size)
	if violin3_ax_top != None :
		violin3_ax_top.set_xlim([0.7, 1.3])
		violin3_ax_top.set_xticks([])
		violin3_ax_top.set_yticks([])
		violin3_ax_top.yaxis.set_tick_params(labelsize=tick_label_size)

	# set top lim
	if violin_ax_top != None:
		violin_ax_top.set_ylim(option['violin_ax_top_lim'])
		violin_ax_top.yaxis.set_ticks([])
	if violin2_ax_top != None:
		violin2_ax_top.set_ylim(option['violin_ax_top_lim'])
		violin2_ax_top.yaxis.set_ticks([])
	if violin3_ax_top != None:
		violin3_ax_top.set_ylim(option['violin_ax_top_lim'])
		violin3_ax_top.yaxis.set_ticks([])


	#-------------------------------------------------------------------------
	# read one case and shade fill each robot data
	robotsData = []
	cutTo = None
	cutTo2 = None
	cutTo3 = None
	if 'cutTo' in option :
		cutTo = option['cutTo']
	#for subFolder in getSubfolders(dataFolder) :
	#	X, sparseData = sparceDataEveryXSteps(readDataFrom(subFolder + "result_data.txt", cutTo), 5)
	#	drawDataInSubplot(sparseData, main_ax)
	for subFolder in getSubfolders(dataFolder) :
		#drawDataInSubplot(readDataFrom(subFolder + "result_data.txt", cutTo), main_ax)
		#drawDataInSubplot(readDataFrom(subFolder + "result_lowerbound_data.txt", cutTo), main_ax)
		# choose a folder
		if 'sample_run' in option and subFolder != dataFolder + "/" + option['sample_run'] + "/" :
			continue
		# draw new lowerbound as pink
		X, sparseLowerbound = sparceDataEveryXSteps(readDataFrom(subFolder + "result_lowerbound_data.txt", cutTo), 5)
		#drawDataWithXInSubplot(X, sparseLowerbound, axs[0], 'hotpink')
		legend_handle_lowerbound, = drawDataInSubplot(sparseLowerbound, main_ax, 'hotpink')

		for subFile in getSubfiles(subFolder + "result_each_robot_error") :
			robotsData.append(readDataFrom(subFile, cutTo))
			#drawDataInSubplot(readDataFrom(subFile, cutTo), main_ax)

		# check switch time
		legend_handle_black_line = None
		if os.path.isfile(subFolder + "formationSwitch.txt") :
			switchSteps = readDataFrom(subFolder + "formationSwitch.txt")
			switchTime = []
			for data in switchSteps :
				switchTime.append(data/5)

			# draw vertical line for switch
			for data in switchTime :
				legend_handle_black_line = main_ax.axvline(x = data, color="black", linestyle=":")
		
		# check failure time
		legend_handle_red_line = None
		if os.path.isfile(subFolder + "failure_step.txt") :
			failure_step = readDataFrom(subFolder + "failure_step.txt")[0]
			if os.path.isfile(subFolder + "saveStartStep.txt") :
				failure_step = failure_step - readDataFrom(subFolder + "saveStartStep.txt")[0] + 1
			failure_time = failure_step / 5
			legend_handle_red_line = main_ax.axvline(x = failure_time, color="red", linestyle=":")

		break

	#drawData(readDataFrom("result_data.txt", cutTo))
	boxdata, positions = transferTimeDataToBoxData(robotsData, None, 5)
	X=[]
	for i in range(0, len(positions)) :
		X.append(i)

	mean = []
	upper = []
	lower = []
	mini = []
	maxi = []
	mask_min = 0

	failurePlaceHolder = None
	if 'failure_place_holder' in option :
		failurePlaceHolder = option['failure_place_holder']

	for stepData in boxdata :
		# filter failure robot data
		if failurePlaceHolder != None :
			while failurePlaceHolder in stepData :
				stepData.remove(failurePlaceHolder)

		meanvalue = statistics.mean(stepData)
		stdev = statistics.stdev(stepData)

		# scipy.mean is deprecated
		#meanvalue = scipy.mean(stepData)
		#stdev = stats.tstd(stepData)

		minvalue = min(stepData)
		maxvalue = max(stepData)
		mean.append(meanvalue)
		count = len(stepData)
		interval95 = 1.96 * stdev / math.sqrt(count)
		#interval999 = 3.291 * stdev / math.sqrt(count)
		interval99999 = 4.417 * stdev / math.sqrt(count)

		'''
		upper.append(meanvalue + interval95)
		lower.append(meanvalue - interval95)
		mini.append(meanvalue - interval99999)
		maxi.append(meanvalue + interval99999)
		'''
		if meanvalue + interval95 >= mask_min :
			upper.append(meanvalue + interval95)
		else :
			upper.append(mask_min)

		if meanvalue - interval95 >= mask_min :
			lower.append(meanvalue - interval95)
		else :
			lower.append(mask_min)

		if meanvalue - interval99999 >= mask_min :
			mini.append(meanvalue - interval99999)
		else :
			mini.append(mask_min)

		if meanvalue + interval99999 >= mask_min :
			maxi.append(meanvalue + interval99999)
		else :
			maxi.append(mask_min)

	#drawDataWithXInSubplot(positions, mean, axs[0], 'royalblue')
	#drawDataWithXInSubplot(X, mean, main_ax, 'royalblue')
	legend_handle_mean, = drawDataWithXInSubplot(X, mean, main_ax, 'b')
	legend_handle_minmax = main_ax.fill_between(
	    #positions, mini, maxi, color='b', alpha=.10)
	    X, mini, maxi, color='b', alpha=.10)
	legend_handle_lowerupper = main_ax.fill_between(
	    #positions, lower, upper, color='b', alpha=.30)
	    X, lower, upper, color='b', alpha=.30)

	legend_handles = [legend_handle_mean,
	                  legend_handle_lowerupper,
	                  legend_handle_minmax,
	                  legend_handle_lowerbound]
	legend_labels = ['mean',
	                 '95% CI',
	                 '99.999% CI',
	                 'lower bound $B$']
	legend_columns = 1
	if legend_handle_black_line != None : 
		legend_handles.append(legend_handle_black_line)
		legend_labels.append('SoNS target change')
		legend_columns = 2
	if legend_handle_red_line != None : 
		legend_handles.append(legend_handle_red_line)
		legend_labels.append('robots failure')

	main_ax.legend(legend_handles, 
	               legend_labels,
	    loc="upper right",
	    fontsize="xx-small",
	    #fontsize="small",
		ncol=legend_columns
	)

	# if no violin
	if 'no_violin' in option and option['no_violin'] == True :
		#-------------------------------------------------------------------------
		# save or show plot
		if 'SRFig_save' in option :
			plt.savefig(option['SRFig_save'])
		if 'SRFig_show' in option and option['SRFig_show'] == True :
			plt.show()
		return 

	#-------------------------------------------------------------------------
	# read all each robot data and make it a total box/violin plot
	if "triple_right_dataFolder1" in option :
		dataFolder = option['triple_right_dataFolder1']

	if 'cutTo2' in option :
		cutTo2 = option['cutTo2']
	if 'cutTo3' in option :
		cutTo3 = option['cutTo3']

	boxdata = []
	''' # read each robot data
	for subFolder in getSubfolders(dataFolder) :
		for subFile in getSubfiles(subFolder + "result_each_robot_error") :
			boxdata = boxdata + readDataFrom(subFile, cutTo)
	'''

	# read mean data and lowerbound, and subtrack
	for subFolder in getSubfolders(dataFolder) :
		mean_data = readDataFrom(subFolder + "result_data.txt", cutTo)
		#lowerbound_data = readDataFrom(subFolder + "result_new_lowerbound_data.txt", cutTo)
		lowerbound_data = readDataFrom(subFolder + "result_lowerbound_data.txt", cutTo)
		data_to_show = subtractLists(mean_data, lowerbound_data)
		boxdata = boxdata + data_to_show

	violin_return_1 = violin_ax.violinplot(boxdata, showmeans=True)
	violin_returns = [violin_return_1]
	if violin_ax_top != None :
		violin_return_2 = violin_ax_top.violinplot(boxdata, showmeans=True)
		violin_returns.append(violin_return_2)
	
	if "boxPlotValue_save" in option :
		logBoxDataValues(boxdata, option["boxPlotValue_save"])
	
	boxdata2 = None
	if violin2_ax != None and \
	  ('double_right_dataFolder' in option or \
	   'triple_right_dataFolder2' in option):
		double_right_dataFolder = None
		if 'double_right_dataFolder' in option:
			double_right_dataFolder = option['double_right_dataFolder']
		elif 'triple_right_dataFolder2' in option:
			double_right_dataFolder = option['triple_right_dataFolder2']

		boxdata2 = []
		'''
		for subFolder in getSubfolders(double_right_dataFolder) :
			for subFile in getSubfiles(subFolder + "result_each_robot_error") :
				boxdata2 = boxdata2 + readDataFrom(subFile, cutTo2)
		'''
		# read mean data and lowerbound, and subtrack
		for subFolder in getSubfolders(double_right_dataFolder) :
			mean_data = readDataFrom(subFolder + "result_data.txt", cutTo2)
			#lowerbound_data = readDataFrom(subFolder + "result_new_lowerbound_data.txt", cutTo2)
			lowerbound_data = readDataFrom(subFolder + "result_lowerbound_data.txt", cutTo2)
			data_to_show = subtractLists(mean_data, lowerbound_data)
			boxdata2 = boxdata2 + data_to_show


		violin_return_3 = violin2_ax.violinplot(boxdata2, showmeans=True)
		violin_returns.append(violin_return_3)
		if violin2_ax_top != None :
			violin_return_4 = violin2_ax_top.violinplot(boxdata2, showmeans=True)
			violin_returns.append(violin_return_4)

		if "boxPlotValue_doubleRight_save" in option :
			logBoxDataValues(boxdata2, option["boxPlotValue_doubleRight_save"])
	
	boxdata3 = None
	if violin3_ax != None and 'triple_right_dataFolder3' in option :
		dataFolder3 = option['triple_right_dataFolder3']

		boxdata3 = []
		'''
		for subFolder in getSubfolders(dataFolder3) :
			for subFile in getSubfiles(subFolder + "result_each_robot_error") :
				boxdata3 = boxdata3 + readDataFrom(subFile, cutTo3)
		'''
		# read mean data and lowerbound, and subtrack
		for subFolder in getSubfolders(dataFolder3) :
			mean_data = readDataFrom(subFolder + "result_data.txt", cutTo3)
			#lowerbound_data = readDataFrom(subFolder + "result_new_lowerbound_data.txt", cutTo3)
			lowerbound_data = readDataFrom(subFolder + "result_lowerbound_data.txt", cutTo3)
			data_to_show = subtractLists(mean_data, lowerbound_data)
			boxdata3 = boxdata3 + data_to_show

		violin_return_5 = violin3_ax.violinplot(boxdata3, showmeans=True)
		violin_returns.append(violin_return_5)
		if violin3_ax_top != None :
			violin_return_6 = violin3_ax_top.violinplot(boxdata3, showmeans=True)
			violin_returns.append(violin_return_6)

		if "boxPlotValue_tripleRight_save" in option :
			logBoxDataValues(boxdata3, option["boxPlotValue_tripleRight_save"])
		
	# set font and style for violin plot (both top and bottom if existed)
	for violin in violin_returns :
		for line in [violin['cbars'], violin['cmins'], violin['cmeans'], violin['cmaxes']] :
			line.set_linewidth(1.2) # used to be 1.5
		for line in [violin['cbars'], violin['cmins'], violin['cmaxes']] :
			line.set_facecolor('grey')
			line.set_edgecolor('grey')
		for line in [violin['cmeans']] :
			line.set_facecolor('b')
			line.set_edgecolor('b')
		for pc in violin['bodies']:
			#pc.set_facecolor('royalblue')
			#pc.set_edgecolor('royalblue')
			pc.set_facecolor('b')
			pc.set_edgecolor('b')

	# set right top tick as the max value of the boxdata
	if violin_ax_top != None :
		#maxvalue = round(max(boxdata), 1)
		maxvalue = max(boxdata)
		violin_ax_top.yaxis.set_ticks([maxvalue])
		violin_ax_top.set_yticklabels(violin_ax_top.get_yticks(), rotation = 45)
		violin_ax_top.yaxis.set_major_formatter(FormatStrFormatter('%.2f'))

	if violin2_ax_top != None :
		#maxvalue = round(max(boxdata2), 1)
		maxvalue = max(boxdata2)
		violin2_ax_top.yaxis.set_ticks([maxvalue])
		violin2_ax_top.set_yticklabels(violin_ax_top.get_yticks(), rotation = 45)
		violin2_ax_top.yaxis.set_major_formatter(FormatStrFormatter('%.2f'))

	if violin3_ax_top != None :
		#maxvalue = round(max(boxdata2), 1)
		maxvalue = max(boxdata3)
		violin3_ax_top.yaxis.set_ticks([maxvalue])
		violin3_ax_top.set_yticklabels(violin_ax_top.get_yticks(), rotation = 45)
		violin3_ax_top.yaxis.set_major_formatter(FormatStrFormatter('%.2f'))

	#-------------------------------------------------------------------------
	# save or show plot
	if 'SRFig_save' in option :
		plt.savefig(option['SRFig_save'])
	if 'SRFig_show' in option and option['SRFig_show'] == True :
		plt.show()

def logBoxDataValues(boxdata, filename) :
	f = open(filename, "w")

	meanvalue = statistics.mean(boxdata)
	stdev = statistics.stdev(boxdata)

	minvalue = min(boxdata)
	maxvalue = max(boxdata)
	count = len(boxdata)
	interval95 = 1.96 * stdev / math.sqrt(count)
	#interval999 = 3.291 * stdev / math.sqrt(count)
	interval99999 = 4.417 * stdev / math.sqrt(count)

	f.write("meanvalue = {}\n".format(meanvalue))
	f.write("stdev     = {}\n".format(stdev))
	f.write("minvalue  = {}\n".format(minvalue))
	f.write("maxvalue  = {}\n".format(maxvalue))
	f.write("confidence interval 95%     = {}, {}\n".format(meanvalue - interval95, meanvalue + interval95))
	f.write("confidence interval 99.999% = {}, {}\n".format(meanvalue - interval99999, meanvalue + interval99999))

	f.close()
