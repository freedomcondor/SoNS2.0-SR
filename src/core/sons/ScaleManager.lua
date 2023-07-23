-- ScaleManager --------------------------------------
-- This module counts the number of each type of robot in the SoNS.
-- Each robot counts the number of robots in its SoNS independantly, as a summation of the counts it recives from its parent and children:
--       This module manages the passing of counts between robots (for different branches of the SoNS) and calculates the depths of branches.
--       It collects count reports from all children and sums them and also collects the count report from the parent.
--       For each neighbor n, it sums up the reports recieved from all other neighbors, and sends it to neighbor n.
------------------------------------------------------
local ScaleManager = {}

--[[
--	related data
--	sons.scalemanager = {
--		scale
--		depth
--	}
--	sons.parentR.scalemanager = {
--		scale
--	}
--	sons.childrenRT[xxx] = {
--		scale
--		depth
--	}
--]]

ScaleManager.Scale = require("Scale")

function ScaleManager.create(sons)
	sons.scalemanager = {}
end

function ScaleManager.reset(sons)
	sons.scalemanager.scale = ScaleManager.Scale:new(sons.robotTypeS)
	sons.scalemanager.depth = 1
end

function ScaleManager.addChild(sons, robotR)
	robotR.scalemanager = {
		scale = ScaleManager.Scale:new(robotR.robotTypeS),
		depth = 1,
		lastSendScale = nil,
	}
end

--function ScaleManager.deleteChild(sons, idS)
--end

function ScaleManager.addParent(sons, robotR)
	robotR.scalemanager = {
		-- scale is set when receive scale command from parent
		scale = nil,
		lastSendScale = nil,
	}
end

--function ScaleManager.deleteParent(sons, idS)
--end

--function ScaleManager.preStep(sons)
--end

function ScaleManager.step(sons)
	-- receive scale from parent
	if sons.parentR ~= nil then for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "scale")) do
		sons.parentR.scalemanager.scale = ScaleManager.Scale:new(msgM.dataT.scale)
	end end
	-- receive scale from children
	for idS, robotR in pairs(sons.childrenRT) do 
		for _, msgM in ipairs(sons.Msg.getAM(idS, "scale")) do
			robotR.scalemanager.scale = ScaleManager.Scale:new(msgM.dataT.scale)
			robotR.scalemanager.depth = msgM.dataT.depth or 1
		end 
	end

	-- add assign_offset
	-- and check assign_offset minus
	for idS, robotR in pairs(sons.childrenRT) do 
		if robotR.assigner.scale_assign_offset ~= nil then
			robotR.scalemanager.scale = robotR.scalemanager.scale + robotR.assigner.scale_assign_offset
		end
		-- sometimes scale_assign_offset may give a false large number when multiple assigns happen parallely
		for typeS, number in pairs(robotR.scalemanager.scale) do
			if number < 0 then robotR.scalemanager.scale[typeS] = 0 end
		end
		if robotR.scalemanager.scale[robotR.robotTypeS] == nil or
		   robotR.scalemanager.scale[robotR.robotTypeS] < 1 then
			robotR.scalemanager.scale[robotR.robotTypeS] = 1
		end
	end
	if sons.parentR ~= nil and sons.parentR.assigner.scale_assign_offset ~= nil then
		sons.parentR.scalemanager.scale = sons.parentR.scalemanager.scale + sons.parentR.assigner.scale_assign_offset
		for typeS, number in pairs(sons.parentR.scalemanager.scale) do
			if number < 0 then sons.parentR.scalemanager.scale[typeS] = 0 end
		end
		if sons.parentR.scalemanager.scale[sons.parentR.robotTypeS] == nil or
		   sons.parentR.scalemanager.scale[sons.parentR.robotTypeS] < 1 then
			sons.parentR.scalemanager.scale[sons.parentR.robotTypeS] = 1
		end
	end

	-- sum up scale
	local sumScale = ScaleManager.Scale:new()
		-- add myself
	sumScale:inc(sons.robotTypeS)
		-- add parent
	if sons.parentR ~= nil then sumScale = sumScale + sons.parentR.scalemanager.scale end
		-- add children
	for idS, robotR in pairs(sons.childrenRT) do 
		sumScale = sumScale + robotR.scalemanager.scale
	end
	sons.scalemanager.scale = sumScale

	-- sum up depth
	local maxdepth = 0
	for idS, robotR in pairs(sons.childrenRT) do 
		if robotR.scalemanager.depth > maxdepth then maxdepth = robotR.scalemanager.depth end
	end
	sons.scalemanager.depth = maxdepth + 1

	-- report scale
	local toReport
	if sons.parentR ~= nil then
		toReport = sumScale - sons.parentR.scalemanager.scale
		if toReport ~= sons.parentR.scalemanager.lastSendScale or
		   sons.scalemanager.depth ~= sons.parentR.scalemanager.lastSendDepth or 
		   sons.api.stepCount % 100 == 0 then
			sons.Msg.send(sons.parentR.idS, "scale", {scale = toReport, depth = sons.scalemanager.depth})
			sons.parentR.scalemanager.lastSendScale = toReport
			sons.parentR.scalemanager.lastSendDepth = sons.scalemanager.depth
		end
	end
	for idS, robotR in pairs(sons.childrenRT) do
		toReport = sumScale - robotR.scalemanager.scale
		if toReport ~= robotR.scalemanager.lastSendScale or 
		   sons.api.stepCount % 100 == 0 then
			sons.Msg.send(idS, "scale", {scale = toReport})
			robotR.scalemanager.lastSendScale = toReport
		end
	end
end

function ScaleManager.create_scalemanager_node(sons)
	return function()
		ScaleManager.step(sons)
		return false, true
	end
end

return ScaleManager
