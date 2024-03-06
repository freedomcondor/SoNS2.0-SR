local function create_1pipuck_3drone_children_node(droneDis, pipuckDis, height, position, orientationQ, tilt_nose)
	if orientationQ == nil then orientationQ = quaternion() end
	local node =
	{ 	robotTypeS = "pipuck",
		positionV3 = position,
		orientationQ = orientationQ,
		children = {
		{	robotTypeS = "drone",
			positionV3 = vector3(pipuckDis, 0, height),
			orientationQ = quaternion(0, vector3(0,0,1)),
		},
		{	robotTypeS = "drone",
			positionV3 = vector3(-pipuckDis/2, pipuckDis/2 * math.sqrt(3), height),
			orientationQ = quaternion(0, vector3(0,0,1)),
		},
		{	robotTypeS = "drone",
			positionV3 = vector3(-pipuckDis/2, -pipuckDis/2 * math.sqrt(3), height),
			orientationQ = quaternion(0, vector3(0,0,1)),
		},
	}}
	if tilt_nose == true then
		node.children[1].positionV3 = vector3(pipuckDis/2, -pipuckDis/2 * math.sqrt(3), height)
	end
	return node
end

function create_3pipuck_9drone_children_node(droneDis, pipuckDis, height, position, orientationQ)
	local node = create_1pipuck_3drone_children_node(droneDis, pipuckDis, height, position, orientationQ)
	table.insert(node.children,
		create_1pipuck_3drone_children_node(droneDis, pipuckDis, height, 
			vector3(-droneDis/2, droneDis/2*math.sqrt(3), 0),
			quaternion()
		)
	)
	table.insert(node.children,
		create_1pipuck_3drone_children_node(droneDis, pipuckDis, height, 
			vector3(-droneDis/2, -droneDis/2*math.sqrt(3), 0),
			quaternion()
		)
	)
	return node
end

--function create_3drone_12pipuck_children_chain(n, droneDis, pipuckDis, height, position, orientationQ)
function create_3pipuck_9drone_children_chain_with_pipuck_number(n_pipuck, droneDis, pipuckDis, height, position, orientationQ)
	if n_pipuck == 0 then return nil end

	local node = create_3pipuck_9drone_children_node(droneDis, pipuckDis, height, position, orientationQ)
	if n_pipuck == 1 then 
		node.children[4] = nil
		node.children[5] = nil
		return node
	elseif n_pipuck == 2 then 
		node.children[5] = nil
		return node
	else
		table.insert(node.children,
			create_3pipuck_9drone_children_chain_with_pipuck_number(n_pipuck - 3, droneDis, pipuckDis, height, 
				vector3(-droneDis, 0, 0),
				quaternion()
			)
		)
	end

	return node
end

function create_back_line_morphology_with_pipuck_number(n_drone, droneDis, pipuckDis, height)
	local node = create_3pipuck_9drone_children_chain_with_pipuck_number(n_drone, droneDis, pipuckDis, height, vector3(), quaternion())
	return node
end