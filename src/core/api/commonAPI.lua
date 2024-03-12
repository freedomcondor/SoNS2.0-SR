local api = {}

---- parameters --------------------------
api.parameters = {}

api.parameters.droneTagDetectionRate = tonumber(robot.params.drone_tag_detection_rate or 0.9)
api.parameters.droneAltitudeBias = tonumber(robot.params.drone_altitude_bias or 0.2)
api.parameters.droneAltitudeNoise = tonumber(robot.params.drone_altitude_noise or 0.1)
api.parameters.droneDefaultHeight = tonumber(robot.params.drone_default_height or 1.5)
api.parameters.droneDefaultStartHeight = tonumber(robot.params.drone_default_start_height or 1.5)

api.parameters.pipuckWheelSpeedLimit = tonumber(robot.params.pipuck_wheel_speed_limit or 0.1)
--api.parameters.pipuckRotationScalar = tonumber(robot.params.pipuck_rotation_scalar or 0.05)
api.parameters.pipuckRotationScalar = tonumber(robot.params.pipuck_rotation_scalar or 0.3)

api.parameters.obstacle_match_distance = tonumber(robot.params.obstacle_match_distance or 0.10)
api.parameters.obstacle_unseen_count = tonumber(robot.params.obstacle_unseen_count or 3)

if robot.params.hardware == "true" then robot.params.hardware = true end
if robot.params.simulation == "true" then robot.params.simulation = true end

---- Time -------------------------------------
-- api.time is used for measuring how much time has past from the last step to the current step
-- The result is in api.time.period
-- For example, when calculating the distance the robot has moved, dis = speed * api.time.period
api.time = {}
api.time.currentTime = robot.system.time
api.time.period = 0.2
function api.processTime()
	api.time.period = robot.system.time - api.time.currentTime
	api.time.currentTime = robot.system.time
end

---- step count -------------------------------
-- api.stepCount counts the step number in the experiment. It is incremented in api.preStep()
api.stepCount = 0

---- Step Function ----------------------------
-- 5 step functions :
-- init, reset, destroy, preStep, postStep
-- api.init() should be called when the experiment starts
-- api.reset() should be called when resetting the experiment
-- api.distroy() should be called when the experiment ends
-- api.preStep() should be called at the beginning of each step
-- api.postStep() should be called at the end of each step
function api.init()
	--api.reset()
end

function api.reset()
	---[[
	api.estimateLocation = {
		positionV3 = vector3(),
		orientationQ = quaternion(),
	}
	--]]
end

function api.destroy()
end

function api.preStep()
	api.stepCount = api.stepCount + 1
	api.processTime()

	api.debug.record = ""
end

function api.postStep()
	api.debug.showVirtualFrame()
end

---- Location Estimate ------------------------
	-- estimates the location and orientation of the next step relative to those at the current one
api.estimateLocation = {
	positionV3 = vector3(),
	orientationQ = quaternion(),
}

---- Virtual Coordinate Frame for Intermediary Motion Management -----------------
	-- The purpose of the intermediary motion frame is to allow all robots, regardless of their hardware, to be given the same type of motion instructions. 
	-- For the ground robot, for example, the frame allows the differential drive robot to be controlled as if it were an omnidirectional robot.
	-- Effectively, when a robot is told (or tells itself) to turn, it turns its intermediary motion frame instead of its body. 
	-- The motion of the robot body itself is then managed independantly. 
api.virtualFrame = {}
api.virtualFrame.orientationQ = quaternion()
function api.virtualFrame.rotateInSpeed(speedV3)
	-- speedV3 in real frame
	local axis = vector3(speedV3):normalize()
	if speedV3:length() == 0 then axis = vector3(1,0,0) end
	api.virtualFrame.orientationQ = 
		quaternion(speedV3:length() * api.time.period,
				   axis
		) * api.virtualFrame.orientationQ
end

-- V3 and Q represents vector3 and quaternion
-- R represents for read coordinate frame (robot's body frame)
-- V represents for virtual frame (robot's "turret" frame)
-- For example, V3_RtoV converts the coordinate of a vector3 from read coordinate frame to virtual frame
function api.virtualFrame.V3_RtoV(vec)
	return vector3(vec):rotate(api.virtualFrame.orientationQ:inverse())
end
function api.virtualFrame.V3_VtoR(vec)
	return vector3(vec):rotate(api.virtualFrame.orientationQ)
end
function api.virtualFrame.Q_RtoV(q)
	return api.virtualFrame.orientationQ:inverse() * q
end
function api.virtualFrame.Q_VtoR(q)
	return api.virtualFrame.orientationQ * q
end

---- Speed Control ---------------------------
-- SoNS uses api.move(<vector3>, <vector3>) to command a robot to move
-- The first vector3 parameter is the velocity of the movement, the second vector3 parameter is the angular speed of the rotation
-- In api.move(), api.setSpeed is used to make the robot move in the desired speed.
--            and api.virtualFrame.rotateInSpeed is used to make the robot's virtualFrame rotate
function api.setSpeed()
	print("api.setSpeed needs to be implemented for specific robot")
end

function api.move(transV3, rotateV3)
	-- transV3 and rotateV3 in virtual frame
	local transRealV3 = api.virtualFrame.V3_VtoR(transV3)
	local rotateRealV3 = api.virtualFrame.V3_VtoR(rotateV3)
	api.setSpeed(transRealV3.x, transRealV3.y, transRealV3.z, 0)
	-- rotate virtual frame
	api.virtualFrame.rotateInSpeed(rotateRealV3)
	-- estimate location of the new step
	api.estimateLocation.positionV3 = transV3 * api.time.period
	local axis = vector3(rotateV3):normalize()
	if rotateV3:length() == 0 then axis = vector3(0,0,1) end
	api.estimateLocation.orientationQ = 
		quaternion(rotateV3:length() * api.time.period, axis)
end

---- Debug Draw -------------------------------
-- api.debug.drawArrow() and api.debug.drawRing() is used to draw arrows and circles in the simulator, so that it will be easy to debug
-- Sometimes, we don't want the all the debug information is drawn, so :
-- api.debug.show_all == true triggers everything gets drawn, otherwise only whose with essential parameter set to true gets drawn
api.debug = {}
api.debug.recordSwitch = false
api.debug.record = ""
function api.debug.drawArrow(color, begin, finish, essential)
	if api.debug.show_all ~= true and essential ~= true then return end
	if robot.debug == nil then return end
	-- parse color
	local colorArray = {}
	for word in string.gmatch(color, '([^,]+)') do
		colorArray[#colorArray + 1] = word
	end 
	-- draw
	if tonumber(colorArray[1]) == nil then
		robot.debug.draw_arrow(begin, finish, color)
	else
		robot.debug.draw_arrow(begin, finish, 
		                       tonumber(colorArray[1]),
		                       tonumber(colorArray[2]),
		                       tonumber(colorArray[3])
		                      )
	end
	-- log drawing
	if api.debug.recordSwitch == true then
		api.debug.record = api.debug.record ..
						   "," .. "arrow" ..
						   "," .. tostring(begin) ..
						   "," .. tostring(finish) ..
						   "," .. color
	end
end

function api.debug.drawRing(color, middle, radius, essential)
	if api.debug.show_all ~= true and essential ~= true then return end
	if robot.debug == nil then return end
	-- parse color
	local colorArray = {}
	for word in string.gmatch(color, '([^,]+)') do
		colorArray[#colorArray + 1] = word
	end 
	if tonumber(colorArray[1]) == nil then
		robot.debug.draw_ring(middle, radius, color) -- 0,0,255 (blue)
	else
		robot.debug.draw_ring(middle, radius, 
		                       tonumber(colorArray[1]),
		                       tonumber(colorArray[2]),
		                       tonumber(colorArray[3])
	                          )
	end
	-- log drawing
	if api.debug.recordSwitch == true then
		api.debug.record = api.debug.record ..
						   "," .. "ring" ..
						   "," .. tostring(middle) ..
						   "," .. tostring(radius) ..
						   "," .. color
	end
end

-- api.debug.showVirtualFrame() draws x,y,z axis to show the virtual frame
function api.debug.showVirtualFrame()
	api.debug.drawArrow(
		"green",
		vector3(-0.1, 0, 0.1):rotate(api.virtualFrame.orientationQ),
		vector3( 0.2, 0, 0.1):rotate(api.virtualFrame.orientationQ)
	)
	api.debug.drawArrow(
		"green",
		vector3(0, -0.1, 0.1):rotate(api.virtualFrame.orientationQ),
		vector3(0,  0.2, 0.1):rotate(api.virtualFrame.orientationQ)
	)
	api.debug.drawArrow("blue", 
		vector3(0,0,0.1),
		vector3(0.1,0,0.1)
	)
end

-- api.debug.showEstimateLocation() draws an arrow showing the estimate location
function api.debug.showEstimateLocation()
	api.debug.drawArrow(
		"red", 
			-vector3(api.estimateLocation.positionV3):rotate(
			quaternion(api.estimateLocation.orientationQ):inverse()
		), 
		vector3(0,0,0.1)
	)
end

-- api.debug.showParent() draws an arrow pointing the parent of the robot in SoNS
-- api.debug.showChildren() draws arrows pointing the children of the robot in SoNS
-- Note the essential is true, these arrows will always be drawn
function api.debug.showParent(sons, color)
	if color == nil then color = "blue" end
	if sons.parentR ~= nil then
		local robotR = sons.parentR
		api.debug.drawArrow(color, vector3(), api.virtualFrame.V3_VtoR(vector3(robotR.positionV3)), true)
		--[[
		api.debug.drawArrow(color, 
			api.virtualFrame.V3_VtoR(robotR.positionV3) + vector3(0,0,0.1),
			api.virtualFrame.V3_VtoR(robotR.positionV3) + vector3(0,0,0.1) +
			vector3(0.1, 0, 0):rotate(
				api.virtualFrame.Q_VtoR(quaternion(robotR.orientationQ))
			),
			true  -- essential
		)
		--]]
	end
end

function api.debug.showChildren(sons, color, withoutBrain)
	if color == nil then color = "blue" end
	-- draw children location
	for i, robotR in pairs(sons.childrenRT) do
		api.debug.drawArrow(
			color,
			vector3(),
			api.virtualFrame.V3_VtoR(
				vector3(
					robotR.positionV3 * (
						(robotR.positionV3:length() - 0.2) / robotR.positionV3:length()
					)
				)
			),
			true
		)
		--[[
		api.debug.drawArrow("blue", 
			api.virtualFrame.V3_VtoR(robotR.positionV3) + vector3(0,0,0.1),
			api.virtualFrame.V3_VtoR(robotR.positionV3) + vector3(0,0,0.1) +
			vector3(0.1, 0, 0):rotate(
				api.virtualFrame.Q_VtoR(quaternion(robotR.orientationQ))
			),
			true
		)
		--]]
	end

	if withoutBrain ~= true then
		if sons.parentR == nil then
			api.debug.drawRing(
				color,
				vector3(0,0,0.08),
				0.15,
				true
			)
		end
	end
end

-- api.debug.showObstacles() draws arrows pointing the obstacles that the robot detects
function api.debug.showObstacles(sons, essential)
	for i, obstacle in ipairs(sons.avoider.obstacles) do
		api.debug.drawArrow("red", vector3(),
		                           api.virtualFrame.V3_VtoR(vector3(obstacle.positionV3)),
		                           essential
		                   )
		api.debug.drawArrow("red",
		                    api.virtualFrame.V3_VtoR(vector3(obstacle.positionV3)),
		                    api.virtualFrame.V3_VtoR(obstacle.positionV3 + vector3(0.1, 0, 0):rotate(obstacle.orientationQ)),
		                    essential
		                   )
		--obstacle.positionV3)
	end
end

------------------------------------------------------
-- This is to wrap argos apis, in case that argos upgrades and change some of the apis.
function api.linkRobotInterface(SoNS)
	SoNS.Msg.sendTable = function(table)
		robot.radios.wifi.send(table)
	end

	SoNS.Msg.getTablesAT = function(table)
		return robot.radios.wifi.recv
	end

	SoNS.Msg.myIDS = function()
		return robot.id
	end

	SoNS.Driver.move = api.move
	SoNS.api = api
end

return api
