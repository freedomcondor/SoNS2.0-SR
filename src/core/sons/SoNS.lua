-- SoNS ------------------------------------------------------
-- This is the root file for SoNS library. It serves as a container that arranges all the SoNS function modules
-- For a robot, to create a SoNS data structure, do something like
--      sons = SoNS:create("pipuck")
-- and sons will be the data structure of SoNS, it contains datas such as which robot is my parent, my children ...
-- sons has basic functions such as sons.addChild(), which adds a child into the data structure
-- in each of these functions, sons iterates all the modules and call the module function with the same name if implemented
-- 
-- At last, it provides create_sons_node() function to return a behavior tree node that contains the basic type of sons behavior tree
--
-- In addition, it provides functions to log sons datas into experiment logs through argos loop function in simulation, or message system in hardware
-------------------------------------------------------------
local SoNS = {SoNSCLASS = true}
SoNS.__index = SoNS

SoNS.Msg = require("Message")
SoNS.Parameters = require("Parameters")

--SoNS.Connector = require("Connector_backup")
SoNS.Connector = require("Connector")
SoNS.DroneConnector = require("DroneConnector")
SoNS.PipuckConnector = require("PipuckConnector")

SoNS.ScaleManager = require("ScaleManager")
SoNS.Assigner = require("Assigner")
SoNS.Allocator = require("Allocator")
SoNS.Avoider = require("Avoider")
SoNS.Spreader = require("Spreader")
SoNS.BrainKeeper = require("BrainKeeper")
SoNS.CollectiveSensor = require("CollectiveSensor")
SoNS.IntersectionDetector = require("IntersectionDetector")
SoNS.Neuron = require("Neuron")
SoNS.Stabilizer = require("Stabilizer")

SoNS.Driver= require("Driver")

SoNS.Modules = {
	SoNS.DroneConnector,
	SoNS.PipuckConnector,
	SoNS.Connector,
	SoNS.Assigner,

	SoNS.ScaleManager,
	SoNS.Stabilizer,

	SoNS.Allocator,
	SoNS.IntersectionDetector,

	SoNS.Avoider,
	SoNS.Spreader,
	SoNS.CollectiveSensor,
	SoNS.BrainKeeper,

	SoNS.Neuron,

	SoNS.Driver,
}

--[[
--	sons = {
--		idS
--		idN
--		robotTypeS
--		scale
--		
--		parentR
--		childrenRT
--
--	}
--]]

function SoNS.create(myType)

	-- a robot =  {
	--     idS,
	--     positionV3, 
	--     orientationQ,
	--     robotTypeS = "drone",
	-- }

	local sons = {}
	sons.robotTypeS = myType

	setmetatable(sons, SoNS)

	for i, module in ipairs(SoNS.Modules) do
		if type(module.create) == "function" then
			module.create(sons)
		end
	end

	SoNS.reset(sons)
	return sons
end

function SoNS.reset(sons)
	sons.parentR = nil
	sons.childrenRT = {}

	sons.idS = SoNS.Msg.myIDS()
	sons.idN = robot.random.uniform()

	for i, module in ipairs(SoNS.Modules) do
		if type(module.reset) == "function" then
			module.reset(sons)
		end
	end
end

function SoNS.preStep(sons)
	SoNS.Msg.preStep()
	for i, module in ipairs(SoNS.Modules) do
		if type(module.preStep) == "function" then
			module.preStep(sons)
		end
	end
end

function SoNS.postStep(sons)
	for i = #SoNS.Modules, 1, -1 do
		local module = SoNS.Modules[i]
		if type(module.postStep) == "function" then
			module.postStep(sons)
		end
	end
	sons.Msg.postStep(sons.api.stepCount)
end

function SoNS.addChild(sons, robotR)
	for i, module in ipairs(SoNS.Modules) do
		if type(module.addChild) == "function" then
			module.addChild(sons, robotR)
		end
	end
end
function SoNS.deleteChild(sons, idS)
	for i = #SoNS.Modules, 1, -1 do
		local module = SoNS.Modules[i]
		if type(module.deleteChild) == "function" then
			module.deleteChild(sons, idS)
		end
	end
end

function SoNS.addParent(sons, robotR)
	for i, module in ipairs(SoNS.Modules) do
		if type(module.addParent) == "function" then
			module.addParent(sons, robotR)
		end
	end
end
function SoNS.deleteParent(sons)
	for i = #SoNS.Modules, 1, -1 do
		local module = SoNS.Modules[i]
		if type(module.deleteParent) == "function" then
			module.deleteParent(sons)
		end
	end
end

function SoNS.setGene(sons, morph)
	for i, module in ipairs(SoNS.Modules) do
		if type(module.setGene) == "function" then
			module.setGene(sons, morph)
		end
	end
end

function SoNS.setMorphology(sons, morph)
	for i, module in ipairs(SoNS.Modules) do
		if type(module.setMorphology) == "function" then
			module.setMorphology(sons, morph)
		end
	end
end

function SoNS.resetMorphology(sons)
	for i, module in ipairs(SoNS.Modules) do
		if type(module.resetMorphology) == "function" then
			module.resetMorphology(sons)
		end
	end
end

function SoNS.setGoal(sons, positionV3, orientationQ)
	for i, module in ipairs(SoNS.Modules) do
		if type(module.setGoal) == "function" then
			module.setGoal(sons, positionV3, orientationQ)
		end
	end
end

---- Print Debug Info ------------------------------------------
SoNS.debug = {}
function SoNS.debug.logInfo(sons, option, indent_str)
	if option == nil then option = {ALL = true} end
	if indent_str == nil then indent_str = "" end

	logger(indent_str .. robot.id, sons.api.stepCount, "-----------------------") 
	sons.debug.logSoNSInfo(sons, option, indent_str)
	logger(indent_str .. "    parent : ") 
	if sons.parentR ~= nil then
		sons.debug.logRobot(sons.parentR, option, indent_str .. "        ")
	end
	logger(indent_str .. "    children : ") 
	for _, childR in pairs(sons.childrenRT) do
		sons.debug.logRobot(childR, option, indent_str .. "        ")
	end
end

function SoNS.debug.logSoNSInfo(sons, option, indent_str)
	if option == nil then option = {ALL = true} end
	if indent_str == nil then indent_str = "" end

	if option.ALL == true or option.idN == true then
		logger(indent_str .. "    idN              = ", sons.idN) 
	end
	if option.ALL == true or option.idS == true then
		logger(indent_str .. "    idS              = ", sons.idS) 
	end
	if option.ALL == true or option.robotTypeS   == true then
		logger(indent_str .. "    robotTypeS       = ", sons.robotTypeS) 
	end
	if option.ALL == true or option.target == true and sons.allocator.target ~= nil then
		logger(indent_str .. "    allocator.target = ", sons.allocator.target.idN) 
	end
	if option.ALL == true or option.goal == true then
		logger(indent_str .. "    goal.positionV3  = ", sons.goal.positionV3) 
		logger(indent_str .. "         orientationQ : X = ", vector3(1,0,0):rotate(sons.goal.orientationQ)) 
		logger(indent_str .. "                        Y = ", vector3(0,1,0):rotate(sons.goal.orientationQ)) 
		logger(indent_str .. "                        Z = ", vector3(0,0,1):rotate(sons.goal.orientationQ)) 
		logger(indent_str .. "         transV3     = ", sons.goal.transV3) 
		logger(indent_str .. "         rotateV3    = ", sons.goal.rotateV3) 
	end
	if option.ALL == true or option.scale == true then 
		logger(indent_str .. "    scale       : ")
		for typeS, number in pairs(sons.scalemanager.scale) do
			logger(indent_str .. "                   " .. typeS, number)
		end
	end
	if option.ALL == true or option.connector == true then 
		logger(indent_str .. "    connector.waitingRobots : ")
		for idS, robotR in pairs(sons.connector.waitingRobots) do
			logger(indent_str .. "                           " .. idS, robotR.waiting_count)
		end
		logger(indent_str .. "    connector.waitingParents: ")
		for idS, robotR in pairs(sons.connector.waitingParents) do
			logger(indent_str .. "                           " .. idS, robotR.waiting_count)
		end
	end
end

function SoNS.debug.logRobot(robotR, option, indent_str)
	if option == nil then option = {ALL = true} end
	if indent_str == nil then indent_str = "" end

	logger(indent_str .. robotR.idS)
	if option.ALL == true or option.robotTypeS   == true then
		logger(indent_str .. "    robotTypeS       = ", robotR.robotTypeS) 
	end
	if option.ALL == true or option.positionV3   == true then
		logger(indent_str .. "    positionV3       = ", robotR.positionV3) 
	end
	if option.ALL == true or option.orientationQ == true then
		logger(indent_str .. "    orientationQ : X = ", vector3(1,0,0):rotate(robotR.orientationQ))
		logger(indent_str .. "                   Y = ", vector3(0,1,0):rotate(robotR.orientationQ))
		logger(indent_str .. "                   Z = ", vector3(0,0,1):rotate(robotR.orientationQ))
	end
	if option.ALL == true or option.scale == true then 
		logger(indent_str .. "    scale       : ")
		for typeS, number in pairs(robotR.scalemanager.scale) do
			logger(indent_str .. "                   " .. typeS, number)
		end
	end
	if (option.ALL == true or option.connector == true) and robotR.connector ~= nil then
		logger(indent_str .. "    connector.unseen_count    = ", robotR.connector.unseen_count)
		logger(indent_str .. "             .heartbeat_count = ", robotR.connector.heartbeat_count)
	end
	-- parent doesn't have these: 
	if (option.ALL == true or option.assigner == true) and robotR.assigner.targetS ~= nil then 
		logger(indent_str .. "    assigner.targetS = ", robotR.assigner.targetS)
	end
	if (option.ALL == true or option.allocator == true) and robotR.allocator ~= nil then 
		if robotR.allocator.match ~= nil then
			logger(indent_str .. "    allocator      = ")
			for _, branch in ipairs(robotR.allocator.match) do
				logger(indent_str .. "                       " .. branch.idN)
			end
		else
			logger(indent_str .. "    allocator      = nil")
		end
	end
end

function SoNS.logLoopFunctionInfoHW(sons)
	local targetID = -2
	if sons.allocator.target ~= nil then
		targetID = sons.allocator.target.idN
	end

	local parentID = nil
	if sons.parentR ~= nil then
		parentID = sons.parentR.idS
	end
	SoNS.Msg.sendTable{
		toS = "LOGINFO",
		stepCount = sons.api.stepCount,
		virtualFrameQ = sons.api.virtualFrame.orientationQ,
		goalPositionV3 = sons.goal.positionV3,
		goalOrientationQ = sons.goal.orientationQ,
		targetID = targetID,
		sonsID = sons.idS,
		parentID = parentID
	}
end

function SoNS.logLoopFunctionInfo(sons)
	if robot.params.hardware == true then
		return SoNS.logLoopFunctionInfoHW(sons)
	end
	if robot.debug == nil or robot.debug.write == nil then return end

	-- log virtual frame
	local str = tostring(sons.api.virtualFrame.orientationQ)

	-- log goal position
	str = str .. "," .. tostring(sons.goal.positionV3)
	-- log goal orientation
	str = str .. "," .. tostring(sons.goal.orientationQ)

	-- log target
	if sons.allocator.target == nil then
		str = str .. ",-2"
	else
		str = str .. "," .. tostring(sons.allocator.target.idN)
	end


	-- log brain name
	str = str .. "," .. tostring(sons.idS)

	-- log parent name
	if sons.parentR ~= nil then
		str = str .. "," .. tostring(sons.parentR.idS)
	else
		str = str .. "," .. tostring(nil)
	end

	robot.debug.write(str)
end

---- Behavior Tree Node ------------------------------------------
function SoNS.create_preconnector_node(sons)
	local pre_connector_node
	if sons.robotTypeS == "drone" then
		return SoNS.DroneConnector.create_droneconnector_node(sons)
	elseif sons.robotTypeS == "pipuck" then
		return SoNS.PipuckConnector.create_pipuckconnector_node(sons)
	elseif sons.robotTypeS == "builderbot" then
		return SoNS.PipuckConnector.create_pipuckconnector_node(sons) -- TODO
	end
end

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
		sons.Connector.create_connector_node(sons, 
			{	no_recruit = option.connector_no_recruit,
				no_parent_ack = option.connector_no_parent_ack,
				specific_name = option.specific_name,
				specific_time = option.specific_time,
			}),
		sons.Assigner.create_assigner_node(sons),
		sons.ScaleManager.create_scalemanager_node(sons),
		sons.Stabilizer.create_stabilizer_node(sons),
		sons.Allocator.create_allocator_node(sons),
		sons.IntersectionDetector.create_intersectiondetector_node(sons),
		sons.Avoider.create_avoider_node(sons, {
			drone_pipuck_avoidance = option.drone_pipuck_avoidance
		}),
		sons.Spreader.create_spreader_node(sons),
		sons.BrainKeeper.create_brainkeeper_node(sons),
		--sons.CollectiveSensor.create_collectivesensor_node(sons),
		--sons.Driver.create_driver_node(sons),
	}}
end

function SoNS.create_sons_node(sons, option)
	-- option = {
	--      connector_no_recruit = true or false or nil,
	--      connector_no_parent_ack = true or false or nil,
	--      driver_waiting
	-- }
	if option == nil then option = {} end
	return { 
		type = "sequence", children = {
		sons.create_preconnector_node(sons),
		sons.create_sons_core_node(sons, option),
		sons.Driver.create_driver_node(sons, {waiting = option.driver_waiting}),
	}}
end

return SoNS
