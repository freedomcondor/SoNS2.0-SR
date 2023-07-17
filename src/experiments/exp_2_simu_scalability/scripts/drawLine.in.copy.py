drawDataFileName = "@CMAKE_SOURCE_DIR@/scripts/drawData.py"
#execfile(drawDataFileName)
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

#import statistics
import scipy
from scipy import stats
import math
from brokenaxes import brokenaxes

dataFolder = "@CMAKE_SOURCE_DIR@/../../SoNS2.0-data/src/experiments/exp_2_simu_scalability/data_simu_scale_2/data"

'''
#-------------------------------------------------------------------------
# draw data plain
for subfolder in getSubfolders("@CMAKE_CURRENT_SOURCE_DIR@/../data") :
	data = readDataFrom(subfolder + "result_data.txt")
	if data[1375] > 1.3 :
		print("wrong case", subfolder)
	drawData(data)
'''

# two subfigures
fig, axs = plt.subplots(2, 2, gridspec_kw={'width_ratios': [5, 1], 'height_ratios': [1, 8]})
fig.subplots_adjust(hspace=0.05)  # adjust space between axes
axs[0,0].axis('off')

# scale 2
axs[0,1].set_ylim([9.5, 10.5])
axs[0,1].yaxis.set_ticks([10])
axs[1,0].set_ylim([-0.5, 7.5])
axs[1,1].set_ylim([-0.5, 7.5])

# draw slides between the break
axs[0,1].spines.bottom.set_visible(False)
axs[1,1].spines.top.set_visible(False)
axs[0,1].xaxis.tick_top()
axs[0,1].tick_params(labeltop=False)  # don't put tick labels at the top
axs[0,1].tick_params(labelbottom=False)  # don't put tick labels at the top
#ax2.xaxis.tick_bottom()
d = .5  # proportion of vertical to horizontal extent of the slanted line
kwargs = dict(marker=[(-1, -d), (1, d)], markersize=12,
              linestyle="none", color='k', mec='k', mew=1, clip_on=False)
axs[0,1].plot([0, 1, 0.5], [0, 0, 0], transform=axs[0,1].transAxes, **kwargs)
axs[1,1].plot([0, 1, 0.5], [1, 1, 1], transform=axs[1,1].transAxes, **kwargs)

#-------------------------------------------------------------------------
# read one case and shade fill each robot data
subplot_ax = axs[1,0]
robotsData = []
#for subfolder in getSubfolders("@CMAKE_CURRENT_SOURCE_DIR@/../data") :
for subFolder in getSubfolders(dataFolder) :
	#drawData(readDataFrom(subfolder + "result_data.txt"))
	#drawData(readDataFrom(subfolder + "result_lowerbound_data.txt"))
	# choose a folder
	#if subFolder != dataFolder + "/test_20220621_7_success_2/" :
	#	continue
	# draw lowerbound
	X, sparseLowerbound = sparceDataEveryXSteps(readDataFrom(subFolder + "result_lowerbound_data.txt"), 5)
	#drawDataWithXInSubplot(X, sparseLowerbound, axs[0], 'hotpink')
	drawDataInSubplot(sparseLowerbound, subplot_ax, 'hotpink')
	for subFile in getSubfiles(subFolder + "result_each_robot_error") :
		robotsData.append(readDataFrom(subFile))
		#drawDataInSubplot(readDataFrom(subFile), subplot_ax)

	if os.path.isfile(subFolder + "formationSwitch.txt") :
		switchSteps = readDataFrom(subFolder + "formationSwitch.txt")
		switchTime = []
		for data in switchSteps :
			switchTime.append(data/5)

	break

# draw vertical line for switch
for data in switchTime :
	subplot_ax.axvline(x = data, color="black", linestyle=":")

#drawData(readDataFrom("result_data.txt"))
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
for stepData in boxdata :
	#meanvalue = statistics.mean(stepData)
	#stdev = statistics.stdev(stepData)

	meanvalue = scipy.mean(stepData)
	stdev = stats.tstd(stepData)

	minvalue = min(stepData)
	maxvalue = max(stepData)
	mean.append(meanvalue)
	count = len(stepData)
	interval95 = 1.96 * stdev / math.sqrt(count)
	#interval999 = 3.291 * stdev / math.sqrt(count)
	interval99999 = 4.417 * stdev / math.sqrt(count)

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
	'''

#drawDataWithXInSubplot(positions, mean, axs[0], 'royalblue')
drawDataWithXInSubplot(X, mean, subplot_ax, 'royalblue')
subplot_ax.fill_between(
    #positions, mini, maxi, color='b', alpha=.10)
    X, mini, maxi, color='b', alpha=.10)
subplot_ax.fill_between(
    #positions, lower, upper, color='b', alpha=.30)
    X, lower, upper, color='b', alpha=.30)

#-------------------------------------------------------------------------
# read all each robot data and make it a total box plot

boxdata = []
for subFolder in getSubfolders(dataFolder) :
	for subFile in getSubfiles(subFolder + "result_each_robot_error") :
		boxdata = boxdata + readDataFrom(subFile)

'''
positions = [0,1]
mean = []
upper = []
lower = []
mini = []
maxi = []

meanvalue = scipy.mean(boxdata)
stdev = stats.tstd(boxdata)
count = len(stepData)
interval95 = 1.96 * stdev / math.sqrt(count)
#interval999 = 3.291 * stdev / math.sqrt(count)
interval99999 = 4.417 * stdev / math.sqrt(count)
for i in range(0,2):
	mean.append(meanvalue)
	upper.append(meanvalue + interval95)
	lower.append(meanvalue - interval95)
	mini.append(meanvalue - interval99999)
	maxi.append(meanvalue + interval99999)

drawDataWithXInSubplot(positions, mean, axs[1], 'royalblue')
axs[1].plot([0.5, 0.5], [mini, maxi], color='b', linestyle='-')
axs[1].fill_between(
    positions, mini, maxi, color='b', alpha=.10)
axs[1].fill_between(
    positions, lower, upper, color='b', alpha=.30)

for data in boxdata:
	if data > maxi[0] or data < mini[0] :
		axs[1].plot([0.5], [data], marker='.', color='b')
'''

'''
flierprops = dict(
	marker='.',
	markersize=2,
	linestyle='none'
)

axs[1].boxplot(boxdata, widths=5, flierprops=flierprops)
'''
axs[0,1].violinplot(boxdata)
axs[1,1].violinplot(boxdata)

plt.show()