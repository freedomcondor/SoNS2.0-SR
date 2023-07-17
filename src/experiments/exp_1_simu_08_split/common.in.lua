local myType = robot.params.my_type

--[[
package.path = package.path .. ";@CMAKE_SOURCE_DIR@/core/api/?.lua"
package.path = package.path .. ";@CMAKE_SOURCE_DIR@/core/utils/?.lua"
package.path = package.path .. ";@CMAKE_SOURCE_DIR@/core/sons/?.lua"
--]]
package.path = package.path .. ";@CMAKE_CURRENT_BINARY_DIR@/?.lua"
if robot.params.hardware ~= "true" then
	package.path = package.path .. ";@CMAKE_CURRENT_BINARY_DIR@/simu/?.lua"
end

local morphologiesGenerator = robot.params.morphologiesGenerator
require(morphologiesGenerator)

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
--local sons
local structure1 = create_main_morphology()
local structure2 = create_ranger_morphology()
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
-- SoNS.Allocator.calcBaseValue = SoNS.Allocator.calcBaseValue_oval -- default is oval

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
	if sons.idS == robot.params.stabilizer_preference_brain then sons.idN = 1 end
	sons.setGene(sons, gene)
	sons.setMorphology(sons, structure1)

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
			if count == 370 then
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
	
			sons.Spreader.emergency_after_core(sons, vector3(-speed, 0, 0), vector3())
			count = count + 1
			if count == 300 then
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
				sons.Spreader.emergency_after_core(sons, vector3(speed, 0, 0), vector3())
			end
			count = count + 1
			if count == 500 then
				state = "end"
				logger("end")
				count = 0
			end
		end
	
		return false, true
	end
end