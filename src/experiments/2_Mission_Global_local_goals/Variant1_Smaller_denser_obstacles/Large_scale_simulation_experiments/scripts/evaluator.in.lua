package.path = package.path .. ";@CMAKE_SOURCE_DIR@/scripts/logReader/?.lua"
package.path = package.path .. ";@CMAKE_SOURCE_DIR@/core/utils/?.lua"
package.path = package.path .. ";@CMAKE_CURRENT_BINARY_DIR@/../simu/?.lua"

logger = require("Logger")
logReader = require("logReader")
logger.enable()

local gene = require("morphology")
local geneIndex = logReader.calcMorphID(gene)

local robotsData = logReader.loadData("./logs")

local endStep = logReader.getEndStep(robotsData)

local saveStartStep = logReader.getStartStep(robotsData)

logReader.calcSegmentData(robotsData, geneIndex, 1, 600)
for i = 601, endStep do
	logReader.calcSegmentData(robotsData, geneIndex, i, i)
end

------------------------------------------------
lowerBoundParameters = {
	time_period = 0.2,
	default_speed = 0.1,
	slowdown_dis = 0.1,
	stop_dis = 0.01,
}

logReader.calcSegmentLowerBound(robotsData, geneIndex, lowerBoundParameters, saveStartStep)

logReader.calcSegmentLowerBoundErrorInc(robotsData, geneIndex, saveStartStep)

logReader.saveData(robotsData, "result_data.txt", "error", saveStartStep)
logReader.saveData(robotsData, "result_lowerbound_data.txt", "lowerBoundError", saveStartStep)
logReader.saveData(robotsData, "result_lowerbound_inc_data.txt", "lowerBoundInc", saveStartStep)
logReader.saveEachRobotData(robotsData, "result_each_robot_error_data", "error", saveStartStep)
logReader.saveEachRobotData(robotsData, "result_each_robot_lowerbound_data", "lowerBoundError", saveStartStep)
logReader.saveEachRobotData(robotsData, "result_each_robot_lowerbound_inc_data", "lowerBoundInc", saveStartStep)

logReader.saveSoNSNumber(robotsData, "result_SoNSNumber_data.txt", saveStartStep)