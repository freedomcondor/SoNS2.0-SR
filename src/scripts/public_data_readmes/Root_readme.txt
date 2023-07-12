This is the data repo of SoNS experiments. It contains the following scenarios :

In each folder of real robot experiments, there are 5 runs
In each folder of simulation experiments, there are folders with different sizes of simulations, each with 50 runs

1. Mission_Self-organized_hierarchy
	1.1. Variant1_Clustered_start
		1.1.1. Real robots experiments
		1.1.2. simulation experiments
			1.1.2.1. simulation with 8 robots
			1.1.2.2. simulation with 50 robots
		
	1.2 Variant2_Scattered_start
		1.2.1. Real robots experiments
		1.2.2. simulation experiments
			1.2.2.1. simulation with 12 robots
			1.2.2.2. simulation with 50 robots

2. Mission_Global_local_goals
	2.1. Variant1_Smaller_denser_obstacles
		2.1.1. Real robots experiments
		2.1.2. simulation experiments
			2.1.2.1. simulation with 8 robots
			2.1.2.2. simulation with 50 robots
	2.2. Variant2_Larger_less_dense_obstacles
		2.2.1. Real robots experiments
		2.2.2. simulation experiments
			2.2.2.1. simulation with 8 robots
			2.2.2.2. simulation with 50 robots

3. Mission_Collective_sensing_actuation
	3.1. Real robots experiments
	3.2. simulation experiments
		3.2.1. simulation with 8 robots
		3.2.2. simulation with 50 robots

4. Mission_Binary_decision
	4.1. Real robots experiments
	4.2. simulation experiments
		4.2.1. simulation with 8 robots
		4.2.2. simulation with 65 robots

5. Mission_Splitting_merging
	5.1. Variant1_Search_and_rescue_in_passage
		5.1.1. Real robots experiments
		5.1.2. simulation experiments
			5.1.2.1. simulation with 8 robots
			5.1.2.2. simulation with 50 robots

	5.2. Variant2_Push_away_obstruction
		5.2.1. Real robots experiments
		5.2.2. simulation experiments
			5.2.2.1. simulation with 5 robots

6. Scalability
	6.1. Scalability_in_decision_making_mission
		6.1.1. simulation with 35 robots
		6.1.2. simulation with 65 robots
		6.1.3. simulation with 95 robots
		6.1.4. simulation with 125 robots

7. Fault_tolerance
	7.1. Real robots experiments
	7.2. simulation experiments
		7.2.1. simulation with 8 robots
		7.2.2. simulation with 50 robots
			7.2.2.1. Variant1 One third chance for each robot to fail
			7.2.2.2. Variant2 Two thirds chance for each robot to fail
			7.2.2.3. Variant3 Temporary system wide vision failue
				7.2.2.3.1. failure for 0.5s
				7.2.2.3.2. failure for 1s
				7.2.2.3.3. failure for 30s
			7.2.2.4. Variant4 Temporary system wide communication failue
				7.2.2.4.1. failure for 0.5s
				7.2.2.4.2. failure for 1s
				7.2.2.4.3. failure for 30s
			7.2.2.5. Additional variants
				7.2.2.5.1. One third chance for each aerial robot to fail
				7.2.2.5.2. One third chance for each ground robot to fail
				7.2.2.5.3. Two thirds chance for each aerial robot to fail
				7.2.2.5.4. Two thirds chance for each ground robot to fail

8. Demos
	8.1. Real robots with failure and substitution

