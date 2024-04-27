logGeneratorFileName = "@CMAKE_SOURCE_DIR@/scripts/logReader/logReplayer.py"
exec(compile(open(logGeneratorFileName, "rb").read(), logGeneratorFileName, 'exec'))
drawDataFileName = "@CMAKE_SOURCE_DIR@/scripts/drawData.py"
exec(compile(open(drawDataFileName, "rb").read(), drawDataFileName, 'exec'))

from matplotlib.gridspec import GridSpec
import statistics

inputFolder = "logs/"
droneFileName = inputFolder + "drone1.log"

#---- read data into positions
positions = []
Xs = []
Ys = []
Zs = []

absXs = []
absYs = []
droneFile = open(droneFileName, "r")
while True :
	stepdata = readNextLine(droneFile, True) 
	if stepdata == None :
		break
	positions.append(stepdata["position"])
	Xs.append(stepdata["position"][0])
	Ys.append(stepdata["position"][1])
	Zs.append(stepdata["position"][2])
	absXs.append(abs(stepdata["position"][0]))
	absYs.append(abs(stepdata["position"][1]))

#---- statistic and replay positions
#  positions = [ [1,2,3], [4,5,6], ...  ]

def setAxParameters(ax):
	ax.set_xlabel("x")
	ax.set_ylabel("y")
	ax.set_zlabel("z")
	ax.set_xlim([-0.2, 0.2])
	ax.set_ylim([-0.2, 0.2])
	ax.set_zlim([-0.8, 1.2])
	ax.view_init(90, -90)

fig = plt.figure()
gs = GridSpec(3, 2, figure=fig)
ax1 = fig.add_subplot(gs[:, 0], projection='3d')
ax2 = fig.add_subplot(gs[0, 1])
ax3 = fig.add_subplot(gs[1, 1])
ax4 = fig.add_subplot(gs[2, 1])

setAxParameters(ax1)

count = 0
lastPoint = [0,0,0]
for position in positions :
	drawVector3(ax1, lastPoint, position, "red", 0.30)
	lastPoint = position
	count = count + 1

drawDataInSubplot(Xs, ax2)
drawDataInSubplot(Ys, ax3)
drawDataInSubplot(Zs, ax4)

print("X: mean  = ", statistics.mean(Xs))
print("   stdev = ", statistics.stdev(Xs))
print("   span  = ", max(Xs) - min(Xs))
print("Y: mean  = ", statistics.mean(Ys))
print("   stdev = ", statistics.stdev(Ys))
print("   span  = ", max(Ys) - min(Ys))

print("mean absX = ", statistics.mean(absXs))
print("mean absY = ", statistics.mean(absYs))

plt.show()
