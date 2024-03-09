createArgosFileName = "@CMAKE_SOURCE_DIR@/scripts/createArgosScenario.py"
#execfile(createArgosFileName)
exec(compile(open(createArgosFileName, "rb").read(), createArgosFileName, 'exec'))

import os
import math

# abuse Experiment_length as drone number
n_pipuck = Experiment_length

print("n_pipuck", n_pipuck)

n_drone = n_pipuck * 3
arena_size = n_pipuck * 3 + 2

Experiment_length = 2500

if n_pipuck > 25 :
    Experiment_length = n_pipuck * 100 + (n_pipuck - 25) * 100

# drone and pipuck
pipuck_locations = generate_random_locations(n_pipuck,                        # total number
                                            n_pipuck * 0.25, 0,              # origin location
                                            -n_pipuck * 0.25-1, n_pipuck * 0.25+1,              # random x range
                                            -3, 3,              # random y range
                                            1.1, 1.3)                       # near limit and far limit
drone_locations = generate_slave_locations_with_origin(n_drone,
                                            pipuck_locations,
                                            n_pipuck * 0.25, 0,              # origin location
                                            -n_pipuck * 0.25-1, n_pipuck * 0.25+1,              # random x range
                                            -3, 3,              # random y range
                                            0.4, 0.9)                       # near limit and far limit

drone_xml = generate_drones(drone_locations, 1, 4.5)                 # from label 1 generate drone xml tags
pipuck_xml = generate_pipucks(pipuck_locations, 1, 4.5)              # from label 1 generate pipuck xml tags


params = '''
              n_pipuck="{}"
              stabilizer_preference_brain="pipuck1"
              drone_tag_detection_rate="1"
              drone_default_height="1.8"
              drone_default_start_height="1.8"
              dangerzone_drone="0.5"
              dangerzone_pipuck="0.25"
              dangerzone_reference_pipuck_scalar="2.0"
              deadzone_reference_pipuck_scalar="2"
              morphologiesGenerator="morphologiesGenerator"

              safezone_pipuck_pipuck="2.0"

              avoid_block_vortex="nil"
              deadzone_block="0.2"
'''.format(n_pipuck)

drone_params = '''
	driver_slowdown_zone = "1.00"
	driver_stop_zone = "0.20"
'''

# generate sons.argos file, replacing each MARKWORD in the sons_template.argos with the content.
# and call argos3 -c sons.argos
generate_argos_file("@CMAKE_CURRENT_BINARY_DIR@/sons_template.argos", 
                    "sons.argos",
	[
		["RANDOMSEED",        str(Inputseed)],
		["MULTITHREADS",      str(MultiThreads)],
		["TOTALLENGTH",       str((Experiment_length)/5)],
		["DRONES",            drone_xml], 
		["PIPUCKS",           pipuck_xml], 
		["ARENA_SIZE",        str(arena_size)], 
		["PIPUCK_CONTROLLER", generate_pipuck_controller('''
              script="@CMAKE_CURRENT_BINARY_DIR@/simu/common.lua"
              my_type="pipuck"
              avoid_speed_scalar="1.0"
        ''' + params)],
		["DRONE_CONTROLLER", generate_drone_controller('''
              script="@CMAKE_CURRENT_BINARY_DIR@/simu/common.lua"
              my_type="drone"
        ''' + params + drone_params)],
		["SIMULATION_SETUP",  generate_physics_media_loop_visualization("@CMAKE_BINARY_DIR@")],
	]
)

os.system("argos3 -c sons.argos" + VisualizationArgosFlag)
