package.path = package.path .. ";@CMAKE_SOURCE_DIR@/scripts/logReader/?.lua"
package.path = package.path .. ";@CMAKE_SOURCE_DIR@/core/utils/?.lua"
package.path = package.path .. ";@CMAKE_CURRENT_BINARY_DIR@/../simu/?.lua"

logger = require("Logger")
logReader = require("logReader")

logger.enable()

------- formation evaluation -----------------------------------------------------------------------
local n_drone = #logReader.getCSVList("./logs", {"drone"})

------- time and comm measure  ------------------------------------------------------------------------------
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
			table.insert(robotNameList, file)
			robotNumber = robotNumber + 1
		end
	end
	io.close(f)
	os.execute("rm fileList.txt")
	return robotNameList, robotNumber
end

-------------------------------------------------------------------
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

function loadTimeDataInFiles(folder, fileNameList)
	timeDatas = {}
	for i, fileName in ipairs(fileNameList) do
		timeDatas[i] = {
			name = fileName,
			data = loadTimeDataInFile(folder .. "/" .. fileName)
		}
	end
	return timeDatas
end

function findMaxTimeForEachStep(timeDatas, step)
	local max = 0
	for i, robotData in ipairs(timeDatas) do
		if robotData.data[step] > max then
			max = robotData.data[step]
		end
	end
	return max
end

function sumMaxTime(folder, fileNameList, from, to)
	local timeDatas = loadTimeDataInFiles(folder, fileNameList)
	local sum = 0
	local count = 0
	for i = from, to do
		sum = sum + findMaxTimeForEachStep(timeDatas, i)
		count = count + 1
	end

	return sum, count
end

function getMaxMaxTime(folder, fileNameList, from, to)
	local timeDatas = loadTimeDataInFiles(folder, fileNameList)
	local max = 0
	for i = from, to do
		local value = findMaxTimeForEachStep(timeDatas, i)
		if max < value then max = value end
	end

	return max
end

---------------------------------------------------------
function sumTimeDataInFile(fileName, from, to)
	print(fileName)
	local f = io.open(fileName, "r")
	local sum = 0
	local count = 0
	local line_count = 0
	for line in f:lines() do
		line_count = line_count + 1
		if (from ~= nil and to ~= nil and 
		   from <= line_count and line_count <= to) or
		   (from == nil and to == nil) then
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
			local numberN = numbers[1] +
			                numbers[2] +
			                numbers[3] +
			                numbers[4]
			sum = sum + numberN
			count = count + 1
		end
	end
	io.close(f)
	return sum, count
end

function sumTimeDataInFiles(folder, fileNameList, from, to)
	local total_sum = 0
	local total_count = 0
	for i, fileName in ipairs(fileNameList) do
		local sum, count = sumTimeDataInFile(folder .. "/" .. fileName, from, to)
		total_sum = total_sum + sum
		total_count = total_count + count
	end
	return total_sum, total_count
end

function getFileLength(file)
	local f = io.open(file, "r")
	local length = 0
	for line in f:lines() do 
		length = length + 1
	end
	io.close(f)
	return length
end

local data_length = getFileLength("result_data.txt")

----- time -----------
local time_file_list, robotNumber = getDataFileList("./logs", "time_dat")
local sum, count = sumMaxTime("./logs", {"drone1.time_dat"}, data_length-500, data_length-200)
local average = sum * 1.0 / count
os.execute("echo " .. tostring(robotNumber) .. " " .. tostring(average) .. " > result_brain_time_data.txt")

local max = getMaxMaxTime("./logs", {"drone1.time_dat"}, 1, data_length-200)
os.execute("echo " .. tostring(robotNumber) .. " " .. tostring(max) .. " > result_brain_max_time_data.txt")

----- comm -----------
function sumDataInFile(fileName, from, to)
	local f = io.open(fileName, "r")
	local sum = 0
	local count = 0
	local line_count = 0
	for line in f:lines() do
		line_count = line_count + 1
		if (from ~= nil and to ~= nil and 
		   from <= line_count and line_count <= to) or
		   (from == nil and to == nil) then
			local number = tonumber(line)
			sum = sum + number
			count = count + 1
		end
	end
	io.close(f)
	return sum, count
end

function sumDataInFiles(folder, fileNameList, from, to)
	local total_sum = 0
	local total_count = 0
	for i, fileName in ipairs(fileNameList) do
		local sum, count = sumDataInFile(folder .. "/" .. fileName, from, to)
		total_sum = total_sum + sum
		total_count = total_count + count
	end
	return total_sum, total_count
end
----------------------------------------------------------------------
function loadCommDataInFile(fileName)
	print(fileName)
	local f = io.open(fileName, "r")
	local line_count = 0
	data = {}
	for line in f:lines() do
		line_count = line_count + 1

		table.insert(data, tonumber(line))
	end
	io.close(f)
	return data
end

function loadCommDataInFiles(folder, fileNameList)
	commDatas = {}
	for i, fileName in ipairs(fileNameList) do
		commDatas[i] = {
			name = fileName,
			data = loadCommDataInFile(folder .. "/" .. fileName)
		}
	end
	return commDatas
end

function findMaxCommForEachStep(commDatas, step)
	local max = 0
	for i, robotData in ipairs(commDatas) do
		if robotData.data[step] > max then
			max = robotData.data[step]
		end
	end
	return max
end

function sumMaxComm(folder, fileNameList, from, to)
	local commDatas = loadCommDataInFiles(folder, fileNameList)
	local sum = 0
	local count = 0
	for i = from, to do
		sum = sum + findMaxCommForEachStep(commDatas, i)
		count = count + 1
	end

	return sum, count
end

function getMaxMaxComm(folder, fileNameList, from, to)
	local commDatas = loadCommDataInFiles(folder, fileNameList)
	local max = 0
	for i = from, to do
		local value = findMaxCommForEachStep(commDatas, i)
		if value > max then max = value end
	end

	return max
end

---------------------------------------------------------------------------------------
local comm_file_list, robotNumber = getDataFileList("./logs", "comm_dat")
--local sum, count = sumDataInFiles("./logs", comm_file_list, 1950, 2000)
local sum, count = sumMaxComm("./logs", {"drone1.comm_dat"}, data_length-500, data_length-200)
local average = sum * 1.0 / count
os.execute("echo " .. tostring(robotNumber) .. " " .. tostring(average) .. " > result_brain_comm_data.txt")

local max = getMaxMaxComm("./logs", {"drone1.comm_dat"}, 1, data_length-200)
os.execute("echo " .. tostring(robotNumber) .. " " .. tostring(max) .. " > result_brain_max_comm_data.txt")
