-- Assigner ------------------------------------------
-- The Assigner module executes handover operations, in which one robot gives one of its children to another robot.
-- The operation is:
--     The parent tells the child to whom it will be handed over.
--     The child get the handover messages, and listens to the recruitment messages from the new parent.
--     The child accepts the recruitment messages and breaks the link with its old parent.
------------------------------------------------------
local Assigner = {}

--[[
--	related data
--	sons.assigner.targetS                -- means to whom I will be handover to
--	sons.childrenRT[xxid].assigner = {
--		targetS                         -- to whom my children will be handover to
--		scale_assign_offset             -- At the time of the parent switch, there will be short period of time when the scale (the number of downstream robots) gets calculated twice
--		                                -- This offset tries to cancel that error
--	}
--]]

-- This function is called by SoNS.create
function Assigner.create(sons)
	sons.assigner = {}
end

-- This function is called by SoNS.reset
function Assigner.reset(sons)
	sons.assigner.targetS = nil
end

-- This function is called by SoNS.addparent,
-- <robotR> is the table of the new robot
function Assigner.addParent(sons, robotR)
	robotR.assigner = {
		scale_assign_offset = sons.ScaleManager.Scale:new(),
	}
	sons.assigner.targetS = nil
	if sons.assigner.targetS == robotR.idS then
		sons.assigner.targetS = nil
	end
end

-- This function is called by SoNS.addChild,
-- <robotR> is the table of the new robot
function Assigner.addChild(sons, robotR)
	robotR.assigner = {
		scale_assign_offset = sons.ScaleManager.Scale:new(),
		targetS = nil,
	}
	if sons.assigner.targetS == robotR.idS then
		sons.assigner.targetS = nil
	end
end

-- This function is called by SoNS.deleteParent,
function Assigner.deleteParent(sons)
	sons.assigner.targetS = nil
	for idS, childR in pairs(sons.childrenRT) do
		if childR.assigner.targetS == sons.parentR.idS then
			Assigner.assign(sons, idS, nil)
		end
	end
end

-- This function is called by SoNS.deleteChild,
-- <deleting_idS> is the id of the child to be deleted
function Assigner.deleteChild(sons, deleting_idS)
	for idS, childR in pairs(sons.childrenRT) do
		if childR.assigner.targetS == deleting_idS then
			Assigner.assign(sons, idS, nil)
		end
	end
end

-- This function is called by SoNS.preStep,
function Assigner.preStep(sons)
	for idS, childR in pairs(sons.childrenRT) do
		childR.assigner.scale_assign_offset = sons.ScaleManager.Scale:new()
	end
	if sons.parentR ~= nil then
		sons.parentR.assigner.scale_assign_offset = sons.ScaleManager.Scale:new()
	end
end

-- This function is the key handover operation
-- It sends a message to the child, and update the data
function Assigner.assign(sons, childIdS, assignToIdS)
	local childR = sons.childrenRT[childIdS]
	if childR == nil then return end

	sons.Msg.send(childIdS, "assign", {assignToS = assignToIdS})
	childR.assigner.targetS = assignToIdS
end

-- This function is called by SoNS.step,
function Assigner.step(sons)
	-- listen to assign
	if sons.parentR ~= nil then for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "assign")) do
		if sons.childrenRT[msgM.dataT.assignToS] == nil and
		   sons.parentR.idS ~= msgM.dataT.assignToS then
			sons.assigner.targetS = msgM.dataT.assignToS
		end
	end end

	-- listen to recruit from assigner.targetS
	for _, msgM in ipairs(sons.Msg.getAM(sons.assigner.targetS, "recruit")) do
		sons.Msg.send(msgM.fromS, "ack")

		-- sum up child scale
		local sumScale = sons.ScaleManager.Scale:new()
		-- add myself
		sumScale:inc(sons.robotTypeS)
		-- add children
		for idS, robotR in pairs(sons.childrenRT) do 
			sumScale = sumScale + robotR.scalemanager.scale
		end

		sons.Msg.send(msgM.fromS, "assign_ack", {oldParent = sons.parentR.idS, scale = sumScale})
		if sons.parentR ~= nil and sons.parentR.idS ~= sons.assigner.targetS then
			sons.Msg.send(sons.parentR.idS, "assign_dismiss", {newParent = msgM.fromS, scale = sumScale})
			sons.deleteParent(sons)
			local robotR = {
				idS = msgM.fromS,
				positionV3 = 
					sons.api.virtualFrame.V3_RtoV(
						vector3(-msgM.dataT.positionV3):rotate(msgM.dataT.orientationQ:inverse())
					),
				orientationQ = 
					sons.api.virtualFrame.Q_RtoV(
						msgM.dataT.orientationQ:inverse()
					),
				robotTypeS = msgM.dataT.fromTypeS,
			}
			sons.addParent(sons, robotR)
			sons.assigner.targetS = nil
		end
		break
	end

	-- listen to assign_dismiss
	for _, msgM in ipairs(sons.Msg.getAM("ALLMSG", "assign_dismiss")) do
		if sons.childrenRT[msgM.fromS] ~= nil then
			local assignTargetS = msgM.dataT.newParent
			if sons.childrenRT[assignTargetS] ~= nil then
				sons.childrenRT[assignTargetS].assigner.scale_assign_offset =
					sons.childrenRT[assignTargetS].assigner.scale_assign_offset + msgM.dataT.scale
				sons.childrenRT[assignTargetS].lastSendScale = nil
			elseif sons.parentR ~= nil and sons.parentR.idS == assignTargetS then
				sons.parentR.assigner.scale_assign_offset =
					sons.parentR.assigner.scale_assign_offset + msgM.dataT.scale
				sons.parentR.lastSendScale = nil
			end
			sons.deleteChild(sons, msgM.fromS)
		end
	end

	-- listen to assign_ack
	for _, msgM in ipairs(sons.Msg.getAM("ALLMSG", "assign_ack")) do
		if sons.childrenRT[msgM.fromS] ~= nil then
			local assignFrom = msgM.dataT.oldParent
			if sons.childrenRT[assignFrom] ~= nil then
				sons.childrenRT[assignFrom].assigner.scale_assign_offset =
					sons.childrenRT[assignFrom].assigner.scale_assign_offset - msgM.dataT.scale
				sons.childrenRT[assignFrom].lastSendScale = nil
			elseif sons.parentR ~= nil and sons.parentR.idS == assignFrom then
				sons.parentR.assigner.scale_assign_offset =
					sons.parentR.assigner.scale_assign_offset - msgM.dataT.scale
				sons.parentR.lastSendScale = nil
			end
		end
	end
end

------ behaviour tree ---------------------------------------
-- A behavior tree node containing step()
function Assigner.create_assigner_node(sons)
	return function()
		Assigner.step(sons)
		return false, true
	end
end

return Assigner
