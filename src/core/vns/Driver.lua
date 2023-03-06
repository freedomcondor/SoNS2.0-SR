-- Driver -----------------------------------------
------------------------------------------------------
local Driver = {}

function Driver.create(vns)
	vns.goal = {
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
	vns.driver = {
		all_arrive = false,
		drone_arrive = false,
	}
end

function Driver.addChild(vns, robotR)
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

function Driver.preStep(vns)
	-- reverse Pos and Ori are old location relative to new location
	local inverseOri = quaternion(vns.api.estimateLocation.orientationQ):inverse()
	vns.goal.positionV3 = (vns.goal.positionV3 - vns.api.estimateLocation.positionV3):rotate(inverseOri)
	vns.goal.orientationQ = vns.goal.orientationQ * inverseOri
--	vns.goal.last.transV3 = vns.goal.transV3
--	vns.goal.last.rotateV3 = vns.goal.rotateV3
	vns.goal.transV3 = vector3()
	vns.goal.rotateV3 = vector3()
end

function Driver.deleteParent(vns)
	vns.goal.positionV3 = vector3()
	vns.goal.orientationQ = quaternion()
	vns.goal.transV3 = vector3()
	vns.goal.rotateV3 = vector3()
end

function Driver.setGoal(vns, positionV3, orientationQ)
	vns.goal.positionV3 = positionV3
	vns.goal.orientationQ = orientationQ
end

function Driver.step(vns, waiting)
	-- waiting is a flag, true or false or nil,
	--	   means whether robot stop moving when neighbour out of the safe zone

	-- receive goal from parent to overwrite vns.goal.position and orientation
	if vns.parentR ~= nil then
		for _, msgM in pairs(vns.Msg.getAM(vns.parentR.idS, "drive")) do
			vns.goal.positionV3 = vns.parentR.positionV3 +
				vector3(msgM.dataT.positionV3):rotate(vns.parentR.orientationQ)
			vns.goal.orientationQ = vns.parentR.orientationQ * msgM.dataT.orientationQ
		end
	end


	-- calculate transV3 and rotateV3 from goal.positionV3 and orientation
	local transV3 = vector3()
	local rotateV3 = vector3()

	-- read parameters
	local speed = vns.Parameters.driver_default_speed
	local threshold = vns.Parameters.driver_slowdown_zone
	local reach_threshold = vns.Parameters.driver_stop_zone
	local rotate_speed_scalar = vns.Parameters.driver_default_rotate_scalar

	-- calc transV3
	local dV3 = vector3(vns.goal.positionV3)
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
	local angle, axis = vns.goal.orientationQ:toangleaxis()
	if angle ~= angle then angle = 0 end -- sometimes toangleaxis returns nan

	if angle > math.pi then angle = angle - math.pi * 2 end

	local rotateV3 = axis * angle * rotate_speed_scalar

	-- respond to goal.transV3 from avoider and spreader
	transV3 = transV3 + vns.goal.transV3
	rotateV3 = rotateV3 + vns.goal.rotateV3

	-- safezone check -- stop the robot if it is going to seperate with neighbours
	if waiting == true then
		local safezone_half

		-- predict next point
		local predict_location = vns.api.time.period * transV3

		-- check parent
		if vns.parentR ~= nil then
			if vns.robotTypeS == "drone" and vns.parentR.robotTypeS == "drone" then
				safezone_half = vns.Parameters.safezone_drone_drone
			elseif vns.robotTypeS == "drone" and vns.parentR.robotTypeS == "pipuck" or
			       vns.robotTypeS == "pipuck" and vns.parentR.robotTypeS == "drone" then
				safezone_half = vns.Parameters.safezone_drone_pipuck
			elseif vns.robotTypeS == "pipuck" and vns.parentR.robotTypeS == "pipuck" then
				safezone_half = vns.Parameters.safezone_pipuck_pipuck
			end

			local predict_distanceV3 = predict_location - vns.parentR.positionV3
			predict_distanceV3.z = 0
			local predict_distance = predict_distanceV3:length()
			local real_distanceV3 = vector3(vns.parentR.positionV3)
			real_distanceV3.z = 0
			local real_distance = real_distanceV3:length()
			if predict_distance > safezone_half and predict_distance > real_distance then
				local new_predict_distanceV3 = predict_distanceV3 * (real_distance / predict_distance)
				local new_predict_location = vns.parentR.positionV3 + new_predict_distanceV3
				new_predict_location.z = 0
				transV3 = new_predict_location * (1/vns.api.time.period)
			end
		end

		-- TODO: not leave children too
		-- check children
		for idS, robotR in pairs(vns.childrenRT) do
			if vns.robotTypeS == "drone" and robotR.robotTypeS == "drone" then
				safezone_half = vns.Parameters.safezone_drone_drone
			elseif vns.robotTypeS == "drone" and robotR.robotTypeS == "pipuck" or
			       vns.robotTypeS == "pipuck" and robotR.robotTypeS == "drone" then
				safezone_half = vns.Parameters.safezone_drone_pipuck
			elseif vns.robotTypeS == "pipuck" and robotR.robotTypeS == "pipuck" then
				safezone_half = vns.Parameters.safezone_pipuck_pipuck
			end

			local predict_distanceV3 = predict_location - robotR.positionV3
			predict_distanceV3.z = 0
			local predict_distance = predict_distanceV3:length()
			local real_distanceV3 = vector3(robotR.positionV3)
			real_distanceV3.z = 0
			local real_distance = real_distanceV3:length()
			if predict_distance > safezone_half and predict_distance > real_distance then
				transV3 = vector3()
				vns.goal.transV3 = vector3()

				vns.api.debug.drawArrow("255, 0, 255",
					vns.api.virtualFrame.V3_VtoR(vector3()),
					vns.api.virtualFrame.V3_VtoR(robotR.positionV3)
				)
			end
		end
	elseif waiting == "spring" and vns.stabilizer.referencing_me ~= true then
		-- create neighbour table
		local neighbours = {}
		if vns.parentR ~= nil then neighbours[#neighbours + 1] = vns.parentR end
		for idS, robotR in pairs(vns.childrenRT) do neighbours[#neighbours + 1] = robotR end
		-- iterate all the neighbours
		for _, robotR in ipairs(neighbours) do
			-- get safezone and critical zone
			local safezone_half
			if vns.robotTypeS == "drone" and robotR.robotTypeS == "drone" then
				safezone_half = vns.Parameters.safezone_drone_drone
			elseif vns.robotTypeS == "drone" and robotR.robotTypeS == "pipuck" or
			       vns.robotTypeS == "pipuck" and robotR.robotTypeS == "drone" then
				safezone_half = vns.Parameters.safezone_drone_pipuck
			elseif vns.robotTypeS == "pipuck" and robotR.robotTypeS == "pipuck" then
				safezone_half = vns.Parameters.safezone_pipuck_pipuck
			end
			local criticalzone_half = safezone_half + 0.1

			-- calc spring speed vector
			local default_speed = vns.Parameters.driver_default_speed * vns.Parameters.driver_spring_default_speed_scalar
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
				vns.api.debug.drawArrow("255, 0, 255",
					vns.api.virtualFrame.V3_VtoR(vector3()),
					vns.api.virtualFrame.V3_VtoR(robotR.positionV3)
				)
			end
		end
	end

	---[[ for debug
	--if robot.id == "pipuck6" then
		local color = "0,0,0,0"
		vns.api.debug.drawArrow(color,
		                        vns.api.virtualFrame.V3_VtoR(vector3(0,0,0.1)),
		                        vns.api.virtualFrame.V3_VtoR(transV3 * 1 + vector3(0,0,0.1))
		                       )
	--end
	--]]

	Driver.move(transV3, rotateV3)

	-- send drive to children
	for _, childR in pairs(vns.childrenRT) do
		if childR.goal ~= nil then
			vns.Msg.send(childR.idS, "drive",
			{
				positionV3 = vns.api.virtualFrame.V3_VtoR(childR.goal.positionV3),
				orientationQ = vns.api.virtualFrame.Q_VtoR(childR.goal.orientationQ),
			})
		end
	end

	-- arrive signal
	for idS, robotR in pairs(vns.childrenRT) do
		for _, msgM in ipairs(vns.Msg.getAM(idS, "arrive_signal")) do
			if msgM.dataT.all_arrive == true then robotR.driver.all_arrive = true end
			if msgM.dataT.all_arrive == false then robotR.driver.all_arrive = false end
			if msgM.dataT.drone_arrive == true then robotR.driver.drone_arrive = true end
			if msgM.dataT.drone_arrive == false then robotR.driver.drone_arrive = false end
		end
	end

	local all_arrive_flag = true
	local drone_arrive_flag = true
	-- check myself
	local goalV2 = vector3(vns.goal.positionV3)
	goalV2.z = 0
	if goalV2:length() > 0.3 then
		-- not arrive
		all_arrive_flag = false
		if vns.robotTypeS == "drone" then drone_arrive_flag = false end
	else
		for idS, robotR in pairs(vns.childrenRT) do
			if robotR.driver.all_arrive ~= true then
				all_arrive_flag = false
			end
			if robotR.driver.drone_arrive ~= true then
				drone_arrive_flag = false
			end
		end
	end

	if drone_arrive_flag == true then
		vns.driver.drone_arrive = true
	else
		vns.driver.drone_arrive = false
	end
	if all_arrive_flag == true then
		vns.driver.all_arrive = true

		local color = "0,255,0,0"
		vns.api.debug.drawArrow(color,
		                        vns.api.virtualFrame.V3_VtoR(vector3(0,0,0)),
		                        vns.api.virtualFrame.V3_VtoR(vector3(vns.goal.positionV3 + vector3(0,0,0.1)))
		                       )
	else
		vns.driver.all_arrive = false
		local color = "0,255,255,0"
		vns.api.debug.drawArrow(color,
		                        vns.api.virtualFrame.V3_VtoR(vector3(0,0,0)),
		                        vns.api.virtualFrame.V3_VtoR(vector3(vns.goal.positionV3 + vector3(0,0,0.1)))
		                       )
	end
	if vns.parentR ~= nil then
		vns.Msg.send(vns.parentR.idS, "arrive_signal", {all_arrive = all_arrive_flag,
	                                                    drone_arrive = drone_arrive_flag,})
	end
end

function Driver.create_driver_node(vns, option)
	-- option = {
	--      waiting = true or false or nil
	-- }
	if option == nil then option = {} end
	return function()
		Driver.step(vns, option.waiting)
		return false, true
	end
end

function Driver.move(transV3, rotateV3)
	print("VNS.Driver.move needs to be implemented")
end

return Driver
