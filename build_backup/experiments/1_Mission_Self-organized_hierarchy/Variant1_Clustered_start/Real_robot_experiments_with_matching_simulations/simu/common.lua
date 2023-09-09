local myType = robot.params.my_type

--[[
package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/src/core/api/?.lua"
package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/src/core/utils/?.lua"
package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/src/core/sons/?.lua"
package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/1_Mission_Self-organized_hierarchy/Variant1_Clustered_start/Real_robot_experiments_with_matching_simulations/?.lua"
--]]
if robot.params.hardware ~= "true" then
	package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/1_Mission_Self-organized_hierarchy/Variant1_Clustered_start/Real_robot_experiments_with_matching_simulations/simu/?.lua"
end

pairs = require("AlphaPairs")
ExperimentCommon = require("ExperimentCommon")
-- includes -------------
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
	--if sons.parentR == nil then
		--api.debug.showObstacles(sons)
	--end
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

-- drone navigation node ---------------------
function create_head_navigate_node(sons)
	local marker_type = 33
	local obstacle_type = 34
return function()
	-- only run for brain
	if sons.parentR == nil then 
		for id, ob in ipairs(sons.avoider.obstacles) do
			if ob.type == marker_type then
				sons.setGoal(sons, ob.positionV3 - vector3(0.7, 0.5, 0), ob.orientationQ * quaternion(math.pi/2, vector3(0,0,1)))
			--[[
			if sons.goal.positionV3:length() < 0.3 then
				state = 5
			end
			--]]
				return false, true
			end
		end
	elseif sons.robotTypeS == "pipuck" then
		for id, ob in ipairs(sons.avoider.obstacles) do
			if ob.positionV3:length() < 0.5 then
				sons.goal.transV3 = sons.goal.transV3 + vector3(-0.02, 0, 0):rotate(ob.orientationQ)
			end
		end
	end
end end
