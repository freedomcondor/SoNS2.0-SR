-- Stabilizer -----------------------------------------
-- The Stabilizer module is used when a drone is the brain of its SoNS.
-- The module allows the brain to use a ground robot or obstacle that it can see on the ground as a reference to stabilize its flight.
--       If there are obstacles visible, the brain will use an obstacle as the reference.
--       If there are no obstacles, the drone will use a ground robot as the reference. In this case, the ground robot gets excluded 
--           from the allocation process of the SoNS and only moves in response to the brain or emergency messages from other robots.
------------------------------------------------------
logger.register("Stabilizer")
local Transform = require("Transform")

local Stabilizer = {}

function Stabilizer.create(sons)
	sons.stabilizer = {}
end

function Stabilizer.reset(sons)
	sons.stabilizer = {}
end

function Stabilizer.preStep(sons)
	sons.stabilizer.referencing_robot = nil
	sons.stabilizer.referencing_me = nil
	sons.stabilizer.stationary_referencing = nil
end

function Stabilizer.addParent(sons)
	for i, ob in ipairs(sons.avoider.obstacles) do
		ob.stabilizer = nil
	end
end

function Stabilizer.deleteParent(sons)
	for i, ob in ipairs(sons.avoider.obstacles) do
		ob.stabilizer = nil
	end
end

function Stabilizer.postStep(sons)
	-- effect only for brain
	if sons.parentR ~= nil then return end

	-- estimate location of the new step 
	local input_transV3 = sons.goal.transV3
	local input_rotateV3 = sons.goal.rotateV3

	-- calculate new goal
	local newGoal = {}
	newGoal.positionV3 = input_transV3 * sons.api.time.period

	local axis = vector3(input_rotateV3):normalize()
	if input_rotateV3:length() == 0 then axis = vector3(0,0,1) end
	newGoal.orientationQ = 
		quaternion(input_rotateV3:length() * sons.api.time.period, axis)

	for i, ob in ipairs(sons.avoider.obstacles) do
		if ob.stabilizer ~= nil then
			-- I should be at newGoal, I see ob.stabilizer, I should see ob as X, newGoal x X = ob.stabilizer
			Transform.AxCisB(newGoal, ob.stabilizer, ob.stabilizer)
		end
	end
end

-- called by SoNS.setGoal. If a goal is set for the robot, all the stabilizer info for obstacles needs to be updated
function Stabilizer.setGoal(sons, positionV3, orientationQ)
	local newGoal = {positionV3 = positionV3, orientationQ = orientationQ}
	for i, ob in ipairs(sons.avoider.obstacles) do
		-- I should be at newGoal, I see ob, this ob should be at my X, newGoal x X = ob
		ob.stabilizer = {}
		Transform.AxCisB(newGoal, ob, ob.stabilizer)
	end
end

function Stabilizer.step(sons)
	if sons.allocator.mode_switch ~= "stationary" then
		-- clear stationary_stabilizer information
		for idS, robotR in pairs(sons.childrenRT) do 
			if robotR.stationary_stabilizer ~= nil then
				robotR.stationary_stabilizer = nil
			end
		end
	end
	-- If I'm not the brain, and it is stationary mode don't do anything
	if sons.parentR ~= nil and sons.allocator.mode_switch ~= "stationary" then
		if sons.robotTypeS == "pipuck" then
			Stabilizer.pipuckListenRequest(sons)
		end
		return
	end
	-- If I'm a drone brain and I haven't fully taken off, don't do anything
	--if sons.robotTypeS == "drone" and sons.api.actuator.flight_preparation.state ~= "navigation" then return end
	-- If I'm a pipuck brain, I don't need stabilizer
	if sons.robotTypeS == "pipuck" then return end

	-- I'm the brain run stabilizer, and set sons.goal
	-- for each obstacle with a stabilizer, average its offset as a new goal
	local offsetAcc = Transform.createAccumulator()

	local flag = false
	for i, ob in ipairs(sons.avoider.obstacles) do
		if ob.stabilizer ~= nil and ob.unseen_count == sons.api.parameters.obstacle_unseen_count then
			flag = true
			-- add offset (choose the nearest)
			local offset = {positionV3 = vector3(), orientationQ = quaternion()}
			-- I see ob, I should see ob at ob.stabilizer, I should be at X, X x ob.stablizer = ob
			Transform.CxBisA(ob, ob.stabilizer, offset)
			-- add offset into offsetAcc
			Transform.addAccumulator(offsetAcc, offset)
			ob.stabilizer.offset = offset
		end
	end

	-- if stationary mode then also count pipucks as reference
	if sons.allocator.mode_switch == "stationary" and flag == false then
		for idS, robotR in pairs(sons.childrenRT) do if robotR.robotTypeS == "pipuck" then
			if robotR.stationary_stabilizer ~= nil and robotR.connector.unseen_count == sons.Parameters.connector_unseen_count then
				flag = true
				-- add offset (choose the nearest)
				local offset = {positionV3 = vector3(), orientationQ = quaternion()}
				-- I see ob, I should see ob at ob.stabilizer, I should be at X, X x ob.stablizer = ob
				Transform.CxBisA(robotR, robotR.stationary_stabilizer, offset)
				-- add offset into offsetAcc
				Transform.addAccumulator(offsetAcc, offset)
				robotR.stationary_stabilizer.offset = offset
			end
		end end
	elseif sons.allocator.mode_switch == "stationary" and flag == true then
		for idS, robotR in pairs(sons.childrenRT) do if robotR.robotTypeS == "pipuck" then
			if robotR.stationary_stabilizer ~= nil then
				robotR.stationary_stabilizer = nil
			end
		end end
	end

	-- filter wrong case (sometimes obstacles are too close, they may be messed up with each other)
	-- check with average and subtrack from acc
	flag = false -- flag for valid reference obstacles
	local averageOffset = Transform.averageAccumulator(offsetAcc)
	for i, ob in ipairs(sons.avoider.obstacles) do
		if ob.stabilizer ~= nil and ob.unseen_count == sons.api.parameters.obstacle_unseen_count then
			if (ob.stabilizer.offset.positionV3 - averageOffset.positionV3):length() > sons.api.parameters.obstacle_match_distance / 2 then
				Transform.subAccumulator(offsetAcc, ob.stabilizer.offset)
				ob.stabilizer = nil
			else
				flag = true
			end
			ob.offset = nil
		end
	end

	-- check if there are pipucks as a valid reference and mark flag
	if sons.allocator.mode_switch == "stationary" then
		for idS, robotR in pairs(sons.childrenRT) do if robotR.robotTypeS == "pipuck" then
			if robotR.stationary_stabilizer ~= nil and robotR.connector.unseen_count == sons.Parameters.connector_unseen_count then
				flag = true
				break
			end
		end end
	end

	local obstacle_flag = false
	for i, ob in ipairs(sons.avoider.obstacles) do
		obstacle_flag = true
		break
	end

	-- check
	local colorflag = false -- flag for whether to show circle or not
	local offset = {positionV3 = vector3(), orientationQ = quaternion()}
	if flag == true and sons.stabilizer.force_pipuck_reference ~= true then
		-- average offsetAcc into offset
		Transform.averageAccumulator(offsetAcc, offset)
		sons.goal.positionV3 = offset.positionV3
		sons.goal.orientationQ = offset.orientationQ
		colorflag = true
		--sons.allocator.keepBrainGoal = true
		sons.stabilizer.lastReference = nil
		if sons.allocator.mode_switch == "stationary" then
			sons.stabilizer.stationary_referencing = true
		end
	---[[
	elseif obstacle_flag == true and sons.stabilizer.force_pipuck_reference ~= true then
		-- There are obstacles, I just don't see them, wait to see them, set offset as the current goal
		offset.positionV3 = sons.goal.positionV3 
		offset.orientationQ = sons.goal.orientationQ
	elseif obstacle_flag == false or sons.stabilizer.force_pipuck_reference == true then
	--]]
	--else
		-- set a pipuck as reference
		local offset = Stabilizer.robotReference(sons)
		if offset == nil then
			offset = {}
			offset.positionV3 = sons.goal.positionV3
			offset.orientationQ = sons.goal.orientationQ
		else
			sons.goal.positionV3 = offset.positionV3
			sons.goal.orientationQ = offset.orientationQ
			colorflag = true
		end
	end

	-- for each new obstacle without a stabilizer, set a stabilizer
	for i, ob in ipairs(sons.avoider.obstacles) do
		if ob.stabilizer == nil then
			-- I should be at offset, I see ob, this ob should be at my X, offset x X = ob
			ob.stabilizer = {}
			Transform.AxCisB(offset, ob, ob.stabilizer)
		end
	end

	-- if stationary mode then also count pipucks as reference
	if sons.allocator.mode_switch == "stationary" then
		for idS, robotR in pairs(sons.childrenRT) do if robotR.robotTypeS == "pipuck" then
			if robotR.stationary_stabilizer == nil then
				robotR.stationary_stabilizer = {}
				Transform.AxCisB(offset, robotR, robotR.stationary_stabilizer)
			end
		end end
	end

	---[[
	if colorflag then
		local color = "255,0,255,0"
		sons.api.debug.drawArrow(color,
		                        sons.api.virtualFrame.V3_VtoR(sons.goal.positionV3),
		                        sons.api.virtualFrame.V3_VtoR(sons.goal.positionV3 + vector3(0.1,0,0):rotate(sons.goal.orientationQ))
		                       )
		sons.api.debug.drawRing(color,
		                       sons.api.virtualFrame.V3_VtoR(sons.goal.positionV3),
		                       0.1
		                      )
	end
	--]]
end

-- Choose a reference pipuck
-- if sons.Parameters.stabilizer_preference_robot is set, first try to find this robot
function Stabilizer.getReferenceChild(sons)
	-- get a reference pipuck
	---[[
	if sons.childrenRT[sons.Parameters.stabilizer_preference_robot] ~= nil then
		-- check preference
		return sons.childrenRT[sons.Parameters.stabilizer_preference_robot]
	--]]
	elseif sons.childrenRT[sons.stabilizer.lastReference] ~= nil then
	--if sons.childrenRT[sons.stabilizer.lastReference] ~= nil then
		return sons.childrenRT[sons.stabilizer.lastReference]
	else
		-- get the nearest to reference pipuck in morphology
		-- get the reference pipuck in morphology
		local reference_position = nil
		if sons.allocator.target.children ~= nil then
			local flag = false
			for _, branch in ipairs(sons.allocator.target.children) do
				if branch.reference == true then
					reference_position = branch.positionV3
					flag = true
					break
				end
			end
			if flag == false then
				for _, branch in ipairs(sons.allocator.target.children) do
					if branch.robotTypeS == "pipuck" then
						reference_position = branch.positionV3
						break
					end
				end
			end
		end

		if reference_position == nil then return end

		local nearestDis = math.huge
		local ref = nil
		for idS, robotR in pairs(sons.childrenRT) do
			local locV3 = robotR.positionV3 - reference_position
			locV3.z = 0
			local dis = locV3:length()
			if robotR.robotTypeS == "pipuck" and dis < nearestDis then
				nearestDis = dis
				ref = robotR
			end
		end
		if ref ~= nil then
			sons.stabilizer.lastReference = ref.idS
		end
		return ref
	end
end

-- If I am a referenced pipuck
-- I try to stay, and ask other pipuck to avoid me harder (when the swarm is too crowded, there may be other pipuck bumping)
function Stabilizer.pipuckListenRequest(sons)
	-- listen to referencing pipuck, avoid it harder in avoider
	sons.stabilizer.referencing_pipuck_neighbour = nil
	for _, msgM in ipairs(sons.Msg.getAM("ALLMSG", "I_am_referenced_pipuck")) do
		sons.stabilizer.referencing_pipuck_neighbour = msgM.fromS
	end

	for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "stabilizer_request")) do
		sons.stabilizer.referencing_me = true
		sons.stabilizer.referencing_me_count_down = sons.Parameters.reference_count_down
	end

	if sons.stabilizer.referencing_me_count_down ~= nil then
		if sons.stabilizer.referencing_me_count_down > 0 then
			sons.stabilizer.referencing_me_count_down =
				sons.stabilizer.referencing_me_count_down - 1
			sons.stabilizer.referencing_me = true
		else
			sons.stabilizer.referencing_me = nil
		end
	end

	if sons.stabilizer.referencing_me == true then
		-- tell other pipuck I'm referenced, so that they know to avoid me harder
		for idS, robotR in pairs(sons.connector.seenRobots) do
			if robotR.robotTypeS == "pipuck" then
				sons.Msg.send(idS, "I_am_referenced_pipuck")
			end
		end

		-- calculate where my parent should be related to me
		local parentTransform = {}
		if sons.allocator.target == nil or sons.allocator.target.idN == -1 then
			return
			--parentTransform.positionV3 = vector3()
			--parentTransform.orientationQ = quaternion()
		else
			if sons.stabilizer.referencing_me_goal_overwrite ~= nil then
				local myGoal = {positionV3 = vector3(), orientationQ = quaternion()}
				if sons.stabilizer.referencing_me_goal_overwrite.positionV3 ~= nil then
					myGoal.positionV3 = sons.stabilizer.referencing_me_goal_overwrite.positionV3
				end
				if sons.stabilizer.referencing_me_goal_overwrite.orientationQ ~= nil then
					myGoal.orientationQ = sons.stabilizer.referencing_me_goal_overwrite.orientationQ
				end
				Transform.AxCisB(sons.allocator.target, myGoal, parentTransform)
			else
				Transform.AxCis0(sons.allocator.target, parentTransform)
			end
		end

		sons.Msg.send(sons.parentR.idS, "stabilizer_reply", {
			parentTransform = {
				positionV3 = sons.api.virtualFrame.V3_VtoR(parentTransform.positionV3),
				orientationQ = sons.api.virtualFrame.Q_VtoR(parentTransform.orientationQ),
			},
		})

		-- The goal of referencing pipuck will be over written in Allocator
		sons.goal.positionV3 = vector3()
		sons.goal.orientationQ = quaternion()

		if sons.stabilizer.referencing_me_goal_overwrite ~= nil then
			if sons.stabilizer.referencing_me_goal_overwrite.positionV3 ~= nil then
				sons.goal.positionV3 = sons.stabilizer.referencing_me_goal_overwrite.positionV3
			end
			if sons.stabilizer.referencing_me_goal_overwrite.orientationQ ~= nil then
				sons.goal.orientationQ = sons.stabilizer.referencing_me_goal_overwrite.orientationQ
			end
			--sons.stabilizer.referencing_me_goal_overwrite = nil
		end

		local color = "255,0,255,0"
		sons.api.debug.drawRing(color,
		                       sons.api.virtualFrame.V3_VtoR(sons.goal.positionV3 + vector3(0,0,0.1)),
		                       0.1
		                      )
	end
end

-- If I see no obstacles, I run this function, choose a pipuck and reference it to stabilzer myself
function Stabilizer.robotReference(sons)
	local refRobot = Stabilizer.getReferenceChild(sons)
	if refRobot == nil then return nil end

	sons.stabilizer.referencing_robot = refRobot

	local color = "255,0,255,0"
	sons.api.debug.drawArrow(color,
	                        sons.api.virtualFrame.V3_VtoR(vector3()),
	                        sons.api.virtualFrame.V3_VtoR(refRobot.positionV3)
	                       )

	logger("try referencing", refRobot.idS)
	sons.Msg.send(refRobot.idS, "stabilizer_request")
	for _, msgM in ipairs(sons.Msg.getAM(refRobot.idS, "stabilizer_reply")) do
		logger("get referencing reply from", refRobot.idS)
		local offset = msgM.dataT.parentTransform
		Transform.AxBisC(refRobot, offset, offset)
		-- TODO: check?

		return offset
	end
end

------ behaviour tree ---------------------------------------
function Stabilizer.create_stabilizer_node(sons)
	return function()
		Stabilizer.step(sons)
		return false, true
	end
end

return Stabilizer
