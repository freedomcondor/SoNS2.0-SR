-- Spreader -----------------------------------------
-- The Spreader module facilitates an emergency message that should spread to the whole SoNS.
-- The emergency message is used when any robot wants to trigger the whole SoNS to move towards a certain direction.
-- When a robot receives an emergency message from a neighbor (parent or child), it immediately sends it to all its other neighbors.
------------------------------------------------------
local Spreader = {}

function Spreader.create(sons)
	sons.spreader = {}
end

function Spreader.reset(sons)
	sons.spreader.spreading_speed = {positionV3 = vector3(), orientationV3 = vector3(), flag = nil,}
end

function Spreader.preStep(sons)
	local chillRate = 0.1
	sons.spreader.spreading_speed.positionV3 = sons.spreader.spreading_speed.positionV3 * chillRate
	sons.spreader.spreading_speed.orientationV3 = sons.spreader.spreading_speed.orientationV3 * chillRate
	sons.spreader.spreading_speed.flag = nil
end

-- Issue a emergency message after the SoNS core module get executed
-- <transV3> and <rotateV3> is the velocity and rotation velocity the robot wants the whole swarm to move
-- <flag> is just an additional payload that the robot wants the whole swarm to know, can be anything
function Spreader.emergency_after_core(sons, transV3, rotateV3, flag)
	Spreader.emergency(sons, transV3, rotateV3, flag, true)
end

-- Issue a emergency message
-- <transV3> and <rotateV3> is the velocity and rotation velocity the robot wants the whole swarm to move
-- <flag> is just an additional payload that the robot wants the whole swarm to know, can be anything
-- <after_core> is a flag showing whether this emergency is before or after SoNS core module executed
function Spreader.emergency(sons, transV3, rotateV3, flag, after_core)
	sons.spreader.spreading_speed.positionV3 = sons.spreader.spreading_speed.positionV3 + transV3
	sons.spreader.spreading_speed.orientationV3 = sons.spreader.spreading_speed.orientationV3 + rotateV3
	flag = flag or sons.spreader.spreading_speed.flag
	sons.spreader.spreading_speed.flag = flag

	if after_core == true then
		sons.goal.transV3 = 
			sons.goal.transV3 + transV3
		sons.goal.rotateV3 = 
			sons.goal.rotateV3 + rotateV3
	end

	-- message from children, send to parent
	if sons.parentR ~= nil then
		sons.Msg.send(sons.parentR.idS, "emergency", {
			transV3 = sons.api.virtualFrame.V3_VtoR(transV3), 
			rotateV3 = sons.api.virtualFrame.V3_VtoR(rotateV3), 
			flag = flag,
		})
	end

	for idS, childR in pairs(sons.childrenRT) do
		sons.Msg.send(idS, "emergency", {
			transV3 = sons.api.virtualFrame.V3_VtoR(transV3), 
			rotateV3 = sons.api.virtualFrame.V3_VtoR(rotateV3), 
			flag = flag,
		})
	end
end

-- <surpress_or_not> if true, the spread speed will surpress other velocity component from sons.goal.transV3
function Spreader.step(sons, surpress_or_not)
	for _, msgM in ipairs(sons.Msg.getAM("ALLMSG", "emergency")) do
		if sons.childrenRT[msgM.fromS] ~= nil or 
		   sons.parentR ~= nil and sons.parentR.idS == msgM.fromS then -- else continue
		
		local fromRobotR = sons.childrenRT[msgM.fromS] or sons.parentR

		local transV3 = sons.api.virtualFrame.V3_RtoV(
			vector3(msgM.dataT.transV3):rotate(
				sons.api.virtualFrame.Q_VtoR(fromRobotR.orientationQ)
			)
		)
		local rotateV3 = sons.api.virtualFrame.V3_RtoV(
			vector3(msgM.dataT.rotateV3):rotate(
				sons.api.virtualFrame.Q_VtoR(fromRobotR.orientationQ)
			)
		)
		local flag = msgM.dataT.flag

		sons.spreader.spreading_speed.positionV3 = sons.spreader.spreading_speed.positionV3 + transV3
		sons.spreader.spreading_speed.orientationV3 = sons.spreader.spreading_speed.orientationV3 + rotateV3
		flag = flag or sons.spreader.spreading_speed.flag
		sons.spreader.spreading_speed.flag = flag

		-- message from children, send to parent
		if sons.childrenRT[msgM.fromS] ~= nil then
			if sons.parentR ~= nil then
				sons.Msg.send(sons.parentR.idS, "emergency", {
					transV3 = sons.api.virtualFrame.V3_VtoR(transV3), 
					rotateV3 = sons.api.virtualFrame.V3_VtoR(rotateV3), 
					flag = flag,
				})
			end
		end

		for idS, childR in pairs(sons.childrenRT) do
			if idS ~= msgM.fromS then
				sons.Msg.send(idS, "emergency", {
					transV3 = sons.api.virtualFrame.V3_VtoR(transV3), 
					rotateV3 = sons.api.virtualFrame.V3_VtoR(rotateV3), 
					flag = flag,
				})
			end
		end
	end end

	if surpress_or_not == true then
		sons.goal.transV3 = sons.spreader.spreading_speed.positionV3
		sons.goal.rotateV3 = sons.spreader.spreading_speed.orientationV3
	else
		sons.goal.transV3 = 
			sons.goal.transV3 + sons.spreader.spreading_speed.positionV3
		sons.goal.rotateV3 = 
			sons.goal.rotateV3 + sons.spreader.spreading_speed.orientationV3
	end
end

function Spreader.create_spreader_node(sons)
	return function()
		Spreader.step(sons)
	end
end

return Spreader
