local myType = robot.params.my_type

--[[
package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/src/core/api/?.lua"
package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/src/core/utils/?.lua"
package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/src/core/sons/?.lua"
--]]
package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/2_Mission_Global_local_goals/Variant2_Larger_less_dense_obstacles/Large_scale_simulation_experiments/?.lua"
if robot.params.hardware ~= "true" then
	package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/2_Mission_Global_local_goals/Variant2_Larger_less_dense_obstacles/Large_scale_simulation_experiments/simu/?.lua"
end

pairs = require("AlphaPairs")
ExperimentCommon = require("ExperimentCommon")
-- includes -------------
local Transform = require("Transform")
logger = require("Logger")
local api = require(myType .. "API")
local SoNS = require("SoNS")
local BT = require("BehaviorTree")
logger.enable()
logger.disable("Allocator")
logger.disable("Stabilizer")
logger.disable("droneAPI")

-- datas ----------------
local bt
--local sons
local gene = require("morphology")

-- SoNS option
-- SoNS.Allocator.calcBaseValue = SoNS.Allocator.calcBaseValue_oval -- default is oval

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
	if sons.idS == robot.params.stabilizer_preference_brain then sons.idN = 1 end
	sons.setGene(sons, gene)
	sons.setMorphology(sons, gene)

	bt = BT.create
	{ type = "sequence", children = {
		sons.create_preconnector_node(sons),
		create_led_node(sons),
		sons.create_sons_core_node(sons),
		create_head_navigate_node(sons),
		sons.Driver.create_driver_node(sons, {waiting = "spring"}),
	}}
end

--- step
function step()
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
	--api.debug.showObstacles(sons)
end

--- destroy
function destroy()
	api.destroy()
end

-- drone avoider led node ---------------------
function create_led_node(sons)
	return function()
		-- signal led
		if sons.robotTypeS == "drone" then
			local flag = false
			for idS, robotR in pairs(sons.connector.seenRobots) do
				if robotR.robotTypeS == "drone" then
					flag = true
				end
			end
			if flag == true then
				robot.leds.set_leds("green")
			else
				robot.leds.set_leds("red")
			end
		end
		return false, true
	end
end

function create_head_navigate_node(sons)
local state = "moving"
return function()
	-- form the formation for 150 steps
	if sons.api.stepCount < 600 then 
		sons.stabilizer.force_pipuck_reference = true
		return false, true 
	end

	sons.stabilizer.force_pipuck_reference = nil

	-- check end
	local target_type = 103
	local target = nil
	if #sons.avoider.obstacles ~= 0 then
		for id, ob in ipairs(sons.avoider.obstacles) do
			if ob.type == target_type then
				target = ob
			end
		end
	end
	if target ~= nil and sons.parentR == nil then
		local target_vec = vector3(target.positionV3)
		local n_vec = vector3(1,0,0):rotate(target.orientationQ)
		target_vec.z = 0
		n_vec.z = 0
		local dis = target_vec:dot(n_vec)

		local goal = target.positionV3 + vector3(-0.5, -0.5, 0):rotate(target.orientationQ)
		goal.z = 0
		goal = goal * 0.1
		if goal:length() > 0.3 then
			goal = goal * (0.3 / goal:length())
		end
		sons.Spreader.emergency_after_core(sons, vector3(goal.x, goal.y ,0), vector3(), nil, true)

		return false, true
	end

	-- adjust orientation
	if #sons.avoider.obstacles ~= 0 then
		local orientationAcc = Transform.createAccumulator()
		for id, ob in ipairs(sons.avoider.obstacles) do
			Transform.addAccumulator(orientationAcc, {positionV3 = vector3(), orientationQ = ob.orientationQ})
		end
		local averageOri = Transform.averageAccumulator(orientationAcc).orientationQ
		sons.setGoal(sons, sons.goal.positionV3, averageOri)
	end

	-- drone move forward
	if sons.parentR == nil and sons.robotTypeS == "drone" then 
		local speed = 0.03
		local speedx = speed
		local speedy = speed * 0.1 * math.cos(math.pi * api.stepCount/500)
		sons.Spreader.emergency_after_core(sons, vector3(speedx,speedy,0), vector3(), nil, true)
	end

	return false, true
end end
