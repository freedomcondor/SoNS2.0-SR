createArgosFileName = "@CMAKE_SOURCE_DIR@/scripts/createArgosScenario.py"
#execfile(createArgosFileName)
exec(compile(open(createArgosFileName, "rb").read(), createArgosFileName, 'exec'))

import os

# drone and pipuck
dis = 0.5
drone_locations = [
    [0,    0],
    [-dis, 0],
    [dis,  0],
    [0,    -dis],
    [-dis, -dis],
    [dis,  -dis],
    [0,    dis],
    [-dis, dis],
    [dis,  dis],
    [dis*2,0],
]

pipuck_index = []
for i in range(0, 5) :
    for j in range(0, 8) :
        pipuck_index.append([i - 2, j - 4])
tmp = pipuck_index[0]
pipuck_index[0] = pipuck_index[21]
pipuck_index[21] = tmp

dis = 0.3
pipuck_locations = []
for index in pipuck_index :
    pipuck_locations.append([dis * index[0], dis * index[1]])

drone_xml = generate_drones(drone_locations, 1)                 # from label 1 generate drone xml tags

pipuck_locations.remove(pipuck_locations[0])

pipuck_xml = generate_pipuck_xml(1, dis*pipuck_index[0][0], dis*pipuck_index[0][1], 90) + \
             generate_pipucks(pipuck_locations, 2)             # from label 2 generate pipuck xml tags

# generate sons.argos file, replacing each MARKWORD in the sons_template.argos with the content.
# and call argos3 -c sons.argos
generate_argos_file("@CMAKE_CURRENT_BINARY_DIR@/sons_template.argos", 
#                    "@CMAKE_CURRENT_BINARY_DIR@/sons.argos",
                    "sons.argos",
    [
        ["RANDOMSEED",        str(Inputseed)],  # Inputseed is inherit from createArgosScenario.py
        ["TOTALLENGTH",       str((Experiment_length or 1000)/5)],
        ["MULTITHREADS",      str(MultiThreads)],
        ["DRONES",            drone_xml], 
        ["PIPUCKS",           pipuck_xml], 
        ["PIPUCK_CONTROLLER", generate_pipuck_controller('''
              script="@CMAKE_CURRENT_BINARY_DIR@/simu/common.lua"
              my_type="pipuck"
              stabilizer_preference_robot="pipuck1"
              stabilizer_preference_brain="drone1"
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
        ''')],
        ["SIMULATION_SETUP",  generate_physics_media_loop_visualization("@CMAKE_BINARY_DIR@")],
    ]
)
              #drone_default_height="1.8"

#os.system("argos3 -c @CMAKE_CURRENT_BINARY_DIR@/sons.argos" + VisualizationArgosFlag)
os.system("argos3 -c sons.argos" + VisualizationArgosFlag)
