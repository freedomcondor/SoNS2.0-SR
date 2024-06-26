package.path = package.path .. ";@CMAKE_SOURCE_DIR@/scripts/logReader/?.lua"
package.path = package.path .. ";@CMAKE_SOURCE_DIR@/core/utils/?.lua"
package.path = package.path .. ";@CMAKE_CURRENT_BINARY_DIR@/../simu/?.lua"
--package.path = package.path .. ";@CMAKE_SoNS_DATA_PATH@/src/experiments/exp_0_hw_07_fault_tolerance/data_hw/data/test_20220712_6_success_5/hw/?.lua"

logger = require("Logger")
logReader = require("logReader")
logger.enable()

local hardware_flag = false
local params = {...}
if params[1] == "hardware" then
	hardware_flag = true
	print("set hardware flag")
end

--------------------------------------------------------------
function fixData(robotsData)
	local drone2Data = robotsData["drone2"]
	local drone3Data = robotsData["drone3"]

	local wrongDroneData = nil
	local wrongDroneName = nil
	local wrongStepStart = nil
	local wrongStepEnd = nil

	for step, drone2StepData in ipairs(drone2Data) do
		local drone3StepData = drone3Data[step]
		if (drone2StepData.positionV3 - drone3StepData.positionV3):len() < 0.3 then
			if wrongStepStart == nil then
				if (drone2Data[step-1].positionV3 - drone2Data[step].positionV3):len() > 0.3 then
					wrongDroneData = drone2Data
					wrongDroneName = "drone2"
				else
					wrongDroneData = drone3Data
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

local structure1 = require("morphology1")
local structure2 = require("morphology2")
local structure3 = require("morphology3")
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

local hardware_flag = false
local params = {...}
if params[1] == "hardware" then
	hardware_flag = true
	print("set hardware flag")
end

-- read failure step
local failure_step = 500
local f = io.open("failure_step.txt", "r")
if f ~= nil then
	local string
	for l in f:lines() do
		string = l
	end
	failure_step = tonumber(string)
end

-- read first step
local saveStartStep = logReader.getStartStep(robotsData)

local stage2Step = logReader.checkIDFirstAppearStep(robotsData, structure2.idN)
local structure2Step = stage2Step
local stage3Step = failure_step
if stage2Step > failure_step then
	stage3Step = stage2Step
	stage2Step = failure_step
end

local stage4Step = logReader.checkIDFirstAppearStep(robotsData, structure3.idN, stage3Step)
local stage5Step = logReader.checkIDLastDisAppearStep(robotsData, structure1.idN)

print("stage2 start at", stage2Step)
print("stage3 start at", stage3Step)
print("stage4 start at", stage4Step)
print("stage5 start at", stage5Step)

-- Start calc
logReader.calcSegmentDataWithFailureCheck(robotsData, geneIndex, saveStartStep, stage2Step - 1)
logReader.calcSegmentDataWithFailureCheck(robotsData, geneIndex, stage2Step, stage3Step - 1)
logReader.calcSegmentDataWithFailureCheck(robotsData, geneIndex, stage3Step, stage4Step - 1)
logReader.calcSegmentDataWithFailureCheck(robotsData, geneIndex, stage4Step, stage5Step - 1)
logReader.calcSegmentDataWithFailureCheck(robotsData, geneIndex, stage5Step, nil)

lowerBoundParameters = {
	time_period = 0.2,
	default_speed = 0.1,
	slowdown_dis = 0.1,
	stop_dis = 0.01,
}

logReader.calcSegmentLowerBound(robotsData, geneIndex, lowerBoundParameters, saveStartStep, structure2Step - 1)

logReader.calcSegmentLowerBound(robotsData, geneIndex, lowerBoundParameters, structure2Step, stage4Step - 1)

logReader.calcSegmentLowerBound(robotsData, geneIndex, lowerBoundParameters, stage4Step, stage5Step - 1)

logReader.calcSegmentLowerBound(robotsData, geneIndex, lowerBoundParameters, stage5Step, nil)

logReader.calcSegmentLowerBoundErrorInc(robotsData, geneIndex, saveStartStep)

-- see if two drones both failed
local failedDroneNumber = 0
for robotName, robotData in pairs(robotsData) do
	if robotData[stage4Step].failed == true then
		local robotTypeS, number = string.match(robotName, "(%a+)(%d+)")
		if robotTypeS == "drone" then
			failedDroneNumber = failedDroneNumber + 1
		end
	end
end

-- if two drone failed, make and endStep at the failure step for data saving,
-- re-calc lowerbound to make lowerbound 0 at the failure step
local endStep = nil
if failedDroneNumber == 2 then
	endStep = failure_step + 1
	logReader.calcSegmentLowerBound(robotsData, geneIndex, lowerBoundParameters, saveStartStep, stage2Step - 1)
	logReader.calcSegmentLowerBound(robotsData, geneIndex, lowerBoundParameters, stage2Step, stage3Step - 1)
	logReader.calcSegmentLowerBound(robotsData, geneIndex, lowerBoundParameters, stage3Step, stage4Step - 1)
end

os.execute("echo " .. saveStartStep.. " > saveStartStep.txt")

os.execute("echo " .. tostring(structure2Step - saveStartStep) .. " > formationSwitch.txt")

if failedDroneNumber ~= 2 then
	os.execute("echo " .. tostring(stage4Step - saveStartStep) .. " >> formationSwitch.txt")
	os.execute("echo " .. tostring(stage5Step - saveStartStep) .. " >> formationSwitch.txt")
end



logReader.saveData(robotsData, "result_data.txt", "error", saveStartStep, endStep)
logReader.saveData(robotsData, "result_lowerbound_data.txt", "lowerBoundError", saveStartStep, endStep)
logReader.saveData(robotsData, "result_lowerbound_inc_data.txt", "lowerBoundInc", saveStartStep, endStep)
logReader.saveEachRobotDataWithFailurePlaceHolder(robotsData, "result_each_robot_error_data", "error", "-1", saveStartStep, endStep)
logReader.saveEachRobotData(robotsData, "result_each_robot_lowerbound_data", "lowerBoundError", saveStartStep, endStep)
logReader.saveEachRobotData(robotsData, "result_each_robot_lowerbound_inc_data", "lowerBoundInc", saveStartStep, endStep)

logReader.saveSoNSNumber(robotsData, "result_SoNSNumber_data.txt", saveStartStep, endStep)
logReader.saveFailedRobot(robotsData, "failure_robots.txt")