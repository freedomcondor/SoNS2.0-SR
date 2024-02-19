package.path = package.path .. ";@CMAKE_SOURCE_DIR@/core/utils/?.lua"
package.path = package.path .. ";@CMAKE_SOURCE_DIR@/scripts/logReader/?.lua"
logger = require("Logger")
logReader = require("logReader")

--------------------------------------
-- Tool functions

-- find all files that ends with data_ext (e.g. .log),
-- assume the file name is robot name,
-- and return a list of robot names
function getDataFileList(dir, data_ext)
	-- ls dir > fileList.txt and read fileList.txt
	-- so that we don't have to depend on lfs to get files in a dir
	os.execute("ls " .. dir .. " > fileList.txt")
	local f = io.open("fileList.txt", "r")
	local robotNameList = {}
	local robotNumber = 0
	for file in f:lines() do 
		-- drone11.log for example
		local name, ext = string.match(file, "([^.]+).([^.]+)")
		-- name = drone11, ext = log
		if ext == data_ext then 
			table.insert(robotNameList, name)
			robotNumber = robotNumber + 1
		end
	end
	io.close(f)
	os.execute("rm fileList.txt")
	return robotNameList, robotNumber
end

-- read a time data file (all the steps of the time data of one robot),
-- return a list of step time of all the time steps
function loadTimeDataInFile(fileName)
	print(fileName)
	local f = io.open(fileName, "r")
	local line_count = 0
	data = {}
	for line in f:lines() do
		line_count = line_count + 1

		numbers = {}
		for numberStr in line:gmatch("%S+") do 
			table.insert(numbers, tonumber(numberStr))
		end
			--[[
			1	timeMeasurePre
			2	ttimeMeasureBT
			3	timeMeasurePost
			4	timeMeasureEnd

			5	timeMeasureCoreConnector
			6	timeMeasureCoreAssigner
			7	timeMeasureCoreScalemanager
			8	timeMeasureCoreStabilizer
			9	timeMeasureCoreAllocator
			10	timeMeasureCoreIntersectiondetector
			11	timeMeasureCoreAvoider
			12	timeMeasureCoreSpreader
			13	timeMeasureCoreBrainkeeper
			--]]
		local numberN = numbers[2]
		              + numbers[3]
		              + numbers[4]
		table.insert(data, numberN)
	end
	io.close(f)
	return data
end

-------------------------------------------------------------
-- input, robotsData = 
	-- {
	--      drone1 = {
	--                  1 = {stepCount, positionV3 ...}
	--                  2 = {stepCount, positionV3 ...}
	--               }
	--      drone2 = { 
	--                  1 = {stepCount, positionV3 ...}
	--                  2 = {stepCount, positionV3 ...}
	--               }
	-- } 
	--
-- output,
	-- {
	--      drone1 = {
	--                  1 = {stepCount, positionV3 ... , time = 0.456}
	--                  2 = {stepCount, positionV3 ... , time = 0.456}
	--               }
	--      drone2 = { 
	--                  1 = {stepCount, positionV3 ... , time = 0.456}
	--                  2 = {stepCount, positionV3 ... , time = 0.456}
	--               }
	-- } 
	--
function loadTimeData(robotsData, dataFolder, fileExt)
	local robotNameList, robotNumber = getDataFileList(dataFolder, fileExt)
	for _, robotName in ipairs(robotNameList) do
		local timeAllSteps = loadTimeDataInFile(dataFolder .. "/" .. robotName .. "." .. fileExt)
		for i, time in ipairs(timeAllSteps) do
			robotsData[robotName][i]["time"] = time
		end
	end
end

-------------------------------------------------------------
-- input, robotsData = 
	-- {
	--      drone1 = {
	--                  1 = {stepCount, positionV3 ...}
	--                  2 = {stepCount, positionV3 ...}
	--               }
	--      drone2 = { 
	--                  1 = {stepCount, positionV3 ...}
	--                  2 = {stepCount, positionV3 ...}
	--               }
	-- } 
	--
-- output,
	-- {
	--      drone1 = {
	--                  1 = {stepCount, positionV3 ... , childrenNumber = 3, parentNumber = 0}
	--                  2 = {stepCount, positionV3 ... , childrenNumber = 5, parentNumber = 1}
	--               }
	--      drone2 = { 
	--                  1 = {stepCount, positionV3 ... , childrenNumber = 3, parentNumber = 0}
	--                  2 = {stepCount, positionV3 ... , childrenNumber = 3, parentNumber = 0}
	--               }
	-- } 
	--
function countChildrenAndParentNumber(robotsData, startStep, endStep)
	-- fill start and end if not provided
	if startStep == nil then startStep = 1 end
	if endStep == nil then 
		endStep = logReader.getEndStep(robotsData)
	end

	-- init counting
	for step = startStep, endStep do
		for robotName, robotData in pairs(robotsData) do
			robotData[step]["childrenNumber"] = 0
			robotData[step]["parentNumber"] = 0
		end
	end
	-- start counting
	for step = startStep, endStep do
		for robotName, robotData in pairs(robotsData) do
			local focalRobotStepData = robotData[step]
			if focalRobotStepData["parentID"] ~= nil then
				focalRobotStepData["parentNumber"] = 1
				local parentRobotStepData = robotsData[focalRobotStepData["parentID"]][step]
				parentRobotStepData["childrenNumber"] = parentRobotStepData["childrenNumber"] + 1
			end
		end
	end
end

------------------------
function saveTimeChildrenParentData(robotsData, saveFile, startStep, endStep)
	-- fill start and end if not provided
	if startStep == nil then startStep = 1 end
	if endStep == nil then 
		endStep = logReader.getEndStep(robotsData)
	end

	-- start save
	local f = io.open(saveFile, "w")
	for step = startStep, endStep do
		for robotName, robotData in pairs(robotsData) do
			f:write(tostring(robotData[step]["parentNumber"]).." ")
			f:write(tostring(robotData[step]["childrenNumber"]).." ")
			f:write(tostring(robotData[step]["time"]).." ")
			f:write(robotName.."\n")
		end
	end
	io.close(f)
	print("save data finish")
end

--------------------------------------------------------------
-- main ------------------------------------------------------

-- load data
local dataFolder = "./logs"
local robotsData = logReader.loadData(dataFolder)
countChildrenAndParentNumber(robotsData)
loadTimeData(robotsData, dataFolder, "time_dat")
--saveTimeChildrenParentData(robotsData, "parent_children_number_time.txt", logReader.getEndStep(robotsData) - 200)
saveTimeChildrenParentData(robotsData, "parent_children_number_time.txt")