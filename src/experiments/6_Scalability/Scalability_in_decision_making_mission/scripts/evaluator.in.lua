package.path = package.path .. ";@CMAKE_SOURCE_DIR@/scripts/logReader/?.lua"
package.path = package.path .. ";@CMAKE_SOURCE_DIR@/core/utils/?.lua"
package.path = package.path .. ";@CMAKE_CURRENT_BINARY_DIR@/../simu/?.lua"

logger = require("Logger")
logReader = require("logReader")

require("morphologiesGenerator")

logger.enable()

local expScale = nil
local params = {...}
if params[1] == "scale_1" then
	expScale = 1
	print("set scale 1")
elseif params[1] == "scale_2" then
	expScale = 2
	print("set scale 2")
elseif params[1] == "scale_3" then
	expScale = 3
	print("set scale 3")
elseif params[1] == "scale_4" then
	expScale = 4
	print("set scale 4")
end

if expScale == nil then
	print("please specify scale by adding \"scale_1\", \"scale_2\", \"scale_3\", or \"scale_4\"")
end

--local expScale = 2
local droneDis = 1.5
local pipuckDis = 0.7
local height = 1.8

local structure1 = create_left_right_line_morphology(expScale, droneDis, pipuckDis, height)
local structure2 = create_back_line_morphology(expScale * 2, droneDis, pipuckDis, height, vector3(), quaternion())
local structure3 = create_left_right_back_line_morphology(expScale, droneDis, pipuckDis, height)

local gene = {
	robotTypeS = "drone",
	positionV3 = vector3(),
	orientationQ = quaternion(),
	children = {
		structure1,
		structure2,
		structure3,
	}
}

local geneIndex = logReader.calcMorphID(gene)

local robotsData = logReader.loadData("./logs")

local saveStartStep = logReader.getStartStep(robotsData)

local stage2Step = logReader.checkIDFirstAppearStep(robotsData, structure2.idN)
local stage3Step = logReader.checkIDFirstAppearStep(robotsData, structure3.idN)

os.execute("echo " .. tostring(stage2Step - saveStartStep) .. " > formationSwitch.txt")
os.execute("echo " .. tostring(stage3Step - saveStartStep) .. " >> formationSwitch.txt")

logReader.calcSegmentData(robotsData, geneIndex, saveStartStep, stage2Step - 1)
logReader.calcSegmentData(robotsData, geneIndex, stage2Step, stage3Step - 1)
logReader.calcSegmentData(robotsData, geneIndex, stage3Step, nil)

------------------------------------------------------------------------
lowerBoundParameters = {
	time_period = 0.2,
	default_speed = 0.1,
	slowdown_dis = 0.1,
	stop_dis = 0.01,
}

logReader.calcSegmentLowerBound(robotsData, geneIndex, lowerBoundParameters, saveStartStep, stage2Step - 1)
logReader.calcSegmentLowerBound(robotsData, geneIndex, lowerBoundParameters, stage2Step, stage3Step - 1)
logReader.calcSegmentLowerBound(robotsData, geneIndex, lowerBoundParameters, stage3Step, nil)

logReader.calcSegmentLowerBoundErrorInc(robotsData, geneIndex, saveStartStep)

logReader.saveData(robotsData, "result_data.txt", "error", saveStartStep)
logReader.saveData(robotsData, "result_lowerbound_data.txt", "lowerBoundError", saveStartStep)
logReader.saveData(robotsData, "result_lowerbound_inc_data.txt", "lowerBoundInc", saveStartStep)
logReader.saveEachRobotData(robotsData, "result_each_robot_error_data", "error", saveStartStep)
logReader.saveEachRobotData(robotsData, "result_each_robot_lowerbound_data", "lowerBoundError", saveStartStep)
logReader.saveEachRobotData(robotsData, "result_each_robot_lowerbound_inc_data", "lowerBoundInc", saveStartStep)