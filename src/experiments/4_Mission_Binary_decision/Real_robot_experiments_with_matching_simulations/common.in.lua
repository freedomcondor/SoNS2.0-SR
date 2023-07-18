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
local Transform = require("Transform")
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
local structure1 = require("morphology1")
local structure2 = require("morphology2")
local structure3 = require("morphology3")
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
SoNS.Allocator.calcBaseValue = SoNS.Allocator.calcBaseValue_vertical

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
	if sons.idS == robot.params.stabilizer_preference_brain then sons.idN = 1 end
	if sons.robotTypeS == "pipuck" then sons.idN = 0 end
	sons.setGene(sons, gene)

	sons.setMorphology(sons, structure1)
	bt = BT.create
	{ type = "sequence", children = {
		sons.create_preconnector_node(sons),
		sons.create_sons_core_node(sons),
		sons.CollectiveSensor.create_collectivesensor_node(sons),
		create_reaction_node(sons),
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
	if sons.robotTypeS == "drone" then api.debug.showObstacles(sons) end

	--ExperimentCommon.detectGates(sons, 253, 1.5) -- gate brick id and longest possible gate size
end

--- destroy
function destroy()
	api.destroy()
end

-- Strategy -----------------------------------------------
function create_reaction_node(sons)
	local state = "waiting"
	local stateCount = 0

	-- parameters ----------------
	local obstacle_type = 32
	local wall_brick_type = 34
	local gate_brick_type = 33
	local target_type = 27
	local max_gate_length = 1.6
	local totalGateNumber = 2
	local n_drone = 2

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
		-- if I receive switch state cmd from parent
		if sons.parentR ~= nil then for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "switch_to_state")) do
			switchAndSendNewState(sons, msgM.dataT.state)
		end end
		-------------------------------------------------------------
		-- waiting for sometime for the 1st formation
		if state == "waiting" then
			sons.stabilizer.force_pipuck_reference = true
			--sons.allocator.pipuck_bridge_switch = true
			stateCount = stateCount + 1
			--if stateCount == 150 + expScale * 50 then
			-- brain wait for sometime and say move_forward
			if sons.parentR == nil then
				--if stateCount > 75 and sons.driver.all_arrive == true then
				if (stateCount > 150) then
					switchAndSendNewState(sons, "move_forward")
				end
			end

		elseif state == "move_forward" then
			sons.stabilizer.force_pipuck_reference = nil
			--sons.allocator.pipuck_bridge_switch = nil
			stateCount = stateCount + 1

			-- everyone reports wall and gates
			ExperimentCommon.reportWall(sons, wall_brick_type)
			local _, _, gateNumber = ExperimentCommon.detectAndReportGates(sons, gate_brick_type, max_gate_length)
			--logger(robot.id, "gateNumber = ", gateNumber)

			-- referencing pipuck gives the moving forward command
				-- and listen newheading command from the brain
			if sons.stabilizer.referencing_me == true then
				sons.Spreader.emergency_after_core(sons, vector3(0.03,0,0), vector3())
				for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "new_heading")) do
					sons.stabilizer.referencing_me_goal_overwrite = {orientationQ = sons.parentR.orientationQ * msgM.dataT.heading}
				end
				-- stop moving forward if other pipucks are in the way
				for idS, robotR in pairs(sons.connector.seenRobots) do
					if robotR.robotTypeS == "pipuck" and
					   robotR.positionV3.x > 0 and robotR.positionV3.x < 0.25 and
					   robotR.positionV3.y > -0.25 and robotR.positionV3.y < 0.25 then
						sons.goal.transV3.x = 0
					end
				end
			end

			-- brain checks the wall and adjust heading
			if sons.parentR == nil then
				if sons.stabilizer.referencing_robot == nil then
					sons.Spreader.emergency_after_core(sons, vector3(0.03,0,0), vector3())
				end
				local receiveWall = ExperimentCommon.detectWall(sons, wall_brick_type)
				if receiveWall == nil then receiveWall = ExperimentCommon.detectWallFromReceives(sons, wall_brick_type) end
				if receiveWall ~= nil then
					sons.api.debug.drawArrow("red", vector3(),
						sons.api.virtualFrame.V3_VtoR(receiveWall.positionV3)
					)
			
					if sons.stabilizer.referencing_robot ~= nil then
						sons.Msg.send(sons.stabilizer.referencing_robot.idS, "new_heading", {heading = sons.api.virtualFrame.Q_VtoR(receiveWall.orientationQ)})
					else
						sons.setGoal(sons, sons.goal.positionV3, receiveWall.orientationQ)
					end
		
					sons.api.debug.drawArrow("blue",  
						api.virtualFrame.V3_VtoR(vector3(receiveWall.positionV3)),
						api.virtualFrame.V3_VtoR(vector3(receiveWall.positionV3) + vector3(0.2, 0, 0):rotate(receiveWall.orientationQ))
					)

					-- brain checks gate and go to next state
					local disToTheWall = receiveWall.positionV3:dot(vector3(1,0,0):rotate(receiveWall.orientationQ))
					logger("disToTheWall = ", disToTheWall, "gateNumber = ", gateNumber)
					if gateNumber == totalGateNumber and disToTheWall < 1.5 then
						switchAndSendNewState(sons, "check_gate")
						logger(robot.id, "check_gate")
					end
				end
			end

		elseif state == "check_gate" then
			stateCount = stateCount + 1
			sons.Parameters.stabilizer_preference_robot = nil

			-- If I see the gate and I'm a drone
			local gateList, gate = ExperimentCommon.detectAndReportGates(sons, gate_brick_type, max_gate_length)
			if gate ~= nil and sons.robotTypeS == "drone" then
				-- remember this gate, I may lost it later
				sons.gate = gate
				-- break with my parent
				if sons.parentR ~= nil then
					sons.Msg.send(sons.parentR.idS, "dismiss")
					sons.deleteParent(sons)
				end
				sons.Connector.newSonsID(sons, 1 + gate.length, 1)
				sons.BrainKeeper.reset(sons)
				sons.allocator.mode_switch = "stationary"
				sons.setMorphology(sons, structure2)

				newState(sons, "break_and_recruit")
				logger(robot.id, "I have a gate, breaking and recruiting")
			end
		elseif state == "break_and_recruit" then
			stateCount = stateCount + 1

			if sons.parentR == nil and sons.scalemanager.scale["drone"] == n_drone and stateCount >= 20 then
				logger(robot.id, "I got everyone, switch to structure2")
				switchAndSendNewState(sons, "switch_to_structure2")
				sons.setMorphology(sons, structure2)
				sons.allocator.mode_switch = "allocate"
				--sons.Allocator.sendAllocate(sons) -- necessary ?
			end
		elseif state == "switch_to_structure2" then
			--sons.allocator.pipuck_bridge_switch = true
			stateCount = stateCount + 1
			-- If I see the gate and I'm a drone

			-- everyone reports wall and gates
			ExperimentCommon.reportWall(sons, wall_brick_type)
			local gateList, gate = ExperimentCommon.detectAndReportGates(sons, gate_brick_type, max_gate_length, true) -- true means all report
			-- detect wall from myself, if not, from receives
			local wall = ExperimentCommon.detectWall(sons, wall_brick_type)
			if wall == nil then wall = ExperimentCommon.detectWallFromReceives(sons, wall_brick_type) end

			-- Brain detects gate, send gate and wall information to the referenced pipuck
			if sons.parentR == nil then
				--sons.stabilizer.force_pipuck_reference = true
				if gate ~= nil and math.abs(gate.length - sons.gate.length) < 0.2 then
					sons.gate = gate
					sons.setGoal(sons, gate.positionV3 + vector3(-0.5, 0, 0):rotate(gate.orientationQ), gate.orientationQ)
					-- TODO: go to next state
					local disV2 = gate.positionV3 + vector3(-0.5, 0, 0):rotate(gate.orientationQ)
					disV2.z = 0
					if disV2:length() < 0.1 then
						logger(robot.id, "I reach gate, switch to wait_forward_again")
						switchAndSendNewState(sons, "wait_forward_again")
					end
				else
					-- I don't see gate this step, move towards sons.gate
					if sons.gate ~= nil then
						local speed = vector3(sons.gate.positionV3)
						speed = speed:normalize() * 0.03
						sons.Spreader.emergency_after_core(sons, speed, vector3())
					end
				end
			end

			-- other robot try not exceed wall
			if sons.parentR ~= nil and sons.stabilizer.referencing_me ~= true then
				if wall ~= nil then
					local disV2 = vector3(wall.positionV3)
					disV2.z = 0
					local baseNormalV2 = vector3(1,0,0):rotate(wall.orientationQ)
					dis = disV2:dot(baseNormalV2)

					local color = "128,128,0,0"
					sons.api.debug.drawArrow(color,
					                        sons.api.virtualFrame.V3_VtoR(vector3(0,0,0.1)),
					                        sons.api.virtualFrame.V3_VtoR(baseNormalV2 * dis + vector3(0,0,0.1))
					                       )

					if dis < 0.2 then
						sons.goal.transV3 = sons.goal.transV3 + baseNormalV2 * (dis - 0.2)
					end
				end
			end

		elseif state == "wait_forward_again" then
			stateCount = stateCount + 1

			if sons.parentR == nil then
				if stateCount > 175 * 1 then
					switchAndSendNewState(sons, "forward_again")
					logger(robot.id, "forward_again")
				end
			end

		elseif state == "forward_again" then
			--sons.allocator.pipuck_bridge_switch = nil
			stateCount = stateCount + 1

			-- everyone reports wall and gates
			ExperimentCommon.reportWall(sons, wall_brick_type)
			local _, gate, gateNumber = ExperimentCommon.detectAndReportGates(sons, gate_brick_type, max_gate_length)
			--logger(robot.id, "gateNumber = ", gateNumber)

			-- referencing pipuck gives the moving forward command
				-- and listen newheading command from the brain
			if sons.stabilizer.referencing_me == true then
				sons.Spreader.emergency_after_core(sons, vector3(0.03,0,0), vector3())
				for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "new_heading")) do
					sons.stabilizer.referencing_me_goal_overwrite = {orientationQ = sons.parentR.orientationQ * msgM.dataT.heading}
					if msgM.dataT.gate ~= nil then
						sons.Spreader.emergency_after_core(sons, vector3(0,msgM.dataT.gate.positionV3.y * 0.1,0), vector3())
					end
				end
			end

			-- brain checks the wall and adjust heading
			if sons.parentR == nil then
				sons.stabilizer.force_pipuck_reference = true
				local receiveWall = ExperimentCommon.detectWall(sons, wall_brick_type)
				if receiveWall == nil then receiveWall = ExperimentCommon.detectWallFromReceives(sons, wall_brick_type) end
				if receiveWall ~= nil then
					sons.api.debug.drawArrow("red", vector3(),
						sons.api.virtualFrame.V3_VtoR(receiveWall.positionV3)
					)
			
					if sons.stabilizer.referencing_robot ~= nil then
						sons.Msg.send(sons.stabilizer.referencing_robot.idS, "new_heading", {
							heading = sons.api.virtualFrame.Q_VtoR(receiveWall.orientationQ),
							gate = gate,
						})
					end
		
					sons.api.debug.drawArrow("blue",  
						api.virtualFrame.V3_VtoR(vector3(receiveWall.positionV3)),
						api.virtualFrame.V3_VtoR(vector3(receiveWall.positionV3) + vector3(0.2, 0, 0):rotate(receiveWall.orientationQ))
					)

					-- brain checks target 
					local target = ExperimentCommon.detectTarget(sons, target_type)
					if target ~= nil then
						local disV2 = target.positionV3
						disV2.z = 0
						logger("disV2 = ", disV2:length())
						if disV2:length() < 1.5 then
							sons.target = target
							sons.stabilizer.force_pipuck_reference = nil
							switchAndSendNewState(sons, "structure3")
							logger(robot.id, "structure3")
							sons.setMorphology(sons, structure3)
						end
					end
				end
			end

			-- other drones that is not the brain checks the gate and try to stay middle of the gate
			if sons.robotTypeS == "drone" and sons.parentR ~= nil then
				if gate ~= nil then
					if sons.allocator.goal_overwrite == nil then
						sons.allocator.goal_overwrite = {
							positionV3 = {
								y = gate.positionV3.y
							}
						}
					end
				end
			end

		elseif state == "structure3" then
			if sons.parentR == nil then
				local target = ExperimentCommon.detectTarget(sons, target_type)
				-- update sons.target
				if target ~= nil then
					sons.target = target
				end

				-- move towards remembered sons.target
				if sons.target ~= nil then
					local new_target = Transform.AxBisC(sons.target, {positionV3 = vector3(-0.7,-0.7,0), orientationQ = quaternion()})
					sons.setGoal(sons, new_target.positionV3, new_target.orientationQ)
				end
			end
		end

		-- for debug
		sons.debugstate = {state = state, stateCount = stateCount}
		return false, true
	end
end