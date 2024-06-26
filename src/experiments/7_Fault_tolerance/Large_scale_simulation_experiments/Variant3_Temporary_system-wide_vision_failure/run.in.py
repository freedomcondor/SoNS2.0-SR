createArgosFileName = "@CMAKE_SOURCE_DIR@/scripts/createArgosScenario.py"
#execfile(createArgosFileName)
customizeOpts = "t:"
exec(compile(open(createArgosFileName, "rb").read(), createArgosFileName, 'exec'))
# createArgosScenario parse the parameters
# python3 run.py -r 12 -l 500 -v false (-r: randomseed, -l: experiment length, -v: run with visualization GUI or not)
# Inputseed, Experiment_length, Visualization = True or False, VisualizationArgosFlag = "" or " -z" in inherited
Experiment_type = None
for opt, value in optlist:
    if opt == "-t":
        Experiment_type = value
        print("Experiment_type provided: ", Experiment_type)
if Experiment_type == None :
    Experiment_type = "0.5s"
    print("Experiment_type not provided: using default", Experiment_type)
    print("Please use -t 0.5s / 1s / 30s to specify a type")

stopSteps = 0
if Experiment_type == "0.5s":
    stopSteps = 2
elif Experiment_type == "1s":
    stopSteps = 5
elif Experiment_type == "30s":
    stopSteps = 150
else :
    print("invalid experiment type. Please use -t 0.5s / 1s / 30s to specify a type")
    exit()

#----------------------------------------------------------------------------------
import os
import math

exp_scale = 2

n_drone = exp_scale * 6 + 1
n_pipuck = n_drone * 4
arena_size = exp_scale * 10 + 8 + (n_drone)/math.pi

# drone and pipuck
drone_locations = generate_random_locations(n_drone,                        # total number
                                            -exp_scale - 4, 0,              # origin location
                                            -exp_scale*3-3.5, -4.2,             # random x range
                                            -exp_scale*2.5,exp_scale*2.5,       # random y range
                                            1.3, 1.5)                       # near limit and far limit
pipuck_locations = generate_slave_locations_with_origin(n_pipuck,
                                            drone_locations,
                                            -exp_scale -3.5, 0.4,          # origin
                                            -exp_scale*3-3.5, -4.2,             # random x range
                                            -exp_scale*2.5,exp_scale*2.5,       # random y range
                                            0.3, 0.7)

drone_xml = generate_drones(drone_locations, 1)                 # from label 1 generate drone xml tags
pipuck_xml = generate_pipucks(pipuck_locations, 1)              # from label 1 generate pipuck xml tags

obstacle_locations = generate_line_locations(15,               # number of obstacles
                                              -5.0, 7.0,        # begin x and y
                                              0.0, 2.0)         # end x and y
obstacle_locations2 = generate_line_locations(15,               # number of obstacles
                                              -5.0, -7.0,       # begin x and y
                                              0.0, -2.0)        # end x and y

obstacle_xml = generate_obstacles(obstacle_locations, 100, 101) # start id and payload
obstacle_xml += generate_obstacles(obstacle_locations2, 200, 102) # start id and payload

# target
droneDis = 1.5
n = exp_scale * 2 + 2
alpha = math.pi * 2 / n
th = (math.pi - alpha) / 2
radius = droneDis / 2 / math.cos(th) - 1.0

target_xml = generate_target_xml(exp_scale * 2.9 + 0.5, 0, 0,      # x, y, th
                                 252, 255,                           # payload
                                 radius, 0.1, 0.2)                   # radius and edge and tag distance

# generate argos file
params = '''
    connector_heartbeat_count="5"
    connector_unseen_count="5"

    stabilizer_preference_robot="pipuck1"
    stabilizer_preference_brain="drone1"
    avoid_block_vortex="nil"

    drone_default_height="1.8"
    drone_default_start_height="1.8"

    pipuck_label_from="1"
    pipuck_label_to="99"
    block_label_from="100"
    block_label_to="300"

    obstacle_unseen_count="0"

    safezone_drone_drone="2.0"
    safezone_drone_pipuck="1.0"
    safezone_pipuck_pipuck="0.3"
    driver_spring_default_speed_scalar="10"
    drone_tag_detection_rate="1"
    pipuck_wheel_speed_limit="0.2"

    morphologiesGenerator="morphologiesGenerator"
    exp_scale="{}"
    stop_steps="{}"
'''.format(exp_scale, stopSteps)

# generate sons.argos file, replacing each MARKWORD in the sons_template.argos with the content.
# and call argos3 -c sons.argos
generate_argos_file("@CMAKE_CURRENT_BINARY_DIR@/sons_template.argos", 
#                    "@CMAKE_CURRENT_BINARY_DIR@/sons.argos",
                    "sons.argos",
    [
        ["RANDOMSEED",        str(Inputseed)],  # Inputseed is inherit from createArgosScenario.py
        ["TOTALLENGTH",       str((Experiment_length or 4000)/5)],
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
