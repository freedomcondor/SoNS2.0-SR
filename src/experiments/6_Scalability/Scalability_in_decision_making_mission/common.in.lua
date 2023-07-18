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

-- get scalability scale
local expScale = tonumber(robot.params.exp_scale or 0)
local n_drone = tonumber(robot.params.n_drone or 1)
local morphologiesGenerator = robot.params.morphologiesGenerator
local totalGateNumber = tonumber(robot.params.gate_number or 1)

pairs = require("AlphaPairs")
ExperimentCommon = require("ExperimentCommon")
require(morphologiesGenerator)
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

--logger.enableFileLog()

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

	--if sons.robotTypeS == "pipuck" then option = {connector_no_recruit = true} end
	sons.setMorphology(sons, structure1)
	bt = BT.create
	{ type = "sequence", children = {
		sons.create_preconnector_node(sons),
		sons.create_sons_core_node(sons, option),
		sons.CollectiveSensor.create_collectivesensor_node(sons),
		create_reaction_node(sons),
		--sons.Driver.create_driver_node(sons, {waiting = true}),
		sons.Driver.create_driver_node(sons, {waiting = "spring"}),
	}}
end

--- step
function step()
	-- prestep
	-- log step
	if robot.id == "drone1" then
		if api.stepCount % 100 == 0 then
			logger("---- step ", api.stepCount, "-------------")
		end
	end

	--logger(robot.id, api.stepCount, "-----------------------")
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
	local state = robot.params.start_state or "waiting"
	--local state = "allocate_test"
	local stateCount = 0
	local stateCountMark = nil

	-- parameters ----------------
	local obstacle_type = 255
	local wall_brick_type = 254
	local gate_brick_type = 253
	local target_type = 252
	local max_gate_length = 4.2

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
		sons.allocator.self_align = true
		-- if I receive switch state cmd from parent
		if sons.parentR ~= nil then for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "switch_to_state")) do
			switchAndSendNewState(sons, msgM.dataT.state)
		end end

		-- waiting for sometime for the 1st formation
		if state == "waiting" then
			sons.allocator.pipuck_bridge_switch = true
			stateCount = stateCount + 1
			--if stateCount == 150 + expScale * 50 then
			-- brain wait for sometime and say move_forward
			if sons.parentR == nil then
				--if stateCount > 75 and sons.driver.all_arrive == true then
				if (stateCount > 250 * expScale) then
					logger(robot.id, "move_forward")
					switchAndSendNewState(sons, "move_forward")
				end
			end

		elseif state == "move_forward" then
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
				sons.stabilizer.force_pipuck_reference = true
				local receiveWall = ExperimentCommon.detectWall(sons, wall_brick_type)
				if receiveWall == nil then receiveWall = ExperimentCommon.detectWallFromReceives(sons, wall_brick_type) end
				if receiveWall ~= nil then
					sons.api.debug.drawArrow("red", vector3(),
						sons.api.virtualFrame.V3_VtoR(receiveWall.positionV3)
					)
			
					if sons.stabilizer.referencing_robot ~= nil then
						sons.Msg.send(sons.stabilizer.referencing_robot.idS, "new_heading", {heading = sons.api.virtualFrame.Q_VtoR(receiveWall.orientationQ)})
					end
		
					sons.api.debug.drawArrow("blue",  
						api.virtualFrame.V3_VtoR(vector3(receiveWall.positionV3)),
						api.virtualFrame.V3_VtoR(vector3(receiveWall.positionV3) + vector3(0.2, 0, 0):rotate(receiveWall.orientationQ))
					)

					-- brain checks gate and go to next state
					local disToTheWall = receiveWall.positionV3:dot(vector3(1,0,0):rotate(receiveWall.orientationQ))
					logger("disToTheWall = ", disToTheWall, "gateNumber = ", gateNumber)
					if gateNumber == totalGateNumber and disToTheWall < 1.75 then
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
				logger(robot.id, "I have a gate, breaking and recruiting, gate length = ", sons.gate.length)
			end
		elseif state == "break_and_recruit" then
			stateCount = stateCount + 1

			if sons.parentR == nil and sons.scalemanager.scale["drone"] == n_drone and stateCount >= expScale * 3 then
				logger(robot.id, "I got everyone, switch to structure2")
				switchAndSendNewState(sons, "switch_to_structure2")
				sons.setMorphology(sons, structure2)
				sons.allocator.mode_switch = "allocate"
				--sons.Allocator.sendAllocate(sons) -- necessary ?
			end
		elseif state == "switch_to_structure2" then
			sons.allocator.pipuck_bridge_switch = true
			stateCount = stateCount + 1
			-- If I see the gate and I'm a drone

			gate_difference_threshold = 0.5

			-- everyone reports wall and gates
			ExperimentCommon.reportWall(sons, wall_brick_type)
			local gateList, gate = ExperimentCommon.detectAndReportGates(sons, gate_brick_type, max_gate_length, true) -- true means all report
			-- detect wall from myself, if not, from receives
			local wall = ExperimentCommon.detectWall(sons, wall_brick_type)
			if wall == nil then wall = ExperimentCommon.detectWallFromReceives(sons, wall_brick_type) end

			-- Brain detects gate, send gate and wall information to the referenced pipuck
			if sons.parentR == nil then
				sons.stabilizer.force_pipuck_reference = true
				-- send both gate and wall
				local sendingGate, sendingWall, memoryGate

				-- if I see a gate, check if it is the same gate, otherwise do nothing
				if gate ~= nil then
					--if sons.gate ~= nil and math.abs(sons.gate.length - gate.length) > gate_difference_threshold then
					if sons.gate ~= nil and gate.length - sons.gate.length < -gate_difference_threshold then
						-- not the same gate, do nothing
						logger(robot.id, "Not the same gate, remember gate length = ", sons.gate.length, "seeing gate length = ", gate.length)
					else
						-- I see the target gate, update sons.gate, and prepare to send this gate
						sons.gate = gate

						if gate ~= nil then
							sendingGate = {
								positionV3 = sons.api.virtualFrame.V3_VtoR(gate.positionV3),
								orientationQ = sons.api.virtualFrame.Q_VtoR(gate.orientationQ),
								length = gate.length,
							}
						end
					end
				end
				if sons.gate ~= nil then
					memoryGate = {
						positionV3 = sons.api.virtualFrame.V3_VtoR(sons.gate.positionV3),
						orientationQ = sons.api.virtualFrame.Q_VtoR(sons.gate.orientationQ),
						length = sons.gate.length,
					}
				else
					logger(robot.id, "warning, for brain, sons.gate is nil, while there should always be one")
				end
				if wall ~= nil then
					sendingWall = {
						positionV3 = sons.api.virtualFrame.V3_VtoR(wall.positionV3),
						orientationQ = sons.api.virtualFrame.Q_VtoR(wall.orientationQ),
					}
				end

				--send to referencing robot
				if sons.stabilizer.referencing_robot ~= nil then
					sons.Msg.send(sons.stabilizer.referencing_robot.idS, "wall_and_gate", {
						gate = sendingGate, wall = sendingWall, memoryGate = memoryGate,
					})

					for _, msgM in ipairs(sons.Msg.getAM(sons.stabilizer.referencing_robot.idS, "structure2_reach")) do
						if stateCountMark == nil then
							stateCountMark = stateCount
							logger(robot.id, "reach gate, start counting")
						else
							if stateCount - stateCountMark > 175 * expScale then
								switchAndSendNewState(sons, "forward_again")
								logger(robot.id, "forward_again")
							end
							--switchAndSendNewState(sons, "wait_forward_again")
							--logger(robot.id, "wait_forward_again")
						end
					end
				end
			end

			--referencing pipuck lead the swarm to move
			if sons.stabilizer.referencing_me == true then
				-- if get gate update sons.gate
				for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "wall_and_gate")) do
					if msgM.dataT.gate ~= nil then
						-- The brain sees a gate, update my sons.gate
						sons.gate = Transform.AxBisC(sons.parentR, msgM.dataT.gate)
						sons.gate.length = msgM.dataT.gate.length
					else
						-- The brain doesn't see a gate, use my sons.gate
						-- if I don't have a sons.gate, use brain's memory
						if sons.gate == nil then 
							if msgM.dataT.memoryGate ~= nil then
								sons.gate = Transform.AxBisC(sons.parentR, msgM.dataT.memoryGate)
								sons.gate.length = msgM.dataT.memoryGate.length
							else
								logger(robot.id, "warning, for reference pipuck, sons.gate is nil, and brain isn't sending one")
							end
						end
						-- otherwise
						-- I have sons.gate, use sons.gate
					end
					if msgM.dataT.wall ~= nil then
						sons.wall = Transform.AxBisC(sons.parentR, msgM.dataT.wall)
					end
				end

				-- calculate myGoal location and orientation from sons.gate and sons.wall and my target branch
				-- calculate brainGoal
				local brainGoal = {positionV3 = sons.allocator.parentGoal.positionV3, orientationQ = sons.allocator.parentGoal.orientationQ}
				local myGoal = {positionV3 = vector3(), orientationQ = quaternion()}
				if sons.gate ~= nil then
					brainGoal.positionV3 = sons.gate.positionV3

					local color = "128,128,128,0"
					sons.api.debug.drawArrow(color,
					                        sons.api.virtualFrame.V3_VtoR(sons.gate.positionV3),
					                        sons.api.virtualFrame.V3_VtoR(sons.gate.positionV3 + vector3(0.2,0,0):rotate(sons.gate.orientationQ))
					                       )
					local color = "128,128,128,0"
					sons.api.debug.drawArrow(color,
					                        sons.api.virtualFrame.V3_VtoR(vector3()),
					                        sons.api.virtualFrame.V3_VtoR(sons.gate.positionV3)
					                       )
				end
				if sons.wall ~= nil then
					brainGoal.orientationQ = sons.wall.orientationQ
					brainGoal.positionV3 = brainGoal.positionV3 + vector3(0.3, 0, 0):rotate(sons.wall.orientationQ)
				end
				if sons.allocator.target ~= nil and sons.allocator.target.idN ~= -1 then
					Transform.AxBisC(brainGoal, sons.allocator.target, myGoal)
					myGoal.positionV3.z = 0
				else
					logger(robot.id, "referencing robot doesn't have a target")
				end

				local color = "128,128,128,0"
				sons.api.debug.drawArrow(color,
				                        sons.api.virtualFrame.V3_VtoR(vector3()),
				                        sons.api.virtualFrame.V3_VtoR(myGoal.positionV3)
				                       )
				sons.api.debug.drawArrow(color,
				                        sons.api.virtualFrame.V3_VtoR(myGoal.positionV3),
				                        sons.api.virtualFrame.V3_VtoR(myGoal.positionV3 + vector3(0.2,0,0):rotate(myGoal.orientationQ))
				                       )

				-- move to myGoal
				local disV2 = vector3(myGoal.positionV3)
				disV2.z = 0
				if disV2:length() > 0.2 then
					sons.Spreader.emergency_after_core(sons, disV2:normalize() * 0.03, vector3())
				end
				-- adjust my direction
				sons.stabilizer.referencing_me_goal_overwrite = {positionV3 = sons.goal.positionV3, orientationQ = myGoal.orientationQ}

				-- check interfering pipucks
				local frontPoint = vector3(sons.goal.transV3):normalize() * 0.15
				frontPoint.z = 0
				for idS, robotR in pairs(sons.connector.seenRobots) do
					if robotR.robotTypeS == "pipuck" and
					   (robotR.positionV3 - frontPoint):length() < 0.15 then
						sons.goal.transV3 = vector3()
					end
				end

				-- check reach
				local headingDis = (vector3(1,0,0) - vector3(1,0,0):rotate(myGoal.orientationQ)):length()
				if sons.gate ~= nil and disV2:length() < 0.2 and headingDis < 0.1 then
					sons.Msg.send(sons.parentR.idS, "structure2_reach")
				end
			end

			-- other robot try not exceed wall
			if sons.parentR ~= nil and sons.stabilizer.referencing_me ~= true and
			   sons.parentR.idS ~= sons.idS then
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
						sons.goal.transV3 = sons.goal.transV3 + baseNormalV2 * (dis - 0.2) * 5
					end
				end
			end

		--[[
		elseif state == "wait_forward_again" then
			stateCount = stateCount + 1

			if sons.parentR == nil then
				if stateCount > 175 * expScale then
					switchAndSendNewState(sons, "forward_again")
					logger(robot.id, "forward_again")
				end
			end
		--]]

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
						sons.Msg.send(sons.stabilizer.referencing_robot.idS, "new_heading", {heading = sons.api.virtualFrame.Q_VtoR(receiveWall.orientationQ)})
					end
		
					sons.api.debug.drawArrow("blue",  
						api.virtualFrame.V3_VtoR(vector3(receiveWall.positionV3)),
						api.virtualFrame.V3_VtoR(vector3(receiveWall.positionV3) + vector3(0.2, 0, 0):rotate(receiveWall.orientationQ))
					)
				end

				-- brain checks target
				local target = ExperimentCommon.detectTarget(sons, target_type)
				if target ~= nil then
					local disV2 = target.positionV3
					disV2.z = 0
					logger("disV2 = ", disV2:length())
					if disV2:length() < 1.6 then
						sons.target = target
						sons.stabilizer.force_pipuck_reference = nil
						switchAndSendNewState(sons, "structure3")
						logger(robot.id, "structure3")
						sons.setMorphology(sons, structure3)
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

			-- other pipucks try to go middle of the gate
			if sons.robotTypeS == "pipuck" and sons.stabilizer.referencing_me ~= true then 
				-- check obstacle for side of the gate
				for i, ob in ipairs(sons.avoider.obstacles) do
					if ob.type == gate_brick_type and ob.positionV3:length() < 0.3 then
						sons.goal.transV3 = sons.goal.transV3 + vector3(1,0,0):rotate(ob.orientationQ) * 0.3
					end

					local color = "255,0,0,0"
					sons.api.debug.drawArrow(color,
											sons.api.virtualFrame.V3_VtoR(vector3(0,0,0.1)),
											sons.api.virtualFrame.V3_VtoR(sons.goal.transV3 * 1 + vector3(0,0,0.1))
										   )
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
					local new_target = Transform.AxBisC(sons.target, {positionV3 = vector3(-1.0,0,0), orientationQ = quaternion()})
					sons.setGoal(sons, new_target.positionV3, new_target.orientationQ)
				end
			end

			-- other pipucks try to go middle of the gate
			if sons.robotTypeS == "pipuck" and sons.stabilizer.referencing_me ~= true then 
				-- check obstacle for side of the gate
				for i, ob in ipairs(sons.avoider.obstacles) do
					if ob.type == gate_brick_type and ob.positionV3:length() < 0.3 then
						sons.goal.transV3 = sons.goal.transV3 + vector3(1,0,0):rotate(ob.orientationQ) * 0.3
					end

					local color = "255,0,0,0"
					sons.api.debug.drawArrow(color,
											sons.api.virtualFrame.V3_VtoR(vector3(0,0,0.1)),
											sons.api.virtualFrame.V3_VtoR(sons.goal.transV3 * 1 + vector3(0,0,0.1))
										   )
				end

			end
		end

		-- for debug
		sons.debugstate = {state = state, stateCount = stateCount}
		return false, true
	end
end
