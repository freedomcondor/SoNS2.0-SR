createArgosFileName = "@CMAKE_SOURCE_DIR@/scripts/createArgosScenario.py"
#execfile(createArgosFileName)
exec(compile(open(createArgosFileName, "rb").read(), createArgosFileName, 'exec'))

import os
import math

# note: for video, run with random seed 1

#------------- over write
#- random locations ------------------------------------------------------------------------
def generate_random_locations(n, origin_x,    origin_y, 
                                 x_min_limit, x_max_limit,
                                 y_min_limit, y_max_limit, 
                                 near_limit,  far_limit) :
	a = [
            [0, -0.75],
            [0, 0.75],
        ]

	# if origin is not None then add origin as the first
	start = 0
	if origin_x != None and origin_y != None :
		#a.append([origin_x, origin_y])
		start = 2

	# start generating
	for i in range(start, n) : # 0/1 to n - 1
		valid = False
		attempt_count_down = attempt_count_down_default
		while valid == False :
			# check attempt
			if attempt_count_down == 0 :
				print("[warning] random locations incomplete")
				break
			else :
				attempt_count_down = attempt_count_down - 1

			# generate a random location
			loc_x = x_min_limit + random.random() * (x_max_limit - x_min_limit)
			loc_y = y_min_limit + random.random() * (y_max_limit - y_min_limit)

			#check near
			valid = True
			for j in range(0, i) :
				if (loc_x - a[j][0]) ** 2 + (loc_y - a[j][1]) ** 2 < near_limit ** 2 :
					valid = False
					break
			if valid == False :
				continue

			#check faraway
			valid = False
			if i == 0 :
				valid = True
			for j in range(0, i) :
				if (loc_x - a[j][0]) ** 2 + (loc_y - a[j][1]) ** 2 < far_limit ** 2 :
					valid = True
					break
			if valid == True :
				a.append([loc_x, loc_y])
		if attempt_count_down == 0 :
			break
	return a

def generate_slave_locations(n, master_locations,
                                x_min_limit, x_max_limit,
                                y_min_limit, y_max_limit,
                                near_limit, far_limit) :
	return generate_slave_locations_with_origin(n,
	                                            master_locations,
	                                            None, None,
	                                            x_min_limit, x_max_limit,
	                                            y_min_limit, y_max_limit,
	                                            near_limit, far_limit)


def generate_slave_locations_with_origin(n, master_locations,
                                         origin_x, origin_y,
                                         x_min_limit, x_max_limit,
                                         y_min_limit, y_max_limit,
                                         near_limit, far_limit) :
	a = [
            [0.5, 0],
            [-0.5, 0],
            [0, 1.5],
            [0, -1.5],
        ]

	# if origin is not None then add origin as the first
	start = 0
	if origin_x != None and origin_y != None :
		#a.append([origin_x, origin_y])
		start = 4

	for i in range(start, n) :
		valid = False
		attempt_count_down = attempt_count_down_default
		while valid == False :
			# check attempt
			if attempt_count_down == 0 :
				print("[warning] slave locations incomplete")
				break
			else :
				attempt_count_down = attempt_count_down - 1

			# generate a random location
			loc_x = x_min_limit + random.random() * (x_max_limit - x_min_limit)
			loc_y = y_min_limit + random.random() * (y_max_limit - y_min_limit)

			# check near
			valid = True
			for j in range(0, i) :
				if (loc_x - a[j][0]) ** 2 + (loc_y - a[j][1]) ** 2 < near_limit ** 2 :
					valid = False
					break
			if valid == False :
				continue

			#check faraway
			valid = False
			for drone_loc in master_locations :
				if (loc_x - drone_loc[0]) ** 2 + (loc_y - drone_loc[1]) ** 2 < far_limit ** 2 :
					valid = True
					break
			if valid == True :
				a.append([loc_x, loc_y])
		if attempt_count_down == 0 :
			break
	return a

exp_scale = 4

n_drone = exp_scale * 6 + 1
n_pipuck = n_drone * 4
arena_size = exp_scale * 10 + 8 + (n_drone)/math.pi
print("arena_size = ", arena_size)

# drone and pipuck
drone_locations = generate_random_locations(n_drone,                        # total number
                                            0, 0,              # origin location
                                            -exp_scale*3-2, exp_scale*3,             # random x range
                                            -exp_scale*3,exp_scale*3,       # random y range
                                            1.3, 1.5)                       # near limit and far limit
pipuck_locations = generate_slave_locations_with_origin(n_pipuck,
                                            drone_locations,
                                            -3+0.8, 0.4,          # origin
                                            -exp_scale*3-2, exp_scale * 3,             # random x range
                                            -exp_scale*3,exp_scale*3,       # random y range
                                            0.5, 0.9)                       # near limit and far limit

drone_xml = generate_drones(drone_locations, 1)                 # from label 1 generate drone xml tags
pipuck_xml = generate_pipucks(pipuck_locations, 1)              # from label 1 generate pipuck xml tags

# wall
gate_number = 2

if exp_scale == 1 :
    gate_number = 1

y_range_from = -exp_scale*1.5-1
y_range_to   =  exp_scale*1.5+1

if exp_scale == 1 :
    y_range_from = -exp_scale*1.5-2
    y_range_to   =  exp_scale*1.5+2

wall_xml, largest_loc = generate_wall(gate_number,              # number of gates
                                      0,                        # x location of the wall
                                      y_range_from, 
                                      y_range_to,               # y range of the wall
                                      #0,
                                      #-exp_scale*3.0-2, 
                                      #2,          # y range of the wall
                                      0.8, 3.3, 4.0,                 # size range and max of the gate
                                      0.25,                     # block distance to fill the wall
                                      253, 254)                 # gate_brick_type, and wall_brick_type

# obstacles
'''
obstacle_locations = generate_random_locations(10,               # total number
                                               None, None,      # origin location
                                               -1.5, -0.5,      # x range
                                               -2.0, 2.0,       # y range
                                               0.5, 3.0)        # near and far limit
obstacle_xml = generate_obstacles(obstacle_locations, 100, 255) # start id and payload
'''

# target
droneDis = 1.5
n = exp_scale * 2 + 2
alpha = math.pi * 2 / n
th = (math.pi - alpha) / 2
radius = droneDis / 2 / math.cos(th) - 1.0

target_xml = generate_target_xml(exp_scale * 2.9 + 0.5, largest_loc, 0,      # x, y, th
                                 252, 255,                           # payload
                                 radius, 0.1, 0.2)                   # radius and edge and tag distance

params = '''
              exp_scale="{}"
              n_drone="{}"
              dangerzone_block="0.30"
              block_label_from="252"
              block_label_to="255"
              stabilizer_preference_robot="pipuck1"
              stabilizer_preference_brain="drone1"
              drone_tag_detection_rate="1"
              drone_default_height="1.8"
              drone_default_start_height="1.8"
              dangerzone_drone="1.25"
              dangerzone_pipuck="0.37"
              dangerzone_reference_pipuck_scalar="1.3"
              deadzone_reference_pipuck_scalar="2"
              obstacle_unseen_count="0"
              morphologiesGenerator="morphologiesGenerator"
              gate_number="{}"

              avoid_block_vortex="nil"
              deadzone_block="0.2"
'''.format(exp_scale, n_drone, gate_number)

# generate sons.argos file, replacing each MARKWORD in the sons_template.argos with the content.
# and call argos3 -c sons.argos
generate_argos_file("@CMAKE_CURRENT_BINARY_DIR@/sons_template.argos", 
                    "sons.argos",
	[
		["RANDOMSEED",        str(Inputseed)],
		["MULTITHREADS",      str(MultiThreads)],
		["TOTALLENGTH",       str((Experiment_length or 6500)/5)],
		["DRONES",            drone_xml], 
		["PIPUCKS",           pipuck_xml], 
		["WALL",              wall_xml], 
		["ARENA_SIZE",        str(arena_size)], 
		#["OBSTACLES",         obstacle_xml], 
		["TARGET",            target_xml], 
		["PIPUCK_CONTROLLER", generate_pipuck_controller('''
              script="@CMAKE_CURRENT_BINARY_DIR@/common.lua"
              my_type="pipuck"
              avoid_speed_scalar="1.0"
        ''' + params)],
		["DRONE_CONTROLLER", generate_drone_controller('''
              script="@CMAKE_CURRENT_BINARY_DIR@/common.lua"
              my_type="drone"
        ''' + params)],
		["SIMULATION_SETUP",  generate_physics_media_loop_visualization("@CMAKE_BINARY_DIR@")],
	]
)

os.system("argos3 -c sons.argos" + VisualizationArgosFlag)
