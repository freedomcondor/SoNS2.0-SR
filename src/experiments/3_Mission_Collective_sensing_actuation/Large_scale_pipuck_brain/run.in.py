createArgosFileName = "@CMAKE_SOURCE_DIR@/scripts/createArgosScenario.py"
#execfile(createArgosFileName)
exec(compile(open(createArgosFileName, "rb").read(), createArgosFileName, 'exec'))
# createArgosScenario parse the parameters
# python3 run.py -r 12 -l 500 -v false (-r: randomseed, -l: experiment length, -v: run with visualization GUI or not)
# Inputseed, Experiment_length, Visualization = True or False, VisualizationArgosFlag = "" or " -z" in inherited

import os
import math

exp_scale = 2

n_pipuck = exp_scale * 6 + 1
n_drone = n_pipuck * 3
arena_size = exp_scale * 10 + 8 + (n_drone)/math.pi
arena_size = arena_size * 2

# drone and pipuck
pipuck_locations = generate_random_locations(n_pipuck,                        # total number
                                            -exp_scale * 3.5 - 8, 0,              # origin location
                                            -exp_scale*6-7, -8.4,             # random x range
                                            -exp_scale*5,exp_scale*5,       # random y range
                                            2.6, 3.0)                       # near limit and far limit
drone_locations = generate_slave_locations_with_origin(n_drone,
                                            pipuck_locations,
                                            -exp_scale*2 -7, 0.8,          # origin
                                            -exp_scale*6-7, -8.4,             # random x range
                                            -exp_scale*5,exp_scale*5,       # random y range
                                            0.6, 1.4)

drone_xml = generate_drones(drone_locations, 1)                 # from label 1 generate drone xml tags
pipuck_xml = generate_pipucks(pipuck_locations, 1)              # from label 1 generate pipuck xml tags

obstacle_locations = generate_line_locations(15,               # number of obstacles
                                              -10.0, 14.0,        # begin x and y
                                              0.0, 4.0)         # end x and y
obstacle_locations2 = generate_line_locations(15,               # number of obstacles
                                              -10.0, -14.0,       # begin x and y
                                              0.0, -4.0)        # end x and y

obstacle_xml = generate_obstacles(obstacle_locations, 100, 101) # start id and payload
obstacle_xml += generate_obstacles(obstacle_locations2, 200, 102) # start id and payload

# target
droneDis = 3
n = exp_scale * 2 + 2
alpha = math.pi * 2 / n
th = (math.pi - alpha) / 2
radius = droneDis / 2 / math.cos(th) - 2.0

target_xml = generate_target_xml(exp_scale * 5.8 + 1.0, 0, 0,      # x, y, th
                                 252, 255,                           # payload
                                 radius, 0.1, 1.0)                   # radius and edge and tag distance

# generate argos file
params = '''
    stabilizer_preference_brain="pipuck1"
    avoid_block_vortex="nil"

    drone_default_height="3.6"
    drone_default_start_height="3.6"

    pipuck_label_from="1"
    pipuck_label_to="99"
    block_label_from="100"
    block_label_to="300"

    obstacle_unseen_count="0"

    safezone_drone_drone="5.0"
    safezone_pipuck_pipuck="5.0"
    safezone_drone_pipuck="2.0"
    dangerzone_drone="1.2"

    driver_spring_default_speed_scalar="6"
    drone_tag_detection_rate="1"
    pipuck_wheel_speed_limit="0.4"
    driver_default_speed_scalar="0.2"

    morphologiesGenerator="morphologiesGenerator"
    exp_scale="{}"
'''.format(exp_scale)

# generate sons.argos file, replacing each MARKWORD in the sons_template.argos with the content.
# and call argos3 -c sons.argos
generate_argos_file("@CMAKE_CURRENT_BINARY_DIR@/sons_template.argos", 
#                    "@CMAKE_CURRENT_BINARY_DIR@/sons.argos",
                    "sons.argos",
    [
        ["RANDOMSEED",        str(Inputseed)],  # Inputseed is inherit from createArgosScenario.py
        ["TOTALLENGTH",       str((Experiment_length or 6000)/5)],
        ["MULTITHREADS",      str(MultiThreads)],
        #["REAL_SCENARIO",     generate_real_scenario_object()],
        ["ARENA_SIZE",        str(arena_size)], 
        ["DRONES",            drone_xml], 
        ["PIPUCKS",           pipuck_xml], 
        ["OBSTACLES",         obstacle_xml], 
        ["TARGET",            target_xml], 
        ["PIPUCK_CONTROLLER", generate_pipuck_controller('''
              script="@CMAKE_CURRENT_BINARY_DIR@/simu/common.lua"
              my_type="pipuck"
        ''' + params)],
        ["DRONE_CONTROLLER", generate_drone_controller('''
              script="@CMAKE_CURRENT_BINARY_DIR@/simu/common.lua"
              my_type="drone"
        ''' + params)],
        ["SIMULATION_SETUP",  generate_physics_media_loop_visualization("@CMAKE_BINARY_DIR@")],
    ]
)

#os.system("argos3 -c @CMAKE_CURRENT_BINARY_DIR@/sons.argos" + VisualizationArgosFlag)
os.system("argos3 -c sons.argos" + VisualizationArgosFlag)
