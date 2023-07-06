import sys

# args check -------------------------------------------------
if len(sys.argv) < 3 :
	print("not enough args")
	exit()

input_file_name  = sys.argv[1]
output_file_name = sys.argv[2]

# title lines -------------------------------------------------
title_line_6 = "position_x,position_y,position_z,orientation_x,orientation_y,orientation_z"
title_line_17 = title_line_6 + ",virtual_frame_x,virtual_frame_y,virtual_frame_z,goal_position_x,goal_position_y,goal_position_z,goal_orientation_x,goal_orientation_y,goal_orientation_z,target_id,brain_name"
title_line_18 = title_line_17 + ",parent_name"

# start copy -------------------------------------------------

input_file = open(input_file_name,"r")
output_file = open(output_file_name,"w")

first_line = True
for line in input_file :
	if first_line :
		first_line = False

		lineList = line.strip().split(",")
		if len(lineList) > 17 :
			output_file.write(title_line_18 + '\n')
		elif len(lineList) > 6 :
			output_file.write(title_line_17 + '\n')
		else :
			output_file.write(title_line_6 + '\n')

	output_file.write(line)

input_file.close()
output_file.close()