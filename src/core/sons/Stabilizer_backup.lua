-- stabilizer -----------------------------------------
-- This is an old version Stabilizer, please refer to Stabilizer.lua
------------------------------------------------------
logger.register("Stabilizer")
local Stabilizer = {}

function Stabilizer.create(sons)
	sons.stabilizer = {
		allocator_signal = nil, -- for allocator
		-- how much should I move in this step
		step_offset = {
			positionV3 = vector3(),
			orientationQ = quaternion(),
		},
		-- location of the goal based on the reference object
		reference_offset = {
			positionV3 = vector3(),
			orientationQ = quaternion(),
		},
		reference = nil,
	}
end

function Stabilizer.reset(sons)
	sons.stabilizer = {
		allocator_signal = nil,
		step_offset = {
			positionV3 = vector3(),
			orientationQ = quaternion(),
		},
		reference_offset = {
			positionV3 = vector3(),
			orientationQ = quaternion(),
		},
		reference = nil,
	}
end

function Stabilizer.preStep(sons)
end

function Stabilizer.postStep(sons)
	-- estimate location of the new step 
	-- based on spreader.spreading_speed
	-- assuming this happens before avoider and after reaction_node
	local input_transV3 = sons.goal.transV3
	local input_rotateV3 = sons.goal.rotateV3
	--local input_transV3 = sons.spreader.spreading_speed.positionV3
	--local input_rotateV3 = sons.spreader.spreading_speed.orientationV3
	sons.stabilizer.step_offset.positionV3 = input_transV3 * sons.api.time.period
	local axis = vector3(input_rotateV3):normalize()
	if input_rotateV3:length() == 0 then axis = vector3(0,0,1) end
	sons.stabilizer.step_offset.orientationV3 = 
		quaternion(input_rotateV3:length() * sons.api.time.period, axis)

	--[[
	if sons.robotTypeS == "pipuck" and sons.parentR ~= nil then
		for _, msgM in pairs(sons.Msg.getAM(sons.parentR.idS, "you_are_a_reference")) do
			sons.Msg.send(sons.parentR.idS, "reference_estimated_location_report", 
			{
				positionV3 = sons.api.virtualFrame.V3_VtoR(sons.api.estimateLocation.positionV3),
				orientationQ = sons.api.virtualFrame.Q_VtoR(sons.api.estimateLocation.orientationQ),
			})
		end
	end
	--]]
end

function Stabilizer.setGoal(sons, positionV3, orientationQ)
	if sons.stabilizer.reference ~= nil then
		sons.stabilizer.reference_offset.positionV3 = 
			(positionV3 - sons.stabilizer.reference.positionV3):rotate(
				sons.stabilizer.reference.orientationQ:inverse()
			)
		sons.stabilizer.reference_offset.orientationQ = sons.stabilizer.reference.orientationQ:inverse() *
													   orientationQ
	end
end

function Stabilizer.step(sons)
	if sons.parentR ~= nil then
		-- I'm not the brain
		sons.stabilizer.allocator_signal = nil
	else
		-- I'm the brain run stabilizer, and set sons.goal

		-- reverse calculation
		-- A.positionV3, A.orientationQ
		-- in A's eye, I'm at
		--   position:     (-A.positionV3):rotate(A.orientationQ:inverse())
		--   orientation:  A.orientationQ:inverse()

		--[[
			A.positionV3, A.orientationQ
			myVec in A's eye
				(myVec-A.positionV3):rotate(A.orientationQ:inverse())
			myQua in A's eye
				A.orientationQ:inverse() * myQua
		--]]
	

		-- find a reference
		local current_reference = Stabilizer.getNearestReference(sons)
		if current_reference == nil then 
			sons.stabilizer.allocator_signal = nil
			return 
		end
		-- if it is not the same one
		--     reset reference and reference_offset
		if sons.stabilizer.reference == nil or
		   (current_reference.positionV3 - sons.stabilizer.reference.positionV3):length() > 0.1 then --TODO set a parameter
			sons.stabilizer.reference_offset = {
				positionV3 = vector3(-current_reference.positionV3):rotate(current_reference.orientationQ:inverse()),
				orientationQ = current_reference.orientationQ:inverse(),
			}
		end
		sons.stabilizer.reference = current_reference

		-- if it is not stable
		--      ask and receive estimated location from it
		--      add it to reference_offset
		--[[
		if sons.stabilizer.reference.robotTypeS == "pipuck" then
			sons.Msg.send(sons.stabilizer.reference.idS, "you_are_a_reference")
			for _, msgM in pairs(sons.Msg.getAM(sons.stabilizer.reference.idS, "reference_estimated_location_report")) do
				--reference_offset in estimated location's eye
				sons.stabilizer.reference_offset.positionV3 = 
					vector3(sons.stabilizer.reference_offset.positionV3 - msgM.dataT.positionV3):rotate(
						msgM.dataT.orientationQ:inverse()
					)
				sons.stabilizer.reference_offset.orientationQ = 
					msgM.dataT.orientationQ:inverse() *
					sons.stabilizer.reference_offset.orientationQ
			end
		end
		--]]
		
		-- add goal into reference
		--[[
		sons.stabilizer.reference_offset.positionV3 = 
			sons.stabilizer.reference_offset.positionV3 + 
			vector3(sons.goal.positionV3):rotate(sons.stabilizer.reference_offset.orientationQ)
		sons.stabilizer.reference_offset.orientationQ = sons.stabilizer.reference_offset.orientationQ * 
		                                               sons.goal.orientationQ
		--]]

		--draw reference
		sons.api.debug.drawArrow("255,255,0,0", 
		    sons.api.virtualFrame.V3_VtoR(sons.stabilizer.reference.positionV3), 
		    sons.api.virtualFrame.V3_VtoR(
				sons.stabilizer.reference.positionV3 + vector3(sons.stabilizer.reference_offset.positionV3):rotate(
					sons.stabilizer.reference.orientationQ
				)
			)
		)

		sons.api.debug.drawArrow("255,255,0,0", 
		    sons.api.virtualFrame.V3_VtoR(
				sons.stabilizer.reference.positionV3 + vector3(sons.stabilizer.reference_offset.positionV3):rotate(
					sons.stabilizer.reference.orientationQ
				)
			),

		    sons.api.virtualFrame.V3_VtoR(
				sons.stabilizer.reference.positionV3 + vector3(sons.stabilizer.reference_offset.positionV3):rotate(
					sons.stabilizer.reference.orientationQ
				) 
				+ 
				vector3(0.2, 0, 0):rotate(sons.stabilizer.reference.orientationQ * sons.stabilizer.reference_offset.orientationQ)
			)
		)

		--[[
		-- estimate location of the new step 
		-- based on spreader.spreading_speed
		-- assuming this happens before avoider and after reaction_node
		sons.stabilizer.step_offset.positionV3 = sons.spreader.spreading_speed.positionV3 * sons.api.time.period
		local axis = vector3(sons.spreader.spreading_speed.orientationV3):normalize()
		if sons.spreader.spreading_speed.orientationV3:length() == 0 then axis = vector3(0,0,1) end
		sons.stabilizer.step_offset.orientationV3 = 
			quaternion(sons.spreader.spreading_speed.orientationV3:length() * sons.api.time.period, axis)
		--]]

		-- accumulate step_offset to reference_offset
		-- offset in reference obstacle's eye
		sons.stabilizer.reference_offset.positionV3 = 
			sons.stabilizer.reference_offset.positionV3 + 
			vector3(sons.stabilizer.step_offset.positionV3):rotate(sons.stabilizer.reference_offset.orientationQ)
		sons.stabilizer.reference_offset.orientationQ = sons.stabilizer.reference_offset.orientationQ * 
		                                               sons.stabilizer.step_offset.orientationQ

		-- accumulate reference_offset to goal
		sons.goal.positionV3 = sons.stabilizer.reference.positionV3 + 
		                      vector3(sons.stabilizer.reference_offset.positionV3):rotate(sons.stabilizer.reference.orientationQ)
		sons.goal.orientationQ = sons.stabilizer.reference.orientationQ * sons.stabilizer.reference_offset.orientationQ

		logger("stablizer reference: ")
		logger(sons.stabilizer.reference)
		logger("stablizer step: end step")
		logger("sons.goal.positionV3 = ", sons.goal.positionV3)
		logger("sons.goal.orientationQ X = ", vector3(1,0,0):rotate(sons.goal.orientationQ))
		logger("                      Y = ", vector3(0,1,0):rotate(sons.goal.orientationQ))
		logger("                      Z = ", vector3(0,0,1):rotate(sons.goal.orientationQ))
		-- tell allocator to use sons.goal for the brain
		sons.stabilizer.allocator_signal = true
	end
end

function Stabilizer.getNearestReference(sons)
	-- get nearest obstacle first
	-- if no obstacle in sight, get nearest pipuck
	local distance = math.huge
	local nearest = nil
	for i, obstacle in ipairs(sons.avoider.obstacles) do
		if obstacle.positionV3:length() < distance then
			distance = obstacle.positionV3:length()
			nearest = obstacle
		end
	end
	--[[
	if nearest == nil then
		local distance = math.huge
		for idS, robotR in pairs(sons.connector.seenRobots) do
			if robotR.robotTypeS == "pipuck" and
			   robotR.positionV3:length() < distance then
				distance = robotR.positionV3:length()
				nearest = robotR 
			end
		end
	end
	--]]
	return nearest
end

------ behaviour tree ---------------------------------------
function Stabilizer.create_stabilizer_node(sons)
	return function()
		Stabilizer.step(sons)
		return false, true
	end
end

return Stabilizer
