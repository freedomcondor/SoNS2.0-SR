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
		sons.create_sons_core_node(sons, {drone_pipuck_avoidance = true}),
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