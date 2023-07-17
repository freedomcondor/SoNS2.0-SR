-- Assigner ------------------------------------------
-- Assigner is the module that handles handover operation of SoNS
-- Handover means A robot gives one of its children to another robot
-- The operation is like this:
--     The parent tells the child to whom it will be handover to
--     The child get the messages, and listens to the recruitment from the new parent
--     Once the new parent recruits, the child answers the recruitment and break the link with the old parent.
------------------------------------------------------
local Assigner = {}

--[[
--	related data
--	vns.assigner.targetS                -- means to whom I will be handover to
--	vns.childrenRT[xxid].assigner = {
--		targetS                         -- to whom my children will be handover to
--		scale_assign_offset             -- At the time of the parent switch, there will be short period of time when the scale (the number of downstream robots) gets calculated twice
--		                                -- This offset tries to cancel that error
--	}
--]]

-- This function is called by SoNS.create
function Assigner.create(vns)
	vns.assigner = {}
end

-- This function is called by SoNS.reset
function Assigner.reset(vns)
	vns.assigner.targetS = nil
end

-- This function is called by SoNS.addparent,
-- <robotR> is the table of the new robot
function Assigner.addParent(vns, robotR)
	robotR.assigner = {
		scale_assign_offset = vns.ScaleManager.Scale:new(),
	}
	vns.assigner.targetS = nil
	if vns.assigner.targetS == robotR.idS then
		vns.assigner.targetS = nil
	end
end

-- This function is called by SoNS.addChild,
-- <robotR> is the table of the new robot
function Assigner.addChild(vns, robotR)
	robotR.assigner = {
		scale_assign_offset = vns.ScaleManager.Scale:new(),
		targetS = nil,
	}
	if vns.assigner.targetS == robotR.idS then
		vns.assigner.targetS = nil
	end
end

-- This function is called by SoNS.deleteParent,
function Assigner.deleteParent(vns)
	vns.assigner.targetS = nil
	for idS, childR in pairs(vns.childrenRT) do
		if childR.assigner.targetS == vns.parentR.idS then
			Assigner.assign(vns, idS, nil)
		end
	end
end

-- This function is called by SoNS.deleteChild,
-- <deleting_idS> is the id of the child to be deleted
function Assigner.deleteChild(vns, deleting_idS)
	for idS, childR in pairs(vns.childrenRT) do
		if childR.assigner.targetS == deleting_idS then
			Assigner.assign(vns, idS, nil)
		end
	end
end

-- This function is called by SoNS.preStep,
function Assigner.preStep(vns)
	for idS, childR in pairs(vns.childrenRT) do
		childR.assigner.scale_assign_offset = vns.ScaleManager.Scale:new()
	end
	if vns.parentR ~= nil then
		vns.parentR.assigner.scale_assign_offset = vns.ScaleManager.Scale:new()
	end
end

-- This function is the key handover operation
-- It sends a message to the child, and update the data
function Assigner.assign(vns, childIdS, assignToIdS)
	local childR = vns.childrenRT[childIdS]
	if childR == nil then return end

	vns.Msg.send(childIdS, "assign", {assignToS = assignToIdS})
	childR.assigner.targetS = assignToIdS
end

-- This function is called by SoNS.step,
function Assigner.step(vns)
	-- listen to assign
	if vns.parentR ~= nil then for _, msgM in ipairs(vns.Msg.getAM(vns.parentR.idS, "assign")) do
		if vns.childrenRT[msgM.dataT.assignToS] == nil and
		   vns.parentR.idS ~= msgM.dataT.assignToS then
			vns.assigner.targetS = msgM.dataT.assignToS
		end
	end end

	-- listen to recruit from assigner.targetS
	for _, msgM in ipairs(vns.Msg.getAM(vns.assigner.targetS, "recruit")) do
		vns.Msg.send(msgM.fromS, "ack")

		-- sum up child scale
		local sumScale = vns.ScaleManager.Scale:new()
		-- add myself
		sumScale:inc(vns.robotTypeS)
		-- add children
		for idS, robotR in pairs(vns.childrenRT) do 
			sumScale = sumScale + robotR.scalemanager.scale
		end

		vns.Msg.send(msgM.fromS, "assign_ack", {oldParent = vns.parentR.idS, scale = sumScale})
		if vns.parentR ~= nil and vns.parentR.idS ~= vns.assigner.targetS then
			vns.Msg.send(vns.parentR.idS, "assign_dismiss", {newParent = msgM.fromS, scale = sumScale})
			vns.deleteParent(vns)
			local robotR = {
				idS = msgM.fromS,
				positionV3 = 
					vns.api.virtualFrame.V3_RtoV(
						vector3(-msgM.dataT.positionV3):rotate(msgM.dataT.orientationQ:inverse())
					),
				orientationQ = 
					vns.api.virtualFrame.Q_RtoV(
						msgM.dataT.orientationQ:inverse()
					),
				robotTypeS = msgM.dataT.fromTypeS,
			}
			vns.addParent(vns, robotR)
			vns.assigner.targetS = nil
		end
		break
	end

	-- listen to assign_dismiss
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "assign_dismiss")) do
		if vns.childrenRT[msgM.fromS] ~= nil then
			local assignTargetS = msgM.dataT.newParent
			if vns.childrenRT[assignTargetS] ~= nil then
				vns.childrenRT[assignTargetS].assigner.scale_assign_offset =
					vns.childrenRT[assignTargetS].assigner.scale_assign_offset + msgM.dataT.scale
				vns.childrenRT[assignTargetS].lastSendScale = nil
			elseif vns.parentR ~= nil and vns.parentR.idS == assignTargetS then
				vns.parentR.assigner.scale_assign_offset =
					vns.parentR.assigner.scale_assign_offset + msgM.dataT.scale
				vns.parentR.lastSendScale = nil
			end
			vns.deleteChild(vns, msgM.fromS)
		end
	end

	-- listen to assign_ack
	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "assign_ack")) do
		if vns.childrenRT[msgM.fromS] ~= nil then
			local assignFrom = msgM.dataT.oldParent
			if vns.childrenRT[assignFrom] ~= nil then
				vns.childrenRT[assignFrom].assigner.scale_assign_offset =
					vns.childrenRT[assignFrom].assigner.scale_assign_offset - msgM.dataT.scale
				vns.childrenRT[assignFrom].lastSendScale = nil
			elseif vns.parentR ~= nil and vns.parentR.idS == assignFrom then
				vns.parentR.assigner.scale_assign_offset =
					vns.parentR.assigner.scale_assign_offset - msgM.dataT.scale
				vns.parentR.lastSendScale = nil
			end
		end
	end
end

------ behaviour tree ---------------------------------------
-- A behavior tree node containing step()
function Assigner.create_assigner_node(vns)
	return function()
		Assigner.step(vns)
		return false, true
	end
end

return Assigner
