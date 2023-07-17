-- Spreader -----------------------------------------
-- Spreader spreads a message to the whole SoNS.
-- It is used when a robot sees an (for example) predator, and wants the whole swarm to move towards a direction
-- The message spread is started by emergency() function, explained below
-- Each robot receives a spread message from a neighbour (parent or children), and send it to other neighbours
------------------------------------------------------
local Spreader = {}

function Spreader.create(vns)
	vns.spreader = {}
end

function Spreader.reset(vns)
	vns.spreader.spreading_speed = {positionV3 = vector3(), orientationV3 = vector3(), flag = nil,}
end

function Spreader.preStep(vns)
	local chillRate = 0.1
	vns.spreader.spreading_speed.positionV3 = vns.spreader.spreading_speed.positionV3 * chillRate
	vns.spreader.spreading_speed.orientationV3 = vns.spreader.spreading_speed.orientationV3 * chillRate
	vns.spreader.spreading_speed.flag = nil
end

-- Issue a emergency message after the SoNS core module get executed
-- <transV3> and <rotateV3> is the velocity and rotation velocity the robot wants the whole swarm to move
-- <flag> is just an additional payload that the robot wants the whole swarm to know, can be anything
function Spreader.emergency_after_core(vns, transV3, rotateV3, flag)
	Spreader.emergency(vns, transV3, rotateV3, flag, true)
end

-- Issue a emergency message
-- <transV3> and <rotateV3> is the velocity and rotation velocity the robot wants the whole swarm to move
-- <flag> is just an additional payload that the robot wants the whole swarm to know, can be anything
-- <after_core> is a flag showing whether this emergency is before or after SoNS core module executed
function Spreader.emergency(vns, transV3, rotateV3, flag, after_core)
	vns.spreader.spreading_speed.positionV3 = vns.spreader.spreading_speed.positionV3 + transV3
	vns.spreader.spreading_speed.orientationV3 = vns.spreader.spreading_speed.orientationV3 + rotateV3
	flag = flag or vns.spreader.spreading_speed.flag
	vns.spreader.spreading_speed.flag = flag

	if after_core == true then
		vns.goal.transV3 = 
			vns.goal.transV3 + transV3
		vns.goal.rotateV3 = 
			vns.goal.rotateV3 + rotateV3
	end

	-- message from children, send to parent
	if vns.parentR ~= nil then
		vns.Msg.send(vns.parentR.idS, "emergency", {
			transV3 = vns.api.virtualFrame.V3_VtoR(transV3), 
			rotateV3 = vns.api.virtualFrame.V3_VtoR(rotateV3), 
			flag = flag,
		})
	end

	for idS, childR in pairs(vns.childrenRT) do
		vns.Msg.send(idS, "emergency", {
			transV3 = vns.api.virtualFrame.V3_VtoR(transV3), 
			rotateV3 = vns.api.virtualFrame.V3_VtoR(rotateV3), 
			flag = flag,
		})
	end
end

-- <surpress_or_not> if true, the spread speed will surpress other velocity component from vns.goal.transV3
function Spreader.step(vns, surpress_or_not)
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "emergency")) do
		if vns.childrenRT[msgM.fromS] ~= nil or 
		   vns.parentR ~= nil and vns.parentR.idS == msgM.fromS then -- else continue
		
		local fromRobotR = vns.childrenRT[msgM.fromS] or vns.parentR

		local transV3 = vns.api.virtualFrame.V3_RtoV(
			vector3(msgM.dataT.transV3):rotate(
				vns.api.virtualFrame.Q_VtoR(fromRobotR.orientationQ)
			)
		)
		local rotateV3 = vns.api.virtualFrame.V3_RtoV(
			vector3(msgM.dataT.rotateV3):rotate(
				vns.api.virtualFrame.Q_VtoR(fromRobotR.orientationQ)
			)
		)
		local flag = msgM.dataT.flag

		vns.spreader.spreading_speed.positionV3 = vns.spreader.spreading_speed.positionV3 + transV3
		vns.spreader.spreading_speed.orientationV3 = vns.spreader.spreading_speed.orientationV3 + rotateV3
		flag = flag or vns.spreader.spreading_speed.flag
		vns.spreader.spreading_speed.flag = flag

		-- message from children, send to parent
		if vns.childrenRT[msgM.fromS] ~= nil then
			if vns.parentR ~= nil then
				vns.Msg.send(vns.parentR.idS, "emergency", {
					transV3 = vns.api.virtualFrame.V3_VtoR(transV3), 
					rotateV3 = vns.api.virtualFrame.V3_VtoR(rotateV3), 
					flag = flag,
				})
			end
		end

		for idS, childR in pairs(vns.childrenRT) do
			if idS ~= msgM.fromS then
				vns.Msg.send(idS, "emergency", {
					transV3 = vns.api.virtualFrame.V3_VtoR(transV3), 
					rotateV3 = vns.api.virtualFrame.V3_VtoR(rotateV3), 
					flag = flag,
				})
			end
		end
	end end

	if surpress_or_not == true then
		vns.goal.transV3 = vns.spreader.spreading_speed.positionV3
		vns.goal.rotateV3 = vns.spreader.spreading_speed.orientationV3
	else
		vns.goal.transV3 = 
			vns.goal.transV3 + vns.spreader.spreading_speed.positionV3
		vns.goal.rotateV3 = 
			vns.goal.rotateV3 + vns.spreader.spreading_speed.orientationV3
	end
end

function Spreader.create_spreader_node(vns)
	return function()
		Spreader.step(vns)
	end
end

return Spreader
