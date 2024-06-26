#----------------------------------------------------------------------------------------------
# This file provides basic functions to configure the .argos file
# Usually, in an experiment setup, there is a run.py that includes this file, generates a
# .argos file, and runs it with argos3
# In this way, to run an experiment: 
#    python3 run.py -r x -l xx -v xx -m xxx 
# The -r -l  parameters are explained below.
#----------------------------------------------------------------------------------------------
import random
import sys
import getopt
import time

#----------------------------------------------------------------------------------------------
# usage message 
usage="[usage] example: python3 xxx.py -r 1 -l 1000 -v true -m 10"

#----------------------------------------------------------------------------------------------
# parse opts
# -r x means setting the randomseed to x, if not set, the default takes the current time
# -l x means setting the randomseed to x, if not set, the default is None, so that run.py for each scenario uses it own defualt experiment length
# -v True/False means sets whether to enable GUI. When we are doing large scale parallel experiments, we do not need GUI, so use -v False
# -m x means using x threads in parallel

#----------------------------------------------------------------------------------------------
# parse opts
if "customizeOpts" not in locals() :
    customizeOpts = ""

try:
	optlist, args = getopt.getopt(sys.argv[1:], "r:l:v:m:h" + customizeOpts)
except:
	print("[error] unexpected opts")
	print(usage)
	sys.exit(0)

Inputseed = None
MultiThreads = None
Experiment_length = None
Visualization = True
VisualizationArgosFlag = ""

for opt, value in optlist:
	if opt == "-r":
		Inputseed = int(value)
		print("Inputseed provided:", Inputseed)
	elif opt == "-l":
		Experiment_length = int(value)
		print("experiment_length provided:", Experiment_length)
	elif opt == "-v":
		if value == "False" or value == "false" :
			Visualization = False
		print("visualization provided:", Visualization)
	elif opt == "-m":
            MultiThreads = int(value) 
            print("Multi threads provided:", MultiThreads)
	elif opt == "-h":
		print(usage)
		exit()

if Inputseed == None :
	Inputseed = int(time.time())
	print("Inputseed not provided, using:", Inputseed)

if MultiThreads == None :
	MultiThreads = 0
	print("MultiThreads not provided, using:", MultiThreads)

if Visualization == False :
	VisualizationArgosFlag = " -z"

#----------------------------------------------------------------------------------------------
# random seed
random.seed(Inputseed)

#----------------------------------------------------------------------------------------------
# Controller
# Generates controller <xml> section in .argos file
# input params will be inserted in <params> as attributes
# for example, a basic usage is generate_drone_controller('''script="pipuck_controller.lua"''')
def generate_drone_controller(params) :
	text = '''
    <!-- Drone Controller -->
    <lua_controller id="drone">
      <actuators>
        <debug implementation="default" />
        <drone_flight_system implementation="default" />
        <drone_leds implementation="default" />
        <radios implementation="default" />
      </actuators>
      <sensors>
        <drone_system implementation="default" />
        <drone_cameras_system implementation="default" show_frustum="false" show_tag_rays="false" />
        <drone_flight_system implementation="default" />
        <radios implementation="default" />
      </sensors>
      <params simulation="true" {} />
    </lua_controller>
    '''.format(params)

	return text

def generate_pipuck_controller(params) :
	text = '''
    <!-- Pi-Puck Controller -->
    <lua_controller id="pipuck">
      <actuators>
        <pipuck_differential_drive implementation="default" />
        <pipuck_leds implementation="default" />
        <debug implementation="default" />
        <radios implementation="default" />
      </actuators>
      <sensors>
        <pipuck_system implementation="default" />
        <radios implementation="default" />
      </sensors>
      <params simulation="true" {} />
    </lua_controller>
    '''.format(params)

	return text

#----------------------------------------------------------------------------------------------
# This function generates <xml> sections in .argos for physcis engines, media, loop functions and visualizations
# This part of code is commonly used for all the experiments, so we don't have to repeat these codes in every experiment scenario
# Parameter cmake_binary_dir is the path where argos loop function and user functions are located
def generate_physics_media_loop_visualization(cmake_binary_dir) :
	text = '''
  <!-- ******************* -->
  <!-- * Physics engines * -->
  <!-- ******************* -->
  <physics_engines>
    <pointmass3d id="pm3d" iterations="10" />
    <dynamics3d id="dyn3d" iterations="25">
      <gravity g="9.8" />
      <floor />
    </dynamics3d>
  </physics_engines>

  <!-- ********* -->
  <!-- * Media * -->
  <!-- ********* -->
  <media>
    <directional_led id="directional_leds" index="grid" grid_size="20,20,20"/>
    <tag id="tags" index="grid" grid_size="20,20,20" />
    <radio id="wifi" index="grid" grid_size="20,20,20" />
  </media>

  <!-- ****************** -->
  <!-- * Loop functions * -->
  <!-- ****************** -->
  <loop_functions library="{}/libmy_extensions"
                  label="my_loop_functions" />

  <!-- ****************** -->
  <!-- * Visualization  * -->
  <!-- ****************** -->
  <visualization>
    <qt-opengl lua_editor="false" show_boundary="false">
      <user_functions library="{}/libmy_qtopengl_extensions"
                      label="my_qtopengl_user_functions" />
      <camera>
        <placements>
          <placement index="0" position="0,-0.1,8" look_at="0,0,0" up="0,0,1" lens_focal_length="30" />
        </placements>
      </camera>
    </qt-opengl>
  </visualization>
    '''.format(cmake_binary_dir, cmake_binary_dir)

	return text

#----------------------------------------------------------------------------------------------
# real lab scenario
# This function generates <xml> sections in .argos for real lab scenario
# It draws several boxes to resemble the wardrobes, tables, arena, and a man, the same as in the lab.
def generate_real_scenario_object() :
	if Visualization == False :
		return ""
	text = '''
	<!-- room -->
	<!--
	<box id="north_room" size="-2.02,14,3.00" movable="false" mass="10">
	  <body position="5.1,0,0"  orientation="0,0,0" />
	</box>
	<box id="south_room" size="-2.02,14,3.00" movable="false" mass="10">
	  <body position="-9.1,0,0"  orientation="0,0,0" />
	</box>
	-->

	<!-- furnitures -->
	<box id="furniture1" size="3.20,1.0,2.00" movable="false" mass="10">
	  <body position="4, 4.90,0"  orientation="0,0,0" />
	</box>
	<box id="furniture2" size="3.20,1.0,2.00" movable="false" mass="10">
	  <body position="4,-4.90,0"  orientation="0,0,0" />
	</box>
	<box id="furniture3" size="3.20,1.0,2.00" movable="false" mass="10">
	  <body position="-1, 4.90,0"  orientation="0,0,0" />
	</box>
	<box id="furniture4" size="3.20,1.0,2.00" movable="false" mass="10">
	  <body position="-1,-4.90,0"  orientation="0,0,0" />
	</box>
	<box id="furniture5" size="3.20,1.0,2.00" movable="false" mass="10">
	  <body position="-6, 4.90,0"  orientation="0,0,0" />
	</box>
	<box id="furniture6" size="3.20,1.0,2.00" movable="false" mass="10">
	  <body position="-6,-4.90,0"  orientation="0,0,0" />
	</box>

	<!-- truss -->
	<box id="south_truss" size="0.02,9.50,0.20" movable="false" mass="10">
	  <body position="-6.26,0,2.5"  orientation="0,0,0" />
	</box>
	<box id="north_truss" size="0.02,9.50,0.20" movable="false" mass="10">
	  <body position="6.26,0,2.5"  orientation="0,0,0" />
	</box>
	<box id="west_truss" size="12.5,0.02,0.20" movable="false" mass="10">
	  <body position="0, 4.76, 2.5"  orientation="0,0,0" />
	</box>
	<box id="east_truss" size="12.5,0.02,0.20" movable="false" mass="10">
	  <body position="0, -4.76, 2.5"  orientation="0,0,0" />
	</box>

	<!-- man -->
	<cylinder id="head" radius="0.1" height="0.2" movable="false" mass="10">
	  <body position="-6, 3.5, 1.55"  orientation="0,0,0" />
	</cylinder>
	<box id="body" size="0.3, 0.5, 0.60" movable="false" mass="10">
	  <body position="-6, 3.5, 0.95"  orientation="0,0,0" />
	</box>
	<cylinder id="leg1" radius="0.1" height="0.95" movable="false" mass="10">
	  <body position="-6, 3.35, 0"  orientation="0,0,0" />
	</cylinder>
	<cylinder id="leg2" radius="0.1" height="0.95" movable="false" mass="10">
	  <body position="-6, 3.65, 0"  orientation="0,0,0" />
	</cylinder>
	<cylinder id="arm1" radius="0.05" height="0.90" movable="false" mass="10">
	  <body position="-6, 3.80, 0.65"  orientation="0,0,0" />
	</cylinder>
	<cylinder id="arm2" radius="0.05" height="0.90" movable="false" mass="10">
	  <body position="-6, 3.2, 0.65"  orientation="0,0,0" />
	</cylinder>

	<!-- boundary markers -->
	<!--box id="marker1" size="0.20,0.20,0.20" movable="false" mass="10">
	  <body position="1.2,-2.4,0"  orientation="0,0,0" />
	</box>
	<box id="marker2" size="0.20,0.20,0.20" movable="false" mass="10">
	  <body position="2.0,-2.0,0"  orientation="0,0,0" />
	</box>
	<box id="marker3" size="0.20,0.20,0.20" movable="false" mass="10">
	  <body position="3.4,-2.4,0"  orientation="0,0,0" />
	</box>
	<box id="marker4" size="0.20,0.20,0.20" movable="false" mass="10">
	  <body position="5.0,-1.1,0"  orientation="0,0,0" />
	</box>
	<box id="marker5" size="0.20,0.20,0.20" movable="false" mass="10">
	  <body position="4.7,1.3,0"  orientation="0,0,0" />
	</box>
	<box id="marker6" size="0.20,0.20,0.20" movable="false" mass="10">
	  <body position="3.6,2.4,0"  orientation="0,0,0" />
	</box>
	<box id="marker7" size="0.20,0.20,0.20" movable="false" mass="10">
	  <body position="2.3,2.6,0"  orientation="0,0,0" />
	</box>
	<box id="marker8" size="0.20,0.20,0.20" movable="false" mass="10">
	  <body position="1.0,3.0,0"  orientation="0,0,0" />
	</box>
	<box id="marker9" size="0.20,0.20,0.20" movable="false" mass="10">
	  <body position="-1.2,2.8,0"  orientation="0,0,0" />
	</box>
	<box id="marker10" size="0.20,0.20,0.20" movable="false" mass="10">
	  <body position="-3.1,3.2,0"  orientation="0,0,0" />
	</box>
	<box id="marker11" size="0.20,0.20,0.20" movable="false" mass="10">
	  <body position="-4.3,2.5,0"  orientation="0,0,0" />
	</box>
	<box id="marker12" size="0.20,0.20,0.20" movable="false" mass="10">
	  <body position="-5.1,1.3,0"  orientation="0,0,0" />
	</box>
	<box id="marker13" size="0.20,0.20,0.20" movable="false" mass="10">
	  <body position="-4.6,-1.3,0"  orientation="0,0,0" />
	</box>
	<box id="marker14" size="0.20,0.20,0.20" movable="false" mass="10">
	  <body position="-3.6,-2.1,0"  orientation="0,0,0" />
	</box>
	<box id="marker15" size="0.20,0.20,0.20" movable="false" mass="10">
	  <body position="-3.0,-2.7,0"  orientation="0,0,0" />
	</box>
	<box id="marker16" size="0.20,0.20,0.20" movable="false" mass="10">
	  <body position="-1.0,-3.1,0"  orientation="0,0,0" />
	</box-->

	<!-- arena -->
	<box id="south_arena_inner" size="0.02,2.62,0.10" movable="false" mass="10">
	  <body position="-4.31,0,0"  orientation="0,0,0" />
	</box>
	<box id="north_arena_inner" size="0.02,2.62,0.10" movable="false" mass="10">
	  <body position="4.31,0,0"  orientation="0,0,0" />
	</box>
	<box id="west_arena_inner" size="6.62,0.02,0.10" movable="false" mass="10">
	  <body position="0, -2.31,0"  orientation="0,0,0" />
	</box>
	<box id="east_arena_inner" size="6.62,0.02,0.10" movable="false" mass="10">
	  <body position="-, 2.31,0"  orientation="0,0,0" />
	</box>
	<box id="south_west_arena_inner" size="0.02,1.42,0.10" movable="false" mass="10">
	  <body position="-3.81,-1.81,0"  orientation="45,0,0" />
	</box>
	<box id="south_east_arena_inner" size="0.02,1.42,0.10" movable="false" mass="10">
	  <body position="3.81,-1.81,0"  orientation="-45,0,0" />
	</box>
	<box id="north_east_arena_inner" size="0.02,1.42,0.10" movable="false" mass="10">
	  <body position="3.81,1.81,0"  orientation="45,0,0" />
	</box>
	<box id="north_west_arena_inner" size="0.02,1.42,0.10" movable="false" mass="10">
	  <body position="-3.81,1.81,0"  orientation="-45,0,0" />
	</box>

	<!--box id="south_arena" size="0.02,6.04,0.10" movable="false" mass="10">
	  <body position="-5.01,0,0"  orientation="0,0,0" />
	</box>
	<box id="north_arena" size="0.02,6.04,0.10" movable="false" mass="10">
	  <body position="5.01,0,0"  orientation="0,0,0" />
	</box>
	<box id="west_arena" size="10.00,0.02,0.10" movable="false" mass="10">
	  <body position="0, -3.01,0"  orientation="0,0,0" />
	</box>
	<box id="east_arena" size="10.00,0.02,0.10" movable="false" mass="10">
	  <body position="-, 3.01,0"  orientation="0,0,0" />
	</box-->


	'''
	return text

#----------------------------------------------------------------------------------------------
# These functions generate <xml> sections in .argos for obstacles, pipuck, drones
# In general, the parameters starts with i, x, y, th, which mean the (i)th obstacle/pipuck/drone, and the x, y location in m, and orientation th in rad

# For obstacles, type means the payload of the tag on the obstacle
# generate_obstacle_box_xml generates a box with a tag on it
# generate_obstacle_cylinder_xml generates a cylinder with a tag on it
# by default, generate_obstacle_xml generates a box obstacle
def generate_obstacle_xml(i, x, y, th, type) :
	return generate_obstacle_box_xml(i, x, y, th, type)

def generate_obstacle_box_xml(i, x, y, th, type) :
	tag = '''
	<prototype id="obstacle{}" movable="false" friction="10">
		<body position="{},{},0" orientation="{},0,0" />
		<links ref="base">
			<link id="base" geometry="box" size="0.12, 0.12, 0.1" mass="0.01"
			      position="0,0,0" orientation="0,0,0" />
		</links>
		<devices>
			<tags medium="tags">
				<tag anchor="base" observable_angle="75" side_length="0.1078" payload="{}"
				     position="0,0,0.101" orientation="0,0,0" />
			</tags>
		</devices>
	</prototype>
	'''.format(i, x, y, th, type)
	return tag

def generate_obstacle_cylinder_xml(i, x, y, th, type) :
	tag = '''
	<prototype id="obstacle{}" movable="false" friction="10">
		<body position="{},{},0" orientation="{},0,0" />
		<links ref="base">
			<link id="base" geometry="cylinder" radius="0.10" height="0.1" mass="0.01"
			      position="0,0,0" orientation="0,0,0" />
		</links>
		<devices>
			<tags medium="tags">
				<tag anchor="base" observable_angle="75" side_length="0.1078" payload="{}"
				     position="0,0,0.101" orientation="0,0,0" />
			</tags>
		</devices>
	</prototype>
	'''.format(i, x, y, th, type)
	return tag

def generate_block_xml(i, x, y, th, type) :
	tag = '''
	<block id="obstacle{}" init_led_color="{}">
		<body position="{},{},0" orientation="{},0,0" />
		<controller config="block"/>
	</block>
	'''.format(i, type, x, y, th)
	return tag

# For drones and pipucks, i, x, y, th is the same as described above
# wifi_range changes the robot's communication range,
# ARGoS's default range is 10m, it is too much,
# So wifi_range is used together with argos-patch/RadioUpgrade.patch so that we can customize the communication range
def generate_drone_xml(i, x, y, th, wifi_range=None) :
	wifi_range_xml = ""
	if wifi_range != None:
		wifi_range_xml = '''wifi_transmission_range="{}"'''.format(wifi_range)
	tag = '''
	<drone id="drone{}" wifi_medium="wifi" {}>
		<body position="{},{},0" orientation="{},0,0"/>
		<controller config="drone"/>
	</drone>
	'''.format(i, wifi_range_xml, x, y, th)
	return tag

def generate_pipuck_xml(i, x, y, th, wifi_range=None) :
	wifi_range_xml = ""
	if wifi_range != None:
		wifi_range_xml = '''wifi_transmission_range="{}"'''.format(wifi_range)
	tag = '''
	<pipuck_ext id="pipuck{}" wifi_medium="wifi" {} tag_medium="tags" debug="true">
		<body position="{},{},0" orientation="{},0,0"/>
		<controller config="pipuck"/>
	</pipuck_ext>
	'''.format(i, wifi_range_xml, x, y, th)
	return tag

#----------------------------------------------------------------------------------------------
# Target is a big flat cylinder for the swarm to surround
# On the big flat cylinder, there will be a circle of tags shows the edge of the cylinder so that robots can avoid it.
# generate_target_xml() takes :
#   x, y, th  :     position and orientation in m and rad
#   mark_type :     The payload of the tag that identifies the target
#   obstacle_type : The payload of the tags shows the edge of the target
#   radius:         radius of the cylinder
#   tag_edge_distance:   the distance between the cylinder edge and the edge-indicating tags
#   tag_distance:        the distance between adjacent edge-indicating tags
# generate_target_tag_xml and generate_target_tags_xml are accessory functions used by generate_target_xml()
def generate_target_tag_xml(x, y, payload):
	tag = '''
		<tag anchor="base" observable_angle="75" side_length="0.1078" payload="{}"
		     position="{},{},0.11" orientation="0,0,0" />
	'''.format(payload, x, y)
	return tag

def generate_target_tags_xml(r, l, mark_payload, obstacle_payload):
	tags = generate_target_tag_xml(-r, 0, mark_payload)

	if l > r * 2 :
		return tags

	th = math.asin(l/2/r) * 2
	alpha = 0
	while alpha < math.pi * 2 - th :
		tags = tags + generate_target_tag_xml(r * math.cos(alpha + math.pi), 
		                                      r * math.sin(alpha + math.pi),
		                                      obstacle_payload
		)
		alpha = alpha + th

	return tags

def generate_target_xml(x, y, th, mark_type, obstacle_type, radius, tag_edge_distance, tag_distance):
	tag = '''
	<prototype id="target" movable="true" friction="2">
		<body position="{},{},0" orientation="{},0,0" />
		<links ref="base">
			<link id="base" geometry="cylinder" radius="{}" height="0.1" mass="0.10"
			      position="0,0,0" orientation="0,0,0" />
		</links>
		<devices>
			<tags medium="tags">
				{}
			</tags>
		</devices>
    </prototype>
	'''.format(x, y, th, radius, generate_target_tags_xml(radius-tag_edge_distance, tag_distance, mark_type, obstacle_type))
	return tag

#----------------------------------------------------------------------------------------------
# generate random locations
# In this section, there are functions to generate random positions with certain constrains for drones and pipucks' initial positions
#                                      to generate a wall with gates
#                                      etc

# generate_gate_locations() from <left_end> to <right_end>, generate <gate_number> gates of different sizes ranging from <small_limit> and <large_limit>
# it makes sure that the biggest gates has the size <max_size>
# return an array of gates in order
#	[
#		[left1, right1],
#		[left2, right2],
#	]
#	and the middle of the largest gate

# How many attempts of random number before giving up
#attempt_count_down_default = 1000
attempt_count_down_default = 100000

def generate_gate_locations(gate_number, left_end, right_end, small_limit, large_limit, max_size) :
	margin = 0.4
	a = []
	largest_length = 0
	largest_loc = 0
	for i in range(1, gate_number+1) :
		valid_position = False
		attempt_count_down = attempt_count_down_default
		while valid_position == False :
			# check attempt
			if attempt_count_down == 0 :
				print("[warning] gate locations incomplete")
				break
			else :
				attempt_count_down = attempt_count_down - 1

			# generate a random location
			loc = left_end + random.random() * (right_end - left_end)
			size = small_limit + random.random() * (large_limit - small_limit)
			if i == 1 :
				size = max_size 
			left = loc - size/2 
			right = loc + size/2 

			# valid check
			if left - margin < left_end or right + margin > right_end :
				valid_position = False
				continue

			valid_position = True
			for item in a:
				if (item[0] < left - margin and right + margin < item[1] or
				    left - margin < item[0] and item[0] < right + margin or
				    left - margin < item[1] and item[1] < right + margin
				   ) :
					valid_position = False
					break

			if valid_position == True:
				# push into list
				a.append([left,right])
				# check largest
				if right - left > largest_length :
					largest_length = right - left
					largest_loc = (left + right) / 2
		if attempt_count_down == 0 :
			break

	#sort
	for i in range(0, gate_number-1) :
		for j in range(i+1, gate_number) :
			if a[i][0] > a[j][0] :
				temp = a[i]
				a[i] = a[j]
				a[j] = temp
	return a, largest_loc

#----------------------------------------------------------------------------------------------
# from <left_end> to <right_end>, generate <gate_number> gates of different sizes ranging from <small_limit> and <large_limit>
# fill the wall with <step>
# return an array of gates in order
#	[
#		[1D-location, type],
#	]
#	and the middle of the largest gate
def generate_block_locations(gate_number, left_end, right_end, small_limit, large_limit, step, gate_brick_type, wall_brick_type) :
	return generate_wall_brick_locations(gate_number, left_end, right_end, small_limit, large_limit, step, 0.055, gate_brick_type, wall_brick_type)

def generate_obstacle_locations(gate_number, left_end, right_end, small_limit, large_limit, max_size, step, gate_brick_type, wall_brick_type) :
	return generate_wall_brick_locations(gate_number, left_end, right_end, small_limit, large_limit, max_size, step, 0.10, gate_brick_type, wall_brick_type) # 254 gate, 255 wall brick

def generate_wall_brick_locations(gate_number, left_end, right_end, small_limit, large_limit, max_size, step, brick_size, gate_brick_type, wall_brick_type) :
	block_locations = []
	margin = 0.10
	gate_locations, largest_loc = generate_gate_locations(gate_number, left_end + margin, right_end - margin, small_limit, large_limit, max_size)
	for i in range(0, gate_number + 1) :
		# get interval of gates
		left = left_end
		right = right_end
		if i != 0 :
			left = gate_locations[i-1][1]
		if i != gate_number :
			right = gate_locations[i][0]

		#set blocks from left to right
		#set left block
		j = left
		block_locations.append([left, -90, gate_brick_type])
		j = j + step
		#set middle block
		while j < right - brick_size:
			block_locations.append([j, 0, wall_brick_type])
			j = j + step
		#set right block
		block_locations.append([right, 90, gate_brick_type])
		
	return block_locations, largest_loc

# from <left_end> to <right_end>, generate <gate_number> gates of different sizes ranging from <small_limit> and <large_limit>
# fill the wall with <step>
# return an array of gates in order
#	[
#		[1D-location, type],
#	]
#	and the middle of the largest gate
def generate_wall(gate_number, wall_x, left_end, right_end, small_limit, large_limit, max_size, step, gate_brick_type, wall_brick_type) :
	tagstr = ""
	#block_locations, largest_loc = generate_block_locations(gate_number, left_end, right_end, small_limit, large_limit, step, gate_brick_type, wall_brick_type) 
	block_locations, largest_loc = generate_obstacle_locations(gate_number, left_end, right_end, small_limit, large_limit, max_size, step, gate_brick_type, wall_brick_type) 
	i = 0
	for loc in block_locations :
		i = i + 1
		tagstr = tagstr + generate_obstacle_xml(i, wall_x, loc[0], loc[1], loc[2]) #loc[0 to 2] means y, th, type

	return tagstr, largest_loc

def generate_line_locations(number, x_left, y_left, x_right, y_right) :
	a = []
	x = x_left
	y = y_left
	x_inc = (x_right - x_left) / (number-1)
	y_inc = (y_right - y_left) / (number-1)
	for i in range(1,number + 1):
		a.append([x,y])
		x = x + x_inc
		y = y + y_inc

	return a


#----------------------------------------------------------------------------------------------
# Generate random locations for pipuck and drones
# generate_random_locations() generates n random locations, with the first one at <origin_x, origin_y>,
# All the locations in range with x falling in (x_min_limit, x_max_limit), and y (y_min_limit, y_max_limit)
# Distance between adjacent positions falls in (near_limit,  far_limit)
# Outputs a list
# [
#	[x1, y1],
#	[x2, y2],
#   ...
# ]
def generate_random_locations(n, origin_x,    origin_y, 
                                 x_min_limit, x_max_limit,
                                 y_min_limit, y_max_limit, 
                                 near_limit,  far_limit) :
	a = []

	# if origin is not None then add origin as the first
	start = 0
	if origin_x != None and origin_y != None :
		a.append([origin_x, origin_y])
		start = 1

	# start generating
	for i in range(start, n) : # 0/1 to n - 1
		valid = False
		attempt_count_down = attempt_count_down_default
		while valid == False :
			# check attempt
			if attempt_count_down == 0 :
				print("[warning] random locations incomplete")
				break
			else :
				attempt_count_down = attempt_count_down - 1

			# generate a random location
			loc_x = x_min_limit + random.random() * (x_max_limit - x_min_limit)
			loc_y = y_min_limit + random.random() * (y_max_limit - y_min_limit)

			#check near
			valid = True
			for j in range(0, i) :
				if (loc_x - a[j][0]) ** 2 + (loc_y - a[j][1]) ** 2 < near_limit ** 2 :
					valid = False
					break
			if valid == False :
				continue

			#check faraway
			valid = False
			if i == 0 :
				valid = True
			for j in range(0, i) :
				if (loc_x - a[j][0]) ** 2 + (loc_y - a[j][1]) ** 2 < far_limit ** 2 :
					valid = True
					break
			if valid == True :
				a.append([loc_x, loc_y])
		if attempt_count_down == 0 :
			break
	return a

#----------------------------------------------------------------------------------------------
# Generates <n> random positions with referencing an existing list of locations, 
# The range falls in <x_min_limit, x_max_limit>, and <y_min_limit, y_max_limit>
# Each position references a position in <master_locations> with a distance between <near_limit, far_limit>

# It is used to generate pipuck locations after drone locations are generated, so that pipucks can be seen by drones
def generate_slave_locations(n, master_locations,
                                x_min_limit, x_max_limit,
                                y_min_limit, y_max_limit,
                                near_limit, far_limit) :
	return generate_slave_locations_with_origin(n,
	                                            master_locations,
	                                            None, None,
	                                            x_min_limit, x_max_limit,
	                                            y_min_limit, y_max_limit,
	                                            near_limit, far_limit)


def generate_slave_locations_with_origin(n, master_locations,
                                         origin_x, origin_y,
                                         x_min_limit, x_max_limit,
                                         y_min_limit, y_max_limit,
                                         near_limit, far_limit) :
	a = []

	# if origin is not None then add origin as the first
	start = 0
	if origin_x != None and origin_y != None :
		a.append([origin_x, origin_y])
		start = 1

	for i in range(start, n) :
		valid = False
		attempt_count_down = attempt_count_down_default
		while valid == False :
			# check attempt
			if attempt_count_down == 0 :
				print("[warning] slave locations incomplete")
				break
			else :
				attempt_count_down = attempt_count_down - 1

			# generate a random location
			loc_x = x_min_limit + random.random() * (x_max_limit - x_min_limit)
			loc_y = y_min_limit + random.random() * (y_max_limit - y_min_limit)

			# check near
			valid = True
			for j in range(0, i) :
				if (loc_x - a[j][0]) ** 2 + (loc_y - a[j][1]) ** 2 < near_limit ** 2 :
					valid = False
					break
			if valid == False :
				continue

			#check faraway
			valid = False
			for drone_loc in master_locations :
				if (loc_x - drone_loc[0]) ** 2 + (loc_y - drone_loc[1]) ** 2 < far_limit ** 2 :
					valid = True
					break
			if valid == True :
				a.append([loc_x, loc_y])
		if attempt_count_down == 0 :
			break
	return a

#----------------------------------------------------------------------------------------------
# From a list of locations generate <xml> sections for all the drones, pipucks, and obstatcles
# start_id means the start index.
# For example generate_drones([pos1, pos2, pos3], 3) will generate xmls for drone3, drone4, drone5 at pos1, pos2, pos3
def generate_drones(locations, start_id, wifi_range=None) :
	tagstr = ""
	i = start_id
	for loc in locations :
		tagstr = tagstr + generate_drone_xml(i, loc[0], loc[1], -45, wifi_range)
		i = i + 1
	return tagstr

def generate_pipucks(locations, start_id, wifi_range=None) :
	tagstr = ""
	i = start_id
	for loc in locations :
		tagstr = tagstr + generate_pipuck_xml(i, loc[0], loc[1], 0, wifi_range)
		i = i + 1
	return tagstr

def generate_obstacles(locations, start_id, type) :
	tagstr = ""
	i = start_id
	for loc in locations :
		tagstr = tagstr + generate_obstacle_xml(i, loc[0], loc[1], 0, type)
		i = i + 1
	return tagstr

#----------------------------------------------------------------------------------------------
# create argos file
# This function takes an .argos template file, replace certain words from it, and generate a .argos file that is ready to run.
# An example is given below, in this example, all "RANDOMSEED" in the template file will be replaced with "500"
def generate_argos_file(template_name, argos_name, replacements) :
	'''
	replacements = 
	[
		[RANDOMSEED, str(500)],
		[xxx, yyy],
		[xxx, yyy],
	]
	'''
	with open(template_name, 'r') as file :
		filedata = file.read()

	for i in replacements :
		filedata = filedata.replace(i[0], i[1])

	with open(argos_name, 'w') as file:
		file.write(filedata)
