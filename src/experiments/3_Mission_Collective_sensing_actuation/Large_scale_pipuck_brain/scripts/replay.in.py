replayerFile = "@CMAKE_MNS3_BINARY_DIR@/scripts/libreplayer/replayer.py"

#execfile(createArgosFileName)
exec(compile(open(replayerFile, "rb").read(), replayerFile, 'exec'))

obstacle_locations = generate_line_locations(15,               # number of obstacles
                                              -10.0, 14.0,        # begin x and y
                                              0.0, 4.0)         # end x and y
obstacle_locations2 = generate_line_locations(15,               # number of obstacles
                                              -10.0, -14.0,       # begin x and y
                                              0.0, -4.0)        # end x and y

obstacle_xml = generate_obstacles(obstacle_locations, 100, 101) # start id and payload
obstacle_xml += generate_obstacles(obstacle_locations2, 200, 102) # start id and payload

# target
exp_scale = 2
droneDis = 3
n = exp_scale * 2 + 2
alpha = math.pi * 2 / n
th = (math.pi - alpha) / 2
radius = droneDis / 2 / math.cos(th) - 2.0

target_xml = generate_target_xml(exp_scale * 5.8 + 1.0, 0, 0,      # x, y, th
                                 252, 255,                           # payload
                                 radius, 0.1, 1.0)                   # radius and edge and tag distance

#----------------------------------------------------------------------------------------------
# generate argos file
generate_argos_file("@CMAKE_CURRENT_BINARY_DIR@/replayer_template.argos", 
                    "replay.argos",
    [
        ["RANDOMSEED",        str(Inputseed)],  # Inputseed is inherit from createArgosScenario.py
        ["TOTALLENGTH",       str((Experiment_length or 4500)/5)],
        ["MULTITHREADS",      str(MultiThreads)],  # MultiThreads is inherit from createArgosScenario.py
        ["OBSTACLES",         obstacle_xml],
        ["TARGET",            target_xml],
        ["DRONES",            drone_xml], 
        ["PIPUCKS",           pipuck_xml], 
        ["ARENA_SIZE",        arena_size_xml], 
        ["ARENA_CENTER",      arena_center_xml], 
    ]
)

os.system("argos3 -c replay.argos")