-- CollectiveSensor ---------------------------------------
-- Collective Sensor is used for a child to report to its parent the obstacles it sees,
-- and for the parent to (optionally) report its childrens' reports further upstream.
-- Data structure: 
--    sons.collectivesensor.receiveList keeps received reports from children
--    sons.collectivesensor.sendList    keeps what needs to be reported to the parent in the end of the step
-----------------------------------------------------------

local DeepCopy = require("DeepCopy")

local CollectiveSensor = {}

function CollectiveSensor.create(sons)
	sons.collectivesensor = {}
end

function CollectiveSensor.preStep(sons)
	sons.collectivesensor.receiveList = {}
	sons.collectivesensor.sendList = {}
end

function CollectiveSensor.addToSendList(sons, object)
	local object = DeepCopy(object)

	-- convert vectors from V to R
	for i, v in pairs(object) do
		--[[
		logger("i = ", i)
		logger("v = ", getmetatable(v))
		logger("vector3 = ", getmetatable(vector3()))
		logger("whether a vector3 = ", getmetatable(v) == getmetatable(vector3()))
		--]]
		if type(v) == "userdata" and getmetatable(v) == getmetatable(vector3()) then
			--logger("I converted a vector3")
			object[i] = sons.api.virtualFrame.V3_VtoR(object[i])
		end
		if type(v) == "userdata" and getmetatable(v) == getmetatable(quaternion()) then
			--logger("I converted a quaternion")
			object[i] = sons.api.virtualFrame.Q_VtoR(object[i])
		end
	end

	table.insert(sons.collectivesensor.sendList, object)
end

function CollectiveSensor.postStep(sons)
	-- send sons.collectivesensor.sendList
	if sons.parentR ~= nil and sons.collectivesensor.sendList ~= nil then
		sons.Msg.send(sons.parentR.idS, "sensor_report", {reportList = sons.collectivesensor.sendList})
	end
end

function CollectiveSensor.step(sons)
	for idS, robotR in pairs(sons.childrenRT) do 
		for _, msgM in ipairs(sons.Msg.getAM(idS, "sensor_report")) do
			-- for each object in a list
			for i, object in pairs(msgM.dataT.reportList) do
				for j, v in pairs(object) do
					if type(v) == "userdata" and getmetatable(v) == getmetatable(vector3()) then
						--[[
						object[j] = sons.api.virtualFrame.V3_RtoV(
							vector3(v):rotate(sons.api.virtualFrame.Q_VtoR(robotR.orientationQ)) + 
							sons.api.virtualFrame.V3_VtoR(robotR.positionV3)
						)
						--]]
						object[j] = 
							vector3(v):rotate(robotR.orientationQ) + robotR.positionV3
					end
					if type(v) == "userdata" and getmetatable(v) == getmetatable(quaternion()) then
						object[j] = 
							robotR.orientationQ
							* v
						--[[
						object[j] = sons.api.virtualFrame.Q_RtoV(
							sons.api.virtualFrame.Q_VtoR(robotR.orientationQ)
							* v
						)
						--]]
					end
				end

				--[[
				-- check existed
				local flag = 0
				for 
				--]]

				table.insert(sons.collectivesensor.receiveList, object)
			end
		end
	end
end

-- Report everything to the parent from sons.avoider.obstacles and sons.collectivesensor.receiveList
function CollectiveSensor.reportAll(sons)
	for i, ob in pairs(sons.avoider.obstacles) do
		CollectiveSensor.addToSendList(sons, ob)
	end
	for i, ob in pairs(sons.collectivesensor.receiveList) do
		local flag = true
		for j, existing_ob in pairs(sons.collectivesensor.sendList) do
			if existing_ob.positionV3 ~= nil and
			   ob.positionV3 ~= nil and
			   (existing_ob.positionV3 - ob.positionV3):length() < 0.01 then
				flag = false
				break
			end
		end
		if flag == true then
			CollectiveSensor.addToSendList(sons, ob)
		end
	end
end

------ behaviour tree ---------------------------------------
function CollectiveSensor.create_collectivesensor_node_reportAll(sons)
	return function()
		if sons.robotTypeS == "drone" then
		CollectiveSensor.step(sons)
		CollectiveSensor.reportAll(sons)
		end
		return false, true
	end
end

function CollectiveSensor.create_collectivesensor_node(sons)
	return function()
		if sons.robotTypeS == "drone" then
			CollectiveSensor.step(sons)
		end
		return false, true
	end
end

return CollectiveSensor
