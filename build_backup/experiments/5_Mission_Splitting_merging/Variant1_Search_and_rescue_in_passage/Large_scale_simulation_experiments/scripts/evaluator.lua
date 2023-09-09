package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/logReader/?.lua"
package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/src/core/utils/?.lua"
package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/5_Mission_Splitting_merging/Variant1_Search_and_rescue_in_passage/Large_scale_simulation_experiments/scripts/../simu/?.lua"

logger = require("Logger")
logReader = require("logReader")
logger.enable()

require("morphologiesGenerator")
--require("morphologiesGenerator_debug")
local structure1 = create_main_morphology()
local structure2 = create_ranger_morphology()
local gene = {
	robotTypeS = "drone",
	positionV3 = vector3(),
	orientationQ = quaternion(),
	children = {
		structure1, 
		structure2, 
	}
}

local geneIndex = logReader.calcMorphID(gene)

local robotsData = logReader.loadData("./logs")

local firstRecruitStep = logReader.calcFirstRecruitStep(robotsData)
local saveStartStep = firstRecruitStep + 10
print("firstRecruit happens", firstRecruitStep, "data start at", saveStartStep)

logReader.calcSegmentData(robotsData, geneIndex)

lowerBoundParameters = {
	time_period = 0.2,
	default_speed = 0.1,
	slowdown_dis = 0.1,
	stop_dis = 0.01,
}

logReader.calcSegmentLowerBound(robotsData, geneIndex, lowerBoundParameters)
logReader.calcSegmentLowerBound(robotsData, geneIndex, lowerBoundParameters, saveStartStep)
logReader.calcSegmentLowerBoundErrorInc(robotsData, geneIndex)

logReader.saveData(robotsData, "result_data.txt", "error", saveStartStep)
logReader.saveData(robotsData, "result_lowerbound_data.txt", "lowerBoundError", saveStartStep)
logReader.saveData(robotsData, "result_lowerbound_inc_data.txt", "lowerBoundInc", saveStartStep)
logReader.saveEachRobotData(robotsData, "result_each_robot_lowerbound_inc_data", "lowerBoundInc", saveStartStep)
logReader.saveEachRobotData(robotsData, "result_each_robot_error", "error", saveStartStep)