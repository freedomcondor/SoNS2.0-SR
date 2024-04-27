local state = "pre_flight"
local state_count = 0
local state_duration = 25
---------------------------------------------------------------------
function init()
end

--- reset
function reset()
end

--- step
function step()
	state_count = state_count + 1

	if robot.flight_system ~= nil and robot.flight_system.ready() then
		-- flight preparation state machine
		if state == "pre_flight" then
			robot.flight_system.set_target_pose(vector3(0,0,0), 0)
			state_count = state_count + 1
			if state_count >= state_duration then
				state_count = 0
				state = "armed"
			end
		elseif state == "armed" then
			robot.flight_system.set_target_pose(vector3(0,0,0), 0)
			robot.flight_system.set_armed(true, false)
			robot.flight_system.set_offboard_mode(true)
			state = "take_off"
			state_count = 0
		elseif state == "take_off" then
			robot.flight_system.set_target_pose(vector3(0,0,1), 0)
			state_count = state_count + 1
			if state_count >= state_duration * 2 then
				state_count = 0
				state = "navigation"
			end
		elseif state == "navigation" then
			robot.flight_system.set_target_pose(vector3(0,0,1), 0)
			--do nothing
			--]]
		end
	end
end

--- destroy
function destroy()
end
