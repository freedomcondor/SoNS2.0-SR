For a detailed explanation of information types listed here, please refer to the Supplemetary Materials of the accompanying manuscript.
		
Each run folder contains:

1. experiment_data folder,
	which contains one csv for each robot. Each csv contains the following columns, when relevant to the respective robot (with each row corresponding to one time step):

		A. position_x
		B. position_y
		C. position_z

			Position of the robot recorded by the external tracking system (meters)

		D. orientation_x
		E. orientation_y
		F. orientation_z

			Orientation of the robot recorded by the external tracking system (Euler angles)
		
		G. virtual_frame_x
		H. virtual_frame_y
		I. virtual_frame_z

			Relative orientation of the robot's intermediary motion frame with respect to its body frame (Euler angles)
			For an explanation of the intermediary motion frame, please refer to the Supplemetary Materials of the accompanying manuscript.
		
		J. goal_position_x
		K. goal_position_y
		L. goal_position_z

			Target relative position of the robot with repect to its intermediary motion frame (meters)

		M. goal_orientation_x
		N. goal_orientation_y
		O. goal_orientation_z

			Target relative orientation iof the robot with repect to its intermediary motion frame (Euler angles)
		
		P. target_id

			ID of the node position of the robot in the SoNS

		Q. brain_name

			The robot ID of the brain of the SoNS that the robot belongs to
		
		R. parent_name

			The robot ID of the parent of the robot

2. error_measurements folder,
	which contains an error.csv file, which gives the total error of the swarm (one column; each row corresponds to one time step).
	           It also contains an error_per_robot folder, which contains one csv for each robot, in the same format as the previously described csv.

Optional files.
Some folders contain one (or both) of the following two informational files:

3. _failed_robots.txt
	In some folders for fault tolerance scenarios, this file gives the robot IDs of all robots that failed in that run.

4. _timesteps_target_SoNS_change.txt
	In some folders for mission scenarios that include changes to the target SoNS, this file gives the timesteps at which the target SoNS was changed.