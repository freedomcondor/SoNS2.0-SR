local myType = robot.params.my_type

package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/src/core/api/?.lua"
package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/src/core/utils/?.lua"
package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/src/core/sons/?.lua"
package.path = package.path .. ";/home/harry/code-mns2.0/SoNS2.0-SR/build/testing/exp_0_hw_00_demo_1_2d_4p/?.lua"

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
	if sons.idS == robot.params.stabilizer_preference_brain then 
		sons.idN = 1 
		api.parameters.droneDefaultStartHeight = 1.6
	end
	if sons.robotTypeS == "pipuck" then 
		sons.idN = 0 
	end
	sons.setGene(sons, gene)
	sons.setMorphology(sons, gene)

	bt = BT.create
	{ type = "sequence", children = {
		sons.create_preconnector_node(sons),
		create_led_node(sons),
		create_start_node(sons),
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
	api.debug.showChildren(sons, nil, true) -- color nil, withoutBrain true
	-- comment out draw parent circle in showChildren in core/api/commonAPI.lua
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
		--[[
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
		--]]

		-- signal video drawings
		---[[ draw goal circle
		if sons.parentR ~= nil then
			local color = "0,255,255,0"
			sons.api.debug.drawArrow(color,
		                        sons.api.virtualFrame.V3_VtoR(vector3(0,0,0.03)),
		                        sons.api.virtualFrame.V3_VtoR(vector3(sons.goal.positionV3 + vector3(0,0,0.03))),
								true
		                       )
			sons.api.debug.drawRing(color, api.virtualFrame.V3_VtoR(sons.goal.positionV3 + vector3(0,0,0.03)), 0.15, true)
		end
		--]]

		---[[ draw brain in red circle
		if sons.robotTypeS == "drone" then
			if sons.parentR == nil then
				robot.leds.set_leds("red")
				sons.api.debug.drawRing("red", vector3(0,0,0), 0.15, true)
			else
				robot.leds.set_leds("black")
			end
		end
		--]]

		return false, true
	end
end

function create_start_node(sons)
	return function()
		if sons.api.stepCount < 75 then
			return false, false
		else
			return false, true 
		end
	end
end
