-- Avoider -------------------------------------------
-- Avoider is the module that handles obstacle avoidance
-- For each obstacle/other robots, it generates an avoidance velocity according to a log curve (explained later)
-- The summation of the avoidance velocity is stored in avoid_speed, and got added into goal.transV3, which is used in Driver module
------------------------------------------------------
local Avoider = {}

function Avoider.create(sons)
	sons.avoider = {
		obstacles = {}
	}
end

function Avoider.reset(sons)
	sons.avoider.obstacles = {}
end

function Avoider.preStep(sons)
end

function Avoider.step(sons, drone_pipuck_avoidance)
	local avoid_speed = {positionV3 = vector3(), orientationV3 = vector3()}

	local backup_avoid_speed_scalar = sons.Parameters.avoid_speed_scalar

	-- avoid seen robots
	-- the brain is not influenced by other robots
	if sons.parentR ~= nil and sons.stabilizer.referencing_me ~= true then
		for idS, robotR in pairs(sons.connector.seenRobots) do
			-- avoid drone
			if robotR.robotTypeS == sons.robotTypeS and
			   robotR.robotTypeS == "drone" then
				if robot.params.hardware == true then
					sons.Parameters.avoid_speed_scalar = sons.Parameters.avoid_speed_scalar * 15
				end
				-- check vortex
				local drone_vortex = sons.Parameters.avoid_drone_vortex
				if drone_vortex == "goal" then
					drone_vortex = sons.goal.positionV3
				elseif drone_vortex == "true" then
					drone_vortex = true 
				elseif drone_vortex == "nil" then
					drone_vortex = nil
				end
				-- add avoid speed
				avoid_speed.positionV3 =
					Avoider.add(vector3(), robotR.positionV3,
					            avoid_speed.positionV3,
					            sons.Parameters.dangerzone_drone,
					            drone_vortex,
					            sons.Parameters.deadzone_drone)
				if robot.params.hardware == true then
					sons.Parameters.avoid_speed_scalar = backup_avoid_speed_scalar
				end
			end
			-- avoid pipuck
			if robotR.robotTypeS == sons.robotTypeS and
			   robotR.robotTypeS == "pipuck" then
				local dangerzone = sons.Parameters.dangerzone_pipuck
				local deadzone = sons.Parameters.deadzone_pipuck
				-- avoid referenced pipuck 10 times harder
				if idS == sons.stabilizer.referencing_pipuck_neighbour then
					sons.Parameters.avoid_speed_scalar = sons.Parameters.avoid_speed_scalar * 15
					dangerzone = dangerzone * sons.Parameters.dangerzone_reference_pipuck_scalar
					deadzone = deadzone * sons.Parameters.deadzone_reference_pipuck_scalar
				end
				-- check vortex
				local pipuck_vortex = sons.Parameters.avoid_pipuck_vortex
				if pipuck_vortex == "goal" then
					pipuck_vortex = sons.goal.positionV3
				elseif pipuck_vortex == "true" then
					pipuck_vortex = true 
				elseif pipuck_vortex == "nil" then
					pipuck_vortex = nil
				end
				-- add avoid speed
				avoid_speed.positionV3 =
					Avoider.add(vector3(), robotR.positionV3,
					            avoid_speed.positionV3,
					            dangerzone,
					            pipuck_vortex,
					            deadzone
					           )
				-- resume
				sons.Parameters.avoid_speed_scalar = backup_avoid_speed_scalar
			end
			-- avoidance between drone and pipuck
			if drone_pipuck_avoidance == true and
			   robotR.robotTypeS ~= sons.robotTypeS then
				local dangerzone = sons.Parameters.dangerzone_pipuck
				local deadzone = sons.Parameters.deadzone_pipuck
				-- check vortex
				local drone_vortex = sons.Parameters.avoid_pipuck_vortex
				if drone_vortex == "goal" then
					drone_vortex = sons.goal.positionV3
				elseif drone_vortex == "true" then
					drone_vortex = true 
				elseif drone_vortex == "nil" then
					drone_vortex = nil
				end
				-- add avoid speed
				avoid_speed.positionV3 =
					Avoider.add(vector3(), robotR.positionV3,
					            avoid_speed.positionV3,
					            dangerzone,
					            drone_vortex,
					            deadzone
					           )
			end
		end
	end

	-- avoid obstacles
	if sons.robotTypeS ~= "drone" then
		for i, obstacle in ipairs(sons.avoider.obstacles) do if obstacle.added ~= true then
			--local vortex = false
			--if obstacle.type == 1 then
			--	vortex = true
			--end

			--[[
			-- counting in nearby obstacles and average
			--local virtualOb = {positionV3 = obstacle.positionV3, number = 1}
			local virtualOb = {positionV3 = vector3(), number = 0}
			for j, nearbyOb in ipairs(sons.avoider.obstacles) do
				if (nearbyOb.positionV3 - obstacle.positionV3):length() < sons.api.parameters.obstacle_match_distance * 2 then
					virtualOb.positionV3 = virtualOb.positionV3 + nearbyOb.positionV3
					virtualOb.number = virtualOb.number + 1
					nearbyOb.added = true
				end
			end
			virtualOb.positionV3 = virtualOb.positionV3 * (1 / virtualOb.number)
			local longest = 0
			for j, nearbyOb in ipairs(sons.avoider.obstacles) do
				if (nearbyOb.positionV3 - obstacle.positionV3):length() < sons.api.parameters.obstacle_match_distance * 2 and
				   (nearbyOb.positionV3 - virtualOb.positionV3):length() > longest then
					longest = (nearbyOb.positionV3 - virtualOb.positionV3):length()
				end
			end
			local virtual_danger_zone = sons.Parameters.dangerzone_block + longest
			                            --sons.api.parameters.obstacle_match_distance * (virtualOb.number - 1) / 2
			--]]
			-- check vortex
			local block_vortex = sons.Parameters.avoid_block_vortex
			if block_vortex == "goal" then
				block_vortex = sons.goal.positionV3
			elseif block_vortex == "true" then
				block_vortex = true 
			elseif block_vortex == "nil" then
				block_vortex = nil
			end
			avoid_speed.positionV3 = 
				Avoider.add(vector3(), obstacle.positionV3,
				            avoid_speed.positionV3,
				            sons.Parameters.dangerzone_block,
				            block_vortex,
				            sons.Parameters.deadzone_block
				)
				            --virtual_danger_zone)
				            --sons.goal.positionV3)
		end end -- end of obstacle.added ~= true and for
		--[[
		for i, obstacle in ipairs(sons.avoider.obstacles) do
			obstacle.added = nil
		end
		--]]
	end

	-- avoid predators
	--[[
	for i, obstacle in ipairs(sons.avoider.obstacles) do
		if obstacle.type == 3 and sons.robotTypeS == "drone" then
			local runawayV3 = vector3()
			runawayV3 = vector3() - obstacle.positionV3
			runawayV3.z = 0
			runawayV3:normalize()
			runawayV3 = runawayV3 * sons.Parameters.driver_default_speed
			sons.Spreader.emergency(sons, runawayV3, vector3(), "green") -- TODO: run away from predator
		end
	end
	--]]

	-- TODO: maybe add surpress or not
	-- add the speed to goal -- the brain can't be influended
	sons.goal.transV3 = sons.goal.transV3 + avoid_speed.positionV3
	sons.goal.rotateV3 = sons.goal.rotateV3 + avoid_speed.orientationV3


	---[[
	--if robot.id == "pipuck6" then
		local color = "255,0,0,0"
		sons.api.debug.drawArrow(color,
		                        sons.api.virtualFrame.V3_VtoR(vector3(0,0,0.1)),
		                        sons.api.virtualFrame.V3_VtoR(sons.goal.transV3 * 1 + vector3(0,0,0.1))
		                       )
	--end
	--]]
end

-- This function calculates the avoidance velocity
-- For each obstacle at <obLocV3>, a virtual force field is generated
-- The robot at <myLocV3> is pushed by the force field
-- The velocity is added into <accumulatorV3>
-- <deadzone>, <threshold> is explained in the following graph
-- Vortex tries to vertex the field to help the robot move around the obstacle
function Avoider.add(myLocV3, obLocV3, accumulatorV3, threshold, vortex, deadzone)
	-- calculate the avoid speed from obLoc to myLoc,
	-- add the result into accumulator
	--[[
	        |  ||
	        |  ||
	speed   |  | |  -log(d/dangerzone) * scalar
	        |  |  |
	        |  |   \  
	        |  |    -\
	        |  |      --\ 
	        |------------+------------------------
	           |         |
	        deadzone   threshold
	--]]
	-- if vortex is true, rotate the speed to create a vortex
	--[[
	    moveup |     /
	           R   \ Ob \
	                  /
	--]]
	-- if vortex is vector3, it means the goal of the robot is at the vortex, 
	--         add left or right speed accordingly
	--[[
	                 /    
	           R   \ Ob -
	   movedown \    \      * goal(vortex)
	--]]

	if deadzone == nil then deadzone = 0 end
	local dV3 = myLocV3 - obLocV3
	dV3.z = 0
	local d = dV3:length() - deadzone
	if d <= 0 then d = 0.000000000000001 end -- TODO: maximum
	local ans = accumulatorV3
	if d < threshold - deadzone then
		if sons.robotTypeS == "drone" and robot.params.hardware == true then
			robot.leds.set_leds("blue")
		end
		dV3:normalize()
		local transV3 = - sons.Parameters.avoid_speed_scalar 
		                * math.log(d/(threshold-deadzone)) 
		                * dV3:normalize()
		if type(vortex) == "bool" and vortex == true then
			ans = ans + transV3:rotate(quaternion(math.pi/4, vector3(0,0,1)))
		elseif type(vortex) == "userdata" and getmetatable(vortex) == getmetatable(vector3()) then
			local goalV3 = vortex - myLocV3
			local cos = goalV3:dot(-dV3) / (goalV3:length() * dV3:length())
			if cos > math.cos(60*math.pi/180) then
				local product = (-dV3):cross(goalV3)
				if product.z > 0 then
					ans = ans + transV3:rotate(quaternion(-math.pi/4, vector3(0,0,1)))
				else
					ans = ans + transV3:rotate(quaternion(math.pi/4, vector3(0,0,1)))
				end
			else
				ans = ans + transV3
			end
		else
			ans = ans + transV3
		end
	end
	return ans
end

------ behaviour tree ---------------------------------------
-- A behavior tree node containing step()
function Avoider.create_avoider_node(sons, option)
	return function()
		Avoider.step(sons, option.drone_pipuck_avoidance)
	end
end

return Avoider
