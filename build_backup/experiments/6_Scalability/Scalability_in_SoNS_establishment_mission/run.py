createArgosFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/createArgosScenario.py"
#execfile(createArgosFileName)
exec(compile(open(createArgosFileName, "rb").read(), createArgosFileName, 'exec'))

import os
import math

# abuse Experiment_length as drone number
n_drone = Experiment_length

print("n_drone", n_drone)

n_pipuck = n_drone * 4
arena_size = n_drone * 3 + 2

Experiment_length = 2500

if n_drone > 25 :
    Experiment_length = n_drone * 100 + (n_drone - 25) * 100

# drone and pipuck
drone_locations = generate_random_locations(n_drone,                        # total number
                                            n_drone * 0.25, 0,              # origin location
                                            -n_drone * 0.25-1, n_drone * 0.25+1,              # random x range
                                            -3, 3,              # random y range
                                            1.1, 1.3)                       # near limit and far limit
pipuck_locations = generate_slave_locations_with_origin(n_pipuck,
                                            drone_locations,
                                            n_drone * 0.25, 0,              # origin location
                                            -n_drone * 0.25-1, n_drone * 0.25+1,              # random x range
                                            -3, 3,              # random y range
                                            0.4, 0.9)                       # near limit and far limit

drone_xml = generate_drones(drone_locations, 1, 4.5)                 # from label 1 generate drone xml tags
pipuck_xml = generate_pipucks(pipuck_locations, 1, 4.5)              # from label 1 generate pipuck xml tags


params = '''
              n_drone="{}"
              stabilizer_preference_robot="pipuck1"
              stabilizer_preference_brain="drone1"
              drone_tag_detection_rate="1"
              drone_default_height="1.8"
              drone_default_start_height="1.8"
              dangerzone_drone="1.1"
              dangerzone_pipuck="0.25"
              dangerzone_reference_pipuck_scalar="2.0"
              deadzone_reference_pipuck_scalar="2"
              morphologiesGenerator="morphologiesGenerator"

              avoid_block_vortex="nil"
              deadzone_block="0.2"
'''.format(n_drone)

# generate sons.argos file, replacing each MARKWORD in the sons_template.argos with the content.
# and call argos3 -c sons.argos
generate_argos_file("/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/6_Scalability/Scalability_in_SoNS_establishment_mission/sons_template.argos", 
                    "sons.argos",
	[
		["RANDOMSEED",        str(Inputseed)],
		["TOTALLENGTH",       str((Experiment_length)/5)],
		["DRONES",            drone_xml], 
		["PIPUCKS",           pipuck_xml], 
		#["WALL",              wall_xml], 
		["ARENA_SIZE",        str(arena_size)], 
		#["OBSTACLES",         obstacle_xml], 
		#["TARGET",            target_xml], 
		["PIPUCK_CONTROLLER", generate_pipuck_controller('''
              script="/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/6_Scalability/Scalability_in_SoNS_establishment_mission/simu/common.lua"
              my_type="pipuck"
              avoid_speed_scalar="1.0"
        ''' + params)],
		["DRONE_CONTROLLER", generate_drone_controller('''
              script="/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/6_Scalability/Scalability_in_SoNS_establishment_mission/simu/common.lua"
              my_type="drone"
        ''' + params)],
		["SIMULATION_SETUP",  generate_physics_media_loop_visualization("/home/harry/code-mns2.0/SoNS2.0-SR/build")],
	]
)

os.system("argos3 -c sons.argos" + VisualizationArgosFlag)
