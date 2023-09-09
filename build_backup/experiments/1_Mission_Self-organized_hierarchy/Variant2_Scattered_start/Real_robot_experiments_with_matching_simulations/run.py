createArgosFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/createArgosScenario.py"
#execfile(createArgosFileName)
exec(compile(open(createArgosFileName, "rb").read(), createArgosFileName, 'exec'))

import os

# drone and pipuck
drone_locations = generate_random_locations(2,                  # total number
                                            0.5, 0,             # origin location
                                            -3, 3,              # random x range
                                            -2, 2,              # random y range
                                            1.5, 1.6)           # near limit and far limit
pipuck_locations = generate_slave_locations_with_origin(
                                            10,
                                            drone_locations,
                                            1, 0.7,
                                            -4, 4,              # random x range
                                            -2.0, 2.0,          # random y range
                                            0.5, 0.8)           # near limit and far limit
drone_xml = generate_drones(drone_locations, 1)                 # from label 1 generate drone xml tags

pipuck_locations.remove(pipuck_locations[0])

pipuck_xml = generate_pipuck_xml(1, 1, 0.7, 90) + \
             generate_pipucks(pipuck_locations, 2)             # from label 2 generate pipuck xml tags

#pipuck_xml = generate_pipuck_xml(1, -3, 0) + \                 # an extra pipuck and pipuck1
#             generate_pipucks(pipuck_locations, 2)             # from label 2 generate pipuck xml tags

# generate sons.argos file, replacing each MARKWORD in the sons_template.argos with the content.
# and call argos3 -c sons.argos
generate_argos_file("/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Real_robot_experiments_with_matching_simulations/sons_template.argos", 
#                    "/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Real_robot_experiments_with_matching_simulations/sons.argos",
                    "sons.argos",
    [
        ["RANDOMSEED",        str(Inputseed)],  # Inputseed is inherit from createArgosScenario.py
        ["TOTALLENGTH",       str((Experiment_length or 500)/5)],
        ["REAL_SCENARIO",     generate_real_scenario_object()],
        ["MULTITHREADS",      str(MultiThreads)],
        ["DRONES",            drone_xml], 
        ["PIPUCKS",           pipuck_xml], 
        ["PIPUCK_CONTROLLER", generate_pipuck_controller('''
              script="/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Real_robot_experiments_with_matching_simulations/simu/common.lua"
              my_type="pipuck"
              stabilizer_preference_robot="pipuck1"
              stabilizer_preference_brain="drone1"
        ''')],
        ["DRONE_CONTROLLER", generate_drone_controller('''
              script="/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Real_robot_experiments_with_matching_simulations/simu/common.lua"
              my_type="drone"
              stabilizer_preference_robot="pipuck1"
              stabilizer_preference_brain="drone1"
        ''')],
        ["SIMULATION_SETUP",  generate_physics_media_loop_visualization("/home/harry/code-mns2.0/SoNS2.0-SR/build")],
    ]
)
              #drone_default_height="1.8"

#os.system("argos3 -c /home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/1_Mission_Self-organized_hierarchy/Variant2_Scattered_start/Real_robot_experiments_with_matching_simulations/sons.argos" + VisualizationArgosFlag)
os.system("argos3 -c sons.argos" + VisualizationArgosFlag)
