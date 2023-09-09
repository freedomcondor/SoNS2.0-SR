createArgosFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/createArgosScenario.py"
#execfile(createArgosFileName)
exec(compile(open(createArgosFileName, "rb").read(), createArgosFileName, 'exec'))

import os

# drone and pipuck
dis = 1.5
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
    [-dis*2,0],
]

pipuck_index = []
for i in range(0, 5) :
    for j in range(0, 8) :
        pipuck_index.append([i - 2, j - 4])
tmp = pipuck_index[0]
pipuck_index[0] = pipuck_index[20]
pipuck_index[20] = tmp

dis = 0.7
pipuck_locations = []
for index in pipuck_index :
    pipuck_locations.append([dis * index[0], dis * index[1]])

drone_xml = generate_drones(drone_locations, 1)                 # from label 1 generate drone xml tags

pipuck_locations.remove(pipuck_locations[0])

pipuck_xml = generate_pipuck_xml(1, 0, 0, 90) + \
             generate_pipucks(pipuck_locations, 2)             # from label 2 generate pipuck xml tags

#pipuck_xml = generate_pipuck_xml(1, -3, 0) + \                 # an extra pipuck and pipuck1
#             generate_pipucks(pipuck_locations, 2)             # from label 2 generate pipuck xml tags

# generate sons.argos file, replacing each MARKWORD in the sons_template.argos with the content.
# and call argos3 -c sons.argos
generate_argos_file("/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/5_Mission_Splitting_merging/Variant1_Search_and_rescue_in_passage/Large_scale_simulation_experiments/sons_template.argos", 
#                    "/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/5_Mission_Splitting_merging/Variant1_Search_and_rescue_in_passage/Large_scale_simulation_experiments/sons.argos",
                    "sons.argos",
    [
        ["RANDOMSEED",        str(Inputseed)],  # Inputseed is inherit from createArgosScenario.py
        ["TOTALLENGTH",       str((Experiment_length or 1500)/5)],
        ["MULTITHREADS",      str(MultiThreads)],
        ["DRONES",            drone_xml], 
        ["PIPUCKS",           pipuck_xml], 
        ["PIPUCK_CONTROLLER", generate_pipuck_controller('''
              script="/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/5_Mission_Splitting_merging/Variant1_Search_and_rescue_in_passage/Large_scale_simulation_experiments/simu/common.lua"
              my_type="pipuck"
              stabilizer_preference_robot="pipuck1"
              stabilizer_preference_brain="drone1"
              morphologiesGenerator="morphologiesGenerator"
        ''')],
        ["DRONE_CONTROLLER", generate_drone_controller('''
              script="/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/5_Mission_Splitting_merging/Variant1_Search_and_rescue_in_passage/Large_scale_simulation_experiments/simu/common.lua"
              my_type="drone"
              stabilizer_preference_robot="pipuck1"
              stabilizer_preference_brain="drone1"
              drone_tag_detection_rate="1"
              drone_default_height="1.8"
              drone_default_start_height="1.8"
              dangerzone_drone="1.3"
              morphologiesGenerator="morphologiesGenerator"
        ''')],
        ["SIMULATION_SETUP",  generate_physics_media_loop_visualization("/home/harry/code-mns2.0/SoNS2.0-SR/build")],
    ]
)
              #drone_default_height="1.8"

#os.system("argos3 -c /home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/5_Mission_Splitting_merging/Variant1_Search_and_rescue_in_passage/Large_scale_simulation_experiments/sons.argos" + VisualizationArgosFlag)
os.system("argos3 -c sons.argos" + VisualizationArgosFlag)
