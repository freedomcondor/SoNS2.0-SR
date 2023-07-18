--- Scale -----------------------------------------------------------
-- This library is used by the ScaleManager module to count the number of each type of robot in the SoNS. 
---------------------------------------------------------------------
local Scale = {}
Scale.__index = Scale

-- create a scale
-- The input can be another scale or a table with same structure
-- Or simply a string as the type name of a robot type ("drone"), and it will create a scale with 1 that type
function Scale:new(table)
	local instance = {}
	setmetatable(instance, self)
	if table == nil then return instance end
	if type(table) == "table" then
		for i, v in pairs(table) do
			instance[i] = v
		end
	elseif type(table) == "string" then
		instance[table] = 1
	end
	return instance
end

-- Increment one for <robotTypeS> type of robot
function Scale:inc(robotTypeS)
	if self[robotTypeS] == nil then
		self[robotTypeS] = 1
	else
		self[robotTypeS] = self[robotTypeS] + 1
	end
end

-- Decrease one for <robotTypeS> type of robot
function Scale:dec(robotTypeS)
	if self[robotTypeS] == nil then
		self[robotTypeS] = -1
	else
		self[robotTypeS] = self[robotTypeS] - 1
	end
end

-- Count the total number of robots from all the types
function Scale:totalNumber()
	local sum = 0
	for i, v in pairs(self) do
		sum = sum + v
	end
	return sum
end

-- Add two scales
function Scale.__add(A, B)
	local C = Scale:new(A)
	if B == nil then return C end
	for i, v in pairs(B) do
		if C[i] == nil then 
			C[i] = v
		else
			C[i] = C[i] + v
		end
	end
	return C
end

-- subtract two scales
function Scale.__sub(A, B)
	local C = Scale:new(A)
	if B == nil then return C end
	for i, v in pairs(B) do
		if C[i] == nil then 
			C[i] = -v
		else
			C[i] = C[i] - v
		end
	end
	return C
end

-- Check if two scales equal
function Scale.__eq(A, B)
	if A == nil and B ~= nil then return false end
	if A ~= nil and B == nil then return false end
	if A == nil and B == nil then return true end
	for i, v in pairs(A) do
		if A[i] ~= B[i] then return false end
	end
	for i, v in pairs(B) do
		if A[i] ~= B[i] then return false end
	end
	return true
end

return Scale
