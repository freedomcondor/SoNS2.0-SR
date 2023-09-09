createArgosFileName = "/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/createArgosScenario.py"
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
    block_label_from="25"
    block_label_to="35"

    obstacle_match_distance="0.30"
    obstacle_unseen_count="10"

    safezone_drone_drone="3.0"
    safezone_drone_pipuck="1.5"
    dangerzone_pipuck="0.35"
    dangerzone_block="0.35"
    dangerzone_drone="2.0"
    deadzone_drone="1.0"

    pipuck_wheel_speed_limit="0.15"
    pipuck_rotation_scalar="0.25"
'''

# generate argos file
generate_argos_file("/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/argos_templates/drone_hw.argos", 
                    "/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/1_Mission_Self-organized_hierarchy/Variant1_Clustered_start/Real_robot_experiments_with_matching_simulations/hw/01_drone.argos",
	[
		["PARAMS",       "driver_default_speed=\"0.03\"\n" + params],  
	]
)

generate_argos_file("/home/harry/code-mns2.0/SoNS2.0-SR/src/scripts/argos_templates/pipuck_hw.argos", 
                    "/home/harry/code-mns2.0/SoNS2.0-SR/build/experiments/1_Mission_Self-organized_hierarchy/Variant1_Clustered_start/Real_robot_experiments_with_matching_simulations/hw/01_pipuck.argos",
	[
		["PARAMS",       params],  
	]
)
