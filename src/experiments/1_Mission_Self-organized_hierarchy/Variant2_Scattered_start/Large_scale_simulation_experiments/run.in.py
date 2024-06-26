createArgosFileName = "@CMAKE_SOURCE_DIR@/scripts/createArgosScenario.py"
#execfile(createArgosFileName)
exec(compile(open(createArgosFileName, "rb").read(), createArgosFileName, 'exec'))

import os

# drone and pipuck
drone_locations = generate_random_locations(10,                  # total number
                                            0.5, 0,             # origin location
                                            -4, 4,              # random x range
                                            -3, 3,              # random y range
                                            1.3, 1.4)           # near limit and far limit
pipuck_locations = generate_slave_locations_with_origin(
                                            40,
                                            drone_locations,
                                            1, 0.7,
                                            -4, 4,              # random x range
                                            -3, 3,          # random y range
                                            0.3, 0.7)           # near limit and far limit
drone_xml = generate_drones(drone_locations, 1)                 # from label 1 generate drone xml tags

pipuck_locations.remove(pipuck_locations[0])

pipuck_xml = generate_pipuck_xml(1, 1, 0.7, 90) + \
             generate_pipucks(pipuck_locations, 2)             # from label 2 generate pipuck xml tags

#pipuck_xml = generate_pipuck_xml(1, -3, 0) + \                 # an extra pipuck and pipuck1
#             generate_pipucks(pipuck_locations, 2)             # from label 2 generate pipuck xml tags

# generate sons.argos file, replacing each MARKWORD in the sons_template.argos with the content.
# and call argos3 -c sons.argos
generate_argos_file("@CMAKE_CURRENT_BINARY_DIR@/sons_template.argos", 
#                    "@CMAKE_CURRENT_BINARY_DIR@/sons.argos",
                    "sons.argos",
    [
        ["RANDOMSEED",        str(Inputseed)],  # Inputseed is inherit from createArgosScenario.py
        ["MULTITHREADS",      str(MultiThreads)],
        ["TOTALLENGTH",       str((Experiment_length or 1000)/5)],
        ["DRONES",            drone_xml], 
        ["PIPUCKS",           pipuck_xml], 
        ["PIPUCK_CONTROLLER", generate_pipuck_controller('''
              script="@CMAKE_CURRENT_BINARY_DIR@/simu/common.lua"
              my_type="pipuck"
              stabilizer_preference_robot="pipuck1"
              stabilizer_preference_brain="drone1"

              safezone_pipuck_pipuck="0.3"
              driver_spring_default_speed_scalar="6"
        ''')],
        ["DRONE_CONTROLLER", generate_drone_controller('''
              script="@CMAKE_CURRENT_BINARY_DIR@/simu/common.lua"
              my_type="drone"
              stabilizer_preference_robot="pipuck1"
              stabilizer_preference_brain="drone1"
              drone_tag_detection_rate="1"
              drone_default_height="1.8"
              drone_default_start_height="1.8"
              dangerzone_drone="1.3"

              safezone_pipuck_pipuck="0.3"
              driver_spring_default_speed_scalar="4"
        ''')],
        ["SIMULATION_SETUP",  generate_physics_media_loop_visualization("@CMAKE_BINARY_DIR@")],
    ]
)
              #drone_default_height="1.8"

#os.system("argos3 -c @CMAKE_CURRENT_BINARY_DIR@/sons.argos" + VisualizationArgosFlag)
os.system("argos3 -c sons.argos" + VisualizationArgosFlag)
