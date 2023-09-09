createArgosFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/createArgosScenario.py"
#execfile(createArgosFileName)
exec(compile(open(createArgosFileName, "rb").read(), createArgosFileName, 'exec'))

import os

# note: for video, run with random seed 2 on mac
# note: for video, run with random seed 4 on ubuntu

# drone and pipuck
drone_locations = [
    [0.5, -0.6],
    [-0.3, 1],
] 
pipuck_locations = [
    [0.5, -0.1],
    [0.5, -1],
    [0, 0.7],
    [-0.3, 1],
]

drone_xml = generate_drones(drone_locations, 1)                 # from label 1 generate drone xml tags

pipuck_xml = generate_pipucks(pipuck_locations, 1)             # from label 2 generate pipuck xml tags

#pipuck_xml = generate_pipuck_xml(1, -3, 0) + \                 # an extra pipuck and pipuck1
#             generate_pipucks(pipuck_locations, 2)             # from label 2 generate pipuck xml tags

# generate sons.argos file, replacing each MARKWORD in the sons_template.argos with the content.
# and call argos3 -c sons.argos
generate_argos_file("/home/harry/code-mns2.0/SoNS2.0-SR/build/testing/exp_0_hw_00_demo_1_2d_4p/sons_template.argos", 
#                    "/home/harry/code-mns2.0/SoNS2.0-SR/build/testing/exp_0_hw_00_demo_1_2d_4p/sons.argos",
                    "sons.argos",
	[
		["RANDOMSEED",        str(Inputseed)],  # Inputseed is inherit from createArgosScenario.py
		["TOTALLENGTH",       str((Experiment_length or 100000)/5)],
		["DRONES",            drone_xml], 
		["PIPUCKS",           pipuck_xml], 
		["PIPUCK_CONTROLLER", generate_pipuck_controller('''
              script="/home/harry/code-mns2.0/SoNS2.0-SR/build/testing/exp_0_hw_00_demo_1_2d_4p/common.lua"
              my_type="pipuck"
              stabilizer_preference_robot="pipuck1"
              stabilizer_preference_brain="drone1"
        ''')],
		["DRONE_CONTROLLER", generate_drone_controller('''
              script="/home/harry/code-mns2.0/SoNS2.0-SR/build/testing/exp_0_hw_00_demo_1_2d_4p/common.lua"
              my_type="drone"
              stabilizer_preference_robot="pipuck1"
              stabilizer_preference_brain="drone1"
              drone_altitude_bias="0"
        ''')],
		["SIMULATION_SETUP",  generate_physics_media_loop_visualization("/home/harry/code-mns2.0/SoNS2.0-SR/build")],
	]
)
              #drone_default_height="1.8"

#os.system("argos3 -c /home/harry/code-mns2.0/SoNS2.0-SR/build/testing/exp_0_hw_00_demo_1_2d_4p/sons.argos" + VisualizationArgosFlag)
os.system("argos3 -c sons.argos" + VisualizationArgosFlag)
