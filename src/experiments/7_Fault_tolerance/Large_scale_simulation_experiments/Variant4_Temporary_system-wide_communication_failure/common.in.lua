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

local expScale = tonumber(robot.params.exp_scale or 0)
local morphologiesGenerator = robot.params.morphologiesGenerator
require(morphologiesGenerator)

pairs = require("AlphaPairs")
local Transform = require("Transform")
-- includes -------------
logger = require("Logger")
local api = require(myType .. "API")
local SoNS = require("SoNS")
local BT = require("BehaviorTree")
logger.enable()
logger.disable("Stabilizer")
logger.disable("droneAPI")

-- datas ----------------
local bt
--local sons
local droneDis = 1.5
local pipuckDis = 0.7
local height = api.parameters.droneDefaultHeight
local structure1 = create_left_right_line_morphology(expScale, droneDis, pipuckDis, height)
--local structure1 = create_3drone_12pipuck_children_chain(1, droneDis, pipuckDis, height, vector3(), quaternion())
local structure2 = create_back_line_morphology(expScale * 2, droneDis, pipuckDis, height, vector3(), quaternion())
--local structure2 = create_back_line_morphology(expScale, droneDis, pipuckDis, height)
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

-- SoNS option
-- SoNS.Allocator.calcBaseValue = SoNS.Allocator.calcBaseValue_oval -- default is oval

-- called when a child lost its parent
function SoNS.Allocator.resetMorphology(sons)
	sons.Allocator.setMorphology(sons, structure1)
end

-- argos functions -----------------------------------------------
--- init
function init()
	api.linkRobotInterface(SoNS)
	api.init() 
	sons = SoNS.create(myType)
	reset()
end

--- reset
function reset()
	sons.reset(sons)
	--if sons.idS == "pipuck1" then sons.idN = 1 end
	if sons.idS == robot.params.stabilizer_preference_brain then sons.idN = 1 end
	sons.setGene(sons, gene)
	sons.setMorphology(sons, structure1)

	bt = BT.create
	{ type = "sequence", children = {
		sons.create_preconnector_node(sons),
		sons.create_sons_core_node(sons),
		sons.CollectiveSensor.create_collectivesensor_node_reportAll(sons),
		create_head_navigate_node(sons),
		sons.Driver.create_driver_node(sons, {waiting="spring"}),
	}}
end

--- step
function step()
	cut_wifi(sons, api)
	-- prestep
	--logger(robot.id, "-----------------------")
	api.preStep()
	sons.preStep(sons)

	-- step
	bt()

	-- poststep
	sons.postStep(sons)
	api.postStep()

	sons.logLoopFunctionInfo(sons)
	-- debug
	api.debug.showChildren(sons)
	if sons.robotTypeS == "drone" then
		api.debug.showObstacles(sons, true)
	end
end

--- destroy
function destroy()
	api.destroy()
end

----------------------------------------------------------------------------------
function create_head_navigate_node(sons)
local state = 1
local stateCount = 0
local left_obstacle_type = 101
local right_obstacle_type = 102
local target_type = 255

	local function sendChilrenNewState(sons, newState)
		for idS, childR in pairs(sons.childrenRT) do
			sons.Msg.send(idS, "switch_to_state", {state = newState})
		end
	end

	local function newState(sons, _newState)
		stateCount = 0
		state = _newState
	end

	local function switchAndSendNewState(sons, _newState)
		newState(sons, _newState)
		sendChilrenNewState(sons, _newState)
	end

return function()
	stateCount = stateCount + 1
	-- for debug
	sons.state = state

	-- if I receive switch state cmd from parent
	if sons.parentR ~= nil then for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "switch_to_state")) do
		switchAndSendNewState(sons, msgM.dataT.state)
	end end

	if state == 4 and stateCount < 600 then
		sons.allocator.pipuck_bridge_switch = true
	else
		sons.allocator.pipuck_bridge_switch = nil
	end

	if sons.parentR == nil then
		-- brain detect width
		local middle = 0

		local left = 10
		local right = -10
		for i, ob in ipairs(sons.avoider.obstacles) do
			if ob.type == left_obstacle_type and
			   ob.positionV3.y < left then
				left = ob.positionV3.y
			end
			if ob.type == right_obstacle_type and
			   ob.positionV3.y > right then
				right = ob.positionV3.y
			end
		end
		for i, ob in ipairs(sons.collectivesensor.receiveList) do
			if ob.type == left_obstacle_type and
			   ob.positionV3.y < left then
				left = ob.positionV3.y
			end
			if ob.type == right_obstacle_type and
			   ob.positionV3.y > right then
				right = ob.positionV3.y
			end
		end

		local width = left - right

		-- brain run state
		if state == 1 then
			if width < 5.0 then
				state = 3
				sons.setMorphology(sons, structure2)
				logger("state2")
			end
		--[[
		elseif state == 2 then
			sons.Parameters.stabilizer_preference_robot = nil
			if width < 1.5 then
				state = 3
				sons.setMorphology(sons, structure3)
				logger("state3")
			end
		--]]
		elseif state == 3 then
			sons.Parameters.stabilizer_preference_robot = nil
			for id, ob in ipairs(sons.avoider.obstacles) do
				if ob.type == target_type then
					switchAndSendNewState(sons, 4)
					sons.setMorphology(sons, structure3)
				end
			end
		elseif state == 4 then
			for id, ob in ipairs(sons.avoider.obstacles) do
				if ob.type == target_type then
					sons.setGoal(sons, ob.positionV3 - vector3(1.0, 0, 0), ob.orientationQ)
					--[[
					if sons.goal.positionV3:length() < 0.3 then
						state = 5
					end
					--]]
					return false, true
				end
			end
		elseif state == 5 then
			-- reach do nothing
			return false, true
		end

		-- align with the average direction of the obstacles
		if #sons.avoider.obstacles ~= 0 or #sons.collectivesensor.receiveList ~= 0 then
			local orientationAcc = Transform.createAccumulator()

			-- add sons.avoider.obstacles and sons.collectivesensor.receiveList together
			local totalGateSideList = {}
			for i, ob in ipairs(sons.avoider.obstacles) do
				totalGateSideList[#totalGateSideList + 1] = ob
			end
			for i, ob in ipairs(sons.collectivesensor.receiveList) do
				totalGateSideList[#totalGateSideList + 1] = ob
			end

			for id, ob in ipairs(totalGateSideList) do
				-- check left and right
				if ob.positionV3.y > 0 and ob.type == obstacle_type and
				   ob.positionV3.y < left then
					left = ob.positionV3.y
			 	end
				if ob.positionV3.y < 0 and ob.type == obstacle_type and
				   ob.positionV3.y > right then
					right = ob.positionV3.y
				end

				-- accumulate orientation
				Transform.addAccumulator(orientationAcc, {positionV3 = vector3(), orientationQ = ob.orientationQ})
			end

			local averageOri = Transform.averageAccumulator(orientationAcc).orientationQ

			if sons.stabilizer.referencing_robot ~= nil then
				sons.Msg.send(sons.stabilizer.referencing_robot.idS, "new_heading", 
					{heading = sons.api.virtualFrame.Q_VtoR(averageOri)}
				)
			else
				sons.setGoal(sons, sons.goal.positionV3, averageOri)
			end
		end

		-- brain calc y speed
		local SpeedY = (left + right) / 2
		if SpeedY > 0 then 
			SpeedY = 1.5
		elseif SpeedY < 0 then 
			SpeedY = -1.5
		elseif SpeedY == 0 then 
			SpeedY = 0 
		end

		-- brain move forward
		if sons.api.stepCount < 250 then return false, true end
		local speed = 0.03
		sons.Spreader.emergency_after_core(sons, vector3(speed,SpeedY * speed,0), vector3())
	end

	-- reference lead move
	if sons.stabilizer.referencing_me == true then
		-- receive from brain information about heading and middle
		sons.stabilizer.referencing_me_goal_overwrite = {}
		for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "new_heading")) do
			sons.stabilizer.referencing_me_goal_overwrite = {orientationQ = sons.parentR.orientationQ * msgM.dataT.heading}
		end

		--[[
		for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "middleY")) do
			local middleV3 = sons.parentR.positionV3 + (msgM.dataT.positionY * vector3(0,1,0)):rotate(sons.parentR.orientationQ)
			newGoalPosition = vector3(sons.goal.positionV3)
			newGoalPosition.y = middleV3.y
			sons.stabilizer.referencing_me_goal_overwrite = {positionV3 = newGoalPosition}
		end
		--]]
	end

	return false, true
end end

function cut_wifi(sons, api)
	--if 500 < api.stepCount and api.stepCount <= 502 then
	if 500 < api.stepCount and api.stepCount <= 650 then  -- 30s
		robot.radios.wifi.recv = {}
	end
end