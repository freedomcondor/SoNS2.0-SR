-- Allocator -----------------------------------------
-- The Allocator module matches the current children with the current target formation branch in an optimized way and manages targeted handovers. 
-- Each robot handles allocations of the robots downstream from it.
-- For details, please refer to the accompanying paper which describe the SoNS algorithms in detail.
------------------------------------------------------
logger.register("Allocator")
--local Arrangement = require("Arrangement")
local MinCostFlowNetwork = require("MinCostFlowNetwork")
local DeepCopy = require("DeepCopy")
local BaseNumber = require("BaseNumber")

local Allocator = {}

--[[
--	related data
--	sons.allocator.target = {positionV3, orientationQ, robotTypeS, children}
--	sons.allocator.gene
--	sons.allocator.gene_index
--	sons.childrenRT[xx].allocator.match
--]]

function Allocator.create(sons)
	sons.allocator = {
		target = {
			positionV3 = vector3(),
			orientationQ = quaternion(),
			robotTypeS = sons.robotTypeS,
			idN = -1,
		},
		parentGoal = {
			positionV3 = vector3(),
			orientationQ = quaternion(),
		},
		mode_switch = "allocate",
		goal_overwrite = nil,
		-- goal overwrite is a hack to let after_core nodes change goal regardless of the parent's command
		-- it will take effective before children allocation, and then set back to nil in step after overwrite goal
		--	{
		--		positionV3.x/y/z, orientationQ               target to change
		--	}
	}
end

function Allocator.reset(sons)
	sons.allocator = {
		target = {
			positionV3 = vector3(),
			orientationQ = quaternion(),
			robotTypeS = sons.robotTypeS,
			idN = -1,
		},
		parentGoal = {
			positionV3 = vector3(),
			orientationQ = quaternion(),
		},
		mode_switch = "allocate",
		goal_overwrite = nil,
	}
end

function Allocator.addChild(sons, robotR)
	robotR.allocator = {match = nil}
end

--function Allocator.deleteChild(sons)
--end

function Allocator.addParent(sons)
	sons.mode_switch = "allocate"
end

function Allocator.deleteParent(sons)
	sons.allocator.parentGoal = {
		positionV3 = vector3(),
		orientationQ = quaternion(),
	}
	--sons.Allocator.setMorphology(sons, sons.allocator.gene)
	-- TODO: resetMorphology?
end

-- Gene is a "gene" that contains all the target formations
function Allocator.setGene(sons, morph)
	sons.allocator.morphIdCount = 0
	sons.allocator.gene_index = {}
	sons.allocator.gene_index[-1] = {
		positionV3 = vector3(),
		orientationQ = quaternion(),
		idN = -1,
		robotTypeS = sons.robotTypeS,
	}
	Allocator.calcMorphScale(sons, morph)
	sons.allocator.gene = morph
	sons.Allocator.setMorphology(sons, morph)
end

-- set target morphology of the swarm
function Allocator.setMorphology(sons, morph)
	-- issue a temporary morph if the morph is not valid
	if morph == nil then
		morph = {
			idN = -1,
			positionV3 = vector3(),
			orientationQ = quaternion(),
			robotTypeS = sons.robotTypeS,
		} 
	elseif morph.robotTypeS ~= sons.robotTypeS then 
		morph = {
			idN = -1,
			positionV3 = morph.positionV3,
			orientationQ = morph.orientationQ,
			robotTypeS = sons.robotTypeS,
		} 
	end
	sons.allocator.target = morph
end

function Allocator.resetMorphology(sons)
	sons.Allocator.setMorphology(sons, sons.allocator.gene)
end

function Allocator.preStep(sons)
	for idS, childR in pairs(sons.childrenRT) do
		childR.allocator.match = nil
	end
	if sons.parentR ~= nil then
		local inverseOri = quaternion(sons.api.estimateLocation.orientationQ):inverse()
		sons.allocator.parentGoal.positionV3 = (sons.allocator.parentGoal.positionV3 - sons.api.estimateLocation.positionV3):rotate(inverseOri)
		sons.allocator.parentGoal.orientationQ = sons.allocator.parentGoal.orientationQ * inverseOri
	end
end

function Allocator.sendStationary(sons)
	for idS, robotR in pairs(sons.childrenRT) do
		sons.Msg.send(idS, "allocator_stationary")
	end
end

function Allocator.sendAllocate(sons)
	for idS, robotR in pairs(sons.childrenRT) do
		sons.Msg.send(idS, "allocator_allocate")
	end
end

function Allocator.sendKeep(sons)
	for idS, robotR in pairs(sons.childrenRT) do
		sons.Msg.send(idS, "allocator_keep")
		sons.Msg.send(idS, "parentGoal", {
			positionV3 = sons.api.virtualFrame.V3_VtoR(sons.goal.positionV3 or vector3()),
			orientationQ = sons.api.virtualFrame.Q_VtoR(sons.goal.orientationQ or quaternion()),
		})
	end
end

function Allocator.step(sons)
	sons.api.debug.drawRing(sons.lastcolor or "black", vector3(0,0,0.3), 0.1)
	-- update parentGoal
	if sons.parentR ~= nil then for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "parentGoal")) do
		sons.allocator.parentGoal.positionV3 = sons.parentR.positionV3 +
			vector3(msgM.dataT.positionV3):rotate(sons.parentR.orientationQ)
		sons.allocator.parentGoal.orientationQ = sons.parentR.orientationQ * msgM.dataT.orientationQ 
	end end

	-- receive mode switch command
	if sons.parentR ~= nil then for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "allocator_stationary")) do
		sons.allocator.mode_switch = "stationary"
	end end
	if sons.parentR ~= nil then for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "allocator_keep")) do
		sons.allocator.mode_switch = "keep"
	end end
	if sons.parentR ~= nil then for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "allocator_allocate")) do
		sons.allocator.mode_switch = "allocate"
	end end

	-- stationary mode
	if sons.allocator.mode_switch == "stationary" then
		-- sons.goal.positionV3 and orientationQ remain nil
		if sons.stabilizer.stationary_referencing ~= true then
			sons.goal.positionV3 = vector3()
			sons.goal.orientationQ = quaternion()
		end
		Allocator.sendStationary(sons)
		return 
	end

	-- keep mode
	if sons.allocator.mode_switch == "keep" then
		sons.goal.positionV3 = sons.allocator.parentGoal.positionV3 +
			vector3(sons.allocator.target.positionV3):rotate(sons.allocator.parentGoal.orientationQ)
		sons.goal.orientationQ = sons.allocator.parentGoal.orientationQ * sons.allocator.target.orientationQ
		Allocator.sendKeep(sons)
		return 
	end

	-- allocate mode
	if sons.allocator.mode_switch == "allocate" then
		Allocator.sendAllocate(sons)
	end

	-- if I just handovered a child to parent, then I will receive an outdated allocate command, ignore this cmd
	if sons.parentR ~= nil and sons.parentR.assigner.scale_assign_offset:totalNumber() ~= 0 then
		for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "branches")) do
			msgM.ignore = true
		end
	end

	-- update my target based on parent's cmd
	local flag
	local second_level
	local self_align
	local temporary_goal
	if sons.parentR ~= nil then for _, msgM in ipairs(sons.Msg.getAM(sons.parentR.idS, "branches")) do 
	if msgM.ignore ~= true then
		flag = true
		second_level = msgM.dataT.branches.second_level
		self_align = msgM.dataT.branches.self_align

		--logger("receive branches")
		--logger(msgM.dataT.branches)

		if #msgM.dataT.branches == 1 then
			local color = "green"
			sons.lastcolor = color
			sons.api.debug.drawRing(color, vector3(), 0.12)
		elseif #msgM.dataT.branches > 1 then
			local color = "blue"
			sons.lastcolor = color
			sons.api.debug.drawRing(color, vector3(), 0.12)
		end
		if second_level == true then
			local color = "red"
			sons.lastcolor = color
			sons.api.debug.drawRing(color, vector3(0,0,0.01), 0.11)
		end
		for i, received_branch in ipairs(msgM.dataT.branches) do
			-- branches = 
			--	{  1 = {
			--              idN, may be -1
			--              number(the scale)
			--              positionV3 and orientationV3
			--         }
			--     2 = {...}
			--     second_level = nil or true
			--         -- indicates if I'm under a split node
			--     goal = {positionV3, orientationQ} 
			--         -- a goal indicates the location of grand parent
			--         -- happens in the first level split
			--     self_align - nil or true
			--         -- indicates whether this child should ignore second_level parent chase
			--	}
			received_branch.positionV3 = sons.parentR.positionV3 +
				vector3(received_branch.positionV3):rotate(sons.parentR.orientationQ)
			received_branch.orientationQ = sons.parentR.orientationQ * received_branch.orientationQ
			received_branch.robotTypeS = sons.allocator.gene_index[received_branch.idN].robotTypeS -- TODO: consider
		end
		if msgM.dataT.branches.goal ~= nil then
			msgM.dataT.branches.goal.positionV3 = sons.parentR.positionV3 +
				vector3(msgM.dataT.branches.goal.positionV3):rotate(sons.parentR.orientationQ)
			msgM.dataT.branches.goal.orientationQ = sons.parentR.orientationQ * msgM.dataT.branches.goal.orientationQ
			temporary_goal = msgM.dataT.branches.goal
		end

		Allocator.multi_branch_allocate(sons, msgM.dataT.branches)
	end end end

	-- I should have a target (either updated or not), 
	-- a goal for this step
	-- a group of children with match = nil

	-- check sons.allocator.goal_overwrite
	if sons.allocator.goal_overwrite ~= nil then
		local newPositionV3 = sons.goal.positionV3
		local newOrientationQ = sons.goal.orientationQ
		if sons.allocator.goal_overwrite.positionV3.x ~= nil then
			newPositionV3.x = sons.allocator.goal_overwrite.positionV3.x
		end
		if sons.allocator.goal_overwrite.positionV3.y ~= nil then
			logger(robot.id, "positionV3.y", sons.allocator.goal_overwrite.positionV3.y)
			newPositionV3.y = sons.allocator.goal_overwrite.positionV3.y
		end
		if sons.allocator.goal_overwrite.positionV3.z ~= nil then
			newPositionV3.z = sons.allocator.goal_overwrite.positionV3.z
		end
		if sons.allocator.goal_overwrite.orientationQ ~= nil then
			newOrientationQ = sons.allocator.goal_overwrite.orientationQ
		end
		sons.setGoal(sons, newPositionV3, newOrientationQ)
		sons.allocator.goal_overwrite = nil
	end

	--if I'm brain, if no stabilizer than stay still
	--[[
	if sons.parentR == nil and
	   sons.stabilizer ~= nil and
	   sons.stabilizer.allocator_signal == nil and
	   sons.allocator.keepBrainGoal == nil then
		sons.goal.positionV3 = vector3()
		sons.goal.orientationQ = quaternion()
	end
	--]]
	--[[
	if sons.parentR == nil and sons.allocator.keepBrainGoal == nil then
		sons.goal.positionV3 = vector3()
		sons.goal.orientationQ = quaternion()
	end
	--]]

	-- tell my children my goal
	if flag ~= true and sons.parentR ~= nil then
		local color = "yellow"
		sons.lastcolor = color
		sons.api.debug.drawRing(color, vector3(), 0.12)

		-- if I don't receive branches cmd, update my goal according to parentGoal
		--[[
		sons.goal.positionV3 = sons.allocator.parentGoal.positionV3 + 
			vector3(sons.allocator.target.positionV3):rotate(sons.allocator.parentGoal.orientationQ)
		sons.goal.orientationQ = sons.allocator.parentGoal.orientationQ * sons.allocator.target.orientationQ
		--]]

		-- send my new goal and don't send command for my children, everyone keep still
		-- send my new goal to children
		for idS, robotR in pairs(sons.childrenRT) do
			sons.Assigner.assign(sons, idS, nil)	
			sons.Msg.send(idS, "parentGoal", {
				positionV3 = sons.api.virtualFrame.V3_VtoR(sons.goal.positionV3 or vector3()),
				orientationQ = sons.api.virtualFrame.Q_VtoR(sons.goal.orientationQ or quaternion()),
			})
		end
		return
	end

	-- if my target is -1, I'm in the process of handing up to grandparent, stop children assign
	-- TODO: what if I'm already in the brain and I have more children 
	-- somethings when topology changing, there will be -1 perturbation shortly, ignore this -1
	---[[
	if sons.allocator.target.idN == -1 and (sons.allocator.extraCount or 0) < 5 then
		second_level = true
	end
	if sons.allocator.target.idN == -1 then
		sons.allocator.extraCount = (sons.allocator.extraCount or 0) + 1
	else
		sons.allocator.extraCount = nil
	end
	--]]

	-- assign better child
	if sons.parentR ~= nil then
		local calcBaseValue = Allocator.calcBaseValue
		if type(sons.allocator.target.calcBaseValue) == "function" then
			calcBaseValue = sons.allocator.target.calcBaseValue
		end
		local myValue = calcBaseValue(sons.allocator.parentGoal.positionV3, vector3(), sons.goal.positionV3)
		--local myValue = Allocator.calcBaseValue(sons.parentR.positionV3, vector3(), sons.goal.positionV3)
		for idS, robotR in pairs(sons.childrenRT) do
			if robotR.allocator.match == nil then
				local value = calcBaseValue(sons.allocator.parentGoal.positionV3, robotR.positionV3, sons.goal.positionV3)
				--local value = Allocator.calcBaseValue(sons.parentR.positionV3, robotR.positionV3, sons.goal.positionV3)
				if robotR.robotTypeS == sons.robotTypeS and value < myValue then
					local send_branches = {}
					send_branches[1] = {
						idN = sons.allocator.target.idN,
						number = sons.allocator.target.scale,
						positionV3 = sons.api.virtualFrame.V3_VtoR(sons.goal.positionV3),
						orientationQ = sons.api.virtualFrame.Q_VtoR(sons.goal.orientationQ),
					}
					send_branches.second_level = second_level
					sons.Msg.send(idS, "branches", {branches = send_branches})
					if second_level ~= true then
						sons.Assigner.assign(sons, idS, sons.parentR.idS)	
					end
					robotR.allocator.match = send_branches
				end
			end
		end
	end

	-- create branches from target children, with goal drifted position
	local branches = {second_level = second_level}
	if sons.allocator.target.children ~= nil then
		for _, branch in ipairs(sons.allocator.target.children) do
			branches[#branches + 1] = {
				idN = branch.idN,
				number = branch.scale,
				-- for brain, sons.goal.positionV3 = nil
				positionV3 = (sons.goal.positionV3) +
					vector3(branch.positionV3):rotate(sons.goal.orientationQ),
				orientationQ = sons.goal.orientationQ * branch.orientationQ, 
				robotTypeS = branch.robotTypeS,
				-- calcBaseValue function
				calcBaseValue = branch.calcBaseValue,
				-- Stabilizer hack -----------------------
				reference = branch.reference
			}

			-- do not drift if self align switch is on
			if sons.allocator.self_align == true and
			   sons.robotTypeS == "drone" and
			   branch.robotTypeS == "pipuck" then
				branches[#branches].positionV3 = branch.positionV3
				branches[#branches].orientationQ = branch.orientationQ
				branches[#branches].self_align = true
			end
		end
	end

	-- Stabilizer hack ------------------------------------------------------
	-- get a reference in branches
	if sons.stabilizer.referencing_robot ~= nil then
		local flag = false
		for _, branch in ipairs(branches) do
			if branch.reference == true then
				branch.robotTypeS = "reference_pipuck"
				flag = true
				branch.number = sons.ScaleManager.Scale:new(branch.number)
				branch.number:dec("pipuck")
				branch.number:inc("reference_pipuck")
				break
			end
		end
		if flag == false then
			for _, branch in ipairs(branches) do
				if branch.robotTypeS == "pipuck" then
					branch.robotTypeS = "reference_pipuck"
					branch.number = sons.ScaleManager.Scale:new(branch.number)
					branch.number:dec("pipuck")
					branch.number:inc("reference_pipuck")
					break
				end
			end
		end
	end
	-- Stabilizer hack ------------------------------------------------------
	-- change reference pipuck to reference_pipuck
	if sons.stabilizer.referencing_robot ~= nil then
		local ref = sons.stabilizer.referencing_robot
		if ref.scalemanager.scale["reference_pipuck"] == nil or
		   ref.scalemanager.scale["reference_pipuck"] == 0 then
			ref.robotTypeS = "reference_pipuck"
			ref.scalemanager.scale:dec("pipuck")
			ref.scalemanager.scale:inc("reference_pipuck")
		end
	end
	-- end Stabilizer hack ------------------------------------------------------

	-- hack branch position to save far away drone
	local goalPositionV2 = sons.goal.positionV3
	goalPositionV2.z = 0
	if sons.robotTypeS == "drone" and
	   --goalPositionV2:length() > 0.5 then
	   sons.driver.drone_arrive == false and
	   sons.allocator.pipuck_bridge_switch == true then
		local neighbours = {}
		if sons.parentR ~= nil and sons.parentR.robotTypeS == "drone" then
			neighbours[#neighbours + 1] = sons.parentR
			sons.parentR.parent = true
		end
		---[[
		for idS, robotR in pairs(sons.childrenRT) do
			if robotR.robotTypeS == "drone" then
				neighbours[#neighbours + 1] = robotR
			end
		end
		--]]
		--for idS, robotR in pairs(sons.childrenRT) do
		for idS, robotR in ipairs(neighbours) do
			--local disV2 = vector3(robotR.positionV3)
			--disV2.z = 0
			--if robotR.robotTypeS == "drone" and
			--   disV2:length() > sons.Parameters.safezone_drone_drone then
			--if robotR.robotTypeS == "drone" then
				-- this drone needs a pipuck in the middle
				-- get the nearest pipuck
				local dis = math.huge
				local nearestBranch = nil
				for _, branch in ipairs(branches) do
					if branch.robotTypeS == "pipuck" and
					   branch.reference ~= true and
					   (branch.positionV3 - robotR.positionV3):length() < dis and
					   branch.drone_bridge_hack == nil then
						dis = (branch.positionV3 - robotR.positionV3):length()
						nearestBranch = branch
					end
				end
				if nearestBranch ~= nil then
					nearestBranch.positionV3 = robotR.positionV3 * 0.5
					local offset = vector3(robotR.positionV3):normalize():rotate(quaternion(math.pi/2, vector3(0,0,1)))
					               * sons.Parameters.dangerzone_pipuck
					nearestBranch.positionV3 = nearestBranch.positionV3 + offset
					nearestBranch.drone_bridge_hack = true
				end
			--end
		end
	end

	Allocator.allocate(sons, branches)

	-- Stabilizer hack ------------------------------------------------------
	-- change reference pipuck back to pipuck
	if sons.stabilizer.referencing_robot ~= nil then
		local ref = sons.stabilizer.referencing_robot
		if ref.scalemanager.scale["reference_pipuck"] == 1 then
			ref.robotTypeS = "pipuck"
			ref.scalemanager.scale:inc("pipuck")
			ref.scalemanager.scale:dec("reference_pipuck")
		end
	end
	-- end Stabilizer hack ------------------------------------------------------

	-- Stabilizer hack ------------------------------------------------------
	-- stop moving is I'm referenced  TODO: combine with goal_overwrite
	if sons.stabilizer.referencing_me == true then
		sons.goal.positionV3 = vector3()
		sons.goal.orientationQ = quaternion()
		if sons.stabilizer.referencing_me_goal_overwrite ~= nil then
			if sons.stabilizer.referencing_me_goal_overwrite.positionV3 ~= nil then
				sons.goal.positionV3 = sons.stabilizer.referencing_me_goal_overwrite.positionV3
			end
			if sons.stabilizer.referencing_me_goal_overwrite.orientationQ ~= nil then
				sons.goal.orientationQ = sons.stabilizer.referencing_me_goal_overwrite.orientationQ
			end
			sons.stabilizer.referencing_me_goal_overwrite = nil
		end
	end
	-- end Stabilizer hack ------------------------------------------------------

	if second_level == true and self_align ~= true and sons.parentR ~= nil then -- parent may be deleted by intersection
		sons.goal.positionV3 = sons.parentR.positionV3
		sons.goal.orientationQ = sons.parentR.orientationQ
	end
	if temporary_goal ~= nil then
		sons.goal.positionV3 = temporary_goal.positionV3
		sons.goal.orientationQ = temporary_goal.orientationQ
	end

	-- send my new goal to children
	for idS, robotR in pairs(sons.childrenRT) do
		sons.Msg.send(idS, "parentGoal", {
			positionV3 = sons.api.virtualFrame.V3_VtoR(sons.goal.positionV3 or vector3()),
			orientationQ = sons.api.virtualFrame.Q_VtoR(sons.goal.orientationQ or quaternion()),
		})
	end

end

function Allocator.multi_branch_allocate(sons, branches)
	--- Stabilizer hack -------------------
	if sons.stabilizer.referencing_me == true then
		sons.robotTypeS = "reference_pipuck"
	end
	--- end Stabilizer hack -------------------

	local sourceList = {}
	-- create sources from myself
	local tempScale = sons.ScaleManager.Scale:new()
	tempScale:inc(sons.robotTypeS)
	sourceList[#sourceList + 1] = {
		number = tempScale,
		index = {
			positionV3 = vector3(),
			robotTypeS = sons.robotTypeS,
		},
	}

	-- create sources from children
	for idS, robotR in pairs(sons.childrenRT) do
		sourceList[#sourceList + 1] = {
			number = sons.ScaleManager.Scale:new(robotR.scalemanager.scale),
			index = robotR,
		}
	end

	if #sourceList == 0 then return end

	-- create targets from branches
	local targetList = {}
	for _, branchR in ipairs(branches) do
		targetList[#targetList + 1] = {
			number = sons.ScaleManager.Scale:new(branchR.number),
			index = branchR
		}
	end

	-- create a cost matrix
	local originCost = {}
	for i = 1, #sourceList do originCost[i] = {} end
	for i = 1, #sourceList do
		for j = 1, #targetList do
			local targetPosition = vector3(targetList[j].index.positionV3)
			local relativeVector = sourceList[i].index.positionV3 - targetPosition
			relativeVector.z = 0
			originCost[i][j] = relativeVector:length()
		end
	end

	Allocator.GraphMatch(sourceList, targetList, originCost, "pipuck")
	Allocator.GraphMatch(sourceList, targetList, originCost, "drone")
	-- Stabilizer hack ----
	Allocator.GraphMatch(sourceList, targetList, originCost, "reference_pipuck")

	--[[
	logger("multi-branch sourceList")
	for i, source in ipairs(sourceList) do
		logger(i, source.index.idS or source.index.idN, source.index.robotTypeS)
		logger("\tposition = ", source.index.positionV3)
		logger("\tnumber")
		logger(source.number, 2)
		logger("\tto")
		for j, to in ipairs(source.to) do
			logger("\t", j, targetList[to.target].index.idS or targetList[to.target].index.idN)
			logger("\t\t\tnumber")
			logger(to.number, 4)
		end
	end
	logger("multi-branch targetList")
	for i, target in ipairs(targetList) do
		logger(i, target.index.idS or target.index.idN, target.index.robotTypeS)
		logger("\tposition = ", target.index.positionV3)
		logger("\tnumber")
		logger(target.number, 2)
		logger("\tfrom")
		for j, from in ipairs(target.from) do
			logger("\t", j, sourceList[from.source].index.idS or sourceList[from.source].index.idN)
			logger("\t\t\tnumber")
			logger(from.number, 4)
		end
	end
	--]]

	--- Stabilizer hack -------------------
	if sons.stabilizer.referencing_me == true then
		sons.robotTypeS = "pipuck"
	end
	--- end Stabilizer hack -------------------

	-- set myself  
	local myTarget = nil
	if #(sourceList[1].to) == 1 then
		myTarget = targetList[sourceList[1].to[1].target]
		local branchID = myTarget.index.idN
		Allocator.setMorphology(sons, sons.allocator.gene_index[branchID])
		sons.goal.positionV3 = myTarget.index.positionV3
		sons.goal.orientationQ = myTarget.index.orientationQ
		---[[ sometimes when topology changes, these maybe a -1 misjudge shortly, ignore this -1
		if branchID == -1 and (sons.allocator.extraCount or 0) < 5 then
			branches.second_level = true
		end
		--]]
	elseif #(sourceList[1].to) == 0 then
		Allocator.setMorphology(sons, sons.allocator.gene_index[-1])
		sons.goal.positionV3 = sons.allocator.parentGoal.positionV3
		sons.goal.orientationQ = sons.allocator.parentGoal.orientationQ
	elseif #(sourceList[1].to) > 1 then
		logger("Impossible! Myself is split in multi_branch_allocation")
	end

	-- handle split children
	-- this means I've already got a multi-branch cmd, I send a second_level multi-branch cmd
	-- if my cmd is first level multi-branch, I handover this child to my parent
	for i = 2, #sourceList do
		if #(sourceList[i].to) > 1 then
			local sourceChild = sourceList[i].index
			local send_branches = {}
			for _, targetItem in ipairs(sourceList[i].to) do
				local target_branch = targetList[targetItem.target]
				send_branches[#send_branches+1] = {
					idN = target_branch.index.idN,
					number = targetItem.number,
					positionV3 = sons.api.virtualFrame.V3_VtoR(target_branch.index.positionV3),
					orientationQ = sons.api.virtualFrame.Q_VtoR(target_branch.index.orientationQ),
				}
			end
			send_branches.second_level = true
			-- send temporary goal based on my temporary goal
			-- if I'm a first level split node, send a temporary goal for grand parent location
			if branches.second_level ~= true then
				send_branches.goal = {
					positionV3 = sons.api.virtualFrame.V3_VtoR(sons.parentR.positionV3),
					orientationQ = sons.api.virtualFrame.Q_VtoR(sons.parentR.orientationQ),
				}
			end

			sons.Msg.send(sourceChild.idS, "branches", {branches = send_branches})
			if branches.second_level ~= true then
				sons.Assigner.assign(sons, sourceChild.idS, sons.parentR.idS)	
			else
				sons.Assigner.assign(sons, sourceChild.idS, nil)	
			end
			sourceChild.allocator.match = send_branches
		end
	end

	-- handle not my children
	-- for each target that is not my assignment
	for j = 1, #targetList do if targetList[j] ~= myTarget then
		local farthest_id = nil
		local farthest_value = math.huge
		-- for each child that is assigned to the current target
		for i = 2, #sourceList do 
		if #(sourceList[i].to) == 1 and sourceList[i].to[1].target == j then
			-- create send branch
			local source_child = sourceList[i].index
			local target_branch = targetList[j].index
			local send_branches = {}
			send_branches[1] = {
				idN = target_branch.idN,
				number = sourceList[i].to[1].number,
				positionV3 = sons.api.virtualFrame.V3_VtoR(target_branch.positionV3),
				orientationQ = sons.api.virtualFrame.Q_VtoR(target_branch.orientationQ),
			}
			-- if I'm a first level split node, send a temporary goal for grand parent location
			if branches.second_level ~= true then
				send_branches.goal = {
					positionV3 = sons.api.virtualFrame.V3_VtoR(sons.parentR.positionV3),
					orientationQ = sons.api.virtualFrame.Q_VtoR(sons.parentR.orientationQ),
				}
			end
			--send_branches.second_level = branches.second_level
			send_branches.second_level = true
			sons.Msg.send(source_child.idS, "branches", {branches = send_branches})

			-- calculate farthest value
			local calcBaseValue = Allocator.calcBaseValue
			if type(target_branch.calcBaseValue) == "function" then
				calcBaseValue = target_branch.calcBaseValue
			end
			local value = calcBaseValue(sons.allocator.parentGoal.positionV3, source_child.positionV3, target_branch.positionV3)
			--local value = Allocator.calcBaseValue(sons.parentR.positionV3, source_child.positionV3, target_branch.positionV3)
			if source_child.robotTypeS == sons.allocator.gene_index[target_branch.idN].robotTypeS and 
			   value < farthest_value then
				farthest_id = i
				farthest_value = value
			end

			-- mark
			source_child.allocator.match = send_branches
		end end

		-- assign
		-- for each child that is assigned to the current target
		for i = 2, #sourceList do if #(sourceList[i].to) == 1 and sourceList[i].to[1].target == j then
			local source_child_id = sourceList[i].index.idS
			if i == farthest_id then
				if branches.second_level ~= true then
					sons.Assigner.assign(sons, source_child_id, sons.parentR.idS)	
				else
					sons.Assigner.assign(sons, source_child_id, nil)	
				end
			elseif farthest_id ~= nil then
				if branches.second_level ~= true then
					--sons.Assigner.assign(sons, source_child_id, sourceList[farthest_id].index.idS)	-- can't hand up and hand among siblings at the same time
					sons.Assigner.assign(sons, source_child_id, sons.parentR.idS)	
				else
					sons.Assigner.assign(sons, source_child_id, nil)	
				end
			elseif farthest_id == nil then -- the children are all different type, no farthest one is chosen
				if branches.second_level ~= true then
					sons.Assigner.assign(sons, source_child_id, sons.parentR.idS)	
				else
					sons.Assigner.assign(sons, source_child_id, nil)	
				end
			end
		end end
	end end
end

function Allocator.allocate(sons, branches)
	-- create sources from children
	local sourceList = {}
	local sourceSum = sons.ScaleManager.Scale:new()
	for idS, robotR in pairs(sons.childrenRT) do
		if robotR.allocator.match == nil then
			sourceList[#sourceList + 1] = {
				number = sons.ScaleManager.Scale:new(robotR.scalemanager.scale),
				index = robotR,
			}
			sourceSum = sourceSum + robotR.scalemanager.scale
		end
	end

	if #sourceList == 0 then return end

	-- create targets from branches
	local targetList = {}
	local targetSum = sons.ScaleManager.Scale:new()
	for _, branchR in ipairs(branches) do
		targetList[#targetList + 1] = {
			number = sons.ScaleManager.Scale:new(branchR.number),
			index = branchR
		}
		targetSum = targetSum + branchR.number
	end

	-- add parent as a target
	local diffSum = sourceSum - targetSum
	for i, v in pairs(diffSum) do
		if diffSum[i] ~= nil and diffSum[i] < 0 then
			diffSum[i] = 0
		end
	end
	if diffSum:totalNumber() > 0 and sons.parentR ~= nil then
		targetList[#targetList + 1] = {
			number = diffSum,
			index = {
				idN = -1,
				positionV3 = sons.parentR.positionV3,
				orientationQ = sons.parentR.orientationQ,
			}
		}
	elseif diffSum:totalNumber() > 0 and sons.parentR == nil then
		targetList[#targetList + 1] = {
			number = diffSum,
			index = {
				idN = -1,
				positionV3 = vector3(),
				orientationQ = quaternion(),
			}
		}
	end

	-- create a cost matrix
	local originCost = {}
	for i = 1, #sourceList do originCost[i] = {} end
	for i = 1, #sourceList do
		for j = 1, #targetList do
			local targetPosition = vector3(targetList[j].index.positionV3)
			local relativeVector = sourceList[i].index.positionV3 - targetPosition
			relativeVector.z = 0
			originCost[i][j] = relativeVector:length()
		end
	end

	Allocator.GraphMatch(sourceList, targetList, originCost, "pipuck")
	Allocator.GraphMatch(sourceList, targetList, originCost, "drone")
	-- Stabilizer hack ----
	Allocator.GraphMatch(sourceList, targetList, originCost, "reference_pipuck")

	--[[
	logger("sourceList")
	for i, source in ipairs(sourceList) do
		logger(i, source.index.idS or source.index.idN, source.index.robotTypeS)
		logger("\tposition = ", source.index.positionV3)
		logger("\tnumber")
		logger(source.number, 2)
		logger("\tto")
		for j, to in ipairs(source.to) do
			logger("\t", j, targetList[to.target].index.idS or targetList[to.target].index.idN)
			logger("\t\t\tnumber")
			logger(to.number, 4)
		end
	end
	logger("targetList")
	for i, target in ipairs(targetList) do
		logger(i, target.index.idS or target.index.idN, target.index.robotTypeS)
		logger("\tposition = ", target.index.positionV3)
		logger("\tnumber")
		logger(target.number, 2)
		logger("\tfrom")
		for j, from in ipairs(target.from) do
			logger("\t", j, sourceList[from.source].index.idS or sourceList[from.source].index.idN)
			logger("\t\t\tnumber")
			logger(from.number, 4)
		end
	end
	--]]

	-- handle split children  -- TODO if one of the split branches is -1
	for i = 1, #sourceList do
		if #(sourceList[i].to) > 1 then
			local sourceChild = sourceList[i].index
			local send_branches = {}
			for _, targetItem in ipairs(sourceList[i].to) do
				local target_branch = targetList[targetItem.target]
				send_branches[#send_branches+1] = {
					idN = target_branch.index.idN,
					number = targetItem.number,
					positionV3 = sons.api.virtualFrame.V3_VtoR(target_branch.index.positionV3),
					orientationQ = sons.api.virtualFrame.Q_VtoR(target_branch.index.orientationQ),
				}
			end
			send_branches.second_level = branches.second_level

			sons.Msg.send(sourceChild.idS, "branches", {branches = send_branches})
			sons.Assigner.assign(sons, sourceChild.idS, nil)	
			sourceChild.allocator.match = send_branches
		end
	end

	-- handle rest of the children
	-- for each target that is not the parent
	for j = 1, #targetList do if targetList[j].index.idN ~= -1 then
		local farthest_id = nil
		local farthest_value = math.huge
		-- for each child that is assigned to the current target
		for i = 1, #sourceList do if #(sourceList[i].to) == 1 and sourceList[i].to[1].target == j then
			-- create send branch
			local source_child = sourceList[i].index
			local target_branch = targetList[j].index
			local send_branches = {}
			send_branches[1] = {
				idN = target_branch.idN,
				number = sourceList[i].to[1].number,
				positionV3 = sons.api.virtualFrame.V3_VtoR(target_branch.positionV3),
				orientationQ = sons.api.virtualFrame.Q_VtoR(target_branch.orientationQ),
			}
			send_branches.second_level = branches.second_level
			send_branches.self_align = target_branch.self_align
			sons.Msg.send(source_child.idS, "branches", {branches = send_branches})

			-- calculate farthest value
			local calcBaseValue = Allocator.calcBaseValue
			if type(target_branch.calcBaseValue) == "function" then
				calcBaseValue = target_branch.calcBaseValue
			end
			local value = calcBaseValue(sons.goal.positionV3, source_child.positionV3, target_branch.positionV3)
			--local value = Allocator.calcBaseValue(vector3(), source_child.positionV3, target_branch.positionV3)

			if source_child.robotTypeS == sons.allocator.gene_index[target_branch.idN].robotTypeS and 
			   value < farthest_value then
				farthest_id = i
				farthest_value = value
			end

			-- mark
			source_child.allocator.match = send_branches
		end end

		-- assign
		-- for each child that is assigned to the current target
		for i = 1, #sourceList do if #(sourceList[i].to) == 1 and sourceList[i].to[1].target == j then
			local source_child_id = sourceList[i].index.idS
			if i == farthest_id then
				sons.Assigner.assign(sons, source_child_id, nil)	
			elseif farthest_id ~= nil then
				if branches.second_level ~= true then
					sons.Assigner.assign(sons, source_child_id, sourceList[farthest_id].index.idS)	
				else
					sons.Assigner.assign(sons, source_child_id, nil)	
				end
			end
		end end
	end end

	-- handle extra children     -- TODO: may set second level
	-- for each target that is the parent
	for j = 1, #targetList do if targetList[j].index.idN == -1 then
		for i = 1, #sourceList do if #(sourceList[i].to) == 1 and sourceList[i].to[1].target == j then
			local source_child = sourceList[i].index
			local target_branch = targetList[j].index
			local send_branches = {}
			send_branches[1] = {
				--idN = sons.allocator.target.idN,
				idN = target_branch.idN, --(-1)
				number = sourceList[i].to[1].number,
				positionV3 = sons.api.virtualFrame.V3_VtoR(target_branch.positionV3),
				orientationQ = sons.api.virtualFrame.Q_VtoR(target_branch.orientationQ),
			}
			send_branches.second_level = branches.second_level
			-- stop children handing over for extre children
			--send_branches.second_level = true 

			sons.Msg.send(source_child.idS, "branches", {branches = send_branches})
			if sons.parentR ~= nil then
				if branches.second_level ~= true then
					sons.Assigner.assign(sons, source_child.idS, sons.parentR.idS)	
				end
			else
				sons.Assigner.assign(sons, source_child.idS, nil)	
			end
			source_child.allocator.match = send_branches
		end end
	end end
end

-------------------------------------------------------------------------------
function Allocator.GraphMatch(sourceList, targetList, originCost, type)
	-- create a enhanced cost matrix
	-- and orderlist, to sort everything in originCost
	local orderList = {}
	local count = 0
	for i = 1, #sourceList do
		for j = 1, #targetList do
			count = count + 1
			orderList[count] = originCost[i][j]
		end
	end

	-- sort orderlist
	for i = 1, #orderList - 1 do
		for j = i + 1, #orderList do
			if orderList[i] > orderList[j] then
				local temp = orderList[i]
				orderList[i] = orderList[j]
				orderList[j] = temp
			end
		end
	end

	-- calculate sum for sourceList
	local sourceSum = 0
	for i = 1, #sourceList do
		sourceSum = sourceSum + (sourceList[i].number[type] or 0)
	end
	-- create a reverse index
	local reverseIndex = {}
	for i = 1, #orderList do reverseIndex[orderList[i]] = i end
	-- create an enhanced cost matrix
	local cost = {}
	for i = 1, #sourceList do
		cost[i] = {}
		for j = 1, #targetList do
			--cost[i][j] = (sourceSum + 1) ^ reverseIndex[originCost[i][j]]
			if (sourceSum + 1) ^ (#orderList + 1) > 2 ^ 31 then
				cost[i][j] = BaseNumber:createWithInc(sourceSum + 1, reverseIndex[originCost[i][j]])
			else
				cost[i][j] = (sourceSum + 1) ^ reverseIndex[originCost[i][j]]
			end
			---[[
			if sourceList[i].index.robotTypeS ~= targetList[j].index.robotTypeS or
			   sourceList[i].index.robotTypeS ~= type then
				if (sourceSum + 1) ^ (#orderList + 1) > 2 ^ 31 then
					cost[i][j] = cost[i][j] + BaseNumber:createWithInc(sourceSum + 1, #orderList + 1)
				else
					cost[i][j] = cost[i][j] + (sourceSum + 1) ^ (#orderList + 1)
				end
			end
			--]]
		end
	end

	-- create a flow network
	local C = {}
	local n = 1 + #sourceList + #targetList + 1
	for i = 1, n do C[i] = {} end
	-- 1, start
	-- 2 to #sourceList+1  source
	-- #sourceList+2 to #sourceList + #targetList + 1  target
	-- #sourceList + #target + 2   end
	local sumSource = 0
	for i = 1, #sourceList do
		C[1][1 + i] = sourceList[i].number[type] or 0
		sumSource = sumSource + C[1][1 + i]
		if C[1][1 + i] == 0 then C[1][1 + i] = nil end
	end
	if sumSource == 0 then
		return
	end

	for i = 1, #targetList do
		C[#sourceList+1 + i][n] = targetList[i].number[type]
		if C[#sourceList+1 + i][n] == 0 then C[#sourceList+1 + i][n] = nil end
	end
	for i = 1, #sourceList do
		for j = 1, #targetList do
			C[1 + i][#sourceList+1 + j] = math.huge
		end
	end
	
	local W = {}
	local n = 1 + #sourceList + #targetList + 1
	for i = 1, n do W[i] = {} end

	for i = 1, #sourceList do
		W[1][1 + i] = 0
	end
	for i = 1, #targetList do
		W[#sourceList+1 + i][n] = 0
	end
	for i = 1, #sourceList do
		for j = 1, #targetList do
			W[1 + i][#sourceList+1 + j] = cost[i][j]
		end
	end

	local F = MinCostFlowNetwork(C, W)

	for i = 1, #sourceList do
		if sourceList[i].to == nil then
			sourceList[i].to = {}
		end
	end
	for j = 1, #targetList do
		if targetList[j].from == nil then
			targetList[j].from = {}
		end
	end
	for i = 1, #sourceList do
		for j = 1, #targetList do
			if F[1 + i][#sourceList+1 + j] ~= nil and
			   F[1 + i][#sourceList+1 + j] ~= 0 then
				-- set sourceTo
				local exist = false
				-- see whether this target has already exist
				for k, sourceTo in ipairs(sourceList[i].to) do
					if sourceTo.target == j then
						sourceTo.number[type] = F[1 + i][#sourceList+1 + j]
						exist = true
						break
					end
				end
				if exist == false then
					local newNumber = sons.ScaleManager.Scale:new()
					newNumber[type] = F[1 + i][#sourceList+1 + j]
					sourceList[i].to[#(sourceList[i].to) + 1] = 
						{
							number = newNumber,
							target = j,
						}
				end
				-- set targetFrom
				exist = false
				-- see whether this source has already exist
				for k, targetFrom in ipairs(targetList[j].from) do
					if targetFrom.source == i then
						targetFrom.number[type] = F[1 + i][#sourceList+1 + j]
						exist = true
						break
					end
				end
				if exist == false then
					local newNumber = sons.ScaleManager.Scale:new()
					newNumber[type] = F[1 + i][#sourceList+1 + j]
					targetList[j].from[#(targetList[j].from) + 1] = 
						{
							number = newNumber,
							source = i,
						}
				end
			end
		end
	end
end

-------------------------------------------------------------------------------
function Allocator.calcBaseValue_vertical(base, current, target)
	local base_target_V3 = target - base
	local base_current_V3 = current - base
	base_target_V3.z = 0
	base_current_V3.z = 0
	return base_current_V3:dot(base_target_V3:normalize())
end

function Allocator.calcBaseValue_oval(base, current, target)
	local base_target_V3 = target - base
	local base_current_V3 = current - base
	base_target_V3.z = 0
	base_current_V3.z = 0
	local dot = base_current_V3:dot(base_target_V3:normalize())
	if dot < 0 then 
		return dot 
	else
		local x = dot
		local x2 = dot ^ 2
		local l = base_current_V3:length()
		local y2 = l ^ 2 - x2
		elliptic_distance2 = x2 + (1/4) * y2
		return elliptic_distance2
	end
end

--Allocator.calcBaseValue = Allocator.calcBaseValue_vertical
Allocator.calcBaseValue = Allocator.calcBaseValue_oval

-------------------------------------------------------------------------------
function Allocator.calcMorphScale(sons, morph)
	Allocator.calcMorphChildrenScale(sons, morph)
	Allocator.calcMorphParentScale(sons, morph)
end

function Allocator.calcMorphChildrenScale(sons, morph, level)
	sons.allocator.morphIdCount = sons.allocator.morphIdCount + 1
	morph.idN = sons.allocator.morphIdCount 
	level = level or 1
	morph.level = level
	sons.allocator.gene_index[morph.idN] = morph

	local sum = sons.ScaleManager.Scale:new()
	if morph.children ~= nil then
		for i, branch in ipairs(morph.children) do
			sum = sum + Allocator.calcMorphChildrenScale(sons, branch, level + 1)
		end
	end
	if sum[morph.robotTypeS] == nil then
		sum[morph.robotTypeS] = 1
	else
		sum[morph.robotTypeS] = sum[morph.robotTypeS] + 1
	end
	morph.scale = sum
	return sum
end

function Allocator.calcMorphParentScale(sons, morph)
	if morph.parentScale == nil then
		morph.parentScale = sons.ScaleManager.Scale:new()
	end
	local sum = morph.parentScale + morph.scale
	if morph.children ~= nil then
		for i, branch in ipairs(morph.children) do
			branch.parentScale = sum - branch.scale
		end
		for i, branch in ipairs(morph.children) do
			Allocator.calcMorphParentScale(sons, branch)
		end
	end
end

-------------------------------------------------------------------------------
function Allocator.create_allocator_node(sons)
	return function()
		Allocator.step(sons)
		return false, true
	end
end

return Allocator
