-- connector -----------------------------------------
-- Connector is the key module to establish a SoNS
-- It handles recruitment, keeps the connection and breaks the connection
------------------------------------------------------
local Connector = {}

--[[
	related data:
	sons.connector = {
		waitingRobots = {}
		waitingParents = {}
		seenRobots
		locker_count
		lastid[idS] = a number 
		-- TODO: locker_count may be overlapped with last_id
	}

	robot(children or parent).connector = {
		unseen_count
		heartbeat_count
	}
--]]

function Connector.create(sons)
	sons.connector = {}
end

function Connector.reset(sons)
	sons.connector.waitingRobots = {}
	sons.connector.waitingParents = {}
	sons.connector.seenRobots = {}
	sons.connector.locker_count = 0
	sons.connector.lastid = {}
end

function Connector.preStep(sons)
	sons.connector.seenRobots = {}
end

function Connector.addChild(sons, robotR)
	sons.childrenRT[robotR.idS] = robotR
	sons.childrenRT[robotR.idS].connector = {
		unseen_count = sons.Parameters.connector_unseen_count,
		heartbeat_count = sons.Parameters.connector_heartbeat_count,
	}
end

function Connector.addParent(sons, robotR)
	sons.parentR = robotR
	sons.parentR.connector = {
		unseen_count = sons.Parameters.connector_unseen_count,
		heartbeat_count = sons.Parameters.connector_heartbeat_count,
	}
end

function Connector.deleteChild(sons, idS)
	sons.connector.waitingRobots[idS] = nil
	sons.childrenRT[idS] = nil
end

function Connector.deleteParent(sons)
	if sons.parentR == nil then return end
	sons.parentR = nil
end

-- Try to recruit a seen robot <robotR>, put it in waiting list until get ack from it.
function Connector.recruit(sons, robotR)
	sons.Msg.send(robotR.idS, "recruit", {	
		positionV3 = sons.api.virtualFrame.V3_VtoR(robotR.positionV3),
		orientationQ = sons.api.virtualFrame.Q_VtoR(robotR.orientationQ),
		fromTypeS = sons.robotTypeS,
		idS = sons.idS,
		idN = sons.idN,
	}) 

	sons.connector.waitingRobots[robotR.idS] = {
		idS = robotR.idS,
		positionV3 = robotR.positionV3,
		orientationQ = robotR.orientationQ,
		robotTypeS = robotR.robotTypeS,
		waiting_count = sons.Parameters.connector_waiting_count,
	}
end

-- A new brain changes the Rank <idN>, and inform all the down stream robots
-- In the meantime, remembers the last id for <lastidPeriod> time, and ignore recruitment from the old SoNS ID to prevent loop
function Connector.newSonsID(sons, idN, lastidPeriod)
	local _idS = sons.Msg.myIDS()
	local _idN = idN or robot.random.uniform()

	Connector.updateSonsID(sons, _idS, _idN, lastidPeriod)
end

-- Change a new SoNS ID <idS>, and rank <idN>, and inform all the down stream robots
-- In the meantime, remembers the last id for <lastidPeriod> time, and ignore recruitment from the old SoNS ID to prevent loop
function Connector.updateSonsID(sons, _idS, _idN, lastidPeriod)
	sons.connector.lastid[sons.idS] = lastidPeriod or (sons.scalemanager.depth + 2)
	sons.connector.locker_count = sons.scalemanager.depth + 2

	sons.idS = _idS
	sons.idN = _idN
	for idS, childR in pairs(sons.childrenRT) do
		sons.Msg.send(idS, "updateSonsID", {idS = _idS, idN = _idN, lastidPeriod = lastidPeriod})
	end
	for idS, childR in pairs(sons.connector.waitingRobots) do
		sons.Msg.send(idS, "updateSonsID", {idS = _idS, idN = _idN, lastidPeriod = lastidPeriod})
	end
end

-- Update all the robot information based on what it sees on this step
-- 1. Update the parent/children position and orientations
-- 2. Update the positions/orientations for robots in the waiting list
-- 3. Listen to heartbeat from parent/children, break the link if heartbeat is lost
function Connector.update(sons)
	-- estimate new position orientation
	local inverseOri = quaternion(sons.api.estimateLocation.orientationQ):inverse()
	for idS, robotR in pairs(sons.childrenRT) do
		robotR.positionV3 = (robotR.positionV3 - sons.api.estimateLocation.positionV3):rotate(inverseOri)
		robotR.orientationQ = robotR.orientationQ * inverseOri
	end
	if sons.parentR ~= nil then
		sons.parentR.positionV3 = (sons.parentR.positionV3 - sons.api.estimateLocation.positionV3):rotate(inverseOri)
		sons.parentR.orientationQ = sons.parentR.orientationQ * inverseOri
	end
	-- updated count
	for idS, robotR in pairs(sons.childrenRT) do
		robotR.connector.unseen_count = robotR.connector.unseen_count - 1
		robotR.connector.heartbeat_count = robotR.connector.heartbeat_count - 1
	end
	if sons.parentR ~= nil then
		sons.parentR.connector.unseen_count = sons.parentR.connector.unseen_count - 1
		sons.parentR.connector.heartbeat_count = sons.parentR.connector.heartbeat_count - 1
	end
	
	-- update waiting list
	for idS, robotR in pairs(sons.connector.seenRobots) do
		if sons.connector.waitingRobots[idS] ~= nil then
			sons.connector.waitingRobots[idS].positionV3 = robotR.positionV3
			sons.connector.waitingRobots[idS].orientationQ = robotR.orientationQ
		end
	end

	-- update sons childrenRT list
	for idS, robotR in pairs(sons.connector.seenRobots) do
		if sons.childrenRT[idS] ~= nil then
			sons.childrenRT[idS].positionV3 = robotR.positionV3
			sons.childrenRT[idS].orientationQ = robotR.orientationQ
			sons.childrenRT[idS].connector.unseen_count = sons.Parameters.connector_unseen_count
		end
	end

	-- update parent
	if sons.parentR ~= nil and sons.connector.seenRobots[sons.parentR.idS] ~= nil then
		sons.parentR.positionV3 = sons.connector.seenRobots[sons.parentR.idS].positionV3
		sons.parentR.orientationQ = sons.connector.seenRobots[sons.parentR.idS].orientationQ
		sons.parentR.connector.unseen_count = sons.Parameters.connector_unseen_count
	end

	-- check heartbeat
	for idS, robotR in pairs(sons.childrenRT) do
		for _, msgM in ipairs(sons.Msg.getAM(idS, "heartbeat")) do
			robotR.connector.heartbeat_count = sons.Parameters.connector_heartbeat_count
		end
	end
	if sons.parentR ~= nil then
		for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "heartbeat")) do
			sons.parentR.connector.heartbeat_count = sons.Parameters.connector_heartbeat_count
		end
	end

	-- check updated
	for idS, robotR in pairs(sons.childrenRT) do
		if robotR.connector.unseen_count == 0 or robotR.connector.heartbeat_count == 0 then
			sons.Msg.send(idS, "dismiss")
			sons.deleteChild(sons, idS)
		end
	end
	if sons.parentR ~= nil and (sons.parentR.connector.unseen_count == 0 or sons.parentR.connector.heartbeat_count == 0) then
		sons.Msg.send(sons.parentR.idS, "dismiss")
		Connector.newSonsID(sons)
		sons.deleteParent(sons)
		sons.resetMorphology(sons)
	end

	-- check locker
	if sons.connector.locker_count > 0 then
		sons.connector.locker_count = sons.connector.locker_count - 1
	end

	-- check last id
	for idS, lastid in pairs(sons.connector.lastid) do
		if sons.connector.lastid[idS] > 0 then
			sons.connector.lastid[idS] = sons.connector.lastid[idS] - 1
		elseif sons.connector.lastid[idS] == 0 then
			sons.connector.lastid[idS] = nil
		end
	end
end

-- count down for waiting list, forget the robot if count down ends
function Connector.waitingCount(sons)
	for idS, robotR in pairs(sons.connector.waitingRobots) do
		robotR.waiting_count = robotR.waiting_count - 1
		if robotR.waiting_count == 0 then
			sons.connector.waitingRobots[idS] = nil
		end
	end
	for idS, robotR in pairs(sons.connector.waitingParents) do
		robotR.waiting_count = robotR.waiting_count - 1
		if robotR.waiting_count == 0 then
			sons.connector.waitingParents[idS] = nil
		end
	end
end

-- called by SoNS.step(), it is the function that runs every step
function Connector.step(sons)
	Connector.update(sons)
	Connector.waitingCount(sons)

	-- check ack
	for _, msgM in ipairs(sons.Msg.getAM("ALLMSG", "ack")) do
		if sons.connector.waitingRobots[msgM.fromS] ~= nil then
			sons.connector.waitingRobots[msgM.fromS].waiting_count = nil
			sons.addChild(sons, sons.connector.waitingRobots[msgM.fromS])
			sons.connector.waitingRobots[msgM.fromS] = nil
		end
	end

	-- check split
	for _, msgM in ipairs(sons.Msg.getAM("ALLMSG", "split")) do
		if sons.parentR ~= nil and msgM.fromS == sons.parentR.idS then
			Connector.newSonsID(sons, msgM.dataT.newID, msgM.dataT.waitTick or 100)
			sons.deleteParent(sons)
			if type(msgM.dataT.morphology) == "number" then
				sons.setMorphology(sons, sons.allocator.gene_index[msgM.dataT.morphology])
			elseif type(msgM.dataT.morphology) == "table" then
				sons.setGene(sons, msgM.dataT.morphology)
				-- TODO: its children don't know this gene
			end
		end
	end

	-- check dismiss
	for _, msgM in ipairs(sons.Msg.getAM("ALLMSG", "dismiss")) do
		if sons.parentR ~= nil and msgM.fromS == sons.parentR.idS then
			Connector.newSonsID(sons, msgM.dataT and msgM.dataT.newID)  -- if dataT is nil then nil
			sons.deleteParent(sons)
			sons.resetMorphology(sons)
		end
		if sons.childrenRT[msgM.fromS] ~= nil then
			sons.deleteChild(sons, msgM.fromS)
		end
	end

	-- check updateSonsID
	for _, msgM in ipairs(sons.Msg.getAM("ALLMSG", "updateSonsID")) do
		if sons.parentR ~= nil and msgM.fromS == sons.parentR.idS then
			Connector.updateSonsID(sons, msgM.dataT.idS, msgM.dataT.idN, msgM.dataT.lastidPeriod)
		end
	end

	-- send heartbeat
	for idS, robotR in pairs(sons.childrenRT) do
		sons.Msg.send(idS, "heartbeat")
	end
	if sons.parentR ~= nil then
		sons.Msg.send(sons.parentR.idS, "heartbeat")
	end
end

-- try to recruit all the robots the it sees
function Connector.recruitAll(sons)
	-- calculate children robot number
	-- count pipucks
	local pipuckChildrenCountN = 0
	local droneChildrenCountN = 0
	for idS, robotR in pairs(sons.childrenRT) do
		if robotR.robotTypeS == "pipuck" then
			pipuckChildrenCountN = pipuckChildrenCountN + 1
		elseif robotR.robotTypeS == "drone" then
			droneChildrenCountN = droneChildrenCountN + 1
		end
	end
	for idS, robotR in pairs(sons.connector.waitingRobots) do
		if robotR.robotTypeS == "pipuck" then
			pipuckChildrenCountN = pipuckChildrenCountN + 1
		elseif robotR.robotTypeS == "drone" then
			droneChildrenCountN = droneChildrenCountN + 1
		end
	end
	-- recruit new
	for idS, robotR in pairs(sons.connector.seenRobots) do
		-- check robot type max children number
		local goFlag = false
		if robotR.robotTypeS == "pipuck" then
			if sons.Parameters.connector_pipuck_children_max_count == 0 or
			   sons.Parameters.connector_pipuck_children_max_count == nil or
			   pipuckChildrenCountN < sons.Parameters.connector_pipuck_children_max_count then
				goFlag = true
			end
		else
			goFlag = true
		end

		if sons.childrenRT[idS] == nil and 
		   sons.connector.waitingRobots[idS] == nil and 
		   (sons.parentR == nil or sons.parentR.idS ~= idS) and
		   (goFlag == true or idS == sons.Parameters.stabilizer_preference_robot) then
			local safezone = sons.Parameters.safezone_default
			if sons.robotTypeS == "drone" and robotR.robotTypeS == "drone" then
				safezone = sons.Parameters.safezone_drone_drone
			elseif sons.robotTypeS == "drone" and robotR.robotTypeS == "pipuck" then
				safezone = sons.Parameters.safezone_drone_pipuck
			elseif sons.robotTypeS == "pipuck" and robotR.robotTypeS == "drone" then
				safezone = sons.Parameters.safezone_drone_pipuck
			elseif sons.robotTypeS == "pipuck" and robotR.robotTypeS == "pipuck" then
				safezone = sons.Parameters.safezone_pipuck_pipuck
			end
			local position2D = vector3(robotR.positionV3)
			position2D.z = 0
			if position2D:length() < safezone then
				Connector.recruit(sons, robotR)
			end
		end
	end
end

-- only recruit robot that doesn't have a nearer robot in between
function Connector.recruitNear(sons)
	-- create a available robot list
	local list = {}
	for idS, robotR in pairs(sons.connector.seenRobots) do
		-- if a foreign robot (not parent, not children, note:waiting robots counts in)
		if sons.childrenRT[idS] == nil and 
		   --sons.connector.waitingRobots[idS] == nil and 
		   (sons.parentR == nil or sons.parentR.idS ~= idS) then
			-- choose safezone according to robot type
			local safezone
			if sons.robotTypeS == "drone" and robotR.robotTypeS == "drone" then
				safezone = sons.Parameters.safezone_drone_drone
			elseif sons.robotTypeS == "drone" and robotR.robotTypeS == "pipuck" then
				safezone = sons.Parameters.safezone_drone_pipuck
			elseif sons.robotTypeS == "pipuck" and robotR.robotTypeS == "drone" then
				safezone = sons.Parameters.safezone_drone_pipuck
			elseif sons.robotTypeS == "pipuck" and robotR.robotTypeS == "pipuck" then
				safezone = sons.Parameters.safezone_pipuck_pipuck
			end
			-- calculate 2D length
			local position2D = vector3(robotR.positionV3)
			position2D.z = 0
			if position2D:length() < safezone then
				list[#list + 1] = {
					idS = idS,
					position2D = position2D,
					robotTypeS = robotR.robotTypeS,
				}
			end
		end
	end
	-- check list, recruit all that doesn't have a nearer one
	for i, robotR in ipairs(list) do
		local flag = true
		for j, blocker in ipairs(list) do
			if i ~= j and 
			   blocker.position2D:length() < robotR.position2D:length() and
			   (blocker.position2D-robotR.position2D):length() < robotR.position2D:length() then
			   --blocker.position2D:dot(robotR.position2D) > 0 then
				flag = false
				break
			end
		end
		if flag == true and 
		   sons.connector.waitingRobots[robotR.idS] == nil then
			Connector.recruit(sons, sons.connector.seenRobots[robotR.idS])
		end
	end
end

-- acknowlege all the recruitment message
function Connector.ackAll(sons, option)
	return Connector.ackSpecific(sons, "ALLMSG", option)
end

-- acknowlege recruitment from a specific robot <specific_name>
function Connector.ackSpecific(sons, specific_name, option)
	-- check acks, ack the nearest valid recruit
	--for _, msgM in pairs(sons.Msg.getAM("ALLMSG", "recruit")) do
	for _, msgM in pairs(sons.Msg.getAM(specific_name, "recruit")) do
		-- check
		-- if id == my sons id then pass unconditionally
		-- else, if it is from changing id, then ack
		-- if not, then check if idN > my idN and my locker
		if (msgM.dataT.idS ~= sons.idS and
		    msgM.dataT.idN > sons.idN and
		    sons.connector.locker_count == 0 and
		    sons.connector.lastid[msgM.dataT.idS] == nil
		    and (option == nil or option.no_parent_ack ~= true or sons.parentR == nil)
			-- no_parent_ack means a robot only ack when it doesn't have a parent
		   )
		   or
		   msgM.fromS == sons.connector.greenLight
		   -- greenLight comes from intersection detector
		   --(sons.parentR == nil or
		   --sons.connector.lastid[msgM.dataT.idS] == nil
		   --) 
		   then
			if sons.connector.waitingParents[msgM.fromS] ~= nil then
				if sons.connector.waitingParents[msgM.fromS].nearest == true then
					-- send ack
					sons.Msg.send(msgM.fromS, "ack")
					-- create robotR
					local robotR = {
						idS = msgM.fromS,
						positionV3 = 
						sons.api.virtualFrame.V3_RtoV(
							vector3(-msgM.dataT.positionV3):rotate(msgM.dataT.orientationQ:inverse())
						),
						orientationQ = 
							sons.api.virtualFrame.Q_RtoV(
								msgM.dataT.orientationQ:inverse()
							),
						robotTypeS = msgM.dataT.fromTypeS,
					}
					-- goodbye to old parent
					if sons.parentR ~= nil and sons.parentR ~= msgM.fromS then
						sons.Msg.send(sons.parentR.idS, "dismiss")
						sons.deleteParent(sons)
					end
					-- update sons id
					-- sons.idS = msgM.dataT.idS
					-- sons.idN = msgM.dataT.idN
					Connector.updateSonsID(sons, msgM.dataT.idS, msgM.dataT.idN)
					sons.addParent(sons, robotR)
				else
					sons.connector.waitingParents[msgM.fromS].waiting_count = sons.Parameters.connector_waiting_parent_count
				end
			else
				local positionV2 = msgM.dataT.positionV3
				positionV2.z = 0
				sons.connector.waitingParents[msgM.fromS] = {
					waiting_count = sons.Parameters.connector_waiting_parent_count,
					distance = positionV2:length(),
					idS = msgM.fromS,
					robotTypeS = msgM.dataT.fromTypeS,
				}
			end
		else
			if sons.connector.waitingParents[msgM.fromS] ~= nil then
				sons.connector.waitingParents[msgM.fromS] = nil
			end
		end
	end

	local MinDis = math.huge
	local MinId = nil
	-- mark the nearest waiting parents, drone priority
	-- if there are drones, mark nearest drone as nearest
	---[[
	local drone_flag = false
	for idS, parent in pairs(sons.connector.waitingParents) do
		if parent.robotTypeS == "drone" then
			drone_flag = true
			break
		end
	end
	--]]
	for idS, parent in pairs(sons.connector.waitingParents) do
		if (drone_flag == true and parent.robotTypeS == "drone") or drone_flag == false then
			if parent.distance < MinDis then
				MinDis = parent.distance
				MinId = idS
			end
		end
	end
	-- old grand parent has priority
	if sons.parentR == nil and
	   sons.brainkeeper.grandParentID ~= nil and
	   sons.connector.waitingParents[sons.brainkeeper.grandParentID] ~= nil then
		MinId = sons.brainkeeper.grandParentID
	end
	for idS, parent in pairs(sons.connector.waitingParents) do
		if idS == MinId then
			parent.nearest = true
		else
			parent.nearest = nil
		end
	end
end

------ behaviour tree ---------------------------------------
function Connector.create_connector_node(sons, option)
	-- option = {
	--     no_parent_ack = true or false or nil
	--         -- means only ack when I don't have a parent
	--	   no_recruit = true or false or nil
	--         -- never recruit, for pipucks
	--     specific_name = "drone1"
	--     specific_time = 500
	--         -- ack only to drone1 for first 500 steps
	-- }
	if option == nil then option = {} end
	return function()
		Connector.step(sons)

		-- ack, specific or all
		if option.specific_time == nil then option.specific_time = 0 end
		if option.specific_name ~= nil and sons.api.stepCount < option.specific_time then
			Connector.ackSpecific(sons, option.specific_name, {no_parent_ack = option.no_parent_ack})
		else
			Connector.ackAll(sons, {no_parent_ack = option.no_parent_ack})
		end

		-- recruit
		if option.no_recruit ~= true then
			Connector.recruitAll(sons)
		end
		--Connector.recruitNear(sons)
		return false, true
	end
end

return Connector
