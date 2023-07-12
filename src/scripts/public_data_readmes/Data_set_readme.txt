In side each of the runX folders, there are :

1. experiment_data
	which contains csv for each robot, recording all the datas about this robot, e.g: positions, orientations ...
	Specifically, in each csv file, there are following columns :

		A. position_x
		B. position_y
		C. position_z

			The global position of the robot

		D. orientation_x
		E. orientation_y
		F. orientation_z

			The global orientation in Euler angles of the robot
		
		G. virtual_frame_x
		H. virtual_frame_y
		I. virtual_frame_z

			The orientation of virtual frame in Euler angles of the robot,
			For virtual frame please refer to Supplemetary Material 1 of the paper.
		
		J. goal_position_x
		K. goal_position_y
		L. goal_position_z

			The relative position of the goal of this robot with repect to the virtual frame

		M. goal_orientation_x
		N. goal_orientation_y
		O. goal_orientation_z

			The relative orientation in Euler angles of the goal of this robot with repect to the virtual frame
		
		P. target_id

			The index of the role of this robot in the target formation

		Q. brain_name

			The ID of the brain of the SoNS that this robot belongs to
		
		R. parent_name

			The ID of the parent of this robot

2. error_measurements
	which contains a file error.csv, which is the error of the whole swarm towards the target formation
	           and a folder error_per_robot, which contains the error of each robot towards its target position

3. _failed_robots.txt
	This file exists specifically in fault_tolerance scenarios where some of the robots fail,
	which contains the name of the failed robots in this run.

4. _timesteps_target_SoNS_change.txt
	This file exists in complex scenarios where the swarm needs to perform a task that requires switching formations.
	which records the timestep that the SoNS switches its target formation.