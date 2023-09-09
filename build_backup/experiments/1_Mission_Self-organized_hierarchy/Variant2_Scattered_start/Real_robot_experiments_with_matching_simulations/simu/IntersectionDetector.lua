-- IntersectionDetector ------------------------------
-- IntersectionDetector handles the following situation that cannot be resolved by the Allocator module:
-- If two links (between two parents and their respective children) are spatially intersected, as in:
--        R  --  R \ / R -- R
--   R <            X
--        R  --  R / \ R -- R
-- one parent hands over its child to the other parent. 
-- The new configuration conforms to situations that can be handled by the Allocator module.
------------------------------------------------------
local IntersectionDetector = {}

--[[
	related data:
	sons.intersectiondetector.seenForeignRobots.parentPositionV3 and goalPositionV3
--]]

function IntersectionDetector.create(sons)
	sons.intersectionDetector = {}
	sons.intersectionDetector.seenForeignRobots = {}
	sons.intersectionDetector.intersectionList = {}
	IntersectionDetector.reset(sons)
end

function IntersectionDetector.reset(sons)
	sons.intersectionDetector.seenForeignRobots = {}
	sons.intersectionDetector.intersectionList = {}
end

function IntersectionDetector.preStep(sons)
	sons.intersectionDetector.seenForeignRobots = {}
end

function IntersectionDetector.step(sons)
	sons.connector.greenLight = nil

	-- stabilizer hack
	if sons.stabilizer.referencing_me == true then return end

	-- create foreign robot list
	for idS, robotR in pairs(sons.connector.seenRobots) do
		if (sons.parentR == nil or sons.parentR.idS ~= idS) and
		   sons.childrenRT[idS] == nil then
			sons.intersectionDetector.seenForeignRobots[idS] = robotR
		end
	end
	-- receive goal and parent location from foreign robots
	for idS, robotR in pairs(sons.intersectionDetector.seenForeignRobots) do
		for _, msgM in ipairs(sons.Msg.getAM(idS, "IntersectionInformationReport")) do
			robotR.parentIdS = msgM.dataT.parentIdS
			robotR.parentPositionV3 = robotR.positionV3 + vector3(msgM.dataT.parentPositionV3):rotate(robotR.orientationQ)
			robotR.goalPositionV3 = robotR.positionV3 + vector3(msgM.dataT.goalPositionV3):rotate(robotR.orientationQ)
			robotR.depth = msgM.dataT.depth
		end
	end

	-- check parent intersection
	for idS, robotR in pairs(sons.intersectionDetector.seenForeignRobots) do
		if sons.parentR ~= nil and robotR.parentIdS ~= nil and
		   sons.parentR.idS ~= robotR.parentIdS then
			-- check if we have parent intersection
			local A = vector3(sons.parentR.positionV3):cross(robotR.parentPositionV3)
			local B = vector3(sons.parentR.positionV3):cross(robotR.positionV3)

			local C = vector3(robotR.parentPositionV3 - robotR.positionV3):cross(vector3() - robotR.positionV3)
			local D = vector3(robotR.parentPositionV3 - robotR.positionV3):cross(sons.parentR.positionV3 - robotR.positionV3)

			if A:dot(B) < 0 and C:dot(D) < 0 then
				-- we have parent intersection
				-- check if our goal switch can be better
				if sons.goal.positionV3 ~= nil and robotR.goalPositionV3 ~= nil then
					local current_cost = sons.goal.positionV3:length()
					if (robotR.goalPositionV3 - robotR.positionV3):length() > current_cost then 
						current_cost = (robotR.goalPositionV3 - robotR.positionV3):length()
					end
					local new_cost = robotR.goalPositionV3:length()
					if (sons.goal.positionV3 - robotR.positionV3):length() > new_cost then
						new_cost = (sons.goal.positionV3 - robotR.positionV3):length()
					end

					local A = vector3(sons.goal.positionV3):cross(robotR.goalPositionV3)
					local B = vector3(sons.goal.positionV3):cross(robotR.positionV3)

					local C = vector3(robotR.goalPositionV3 - robotR.positionV3):cross(vector3() - robotR.positionV3)
					local D = vector3(robotR.goalPositionV3 - robotR.positionV3):cross(sons.goal.positionV3 - robotR.positionV3)
					if (A:dot(B) < 0 and C:dot(D) < 0) or 
					   (sons.scalemanager.depth == 1 and new_cost < current_cost) or
					   (sons.scalemanager.depth > 1 and new_cost + math.sqrt(2) - 1 < current_cost) then
						-- we have switch intersection
						sons.api.debug.drawRing("red", vector3(0,0,0.3), 0.1)
						sons.api.debug.drawRing("red", vector3(0,0,0.32), 0.1)
						sons.api.debug.drawRing("red", vector3(0,0,0.34), 0.1)

						if sons.intersectionDetector.intersectionList[idS] ~= nil then
							sons.intersectionDetector.intersectionList[idS].detect = true
							sons.intersectionDetector.intersectionList[idS].count = 1 + 
								sons.intersectionDetector.intersectionList[idS].count
							if sons.intersectionDetector.intersectionList[idS].count >= 15 then
								-- need to break some link
								if sons.parentR.positionV3:length() > (robotR.parentPositionV3 - robotR.positionV3):length() and
								   sons.scalemanager.depth < robotR.depth then
									if sons.connector.greenLight ~= nil then
										if robotR.positionV3:length() <
										   sons.intersectionDetector.seenForeignRobots[sons.connector.greenLight].positionV3:length() then
											sons.connector.greenLight = idS
										end
									else
										sons.connector.greenLight = idS
									end
								end
							end
						else
							sons.intersectionDetector.intersectionList[idS] = {detect = true, count = 0}
						end
					end
				end
			end
		end
	end

	if sons.connector.greenLight ~= nil then
		sons.connector.greenLight = sons.intersectionDetector.seenForeignRobots[sons.connector.greenLight].parentIdS
	end

	for idS, item in pairs(sons.intersectionDetector.intersectionList) do
		if item.detect ~= true then
			sons.intersectionDetector.intersectionList[idS] = nil
		end
		item.detect = nil 
	end

	-- send my parent and goal to foreign robots
	for idS, robotR in pairs(sons.intersectionDetector.seenForeignRobots) do
		local send_parentIdS = nil
		local send_parentPositionV3 = vector3()
		if sons.parentR ~= nil then 
			send_parentIdS = sons.parentR.idS
			send_parentPositionV3 = sons.parentR.positionV3 
		end
		local send_goalPositionV3 = sons.goal.positionV3 or vector3()
		sons.Msg.send(idS, "IntersectionInformationReport", {
			parentIdS = send_parentIdS,
			parentPositionV3 = sons.api.virtualFrame.V3_VtoR(send_parentPositionV3),
			goalPositionV3 = sons.api.virtualFrame.V3_VtoR(send_goalPositionV3),
			depth = sons.scalemanager.depth,
		})
	end
end

------ behaviour tree ---------------------------------------
function IntersectionDetector.create_intersectiondetector_node(sons)
	return function()
		IntersectionDetector.step(sons)
		return false, true
	end
end

return IntersectionDetector
