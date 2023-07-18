-- BrainKeeper ---------------------------------------
-- The BrainKeeper module (locally) remembers the position of the brain for each robot.
-- If the robot got seperated from the SoNS, it can potentially choose to move towards the last remembered brain location to try to get re-connected.
------------------------------------------------------

local BrainKeeper = {}

--[[
--	sons.brainkeeper.brain = {positionV3, orientationQ}
--]]

function BrainKeeper.create(sons)
	-- forget the brain after countdown
	-- countdown time is set from sons.Parameters.brainkeeper_time
	sons.brainkeeper = {countdown = 0}
end

function BrainKeeper.reset(sons)
	sons.brainkeeper = {countdown = 0}
end

function BrainKeeper.deleteParent(sons)
end

function BrainKeeper.preStep(sons)
end

function BrainKeeper.step(sons)
	-- receive brain location from parent
	if sons.parentR ~= nil then for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "brain_location")) do
		sons.brainkeeper.brain = {
			positionV3 = sons.parentR.positionV3 +
			             vector3(msgM.dataT.positionV3):rotate(sons.parentR.orientationQ),
			orientationQ = sons.parentR.orientationQ * msgM.dataT.orientationQ,
		}
		sons.brainkeeper.grandParentID = msgM.dataT.grandParentID
		sons.brainkeeper.countdown = sons.Parameters.brainkeeper_time
	end end

	local positionV3 = vector3()
	local orientationQ = sons.api.virtualFrame.Q_VtoR(quaternion())
	if sons.brainkeeper.brain ~= nil then
		positionV3 = sons.api.virtualFrame.V3_VtoR(sons.brainkeeper.brain.positionV3)
		orientationQ = sons.api.virtualFrame.Q_VtoR(sons.brainkeeper.brain.orientationQ)
	end

	local grandParentID = nil
	if sons.parentR ~= nil then grandParentID = sons.parentR.idS end

	for idS, robotR in pairs(sons.childrenRT) do 
		sons.Msg.send(idS, "brain_location", {
			positionV3 = positionV3, orientationQ = orientationQ, grandParentID = grandParentID,
		})
	end

	if sons.brainkeeper.countdown > 0 then
		sons.brainkeeper.countdown = sons.brainkeeper.countdown - 1
	end
	if sons.brainkeeper.countdown == 0 then
		sons.brainkeeper.brain = nil
		sons.brainkeeper.grandParentID = nil
	end
end

function BrainKeeper.create_brainkeeper_node(sons)
	return function()
		BrainKeeper.step(sons)
		return false, true
	end
end

return BrainKeeper
