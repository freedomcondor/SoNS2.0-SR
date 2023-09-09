package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/logReader/?.lua"
package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/src/core/utils/?.lua"
package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Real_robot_experiments_with_matching_simulations/scripts/../simu/?.lua"

logger = require("Logger")
logReader = require("logReader")
logger.enable()

--------------------------------------------------------------
function fixData(robotsData)
	local drone2Data = robotsData["drone2"]
	local drone4Data = robotsData["drone4"]

	local wrongDroneData = nil
	local wrongDroneName = nil
	local wrongStepStart = nil
	local wrongStepEnd = nil

	for step, drone2StepData in ipairs(drone2Data) do
		local drone3StepData = drone4Data[step]
		if (drone2StepData.positionV3 - drone3StepData.positionV3):len() < 0.3 then
			if wrongStepStart == nil then
				if (drone2Data[step-1].positionV3 - drone2Data[step].positionV3):len() > 0.3 then
					wrongDroneData = drone2Data
					wrongDroneName = "drone2"
				else
					wrongDroneData = drone4Data
					wrongDroneName = "drone3"
				end
				wrongStepStart = step
			end
		else
			if wrongStepStart ~= nil then
				-- calc
				wrongStepEnd = step - 1
				print("fixing wrong segment:", wrongDroneName, wrongStepStart, wrongStepEnd)
				local wrongLength = wrongStepEnd - wrongStepStart + 1

				local baseV3 = wrongDroneData[wrongStepStart - 1].positionV3
				local baseQ = wrongDroneData[wrongStepStart - 1].orientationQ

				local incV3 = (wrongDroneData[wrongStepEnd + 1].positionV3 - wrongDroneData[wrongStepStart - 1].positionV3) / wrongLength
				for i = wrongStepStart, wrongStepEnd do
					wrongDroneData[i].positionV3 = wrongDroneData[i-1].positionV3 + incV3
					wrongDroneData[i].orientationQ = baseQ
					wrongDroneData[i].goalPositionV3 = wrongDroneData[i].positionV3 + wrongDroneData[i].orientationQ:toRotate(wrongDroneData[i].originGoalPositionV3)
					wrongDroneData[i].goalOrientationQ = wrongDroneData[i].orientationQ * wrongDroneData[i].originGoalOrientationQ
					print("    fixing", i, wrongDroneData[i].positionV3)
					print("             ", wrongDroneData[i].positionV3)
				end
				-- clear for next segment
				wrongDroneData = nil
				wrongDroneName = nil
				wrongStepStart = nil
				wrongStepEnd = nil
			end
		end
	end
end
-------------------------------------------------------------------------------

local gene = require("morphology")
local geneIndex = logReader.calcMorphID(gene)

local robotsData = logReader.loadData("./logs")

fixData(robotsData)  -- only for hardware datas

local firstRecruitStep = logReader.calcFirstRecruitStep(robotsData)
local saveStartStep = firstRecruitStep - 10
local saveStartStep = firstRecruitStep + 10 -- for simulation data
print("firstRecruit happens", firstRecruitStep, "data start at", saveStartStep)

logReader.calcSegmentData(robotsData, geneIndex, saveStartStep)

lowerBoundParameters = {
	time_period = 0.2,
	default_speed = 0.1,
	slowdown_dis = 0.1,
	stop_dis = 0.01,
}
logReader.calcSegmentLowerBound(robotsData, geneIndex, lowerBoundParameters, saveStartStep)

logReader.saveData(robotsData, "result_data.txt", "error", saveStartStep)
logReader.saveData(robotsData, "result_lowerbound_data.txt", "lowerBoundError", saveStartStep)
logReader.saveEachRobotData(robotsData, "result_each_robot_lowerbound", "lowerBoundError", saveStartStep)
logReader.saveEachRobotData(robotsData, "result_each_robot_lowerbound_inc_data", "lowerBoundInc", saveStartStep)
logReader.saveEachRobotData(robotsData, "result_each_robot_error", "error", saveStartStep)
