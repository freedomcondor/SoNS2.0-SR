import sys

# args check -------------------------------------------------
if len(sys.argv) < 3 :
	print("not enough args")
	exit()

input_file_name  = sys.argv[1]
output_file_name = sys.argv[2]

# title lines -------------------------------------------------
title_line = "PreStage, " + \
             "BehaviorTreeStage, " + \
             "PostStage, " + \
             "EndStage, " + \
             "Connector, " + \
             "Assigner, " + \
             "Scalemanager, " + \
             "Stabilizer, " + \
             "Allocator, " + \
             "Intersectiondetector, " + \
             "Avoider, " + \
             "Spreader, " + \
             "BrainKeeper"

# start copy -------------------------------------------------

input_file = open(input_file_name,"r")
output_file = open(output_file_name,"w")


output_file.write(title_line + '\n')
for line in input_file :
	lineList = line.strip().split(" ")
	output_file.write(lineList[0])
	for i in range(1, len(lineList)) :
		output_file.write(", " + lineList[i])
	output_file.write('\n')

input_file.close()
output_file.close()