createArgosFileName = "@CMAKE_SOURCE_DIR@/scripts/createArgosScenario.py"
#execfile(createArgosFileName)
exec(compile(open(createArgosFileName, "rb").read(), createArgosFileName, 'exec'))

params = '''
    script="common.lua"
    stabilizer_preference_robot="pipuck1"
    stabilizer_preference_brain="drone1"

    connector_waiting_count="5"
    connector_waiting_parent_count="8"
    connector_unseen_count="20"
    connector_heartbeat_count="10"

    pipuck_label_from="1"
    pipuck_label_to="20"
    block_label_from="30"
    block_label_to="35"

    obstacle_match_distance="0.30"

    safezone_drone_drone="2.5"

    dangerzone_drone="1.8"
    dangerzone_pipuck="0.35"
    dangerzone_block="0.35"

    pipuck_wheel_speed_limit="0.15"
    pipuck_rotation_scalar="0.25"
'''

drone_params = '''
    obstacle_unseen_count="10"
    driver_default_speed="0.03"
'''
pipuck_params = '''
    obstacle_unseen_count="4"
'''
#    safezone_drone_pipuck="1.1"
#    drone_default_height="1.50"

# generate argos file
generate_argos_file("@CMAKE_SOURCE_DIR@/scripts/argos_templates/drone_hw.argos", 
                    "@CMAKE_CURRENT_BINARY_DIR@/hw/01_drone.argos",
	[
		["PARAMS",       params + drone_params],  
	]
)

generate_argos_file("@CMAKE_SOURCE_DIR@/scripts/argos_templates/pipuck_hw.argos", 
                    "@CMAKE_CURRENT_BINARY_DIR@/hw/01_pipuck.argos",
	[
		["PARAMS",       params + pipuck_params],  
	]
)