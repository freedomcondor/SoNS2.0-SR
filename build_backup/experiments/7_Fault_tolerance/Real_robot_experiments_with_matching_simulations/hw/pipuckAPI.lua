--[[
--	pipuck api
--]]

local api = require("commonAPI")

---- actuator --------------------------
api.actuator = {}
-- in each step, robot.differential_drive.set_linear_velocity should only be called once at last
-- sons and api level uses setNewWheelSpeed to command pipuck's speed
-- no matter how many command is given, newLeft and newRight are recorded, and enforced to set_linear_velocity at last in dronePostStep
api.actuator = {}
api.actuator.newLeft = 0
api.actuator.newRight = 0
function api.actuator.setNewWheelSpeed(x, y)
	api.actuator.newLeft = x
	api.actuator.newRight = y
end

---- overwrite Step Function ---------------------
-- api inherits step functions from commonAPI
-- 5 step functions: init, reset, destroy, preStep, postStep
-- Here we overwrite these functions adding specific drone operations (if needed).
api.commonPreStep = api.preStep
function api.preStep()
	if robot.leds ~= nil then
		robot.leds.set_ring_leds(false)
	end
	api.commonPreStep()
end

api.commonPostStep = api.postStep
function api.postStep()
	robot.differential_drive.set_linear_velocity(
		api.actuator.newLeft, 
		api.actuator.newRight
	)
	api.commonPostStep()
end

---- speed control --------------------
-- Pipuck is non-omni-directional, so speed control for pipuck follows basic differential drive principle
-- everything in robot body coordinate frame

-- pipuckSetWheelSpeed(x,y) sets pipuck left wheel and right wheel speed
-- In the meantime, counter rotate the virtual frame to keep the virtual frame steady if the pipuck body is rotating
function api.pipuckSetWheelSpeed(x, y)
	-- x, y in m/s
	-- the scalar is to make x,y match m/s
	local limit = api.parameters.pipuckWheelSpeedLimit
	if x > limit then
		y = y * (limit / x)
		x = limit
	end
	if x < -limit then
		y = y * (-limit / x)
		x = -limit
	end
	if y > limit then
		x = x * (limit / y)
		y = limit
	end
	if y < -limit then
		x = x * (-limit / y)
		y = -limit
	end
	api.actuator.setNewWheelSpeed(x, y)

	--if robot.id == "pipuck35" then
		local color = "128,0,128,0"
		api.debug.drawArrow(color,
								vector3(0,0.1,0.3),
								vector3(x,0,0)*3 + vector3(0,0.1,0.3)
							   )
		api.debug.drawArrow(color,
								vector3(0,-0.1,0.3),
								vector3(y,0,0)*3 + vector3(0,-0.1,0.3)
							   )
	--end

	local virtual_frame_scalar = 0.0535
	local th = (y - x) / virtual_frame_scalar
	if th > math.pi / 4 then
		th = math.pi / 4
	elseif th < -math.pi / 4 then
		th = -math.pi / 4
	end
	api.virtualFrame.rotateInSpeed(vector3(0,0,1) * (-th))
end

-- pipuckSetRotationSpeed(x, th) moves the pipuck forward by a speed of x m/s
-- in the meantime rotates by a speed of th rad/s in the direction of anti-clockwise
function api.pipuckSetRotationSpeed(x, th)
	-- x, in m/s, x front,
	-- th in rad/s, counter-clockwise positive
	local scalar = api.parameters.pipuckRotationScalar
	local aug = scalar * th * x
	api.pipuckSetWheelSpeed(x - aug, x + aug)
end

-- pipuckSetRotationSpeed(x, y) moves the pipuck roughly in a velocity of (x, y)
-- X axis points front and Y axis points left
-- Since pipuck is non-omni directional, y will makes the pipuck rotate
function api.pipuckSetSpeed(x, y)
	local th = math.atan(y/x)
	--local limit = math.pi / 3 * 2
	--if th > limit then th = limit
	--elseif th < -limit then th = -limit end
	--api.pipuckSetRotationSpeed(x, th)
	
	local scalar = api.parameters.pipuckRotationScalar
	y = y * scalar

	api.pipuckSetWheelSpeed(x - y, x + y)
end

api.setSpeed = api.pipuckSetSpeed
--api.move is implemented in commonAPI

---- Debugs --------------------
-- This funcion overwrites api.debug.showChildren in commonAPI
-- It not only draws an arrow to the children, but also lights the body leds to indicate the direction of the parent.
api.debug.commonShowChildren = api.debug.showChildren
function api.debug.showChildren(sons, color, withoutBrain)
	api.debug.commonShowChildren(sons, color, withoutBrain)
	-- draw children location
	if sons.parentR ~= nil then
		api.pipuckShowLED(api.virtualFrame.V3_VtoR(vector3(sons.parentR.positionV3)))
	else
		if robot.leds ~= nil then
			robot.leds.set_body_led(true)
		end
	end
end

---- LEDs --------------------
function api.pipuckShowAllLEDs()
	for count = 1, 8 do
		robot.leds.set_ring_led_index(count, true)
	end
end

-- pipuckShowLED takes a vector3 in robot's body frame, and lights the LED towards that direction
function api.pipuckShowLED(vec)
	-- direction is a vector3, x front, y left
	-- th = 0 front, clockwise, -180 to 180
	local th
	if vec.x == 0 and vec.y > 0 then th = -90
	elseif vec.x == 0 and vec.y < 0 then th = 90
	elseif vec.x == 0 and vec.y == 0 then th = 0
	elseif vec.x > 0 then th = math.atan(-vec.y / vec.x) * 180 / math.pi
	elseif vec.x < 0 then th = math.atan(-vec.y / vec.x) * 180 / math.pi
		if vec.y > 0 then th = th - 180
		else th = th + 180
		end
	end

	local count = math.floor((th + 22.5) / 45)
	count = count % 8 + 1

	if robot.leds ~= nil then
		robot.leds.set_ring_led_index(count, true)
	end
end

return api