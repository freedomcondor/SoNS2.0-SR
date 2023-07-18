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
local Transform = require("Transform")
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
local gene = {
	robotTypeS = "drone",
	positionV3 = vector3(),
	orientationQ = quaternion(),
	children = {
		structure1, 
		structure2, 
	}
}

-- SoNS option
--SoNS.Allocator.calcBaseValue = SoNS.Allocator.calcBaseValue_vertical -- default is oval

-- called when a child lost its parent
function SoNS.Allocator.resetMorphology(sons)
	sons.Allocator.setMorphology(sons, structure1)
end

if robot.id == robot.params.single_robot then 
function SoNS.Connector.newSonsID(sons, idN, lastidPeriod)
	local _idS = sons.Msg.myIDS()
	local _idN = idN or 0

	SoNS.Connector.updateSonsID(sons, _idS, _idN, lastidPeriod)
end
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
	if sons.idS == robot.params.single_robot then sons.idN = 0 end
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
end

--- destroy
function destroy()
	api.destroy()
end

----------------------------------------------------------------------------------
function create_head_navigate_node(sons)
local state = "form"
local count = 0
local speed = 0.05
return function()
	-- only run after navigation
	if sons.api.stepCount < 150 then return false, true end

	-- State
	if state == "form" and 
	   sons.allocator.target.split == true then
		count = count + 1
		if count == 200 then
			-- rebellion
			if sons.parentR ~= nil then
				sons.Msg.send(sons.parentR.idS, "dismiss")
				sons.deleteParent(sons)
			end
			sons.setMorphology(sons, structure2)
			sons.Connector.newSonsID(sons, 0.9, 200)

			state = "split"
			logger("split")
			count = 0
		end
	elseif state == "split" and 
	       sons.allocator.target.ranger == true then
		
		-- adjust orientation
		if #sons.avoider.obstacles ~= 0 then
			local orientationAcc = Transform.createAccumulator()
			for id, ob in ipairs(sons.avoider.obstacles) do
				Transform.addAccumulator(orientationAcc, {positionV3 = vector3(), orientationQ = ob.orientationQ})
			end
			local averageOri = Transform.averageAccumulator(orientationAcc).orientationQ
			sons.setGoal(sons, sons.goal.positionV3, averageOri)
		end

		sons.Spreader.emergency_after_core(sons, vector3(0, speed, 0), vector3())
		count = count + 1
		if count == 200 then
			state = "go_back"
			logger("go_back")
			count = 0
		end
	elseif state == "go_back" and 
	       sons.allocator.target.ranger == true then

		-- adjust orientation
		if #sons.avoider.obstacles ~= 0 then
			local orientationAcc = Transform.createAccumulator()
			for id, ob in ipairs(sons.avoider.obstacles) do
				Transform.addAccumulator(orientationAcc, {positionV3 = vector3(), orientationQ = ob.orientationQ})
			end
			local averageOri = Transform.averageAccumulator(orientationAcc).orientationQ
			sons.setGoal(sons, sons.goal.positionV3, averageOri)
		end

		if sons.parentR == nil then
			sons.Spreader.emergency_after_core(sons, vector3(0, -speed, 0), vector3())
		end
		count = count + 1
		if count == 500 then
			state = "end"
			logger("end")
			count = 0
		end
	end

	return false, true
end end