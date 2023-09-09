logger.register("droneAPI")

local api = require("commonAPI")
if robot.params.simulation == true then local DroneRealistSimulator = require("DroneRealistSimulator") end
local Transform = require("Transform")

---- actuator --------------------------
-- in each step, robot.flight_system.set_targets should only be called once at last
-- newPosition and newRad are recorded, and enforced at last in dronePostStep

-- To control the drone directly, us api.actuator.setNewLocation(vector3(x,y,z), rad),
--     where vector3(x,y,z) and rad are the new waypoint with respect to the drone's home position.
-- But more usually, api.setSpeed(x,y,z) is used to control the drone in the speed level.
-- Note that z compoment will be overwritten by height control which make sure the drone fly in a certain height.
api.actuator = {}
if robot.flight_system ~= nil then
	api.actuator.newPosition = robot.flight_system.position
	api.actuator.newRad = robot.flight_system.orientation.z
else
	api.actuator.newPosition = vector3()
	api.actuator.newRad = 0
end
function api.actuator.setNewLocation(locationV3, rad)
	api.actuator.newPosition = locationV3
	api.actuator.newRad = rad
end

-- drone flight preparation sequence
-- For details of drone operation, see the drone technical report here: https://iridia.ulb.ac.be/IridiaTrSeries/link/IridiaTr2022-010.pdf
-- In hardware, the drone follows a procedure to take off
-- 1. set armed, the propellers start to rotate
-- 2. set offboard mode, the pixhawk start take commands from the upcore, and upcore should set (0,0,1.5) so that the drone takes off
-- 3. After the drone takes off, we go to navigation mode, where the upcore can freely navigate the drone by using either setNewLocation or setSpeed
api.actuator.flight_preparation = {
	state = "pre_flight",
	state_duration = 25,
	state_count = 0,
}

api.actuator.flight_preparation.run_state = function()
	if robot.flight_system ~= nil and robot.flight_system.ready() then
		-- flight preparation state machine
		if api.actuator.flight_preparation.state == "pre_flight" then
			api.actuator.newPosition.x = 0
			api.actuator.newPosition.y = 0
			api.actuator.newPosition.z = api.parameters.droneDefaultStartHeight
			api.actuator.newRad = 0

			api.actuator.flight_preparation.state_count =
				api.actuator.flight_preparation.state_count + 1
			if api.actuator.flight_preparation.state_count >= api.actuator.flight_preparation.state_duration then
				api.actuator.flight_preparation.state_count = 0
				api.actuator.flight_preparation.state = "armed"
			end
		elseif api.actuator.flight_preparation.state == "armed" then
			api.actuator.newPosition.x = 0
			api.actuator.newPosition.y = 0
			api.actuator.newPosition.z = api.parameters.droneDefaultStartHeight
			api.actuator.newRad = 0

			robot.flight_system.set_armed(true, false)
			robot.flight_system.set_offboard_mode(true)
			api.actuator.flight_preparation.state = "take_off"
			api.actuator.flight_preparation.state_count = 0
		elseif api.actuator.flight_preparation.state == "take_off" then
			api.actuator.newPosition.x = 0
			api.actuator.newPosition.y = 0
			api.actuator.newPosition.z = api.parameters.droneDefaultStartHeight

			api.actuator.flight_preparation.state_count =
				api.actuator.flight_preparation.state_count + 1
			if api.actuator.flight_preparation.state_count >= api.actuator.flight_preparation.state_duration * 2 then
				api.actuator.flight_preparation.state_count = 0
				api.actuator.flight_preparation.state = "navigation"
			end
		elseif api.actuator.flight_preparation.state == "navigation" then
			-- TODO: there may be a jump after navigation mode
			--do nothing
		end
	end
end

---- Virtual Frame for Intermediary Motion Management and tilt ---------------------
-- For explanation of intermediary motion frame, please refer to commonAPI.lua, and see the accompanying paper for more details.
-- For drones, since the drones tilts when moving, the frame of drones also serves to cancel the tilt.
-- Here we use logicOrientationQ for rotation, in the same way as orientationQ in commonAPI, and incorporate the anti-tilt.
-- In this way, api.virtualFrame.orientationQ provides the correct intermediary motion frame for the drones.
api.virtualFrame.orientationQ = quaternion(math.pi/4, vector3(0,0,1))
api.virtualFrame.logicOrientationQ = api.virtualFrame.orientationQ
-- overwrite rotateInspeed to change logicOrientation
function api.virtualFrame.rotateInSpeed(speedV3)
	-- speedV3 in real frame
	local speedV3_in_Z = vector3(speedV3)
	speedV3_in_Z.x = 0
	speedV3_in_Z.y = 0
	local axis = vector3(speedV3_in_Z):normalize()
	if speedV3:length() == 0 then axis = vector3(1,0,0) end
	api.virtualFrame.logicOrientationQ =
		quaternion(speedV3:length() * api.time.period,
				   axis
		) * api.virtualFrame.logicOrientationQ
end

function api.droneTiltVirtualFrame()
	local tilt
	if robot.flight_system ~= nil then
		tilt = (quaternion(robot.flight_system.orientation.x, vector3(1,0,0)) *
		        quaternion(robot.flight_system.orientation.y, vector3(0,1,0))):inverse()
		--tilt = quaternion()
	else
		tilt = quaternion()
	end
	api.virtualFrame.tiltQ = tilt
	api.virtualFrame.orientationQ = tilt * api.virtualFrame.logicOrientationQ
end

---- overwrite Step Function ---------------------
-- api inherits step functions from commonAPI
-- 5 step functions: init, reset, destroy, preStep, postStep
-- Here we overwrite these functions adding specific drone operations (if needed).
api.commonInit = api.init
function api.init()
	api.commonInit()
	if robot.params.simulation == true then DroneRealistSimulator.init(api) end
	api.droneEnableCameras()
end

api.commonDestroy = api.destroy
function api.destroy()
	api.droneDisableCameras()
	api.commonDestroy()
end

api.commonPreStep = api.preStep
function api.preStep()
	if robot.flight_system ~= nil then logger("droneAPI: position sensor = ", robot.flight_system.position, robot.flight_system.orientation) end
	api.commonPreStep()
	api.droneTags = nil
	if robot.params.simulation == true then DroneRealistSimulator.changeSensors(api) end
	if robot.flight_system ~= nil then logger("droneAPI: after real sim  = ", robot.flight_system.position, robot.flight_system.orientation) end
	api.droneTiltVirtualFrame()
end

api.commonPostStep = api.postStep
function api.postStep()
	if robot.flight_system ~= nil then
		api.droneAdjustHeight(api.parameters.droneDefaultHeight)
		api.actuator.flight_preparation.run_state()
		logger("droneAPI: set_target_pose = ", api.actuator.newPosition, api.actuator.newRad)
		if robot.params.simulation == true then DroneRealistSimulator.changeActuators(api) end
		logger("droneAPI: after real simu = ", api.actuator.newPosition, api.actuator.newRad)
		robot.flight_system.set_target_pose(api.actuator.newPosition, api.actuator.newRad)
		api.updateLastSpeed()
	end
	api.commonPostStep()
end

---- Height control --------------------
-- In real experiments, the LiDAR measurements on different drones are not perfectly calibrated to match.
-- This could cause drones to fly at different heights when set to the same target height.
-- Height control addresses this problem by using the drone cameras and the tags on the ground to provide supplementary measurements of the current height,
-- for feedback control when setting the target height.
-- For details of drone hardware and operation, see the drone technical report here: https://iridia.ulb.ac.be/IridiaTrSeries/link/IridiaTr2022-010.pdf

-- api.droneAdjustHeight(z) is called in postStep() to make sure the drone fly in a height of z

api.droneCheckHeightCountDown = api.actuator.flight_preparation.state_duration * 3
api.droneLastHeight = api.parameters.droneDefaultStartHeight

function api.droneAdjustHeight(z)
	-- Sometimes, if we check the tags distances and adjust target height every step, the drones may fly in a not very stable way.
	-- droneCheckHeightCountDown tries not to do the feedback control every step, but checking tags distances every droneCheckHeightCountDown steps
	-- So that the drone can keep a steady height and only adjust the height occasionaly.
	--[[
	if api.droneCheckHeightCountDown > 0 then
		api.actuator.newPosition.z = api.droneLastHeight
		api.droneCheckHeightCountDown = api.droneCheckHeightCountDown - 1
	elseif api.droneCheckHeightCountDown <= 0 then
	--]]
	if true then
		local currentHeight = api.droneEstimateHeight()
		logger("checking height, current height = ", currentHeight)
		if currentHeight == nil then
			api.actuator.newPosition.z = api.droneLastHeight
			if z == 0 then
				local threshold = 0
				if robot.params.hardware == true then threshold = -1 end
				if api.actuator.newPosition.z > threshold then
					api.actuator.newPosition.z =
						api.actuator.newPosition.z - 0.02 * api.time.period
				end
				api.droneLastHeight = api.actuator.newPosition.z
			end
			return
		end
		local heightError = z - currentHeight
		local speed_limit = 0.3
		if heightError > speed_limit then heightError = speed_limit end
		if heightError < -speed_limit then heightError = -speed_limit end
		local ZScalar = 5
		if robot.params.hardware == true then ZScalar = 3 end
		-- TODO: there may be a jump here
		api.actuator.newPosition.z = robot.flight_system.position.z + heightError * api.time.period * ZScalar
		logger("heightError = ", heightError)
		logger("robot.flight_system.position.z = ", robot.flight_system.position.z)
		logger("api.actuator.newPosition.z = ", api.actuator.newPosition.z)
		api.droneLastHeight = api.actuator.newPosition.z
		if math.abs(heightError) < 0.1 then
			api.droneCheckHeightCountDown = api.actuator.flight_preparation.state_duration * 3
		end
	end
end

function api.droneEstimateHeight()
	-- estimate height
	local average_height = 0
	local average_count = 0
	local tags = api.droneDetectTags()
	for _, tag in ipairs(tags) do
		-- tag see me
		local tagSeeMe = Transform.AxCis0(tag)

		average_height = average_height + tagSeeMe.positionV3.z
		average_count = average_count + 1
	end

	if average_count ~= 0 then
		average_height = average_height / average_count
		return average_height
	else
		return nil
	end
end

---- speed control --------------------
-- The drone's speed is commanded by api.droneSetSpeed(x, y, z, th) 
-- x,y,z is the linear velocity in m/s and th is the angular velocity in rad/s
-- For smooth flying, when setting droneSetSpeed(x,y,z,th), the actual target speed
-- is the average of the last speed setting and the new one.
-- The last speed setting is remembered by api.rememberLastSpeed and updateLastSpeed

-- The following values are in the robot's body frame.
-- For details about frames, see the accompanying paper.
-- Speed may be set multiple times in a step, remembered in justSetSpeed, and pushed to lastSetSpeed in postStep
function api.rememberLastSpeed(x,y,z,th)
	api.actuator.justSetSpeed = {
		x = x, y = y, z = z, th = th,
	}
end

function api.updateLastSpeed()
	if api.actuator.justSetSpeed == nil then
		api.rememberLastSpeed(0,0,0,0)
	end

	api.actuator.lastSetSpeed = {
		x = api.actuator.justSetSpeed.x,
		y = api.actuator.justSetSpeed.y,
		z = api.actuator.justSetSpeed.z,
		th = api.actuator.justSetSpeed.th,
	}
end

function api.droneSetSpeed(x, y, z, th)
	logger("droneSetSpeed = ", x, y, z, th)
	if robot.flight_system == nil then return end
	-- x, y, z in m/s, x front, z up, y left
	-- th in rad/s, counter-clockwise positive
	local rad = robot.flight_system.orientation.z
	local q = quaternion(rad, vector3(0,0,1))

	api.rememberLastSpeed(x, y, z, th)

	if api.actuator.lastSetSpeed ~= nil then
		logger(" last speed = ", api.actuator.lastSetSpeed.x, 
		                         api.actuator.lastSetSpeed.y,
		                         api.actuator.lastSetSpeed.z,
		                         api.actuator.lastSetSpeed.th)
		x = (x + api.actuator.lastSetSpeed.x) / 2
		y = (y + api.actuator.lastSetSpeed.y) / 2
		z = (z + api.actuator.lastSetSpeed.z) / 2
		th = (th + api.actuator.lastSetSpeed.th) / 2
	end

	-- tune these scalars to make x,y,z,th match m/s and rad/s
		-- 6 and 0.5 are roughly calibrated for simulation
	local transScalar = 4
	local transScalarZ = 4
	local rotateScalar = 0.5
	if robot.params.hardware == true then
		transScalar = 10
		transScalarZ = 5
		rotateScalar = 0.1
	end

	x = x * transScalar * api.time.period
	y = y * transScalar * api.time.period
	z = z * transScalarZ * api.time.period
	th = th * rotateScalar * api.time.period

	logger("time = ", api.time.period)
	logger("inc = ", x, y, z, th)

	api.actuator.setNewLocation(
		vector3(x,y,z):rotate(q) + robot.flight_system.position,
		rad + th
	)
end

api.setSpeed = api.droneSetSpeed
--api.move is implemented in commonAPI

---- Cameras -------------------------
-- For details of camera calibration and drone operation, see the drone technical report here: https://iridia.ulb.ac.be/IridiaTrSeries/link/IridiaTr2022-010.pdf
-- 
-- The cameras need to be enabled at the beginning and disabled at the end by api.droneEnableCameras() and api.droneDisableCameras()
-- api.droneDetectTag() combines the tags seen by all four cameras, converts the position and orientation from camera's frame into drone's body frame
-- api.droneDetectLeds() is optinal, it tries to detect the color of LEDs surrounding the tag in some scenario setups.
-- api.droneAddSeenRobots() and api.droneAddObstacles() takes the detected tags as input, and distinguishes each tag that represents a drone/a pipuck/an obstacle ...
-- api.tagLabelIndex is used to set the range of tag id for each type of robot. For example, tag number 1-500 is considered as pipucks ...
-- This range can be set by .argos parameters for each scenario
function api.droneEnableCameras()
	for index, camera in pairs(robot.cameras_system) do
		camera.enable()
	end 
end

function api.droneDisableCameras()
	for index, camera in pairs(robot.cameras_system) do
		camera.disable()
	end
end

function api.droneDetectLeds()
	-- detect led is depricated by argos-srocs and resume in the future.
	for _, camera in pairs(robot.cameras_system) do
		if camera.detect_led == nil then return end
	end

	-- takes tags in camera_frame_reference
	local led_dis = 0.02 -- distance between leds to the center
	local led_loc_for_tag = {
	vector3(led_dis, 0, 0),
	vector3(0, led_dis, 0),
	vector3(-led_dis, 0, 0),
	vector3(0, -led_dis, 0)
	} -- start from x+ , counter-closewise

	for _, camera in pairs(robot.cameras_system) do
		for _, tag in ipairs(camera.tags) do
			tag.type = 0
			for j, led_loc in ipairs(led_loc_for_tag) do
				local led_loc_for_camera = vector3(led_loc):rotate(tag.orientation) + tag.position
				local color_number = camera.detect_led(led_loc_for_camera)
				if color_number ~= tag.type and color_number ~= 0 then
					tag.type = color_number
				end
			end
		end
	end
end


function api.droneDetectTags()
	-- droneDetectTags maybe called multiple times by dronePreconnector and adjustheight in postStep
	if api.droneTags ~= nil then return api.droneTags end
	-- This function returns a tags table, in real robot coordinate frame
	api.droneDetectLeds()

	-- add tags 
	tags = {}
	for _, camera in pairs(robot.cameras_system) do
		for _, newTag in ipairs(camera.tags) do
			local positionV3 = 
			  (
			    camera.transform.position + 
			    vector3(newTag.position):rotate(camera.transform.orientation)
			  )

			local orientationQ = 
				camera.transform.orientation * 
				newTag.orientation * quaternion(math.pi, vector3(1,0,0))

			-- check existed
			local flag = 0
			for i, existTag in ipairs(tags) do
				if (existTag.positionV3 - positionV3):length() < api.parameters.obstacle_match_distance and
				   existTag.id == newTag.id then
					flag = 1
					break
				end
			end

			-- check orientation Z up
			-- Sometimes, in hardware, Apriltag library may gives a wrong tag orientation
			-- This part checks whether the tag's z axis points up, if not, disgard this tag.
			if (vector3(0,0,1):rotate(orientationQ) - vector3(0,0,1)):length() > 0.3 then
				logger("bad tag orientation, ignore tag", newTag.id)
				logger("                     positionV3", positionV3)
				logger("                     orientationQ", orientationQ)
				logger("                             X = ", vector3(1,0,0):rotate(orientationQ))
				logger("                             Y = ", vector3(0,1,0):rotate(orientationQ))
				logger("                             Z = ", vector3(0,0,1):rotate(orientationQ))
				flag = 1
			end

			if flag == 0 then
				tags[#tags + 1] = {
					id = newTag.id,
					type = newTag.type,
					positionV3 = positionV3,
					orientationQ = orientationQ
				}
			end
		end
	end

	api.droneTags = tags
	return tags
end

api.tagLabelIndex = {
	block = {
		from = tonumber(robot.params.block_label_from or 0),
		to = tonumber(robot.params.block_label_to or 0),
	},

	pipuck = {
		from = tonumber(robot.params.pipuck_label_from or 1),
		to = tonumber(robot.params.pipuck_label_to or 500),
	},

	builderbot = {
		from = tonumber(robot.params.builderbot_label_from or 501),
		to = tonumber(robot.params.builderbot_label_to or 1000),
	},
}

function api.droneAddSeenRobots(tags, seenRobotsInRealFrame)
	-- this function adds robots (in real frame) from seen tags (in real robot frames)
	for i, tag in ipairs(tags) do
		local robotTypeS = nil
		for typeS, index in pairs(api.tagLabelIndex) do
			if index.from <= tag.id and tag.id <= index.to then
				robotTypeS = typeS
				break
			end
		end
		if robotTypeS == nil then robotTypeS = "unknown" end

		if robotTypeS ~= "unknown" and robotTypeS ~= "block" then
			local idS = robotTypeS .. math.floor(tag.id)
			seenRobotsInRealFrame[idS] = {
				idS = idS,
				robotTypeS = robotTypeS,
				positionV3 = tag.positionV3 + vector3(0,0,-0.08):rotate(tag.orientationQ),
				orientationQ = tag.orientationQ,
			}
		end
	end
end

function api.droneAddObstacles(tags, obstaclesInRealFrame) -- tags is an array of R
	for i, tag in ipairs(tags) do
		if api.tagLabelIndex.block.from <= tag.id and
		   api.tagLabelIndex.block.to >= tag.id then
			obstaclesInRealFrame[#obstaclesInRealFrame + 1] = {
				type = tag.id,
				robotTypeS = "block",
				positionV3 = tag.positionV3 + vector3(0,0,-0.1):rotate(tag.orientationQ),
				orientationQ = tag.orientationQ,
			}
		end
	end
end

return api