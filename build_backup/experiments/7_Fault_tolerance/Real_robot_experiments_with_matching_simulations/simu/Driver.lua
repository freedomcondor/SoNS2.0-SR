-- Driver --------------------------------------------
-- Driver handles the motion of the robot.
-- The module takes data from sons.goal.
--     From sons.goal.positionV3 and orientationQ, it generates the velocity needed to move to that position.
--     From sons.goal.transV3 and rotateV3, it takes additional velocities into consideration (for example, to avoid obstacles).
-- It sums these velocities and uses SoNS.move().
-- SoNS.move() links to the api of each type of robot to move the robot.
------------------------------------------------------
local Driver = {}

function Driver.create(sons)
	sons.goal = {
		positionV3 = vector3(),
		orientationQ = quaternion(),
		transV3 = vector3(),
		rotateV3 = vector3(),
		--[[last = {
			transV3 = vector3(),
			rotateV3 = vector3(),
		}
		--]]
	}
	-- arrive signal marks if all the down stream children has arrived at the goal positionV3
	-- It lets brain know if the swarm has formed the target formation
	sons.driver = {
		all_arrive = false,
		drone_arrive = false,
	}
end

function Driver.addChild(sons, robotR)
	-- childR.goal is optional, default nil
	-- only effective when mannualy set
	--[[
	robotR.goal = {
		positionV3 = robotR.positionV3,	
		orientationQ = robotR.orientationQ,
		--transV3 = vector3(),
		--rotateV3 = vector3(),
	}
	--]]
	robotR.driver = {
		all_arrive = false,
		drone_arrive = false,
	}
end

function Driver.preStep(sons)
	-- reverse Pos and Ori are old location relative to new location
	local inverseOri = quaternion(sons.api.estimateLocation.orientationQ):inverse()
	sons.goal.positionV3 = (sons.goal.positionV3 - sons.api.estimateLocation.positionV3):rotate(inverseOri)
	sons.goal.orientationQ = sons.goal.orientationQ * inverseOri
--	sons.goal.last.transV3 = sons.goal.transV3
--	sons.goal.last.rotateV3 = sons.goal.rotateV3
	sons.goal.transV3 = vector3()
	sons.goal.rotateV3 = vector3()
end

function Driver.deleteParent(sons)
	sons.goal.positionV3 = vector3()
	sons.goal.orientationQ = quaternion()
	sons.goal.transV3 = vector3()
	sons.goal.rotateV3 = vector3()
end

function Driver.setGoal(sons, positionV3, orientationQ)
	sons.goal.positionV3 = positionV3
	sons.goal.orientationQ = orientationQ
end

-- <waiting> is a swith flag, indicating which method to use to stop children/parent move too far away (explained in the following section)
function Driver.step(sons, waiting)
	-- waiting is a flag, true or false or nil,
	--	   means whether robot stop moving when neighbour out of the safe zone

	-- receive goal from parent to overwrite sons.goal.position and orientation
	if sons.parentR ~= nil then
		for _, msgM in pairs(sons.Msg.getAM(sons.parentR.idS, "drive")) do
			sons.goal.positionV3 = sons.parentR.positionV3 +
				vector3(msgM.dataT.positionV3):rotate(sons.parentR.orientationQ)
			sons.goal.orientationQ = sons.parentR.orientationQ * msgM.dataT.orientationQ
		end
	end

	-- calculate transV3 and rotateV3 from goal.positionV3 and orientation
	local transV3 = vector3()
	local rotateV3 = vector3()

	-- read parameters
	local speed = sons.Parameters.driver_default_speed
	local threshold = sons.Parameters.driver_slowdown_zone
	local reach_threshold = sons.Parameters.driver_stop_zone
	local rotate_speed_scalar = sons.Parameters.driver_default_rotate_scalar

	--[[
	        |          slowdown            
	        |              /----------- default_speed
	speed   |             /
	        |            /
	        |       stop/ 
	        |-----------------------------------
	                      distance
	--]]

	-- calc transV3
	local dV3 = vector3(sons.goal.positionV3)
	dV3.z = 0
	local d = dV3:length()
	if d > threshold then
		transV3 = dV3:normalize() * speed
	elseif d < reach_threshold then
		transV3 = vector3()
	else
		transV3 = dV3:normalize() * speed * (d / threshold)
		-- TODO: (d-reach) / threshold ??
	end

	-- calc rotateV3
	local angle, axis = sons.goal.orientationQ:toangleaxis()
	if angle ~= angle then angle = 0 end -- sometimes toangleaxis returns nan

	if angle > math.pi then angle = angle - math.pi * 2 end

	local rotateV3 = axis * angle * rotate_speed_scalar

	-- respond to goal.transV3 from avoider and spreader
	transV3 = transV3 + sons.goal.transV3
	rotateV3 = rotateV3 + sons.goal.rotateV3

	-- safezone check : try not to let neighbours go too far away
	-- if waiting == true, stop the robot if it is going to far enough
	if waiting == true then
		local safezone_half

		-- predict next point
		local predict_location = sons.api.time.period * transV3

		-- check parent
		if sons.parentR ~= nil then
			if sons.robotTypeS == "drone" and sons.parentR.robotTypeS == "drone" then
				safezone_half = sons.Parameters.safezone_drone_drone
			elseif sons.robotTypeS == "drone" and sons.parentR.robotTypeS == "pipuck" or
			       sons.robotTypeS == "pipuck" and sons.parentR.robotTypeS == "drone" then
				safezone_half = sons.Parameters.safezone_drone_pipuck
			elseif sons.robotTypeS == "pipuck" and sons.parentR.robotTypeS == "pipuck" then
				safezone_half = sons.Parameters.safezone_pipuck_pipuck
			end

			local predict_distanceV3 = predict_location - sons.parentR.positionV3
			predict_distanceV3.z = 0
			local predict_distance = predict_distanceV3:length()
			local real_distanceV3 = vector3(sons.parentR.positionV3)
			real_distanceV3.z = 0
			local real_distance = real_distanceV3:length()
			if predict_distance > safezone_half and predict_distance > real_distance then
				local new_predict_distanceV3 = predict_distanceV3 * (real_distance / predict_distance)
				local new_predict_location = sons.parentR.positionV3 + new_predict_distanceV3
				new_predict_location.z = 0
				transV3 = new_predict_location * (1/sons.api.time.period)
			end
		end

		-- TODO: not leave children too
		-- check children
		for idS, robotR in pairs(sons.childrenRT) do
			if sons.robotTypeS == "drone" and robotR.robotTypeS == "drone" then
				safezone_half = sons.Parameters.safezone_drone_drone
			elseif sons.robotTypeS == "drone" and robotR.robotTypeS == "pipuck" or
			       sons.robotTypeS == "pipuck" and robotR.robotTypeS == "drone" then
				safezone_half = sons.Parameters.safezone_drone_pipuck
			elseif sons.robotTypeS == "pipuck" and robotR.robotTypeS == "pipuck" then
				safezone_half = sons.Parameters.safezone_pipuck_pipuck
			end

			local predict_distanceV3 = predict_location - robotR.positionV3
			predict_distanceV3.z = 0
			local predict_distance = predict_distanceV3:length()
			local real_distanceV3 = vector3(robotR.positionV3)
			real_distanceV3.z = 0
			local real_distance = real_distanceV3:length()
			if predict_distance > safezone_half and predict_distance > real_distance then
				transV3 = vector3()
				sons.goal.transV3 = vector3()

				sons.api.debug.drawArrow("255, 0, 255",
					sons.api.virtualFrame.V3_VtoR(vector3()),
					sons.api.virtualFrame.V3_VtoR(robotR.positionV3)
				)
			end
		end
	-- if waiting == "spring", use a spring model to attract neighbours
	elseif waiting == "spring" and sons.stabilizer.referencing_me ~= true then
		-- create neighbour table
		local neighbours = {}
		if sons.parentR ~= nil then neighbours[#neighbours + 1] = sons.parentR end
		for idS, robotR in pairs(sons.childrenRT) do neighbours[#neighbours + 1] = robotR end
		-- iterate all the neighbours
		for _, robotR in ipairs(neighbours) do
			-- get safezone and critical zone
			local safezone_half
			if sons.robotTypeS == "drone" and robotR.robotTypeS == "drone" then
				safezone_half = sons.Parameters.safezone_drone_drone
			elseif sons.robotTypeS == "drone" and robotR.robotTypeS == "pipuck" or
			       sons.robotTypeS == "pipuck" and robotR.robotTypeS == "drone" then
				safezone_half = sons.Parameters.safezone_drone_pipuck
			elseif sons.robotTypeS == "pipuck" and robotR.robotTypeS == "pipuck" then
				safezone_half = sons.Parameters.safezone_pipuck_pipuck
			end
			local criticalzone_half = safezone_half + 0.1

			-- calc spring speed vector
			local default_speed = sons.Parameters.driver_default_speed * sons.Parameters.driver_spring_default_speed_scalar
			local disV2 = vector3(robotR.positionV3)
			disV2.z = 0
			local dis = disV2:length()
			local speed
			if dis > criticalzone_half then
				speed = default_speed
			elseif safezone_half < dis and dis < criticalzone_half then
				speed = default_speed * (dis - safezone_half) / (criticalzone_half - safezone_half)
			elseif dis < safezone_half then
				speed = 0
			end
			local speedV3 = speed * disV2:normalize()
			transV3 = transV3 + speedV3
			if dis > safezone_half then
				sons.api.debug.drawArrow("255, 0, 255",
					sons.api.virtualFrame.V3_VtoR(vector3()),
					sons.api.virtualFrame.V3_VtoR(robotR.positionV3)
				)
			end
		end
	end

	---[[ for debug
	--if robot.id == "pipuck6" then
		local color = "0,0,0,0"
		sons.api.debug.drawArrow(color,
		                        sons.api.virtualFrame.V3_VtoR(vector3(0,0,0.1)),
		                        sons.api.virtualFrame.V3_VtoR(transV3 * 1 + vector3(0,0,0.1))
		                       )
	--end
	--]]

	Driver.move(transV3, rotateV3)

	-- send drive to children
	for _, childR in pairs(sons.childrenRT) do
		if childR.goal ~= nil then
			sons.Msg.send(childR.idS, "drive",
			{
				positionV3 = sons.api.virtualFrame.V3_VtoR(childR.goal.positionV3),
				orientationQ = sons.api.virtualFrame.Q_VtoR(childR.goal.orientationQ),
			})
		end
	end

	-- arrive signal
	for idS, robotR in pairs(sons.childrenRT) do
		for _, msgM in ipairs(sons.Msg.getAM(idS, "arrive_signal")) do
			if msgM.dataT.all_arrive == true then robotR.driver.all_arrive = true end
			if msgM.dataT.all_arrive == false then robotR.driver.all_arrive = false end
			if msgM.dataT.drone_arrive == true then robotR.driver.drone_arrive = true end
			if msgM.dataT.drone_arrive == false then robotR.driver.drone_arrive = false end
		end
	end

	local all_arrive_flag = true
	local drone_arrive_flag = true
	-- check myself
	local goalV2 = vector3(sons.goal.positionV3)
	goalV2.z = 0
	if goalV2:length() > 0.3 then
		-- not arrive
		all_arrive_flag = false
		if sons.robotTypeS == "drone" then drone_arrive_flag = false end
	else
		for idS, robotR in pairs(sons.childrenRT) do
			if robotR.driver.all_arrive ~= true then
				all_arrive_flag = false
			end
			if robotR.driver.drone_arrive ~= true then
				drone_arrive_flag = false
			end
		end
	end

	if drone_arrive_flag == true then
		sons.driver.drone_arrive = true
	else
		sons.driver.drone_arrive = false
	end
	if all_arrive_flag == true then
		sons.driver.all_arrive = true

		local color = "0,255,0,0"
		sons.api.debug.drawArrow(color,
		                        sons.api.virtualFrame.V3_VtoR(vector3(0,0,0)),
		                        sons.api.virtualFrame.V3_VtoR(vector3(sons.goal.positionV3 + vector3(0,0,0.1)))
		                       )
	else
		sons.driver.all_arrive = false
		local color = "0,255,255,0"
		sons.api.debug.drawArrow(color,
		                        sons.api.virtualFrame.V3_VtoR(vector3(0,0,0)),
		                        sons.api.virtualFrame.V3_VtoR(vector3(sons.goal.positionV3 + vector3(0,0,0.1)))
		                       )
	end
	if sons.parentR ~= nil then
		sons.Msg.send(sons.parentR.idS, "arrive_signal", {all_arrive = all_arrive_flag,
	                                                    drone_arrive = drone_arrive_flag,})
	end
end

-- Behavior tree node for driver
function Driver.create_driver_node(sons, option)
	-- option = {
	--      waiting = true or false or nil
	-- }
	if option == nil then option = {} end
	return function()
		Driver.step(sons, option.waiting)
		return false, true
	end
end

-- Driver.move is implement in SoNS.lua
function Driver.move(transV3, rotateV3)
	print("SoNS.Driver.move needs to be implemented")
end

return Driver
