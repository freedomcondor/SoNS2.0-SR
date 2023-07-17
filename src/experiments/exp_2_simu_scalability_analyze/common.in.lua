local myType = robot.params.my_type

--[[
package.path = package.path .. ";@CMAKE_SOURCE_DIR@/core/api/?.lua"
package.path = package.path .. ";@CMAKE_SOURCE_DIR@/core/utils/?.lua"
package.path = package.path .. ";@CMAKE_SOURCE_DIR@/core/sons/?.lua"
package.path = package.path .. ";@CMAKE_CURRENT_BINARY_DIR@/?.lua"
--]]
if robot.params.hardware ~= "true" then
	package.path = package.path .. ";@CMAKE_CURRENT_BINARY_DIR@/simu/?.lua"
end

-- get scalability scale
local n_drone = tonumber(robot.params.n_drone or 1)
local morphologiesGenerator = robot.params.morphologiesGenerator

pairs = require("AlphaPairs")
ExperimentCommon = require("ExperimentCommon")
require(morphologiesGenerator)
local Transform = require("Transform")

-- includes -------------
logger = require("Logger")
local api = require(myType .. "API")
local SoNS = require("SoNS")
local BT = require("BehaviorTree")
logger.enable()
logger.disable("Allocator")
logger.disable("Stabilizer")
logger.disable("droneAPI")

--logger.enableFileLog()

-- datas ----------------
local bt
--local sons
local droneDis = 1.5
local pipuckDis = 0.7
local height = api.parameters.droneDefaultHeight
local gene = create_back_line_morphology_with_drone_number(n_drone, droneDis, pipuckDis, height)

Message = SoNS.Msg

-- SoNS option
SoNS.Allocator.calcBaseValue = SoNS.Allocator.calcBaseValue_vertical

function SoNS.create_sons_core_node(sons, option)
	-- option = {
	--      connector_no_recruit = true or false or nil,
	--      connector_no_parent_ack = true or false or nil,
	--      specific_name = "drone1"
	--      specific_time = 150
	--          -- If I am stabilizer_preference_robot then ack to only drone1 for 150 steps
	-- }
	if option == nil then option = {} end
	if robot.id == sons.Parameters.stabilizer_preference_robot then
		option.specific_name = sons.Parameters.stabilizer_preference_brain
		option.specific_time = sons.Parameters.stabilizer_preference_brain_time
	end
	return 
	{type = "sequence", children = {
		--sons.create_preconnector_node(sons),
		function()           timeCoreStart = getCurrentTime() return false, true end,	
		sons.Connector.create_connector_node(sons, 
			{	no_recruit = option.connector_no_recruit,
				no_parent_ack = option.connector_no_parent_ack,
				specific_name = option.specific_name,
				specific_time = option.specific_time,
			}),
		function()  timeCoreAfterConnector = getCurrentTime() return false, true end,	
		sons.Assigner.create_assigner_node(sons),
		function()  timeCoreAfterAssigner  = getCurrentTime() return false, true end,	
		sons.ScaleManager.create_scalemanager_node(sons),
		function()  timeCoreAfterScalemanager  = getCurrentTime() return false, true end,	
		sons.Stabilizer.create_stabilizer_node(sons),
		function()  timeCoreAfterStabilizer = getCurrentTime() return false, true end,	
		sons.Allocator.create_allocator_node(sons),
		function()  timeCoreAfterAllocator = getCurrentTime() return false, true end,	
		sons.IntersectionDetector.create_intersectiondetector_node(sons),
		function()  timeCoreAfterIntersectiondetector = getCurrentTime() return false, true end,	
		sons.Avoider.create_avoider_node(sons, {
			drone_pipuck_avoidance = option.drone_pipuck_avoidance
		}),
		function()  timeCoreAfterAvoider = getCurrentTime() return false, true end,	
		sons.Spreader.create_spreader_node(sons),
		function()  timeCoreAfterSpreader = getCurrentTime() return false, true end,	
		sons.BrainKeeper.create_brainkeeper_node(sons),
		function()  timeCoreAfterBrainkeeper = getCurrentTime() return false, true end,	
		--sons.CollectiveSensor.create_collectivesensor_node(sons),
		--sons.Driver.create_driver_node(sons),
	}}
end

local timeMeasureDataFile = "logs/" .. robot.id .. ".time_dat"
local commMeasureDataFile = "logs/" .. robot.id .. ".comm_dat"

-- argos functions -----------------------------------------------
--- init
function init()
	api.linkRobotInterface(SoNS)
	api.init() 
	sons = SoNS.create(myType)
	reset()
	os.execute("rm -f " .. timeMeasureDataFile)
end

--- reset
function reset()
	sons.reset(sons)
	if sons.idS == robot.params.stabilizer_preference_brain then sons.idN = 1 end
	if sons.robotTypeS == "pipuck" then sons.idN = 0 end
	sons.setGene(sons, gene)

	sons.setMorphology(sons, gene)

	bt = BT.create
	{ type = "sequence", children = {
		sons.create_preconnector_node(sons),
		function() timeAfterPre = getCurrentTime() return false, true end,
		sons.create_sons_core_node(sons, option),
		sons.CollectiveSensor.create_collectivesensor_node(sons),
		sons.Driver.create_driver_node(sons, {waiting = "spring"}),
	}}
end

--- step
function step()
	local timeStepStart = getCurrentTime()
	-- prestep
	-- log step
	if robot.id == "drone1" then
		if api.stepCount % 100 == 0 then
			logger("---- step ", api.stepCount, "-------------")
		end
	end

	--logger(robot.id, api.stepCount, "-----------------------")
	api.preStep()
	sons.preStep(sons)

	-- step
	bt()

	local timeAfterBT = getCurrentTime()

	-- poststep
	sons.postStep(sons)
	api.postStep()

	local timeAfterPost = getCurrentTime()

	sons.logLoopFunctionInfo(sons)
	-- debug
	api.debug.showChildren(sons)

	local timeStepEnd = getCurrentTime()

	local timeMeasurePre = timeAfterPre - timeStepStart
	local timeMeasureBT = timeAfterBT - timeAfterPre 
	local timeMeasurePost = timeAfterPost - timeAfterBT
	local timeMeasureEnd = timeStepEnd - timeAfterPost

	local timeMeasureCoreConnector = timeCoreAfterConnector - timeCoreStart
	local timeMeasureCoreAssigner = timeCoreAfterAssigner - timeCoreAfterConnector
	local timeMeasureCoreScalemanager = timeCoreAfterScalemanager - timeCoreAfterAssigner
	local timeMeasureCoreStabilizer = timeCoreAfterStabilizer - timeCoreAfterScalemanager
	local timeMeasureCoreAllocator = timeCoreAfterAllocator - timeCoreAfterStabilizer
	local timeMeasureCoreIntersectiondetector = timeCoreAfterIntersectiondetector - timeCoreAfterAllocator
	local timeMeasureCoreAvoider = timeCoreAfterAvoider - timeCoreAfterIntersectiondetector
	local timeMeasureCoreSpreader = timeCoreAfterSpreader - timeCoreAfterAvoider
	local timeMeasureCoreBrainkeeper = timeCoreAfterBrainkeeper- timeCoreAfterSpreader

	os.execute('echo ' .. tostring(timeMeasurePre)  .. ' ' ..
	                      tostring(timeMeasureBT)   .. ' ' ..
	                      tostring(timeMeasurePost) .. ' ' ..
	                      tostring(timeMeasureEnd)  .. ' ' ..

	                      tostring(timeMeasureCoreConnector)  .. ' ' ..
	                      tostring(timeMeasureCoreAssigner)  .. ' ' ..
	                      tostring(timeMeasureCoreScalemanager)  .. ' ' ..
	                      tostring(timeMeasureCoreStabilizer)  .. ' ' ..
	                      tostring(timeMeasureCoreAllocator)  .. ' ' ..
	                      tostring(timeMeasureCoreIntersectiondetector)  .. ' ' ..
	                      tostring(timeMeasureCoreAvoider)  .. ' ' ..
	                      tostring(timeMeasureCoreSpreader)  .. ' ' ..
	                      tostring(timeMeasureCoreBrainkeeper)  .. ' ' ..
	           ' >> ' .. timeMeasureDataFile
	          )
	local commMeasure = countMessage(sons.Msg.waitToSend)
	os.execute('echo ' .. tostring(commMeasure) .. ' >> ' .. commMeasureDataFile)
end

--- destroy
function destroy()
	api.destroy()
end

-- Analyze function -----
function getCurrentTime()
	local wallTimeS, wallTimeNS, CPUTimeS, CPUTimeNS = robot.radios.wifi.get_time()
	return CPUTimeS + CPUTimeNS * 0.000000001
end

function getCurrentTime_backup()
	local tmpfile = robot.id .. '_time_tmp.dat'

	os.execute('date +\"%s.%N\" > ' .. tmpfile)
	--os.execute('gdate +\"%s.%N\" > ' .. tmpfile) -- use gdate in mac

	local time
	local f = io.open(tmpfile)
	for line in f:lines() do
		time = tonumber(line)
	end
	f:close()
	return time
end

function countMessage(waitToSend)
	local count = 0
	for index, value in pairs(waitToSend) do
		if type(value) == "number" then
			count = count + 1
		elseif type(value) == "string" then
			count = count + 1
		elseif type(value) == "userdata" then
			count = count + 3
		elseif type(value) == "table" then
			count = count + countMessage(value)
		end
	end
	return count
end