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

	api.debug.recordSwitch = true
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
		create_navigation_node(sons),
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

	-- debug
	api.debug.showChildren(sons)
	--api.debug.showObstacles(sons)
	sons.logLoopFunctionInfo(sons)
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
function create_navigation_node(sons)
	return function()
		if sons.stabilizer.referencing_me == true then
			for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "new_heading")) do
				sons.stabilizer.referencing_me_goal_overwrite = {orientationQ = sons.parentR.orientationQ * msgM.dataT.heading}
			end
		end
		if sons.stabilizer.referencing_robot ~= nil and sons.api.stepCount > 50 then
			sons.Msg.send(sons.stabilizer.referencing_robot.idS, "new_heading", {heading = sons.api.virtualFrame.Q_VtoR(quaternion())})
		end

		local predator_velocity = vector3(0,0,0)
		for i, ob in ipairs(sons.avoider.seenObstacles) do
			if ob.type == 0 then
				local speed = 1 / ob.positionV3:length()
				if speed > 0.01 then speed = 0.01 end
				predator_velocity = predator_velocity - vector3(ob.positionV3):normalize() * speed
			end
		end
		sons.Spreader.emergency_after_core(sons, predator_velocity, vector3())
		return false, true
	end
end