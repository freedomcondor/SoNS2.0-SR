-- This file provides some common operations for many scenarios, for example detect wall, detect gates.. etc

ExperimentCommon = {}

-- This function iterates all the obstacles that are <wall_brick_type> in sons.avoider.obstacles
-- Returns the nearest obstacle
ExperimentCommon.detectWall = function(sons, wall_brick_type)
	local nearest = nil
	local dis = math.huge
	for i, ob in ipairs(sons.avoider.obstacles) do
		if ob.type == wall_brick_type and
		   ob.positionV3:length() < dis then
			dis = ob.positionV3:length()
			nearest = ob
		end
	end

	return nearest
end

-- This function iterates all the obstacles that are <wall_brick_type> in sons.collectivesensor.receiveList
-- Returns the nearest obstacle
ExperimentCommon.detectWallFromReceives = function(sons, wall_brick_type)
	local nearest = nil
	local dis = math.huge
	for i, ob in ipairs(sons.collectivesensor.receiveList) do
		if ob.type == wall_brick_type and
		   ob.positionV3:length() < dis then
			dis = ob.positionV3:length()
			nearest = ob
		end
	end
	
	return nearest
end

-- This function matches two gate bricks into gates and detects the largest gate in a wall that it sees or receives from children
-- input:  
--     sons: checks from both sons.avoider.obstacles and sons.collectivesensor.receiveList
--     gate_brick_type: gate brick type is <gate_brick_type>
--     max_gate_size: the largest possible gate size,
--          sometimes, robot may mistakenly match two gate side very far away, so max_gate_size is set so that robot knows it matches wrong
--     report_all: if true, robot reports to its parent all the gate/gate side it sees, otherwise only the unmatched one
--         
-- output: 1. the table of the largest gate
--         2. the size of the largest gate
--         3. the total number of gates it and its downstream children have seen
ExperimentCommon.detectAndReportGates = function(sons, gate_brick_type, max_gate_size, report_all)
	if sons.robotTypeS ~= "drone" then return {}, nil end

	-- add sons.avoider.obstacles and sons.collectivesensor.receiveList together
	local totalGateSideList = {}
	for i, ob in ipairs(sons.avoider.obstacles) do
		if ob.type == gate_brick_type then
			totalGateSideList[#totalGateSideList + 1] = ob
		end
	end
	for i, ob in ipairs(sons.collectivesensor.receiveList) do
		if ob.type == gate_brick_type then
			totalGateSideList[#totalGateSideList + 1] = ob
		end
	end

	-- mark the gates from obstacles with gateV3
	--for i, ob in ipairs(sons.avoider.obstacles) do
	for i, ob in ipairs(totalGateSideList) do
		ob.gateDetection = {
			gateV3 = vector3(max_gate_size,0,0):rotate(ob.orientationQ)
		}
	end

	-- for each gate find the nearest opposite gate
	--for i, ob in ipairs(sons.avoider.obstacles) do if ob.gateV3 ~= nil and ob.paired == nil then
	for i, ob in ipairs(totalGateSideList) do if ob.gateDetection.paired == nil then
		-- find the nearest gate_brick towards my direction
		-- and then check if that gate_brick is towards me 
		--     because sometimes there may be conditions like 
		--                -> (missing one <-)   ->  <-
		local pair = nil
		--local dis = ob.gateV3:length()
		local dis = max_gate_size
		--for i, ob2 in ipairs(sons.avoider.obstacles) do if ob2.gateV3 ~= nil then
		for i, ob2 in ipairs(totalGateSideList) do if ob2.gateDetection.paired == nil then
			-- if it is in my direction
			if ob.gateDetection.gateV3:dot(ob2.positionV3 - ob.positionV3) > 0 then
				-- if nearer
				if (ob2.positionV3 - ob.positionV3):length() < dis then
					pair = ob2
					dis = (ob2.positionV3 - ob.positionV3):length()
				end
			end
		end end
		-- if the nearest is opposite towards me, then we find an effect gate
		if pair ~= nil and 
		   pair.gateDetection.gateV3:dot(ob.gateDetection.gateV3) < 0 then
			ob.gateDetection.gateV3 = ob.gateDetection.gateV3:normalize() * dis
			pair.gateDetection.gateV3 = pair.gateDetection.gateV3:normalize() * dis
			pair.gateDetection.paired = true

			-- if report_all flag is set, report this gate brick anyway
			if report_all == true then
				sons.CollectiveSensor.addToSendList(sons, ob)
			end
		else
			-- unpaired wall side, I report it
			sons.CollectiveSensor.addToSendList(sons, ob)
			ob.gateDetection.single = true
		end
	end end

	-- generate a list of gates
	local gates = {}
	-- add gates from obstacles
	--for i, ob in ipairs(sons.avoider.obstacles) do if ob.gateV3 ~= nil and ob.paired == nil then
	for i, ob in ipairs(totalGateSideList) do if ob.gateDetection.single == nil and ob.gateDetection.paired == nil then
		local positionV3 = ob.positionV3 + ob.gateDetection.gateV3 * 0.5
		local orientationQ = ob.orientationQ * quaternion(math.pi/2, vector3(0,0,1))
		if vector3(1,0,0):rotate(orientationQ):dot(positionV3) < 0 then
			orientationQ = orientationQ * quaternion(math.pi, vector3(0,0,1))
		end
		local length = ob.gateDetection.gateV3:length()

		-- check if this gate already exists in receiveList
		local flag = true
		for i, existingGate in ipairs(sons.collectivesensor.receiveList) do if existingGate.type == "gate" then
			if (existingGate.positionV3 - positionV3):length() < (existingGate.length + length) / 2 then
				flag = false
				break
			end
		end end
		-- check if this gate already exists in gates
		for i, existingGate in ipairs(gates) do
			if (existingGate.positionV3 - positionV3):length() < (existingGate.length + length) / 2 then
				flag = false
				break
			end
		end

		if flag == true then
			gates[#gates+1] = {
				positionV3 = positionV3,
				orientationQ = orientationQ,
				length = length,
				type = "gate",
			}
		end
	end end

	-- find the largest gate
	local largest = nil
	local largest_length = 0
	for i, gate in ipairs(gates) do
		if gate.length > largest_length then
			largest = gate
			largest_length = gate.length
		end
	end

	for i, gate in ipairs(gates) do
		sons.api.debug.drawArrow("red", 
			sons.api.virtualFrame.V3_VtoR(vector3()),
			sons.api.virtualFrame.V3_VtoR(vector3(gate.positionV3))
		)
		sons.api.debug.drawArrow("red", 
			sons.api.virtualFrame.V3_VtoR(vector3(gate.positionV3)),
			sons.api.virtualFrame.V3_VtoR(vector3(gate.positionV3 + vector3(0.1,0,0):rotate(gate.orientationQ)))
		)
	end

	-- calculate gateNumber

	-- send gate list
	local gateNumber = #gates
	for i, gate in ipairs(gates) do
		sons.CollectiveSensor.addToSendList(sons, gate)
	end
	for i, ob in ipairs(sons.collectivesensor.receiveList) do if ob.type == "gate" then
		sons.CollectiveSensor.addToSendList(sons, ob)
	end end
	-- get and report gate number
	for idS, robotR in pairs(sons.childrenRT) do
		for _, msgM in ipairs(sons.Msg.getAM(idS, "gateReport")) do
			gateNumber = gateNumber + msgM.dataT.gateNumber
		end
	end
	if sons.parentR ~= nil then
		sons.Msg.send(sons.parentR.idS, "gateReport", {gateNumber = gateNumber})
	end

	return gates, largest, gateNumber
end

-- This function iterates all the obstacles that are <target_type> in sons.avoider.obstacles
-- Returns the nearest
ExperimentCommon.detectTarget = function(sons, target_type)
	--return the nearest target sons.avoider.obstacles
	local nearest = nil
	local dis = math.huge
	for i, ob in ipairs(sons.avoider.obstacles) do
		if ob.type == target_type and
		   ob.positionV3:length() < dis then
			dis = ob.positionV3:length()
			nearest = ob
		end
	end

	return nearest
end

-- This function checks if it sees obstacle of <wall_brick_type> and report to parent
-- It first checks from sons.avoider.obstacles, if nothing, it checks sons.collectivesensor.receiveList (Only trust my eye first)

ExperimentCommon.reportWall = function(sons, wall_brick_type)
	local wall_brick 
	if sons.robotTypeS == "drone" then
		wall_brick = ExperimentCommon.detectWall(sons, wall_brick_type)
	end
	if wall_brick ~= nil then
		-- I see a wall, I report it
		sons.CollectiveSensor.addToSendList(sons, wall_brick)
	else
		-- I see nothing, I report one of what I received
		for i, ob in pairs(sons.collectivesensor.receiveList) do
			if ob.type == wall_brick_type then
				sons.CollectiveSensor.addToSendList(sons, ob)
				break
			end
		end
	end
end

return ExperimentCommon