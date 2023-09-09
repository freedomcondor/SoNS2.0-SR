createArgosFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/createArgosScenario.py"
#execfile(createArgosFileName)
exec(compile(open(createArgosFileName, "rb").read(), createArgosFileName, 'exec'))

import os

# drone and pipuck
drone_locations = generate_random_locations(3,                  # total number
                                            0, 0.5,               # origin location
                                            -3, 3,              # random x range
                                            -2, 2,              # random y range
                                            1.5, 1.7)           # near limit and far limit
pipuck_locations = generate_slave_locations_with_origin(
                                            14,
                                            drone_locations,
                                            0, 0.7,
                                            -4, 4,              # random x range
                                            -2.0, 2.0,          # random y range
                                            0.5, 0.7)           # near limit and far limit
drone_xml = generate_drones(drone_locations, 1)                 # from label 1 generate drone xml tags

pipuck_locations.remove(pipuck_locations[0])

pipuck_xml = generate_pipuck_xml(1, 0, 0.7, 90) + \
             generate_pipucks(pipuck_locations, 2)             # from label 2 generate pipuck xml tags

#pipuck_xml = generate_pipuck_xml(1, -3, 0) + \                 # an extra pipuck and pipuck1
#             generate_pipucks(pipuck_locations, 2)             # from label 2 generate pipuck xml tags

# generate sons.argos file, replacing each MARKWORD in the sons_template.argos with the content.
# and call argos3 -c sons.argos
generate_argos_file("/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/8_Demo/Demo_with_3_drones/sons_template.argos", 
#                    "/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/8_Demo/Demo_with_3_drones/sons.argos",
                    "sons.argos",
	[
		["RANDOMSEED",        str(Inputseed)],  # Inputseed is inherit from createArgosScenario.py
		["TOTALLENGTH",       str((Experiment_length or 1000)/5)],
        ["MULTITHREADS",      str(MultiThreads)],
		["REAL_SCENARIO",     generate_real_scenario_object()],
		["DRONES",            drone_xml], 
		["PIPUCKS",           pipuck_xml], 
		["PIPUCK_CONTROLLER", generate_pipuck_controller('''
              script="/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/8_Demo/Demo_with_3_drones/simu/common.lua"
              my_type="pipuck"
              stabilizer_preference_robot="pipuck1"
              stabilizer_preference_brain="drone1"
              connector_pipuck_children_max_count="5"
              safezone_pipuck_pipuck="1.5"
              deadzone_reference_pipuck_scalar="1"
        ''')],
		["DRONE_CONTROLLER", generate_drone_controller('''
              script="/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/8_Demo/Demo_with_3_drones/simu/common.lua"
              my_type="drone"
              stabilizer_preference_robot="pipuck1"
              stabilizer_preference_brain="drone1"
              connector_pipuck_children_max_count="4"
              safezone_pipuck_pipuck="1.5"
              drone_default_height="1.7"
        ''')],
		["SIMULATION_SETUP",  generate_physics_media_loop_visualization("/home/harry/code-mns2.0/SoNS2.0-SR/build")],
	]
)
              #drone_default_height="1.8"

#os.system("argos3 -c /home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/8_Demo/Demo_with_3_drones/sons.argos" + VisualizationArgosFlag)
os.system("argos3 -c sons.argos" + VisualizationArgosFlag)
