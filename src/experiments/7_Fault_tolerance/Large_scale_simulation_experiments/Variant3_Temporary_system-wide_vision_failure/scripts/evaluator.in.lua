package.path = package.path .. ";@CMAKE_SOURCE_DIR@/scripts/logReader/?.lua"
package.path = package.path .. ";@CMAKE_SOURCE_DIR@/core/utils/?.lua"
package.path = package.path .. ";@CMAKE_CURRENT_BINARY_DIR@/../simu/?.lua"

logger = require("Logger")
logReader = require("logReader")

logger.enable()

require("morphologiesGenerator")

local droneDis = 1.5
local pipuckDis = 0.7
local height = 1.8
local structure1 = create_left_right_line_morphology(2, droneDis, pipuckDis, height)
local structure2 = create_back_line_morphology(4, droneDis, pipuckDis, height, vector3(), quaternion())
local structure3 = create_left_right_back_line_morphology(2, droneDis, pipuckDis, height)
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

local firstRecruitStep = logReader.calcFirstRecruitStep(robotsData)
local saveStartStep = firstRecruitStep + 15
print("firstRecruit happens", firstRecruitStep, "data start at", saveStartStep)

local stage2Step = logReader.checkIDFirstAppearStep(robotsData, structure2.idN)
local structure2Step = stage2Step
local failureStep = 500 
local stage3Step = failureStep
if stage2Step > failureStep then
	stage3Step = stage2Step
	stage2Step = failureStep
end

local stage4Step = logReader.checkIDFirstAppearStep(robotsData, structure3.idN)

print("stage2 start at", stage2Step)
print("stage3 start at", stage3Step)
print("stage4 start at", stage4Step)

logReader.calcSegmentData(robotsData, geneIndex, saveStartStep, stage2Step - 1)
logReader.calcSegmentData(robotsData, geneIndex, stage2Step, stage3Step - 1)
logReader.calcSegmentData(robotsData, geneIndex, stage3Step, stage4Step - 1)
logReader.calcSegmentData(robotsData, geneIndex, stage4Step, nil)

lowerBoundParameters = {
	time_period = 0.2,
	default_speed = 0.1,
	slowdown_dis = 0.1,
	stop_dis = 0.01,
}

logReader.calcSegmentLowerBound(robotsData, geneIndex, lowerBoundParameters, saveStartStep, structure2Step - 1)
logReader.calcSegmentLowerBound(robotsData, geneIndex, lowerBoundParameters, structure2Step, stage4Step - 1)
logReader.calcSegmentLowerBound(robotsData, geneIndex, lowerBoundParameters, stage4Step, nil)

logReader.calcSegmentLowerBoundErrorInc(robotsData, geneIndex, saveStartStep)

os.execute("echo " .. saveStartStep.. " > saveStartStep.txt")
os.execute("echo " .. failureStep.. " > failure_step.txt")
os.execute("echo " .. tostring(structure2Step - saveStartStep) .. " > formationSwitch.txt")
os.execute("echo " .. tostring(stage4Step - saveStartStep) .. " >> formationSwitch.txt")

logReader.saveData(robotsData, "result_data.txt", "error", saveStartStep)
logReader.saveData(robotsData, "result_lowerbound_data.txt", "lowerBoundError", saveStartStep)
logReader.saveData(robotsData, "result_lowerbound_inc_data.txt", "lowerBoundInc", saveStartStep)
logReader.saveEachRobotDataWithFailurePlaceHolder(robotsData, "result_each_robot_error_data", "error", "0.0", saveStartStep)
logReader.saveEachRobotData(robotsData, "result_each_robot_lowerbound_data", "lowerBound", saveStartStep)
logReader.saveEachRobotData(robotsData, "result_each_robot_lowerbound_inc_data", "lowerBoundInc", saveStartStep)

logReader.saveSoNSNumber(robotsData, "result_SoNSNumber_data.txt", saveStartStep)