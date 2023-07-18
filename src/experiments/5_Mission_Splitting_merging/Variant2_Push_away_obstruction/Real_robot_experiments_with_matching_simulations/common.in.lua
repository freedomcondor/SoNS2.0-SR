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

pairs = require("AlphaPairs")
ExperimentCommon = require("ExperimentCommon")
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
local structure1 = require("morphology1")
local structure2 = require("morphology2")
local structure3 = require("morphology3")
local structure4 = require("morphology4")
local gene = {
	robotTypeS = "drone",
	positionV3 = vector3(),
	orientationQ = quaternion(),
	children = {
		structure1, 
		structure2, 
		structure3,
		structure4,
	}
}

-- SoNS option
SoNS.Allocator.calcBaseValue = SoNS.Allocator.calcBaseValue_vertical -- default is oval

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
		create_head_navigate_node(sons),
		sons.Driver.create_driver_node(sons, {waiting = true}),
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

	if sons.parentR == nil then
		api.debug.showObstacles(sons)
	end

	--ExperimentCommon.detectGates(sons, 253, 1.5) -- gate brick id and longest possible gate size
end

--- destroy
function destroy()
	api.destroy()
end

----------------------------------------------------------------------------------
function create_head_navigate_node(sons)
local state = "reach"
local count = 0
return function()
	-- only run for brain
	if sons.parentR ~= nil then return false, true end
	if sons.api.stepCount < 250 then return false, true end

	-- detect target
	local target = nil
	local marker = nil
	for i, ob in ipairs(sons.avoider.obstacles) do
		if ob.type == 100 then
			target = {
				positionV3 = ob.positionV3,
				orientationQ = ob.orientationQ,
			}
		end
		if ob.type == 101 then
			marker = {
				positionV3 = ob.positionV3,
				orientationQ = ob.orientationQ,
			}
		end
	end

	-- State
	if state == "reach" then
		-- move
		local speed = 0.03
		local disV2 = nil
		if target == nil then
			sons.Spreader.emergency_after_core(sons, vector3(speed,0,0), vector3())
		else
			local goal = target.positionV3 + vector3(-1.2, 0.8, 0):rotate(target.orientationQ)
			sons.setGoal(sons, goal, sons.goal.orientationQ)
			disV2 = vector3(goal)
			disV2.z = 0
		end

		if disV2 ~= nil and disV2:length() < 0.10 then
			state = "stretch"
			logger("stretch")
			count = 0
			sons.setMorphology(sons, structure2)
		end
	elseif state == "stretch" then
		local disV2 = nil
		if target ~= nil then
			local goal = target.positionV3 + vector3(-1, 0, 0)
			sons.setGoal(sons, goal, target.orientationQ)
			disV2 = vector3(goal)
			disV2.z = 0
		end

		if disV2 ~= nil and disV2:length() < 0.30 and sons.driver.all_arrive == true then
			count = count + 1
		end
		if count == 100 then
			state = "push"
			logger("push")
			count = 0
			sons.setMorphology(sons, structure3)
		end

	elseif state == "push" then
		count = count + 1
		sons.Allocator.calcBaseValue = function() return 0 end

		if sons.robotTypeS == "drone" then
			sons.api.parameters.droneDefaultHeight = 1.2
		end

		sons.Spreader.emergency_after_core(sons, vector3(0.03,0,0), vector3())
		if target ~= nil then
			sons.setGoal(sons, sons.goal.positionV3, target.orientationQ)
		end

		if marker ~= nil and marker.positionV3.x < 0 then
			state = "resume"
			logger("resume")
			count = 0
			sons.setMorphology(sons, structure1)
		end
	elseif state == "resume" then
		sons.Allocator.calcBaseValue = sons.Allocator.calcBaseValue_oval
		count = count + 1

		if marker ~= nil then
			local goal = marker.positionV3 + vector3(-1.0, -0.5, 0):rotate(marker.orientationQ)
			sons.setGoal(sons, goal, marker.orientationQ)
			disV2 = vector3(goal)
			disV2.z = 0
		end

		if sons.robotTypeS == "drone" then
			sons.api.parameters.droneDefaultHeight = 1.5
			sons.api.tagLabelIndex.pipuck.from = 1
		end

		if count == 200 then
			state = "end"
			logger("end")
			count = 0
		end

	elseif state == "end" then
		sons.Spreader.emergency_after_core(sons, vector3(-0.03,0,0), vector3())
		sons.stabilizer.force_pipuck_reference = true

	--[[
	elseif state == "stretch" then
		count = count + 1

		if target ~= nil then
			sons.setGoal(sons, target.positionV3, target.orientationQ)
			target.positionV3.z = 0
		end
		
		if count == 300 then
			state = "clutch"
			logger("clutch")
			count = 0
			sons.setMorphology(sons, structure3)
		end
	elseif state == "clutch" then
		count = count + 1

		sons.Spreader.emergency_after_core(sons, vector3(-0.01,0,0), vector3())

		if target ~= nil then
			sons.setGoal(sons, target.positionV3, target.orientationQ)
			target.positionV3.z = 0
		end

		if count == 200 then
			state = "retrieve"
			logger("retrieve")
			count = 0
			sons.setMorphology(sons, structure4)
		end
	elseif state == "retrieve" then
		sons.stabilizer.force_pipuck_reference = true
		sons.Parameters.stabilizer_preference_robot = nil
		sons.Parameters.dangerzone_pipuck = 0
		sons.Parameters.deadzone_pipuck = 0

		sons.Spreader.emergency_after_core(sons, vector3(-0.03,0,0), vector3())

		count = count + 1
		if count == 250 then
			state = "end"
			logger("end")
			sons.Parameters.dangerzone_pipuck = 0.4
			sons.Parameters.deadzone_pipuck = 0.2
			sons.setMorphology(sons, structure1)
		end
	--]]
	end

	return false, true
end end