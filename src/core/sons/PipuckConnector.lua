--- Pipuck connector -------------------------------------------------
-- Pipuck connector makes a pipucks see a drone if it is seen by a drone
--             also makes two pipucks see each other if they can be seen by a common drone
-- It checks messages from drones, convert them into robots or obstacles and store in sons.connector.seenRobots and sons.avoider.seenObstacles
-- So that connector may handle the connection later
---------------------------------------------------------------------

local PipuckConnector = {}
local SensorUpdater = require("SensorUpdater")

function PipuckConnector.preStep(sons)
	sons.connector.seenRobots = {}
end

function PipuckConnector.step(sons)
	local seenObstacles = {}

	-- For any sight report, update quadcopter and other pipucks to seenRobots
	for _, msgM in ipairs(sons.Msg.getAM("ALLMSG", "reportSight")) do
		if msgM.dataT.mySight[sons.Msg.myIDS()] ~= nil then
			-- I'm seen in this report sight, add this drone into seenRobots
			local common = msgM.dataT.mySight[sons.Msg.myIDS()]
			local quad = {
				idS = msgM.fromS,
				positionV3 = 
					vector3(-common.positionV3):rotate(
					common.orientationQ:inverse()),
				orientationQ = 
					common.orientationQ:inverse(),
				robotTypeS = "drone",
			}

			if sons.connector.seenRobots[quad.idS] == nil then --TODO average
				sons.connector.seenRobots[quad.idS] = quad
			end

			-- add other pipucks to seenRobots
			for idS, R in pairs(msgM.dataT.mySight) do
				if idS ~= sons.Msg.myIDS() and sons.connector.seenRobots[idS] == nil and 
				   R.robotTypeS ~= "drone" then -- TODO average
					sons.connector.seenRobots[idS] = {
						idS = idS,
						positionV3 = quad.positionV3 + 
						             vector3(R.positionV3):rotate(quad.orientationQ),
						orientationQ = quad.orientationQ * R.orientationQ,
						robotTypeS = R.robotTypeS,
					}
				end
			end

			-- add obstacles
			if msgM.dataT.myObstacles ~= nil then
				for i, obstacle in ipairs(msgM.dataT.myObstacles) do
					local positionV3 = quad.positionV3 + 
									   vector3(obstacle.positionV3):rotate(quad.orientationQ) +
									   vector3(0,0,0.08)
					local orientationQ = quad.orientationQ * obstacle.orientationQ 

					-- check positionV3 in existing obstacles
					local flag = true
					for j, existing_ob in ipairs(seenObstacles) do
						if (existing_ob.positionV3 - positionV3):length() < sons.api.parameters.obstacle_match_distance then
							flag = false
							break
						end
					end

					if flag == true then
						seenObstacles[#seenObstacles + 1] = {
							type = obstacle.type,
							robotTypeS = "block",
							positionV3 = positionV3,
							orientationQ = orientationQ,
						}
					end
				end
			end
		end
	end

	-- convert sons.connector.seenRobots from real frame into virtual frame
	local seenRobotinR = sons.connector.seenRobots
	sons.connector.seenRobots = {}
	for idS, robotR in pairs(seenRobotinR) do
		sons.connector.seenRobots[idS] = {
			idS = idS,
			robotTypeS = robotR.robotTypeS,
			positionV3 = sons.api.virtualFrame.V3_RtoV(robotR.positionV3),
			orientationQ = sons.api.virtualFrame.Q_RtoV(robotR.orientationQ),
		}
	end

	-- convert seenObstacles from real frame into virtual frame seenObstaclesInVirtualFrame
	local seenObstaclesInVirtualFrame = {}
	for i, v in ipairs(seenObstacles) do
		seenObstaclesInVirtualFrame[i] = {
			type = v.type,
			robotTypeS = v.robotTypeS,
			positionV3 = sons.api.virtualFrame.V3_RtoV(v.positionV3),
			orientationQ = sons.api.virtualFrame.Q_RtoV(v.orientationQ),
		}
	end

	SensorUpdater.updateObstacles(sons, seenObstaclesInVirtualFrame, sons.avoider.obstacles)

	--[[
	for i, ob in ipairs(sons.avoider.obstacles) do
		local color = "green"
		if ob.unseen_count ~= 3 then color = "red" end
		sons.api.debug.drawArrow(color,
		                        sons.api.virtualFrame.V3_VtoR(vector3(0,0,0)),
		                        sons.api.virtualFrame.V3_VtoR(vector3(ob.positionV3))
		                       )
		sons.api.debug.drawArrow(color,
		                        sons.api.virtualFrame.V3_VtoR(vector3(ob.positionV3)),
		                        sons.api.virtualFrame.V3_VtoR(vector3(ob.positionV3) + vector3(0.1,0,0):rotate(ob.orientationQ))
		                       )
	end
	--]]
end

function PipuckConnector.create_pipuckconnector_node(sons)
	return function()
		sons.PipuckConnector.step(sons)
		return false, true
	end
end

return PipuckConnector
