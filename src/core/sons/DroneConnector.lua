--- Drone connector -------------------------------------------------
-- Drone connector makes two drones see each other if they can see a common pipuck on the ground
-- It checks tags it sees, convert them into robots or obstacles and store in sons.connector.seenRobots and sons.avoider.seenObstacles
-- So that connector may handle the connection later
---------------------------------------------------------------------

require("DeepCopy")
local SensorUpdater = require("SensorUpdater")
local Transform = require("Transform")

local DroneConnector = {}

function DroneConnector.preStep(sons)
	sons.connector.seenRobots = {}
end

function DroneConnector.step(sons)
	-- add tags into seen Robots
	sons.api.droneAddSeenRobots(
		sons.api.droneDetectTags(),
		sons.connector.seenRobots
	)

	local seenObstacles = {}
	sons.api.droneAddObstacles(
		sons.api.droneDetectTags(),
		seenObstacles
	)

	-- report my sight to all seen pipucks, and drones in parent and children
	--[[ -- legancy code from the 1st version. could be useful
	if sons.parentR ~= nil and sons.parentR.robotTypeS == "drone" then
		sons.Msg.send(sons.parentR.idS, "reportSight", {mySight = sons.connector.seenRobots})
	end

	for idS, robotR in pairs(sons.childrenRT) do
		if robotR.robotTypeS == "drone" then
			sons.Msg.send(idS, "reportSight", {mySight = sons.connector.seenRobots})
		end
	end

	for idS, robotR in pairs(sons.connector.seenRobots) do
		sons.Msg.send(idS, "reportSight", {mySight = sons.connector.seenRobots})
	end
	--]]

	---[[
	-- broadcast my sight so other drones would see me
	--sons.Msg.send("ALLMSG", "reportSight", {mySight = sons.connector.seenRobots, myObstacles = sons.avoider.obstacles})
	local myRobotRT = DeepCopy(sons.connector.seenRobots)

	sons.Msg.send("ALLMSG", "reportSight", {mySight = myRobotRT, myObstacles = seenObstacles})
	--]]

	-- for sight report, generate quadcopters
	for _, msgM in ipairs(sons.Msg.getAM("ALLMSG", "reportSight")) do
		--[[
		for idS, robotR in pairs(sons.childrenRT) do
			if myRobotRT[idS] == nil and robotR.robotTypeS == "pipuck" then 
				myRobotRT[idS] = {
					idS = idS,
					positionV3 = sons.api.virtualFrame.V3_VtoR(robotR.positionV3),
					orientationQ = sons.api.virtualFrame.Q_VtoR(robotR.orientationQ),
				} 
			end
		end
		if sons.parentR ~= nil and sons.parentR.robotTypeS == "pipuck" and myRobotRT[sons.parentR.idS] == nil then
			myRobotRT[sons.parentR.idS] = {
				idS = sons.parentR.idS,
				positionV3 = sons.api.virtualFrame.V3_VtoR(sons.parentR.positionV3),
				orientationQ = sons.api.virtualFrame.Q_VtoR(sons.parentR.orientationQ),
			}
		end
		--]]
		sons.connector.seenRobots[msgM.fromS] = DroneConnector.calcQuadR(msgM.fromS, myRobotRT, msgM.dataT.mySight)
		--sons.connector.seenRobots[msgM.fromS] = DroneConnector.calcQuadR(msgM.fromS, sons.connector.seenRobots, msgM.dataT.mySight)
		--sons.connector.seenRobots[msgM.fromS] = DroneConnector.calcQuadRHW(sons, msgM.fromS, msgM.dataT.mySight)
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
			locationInRealFrame = {
				positionV3 = vector3(v.positionV3),
				orientationQ = quaternion(v.orientationQ),
			}
		}
	end

	--SensorUpdater.updateObstacles(sons, seenObstaclesInVirtualFrame, sons.avoider.obstacles)
	SensorUpdater.updateObstaclesByRealFrame(sons, seenObstaclesInVirtualFrame, sons.avoider.obstacles)

	--[[
	if sons.parentR == nil then
	for i, ob in ipairs(sons.avoider.obstacles) do
		local color = "green"
		if ob.unseen_count ~= sons.api.parameters.obstacle_unseen_count then color = "red" end
		sons.api.debug.drawArrow(color, 
		                        sons.api.virtualFrame.V3_VtoR(vector3(0,0,0)), 
		                        sons.api.virtualFrame.V3_VtoR(vector3(ob.positionV3))
		                       )
		sons.api.debug.drawArrow(color, 
		                        sons.api.virtualFrame.V3_VtoR(vector3(ob.positionV3)),
		                        sons.api.virtualFrame.V3_VtoR(vector3(ob.positionV3) + vector3(0.1,0,0):rotate(ob.orientationQ))
		                       )
	end
	end
	--]]
end

-- Generate a drone robot from the ground robots I have seen <myVehiclesTR> and another drone have seen <yourVehiclesTR>
-- Return the drone robot table
function DroneConnector.calcQuadR(idS, myVehiclesTR, yourVehiclesTR)
	local quadR = nil
	local n = 0
	local totalAcc = Transform.createAccumulator()
	for _, robotR in pairs(yourVehiclesTR) do
		if myVehiclesTR[robotR.idS] ~= nil and
		   myVehiclesTR[robotR.idS].robotTypeS ~= "drone" then
			local myRobotR = myVehiclesTR[robotR.idS]
			local positionV3 = 
			                 myRobotR.positionV3 +
			                 vector3(-robotR.positionV3):rotate(
			                    --robotR.orientationQ:inverse() * myRobotR.orientationQ
			                    myRobotR.orientationQ * robotR.orientationQ:inverse() 
			                 )
			local orientationQ = myRobotR.orientationQ * robotR.orientationQ:inverse()

			Transform.addAccumulator(totalAcc, {positionV3 = positionV3, orientationQ = orientationQ})
			n = n + 1
		end
	end
	if n >= 1 then
		local average = Transform.averageAccumulator(totalAcc)
		quadR = {
			idS = idS,
			positionV3 = average.positionV3,
			orientationQ = average.orientationQ,
			robotTypeS = "drone",
		}
	end
	return quadR
end

function DroneConnector.create_droneconnector_node(sons)
	return function()
		sons.DroneConnector.step(sons)
		return false, true
	end
end

return DroneConnector
