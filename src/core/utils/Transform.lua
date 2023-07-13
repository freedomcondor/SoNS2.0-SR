-- This is a library doing linear operations on position and orientation
-- A transform is defined as a combination of position and orientation, it describes where an object is relative to another
-- Here, a transformed is represented by a table with two elemets: positionV3 and orientationQ
-- t = {
--          positionV3 = vector3(xxx)
--          orientationQ = quaternion(xxx)
--     }

-- Operation between transforms can be considered as a group (group from group, ring, field ... )
-- For example, the transform of Object B relative to Object A can be considered as a : A -> B (A see B at a)
--              the transform of Object C relative to Object B is   b : B -> C                 (B see C at b)
--        Then, the transform of Object C relative to Object A is   c : A -> C = a x b         (A see C at axb)

--    a
-- A --> B
--  \    |
--   \   |b
--  c \  v
--     \ C

-- The following functions provides basic calculations around axb=c

local Transform = {}

-- C = A x B
function Transform.AxBisC(a, b, c)
	if c == nil then c = {} end
	c.positionV3 = a.positionV3 + vector3(b.positionV3):rotate(a.orientationQ)
	c.orientationQ = a.orientationQ * b.orientationQ
	return c
end

-- C = A^-1
function Transform.AxCis0(a, c)
	if c == nil then c = {} end
	c.positionV3 = (-a.positionV3):rotate(a.orientationQ:inverse())
	c.orientationQ = a.orientationQ:inverse()
	return c
end

--[[
	A.positionV3, A.orientationQ
	myVec in A's eye
		(myVec-A.positionV3):rotate(A.orientationQ:inverse())
	myQua in A's eye
		A.orientationQ:inverse() * myQua
--]]

-- C = A^-1 x B	
-- A x X = B
-- I see A and B, what is A see B
-- I --> A
--  \    |
--   \   |
--    \  v
--     \ B
function Transform.AxCisB(a, b, c)
	-- a in b's eye
	if c == nil then c = {} end
	c.positionV3 = (b.positionV3 - a.positionV3):rotate(a.orientationQ:inverse())
	c.orientationQ = a.orientationQ:inverse() * b.orientationQ 
	return c
end

-- C = A x B^-1
-- X x A = B
-- A, B see a common object, what is A see B?
-- A --> B
--  \    |
--   \   |
--    \  v
--     \ common
function Transform.CxBisA(a, b, c)
	Transform.AxCis0(b, c)
	Transform.AxBisC(a, c, c)
end

-------------------------------------------------------------------
-- Accumulator
-- This section provides a accumulator and averager of transforms
-- What is the average of several transforms?
-- It is used when multiple robots see the same object, the brain or common parent needs to decide where this object is.

-- Creates an accumulator
function Transform.createAccumulator()
	return {
		positionV3 = vector3(),
		orientation_X_V3 = vector3(),
		orientation_Y_V3 = vector3(),
		orientation_Z_V3 = vector3(),
		n = 0,
	}
end

-- Add a transform into an accumulator
function Transform.addAccumulator(accumulator, transform)
	accumulator.n = accumulator.n + 1
	accumulator.positionV3 = accumulator.positionV3 + transform.positionV3
	accumulator.orientation_X_V3 = accumulator.orientation_X_V3 + vector3(1,0,0):rotate(transform.orientationQ)
	accumulator.orientation_Y_V3 = accumulator.orientation_Y_V3 + vector3(0,1,0):rotate(transform.orientationQ)
	accumulator.orientation_Z_V3 = accumulator.orientation_Z_V3 + vector3(0,0,1):rotate(transform.orientationQ)
end

-- subtract a transform from an accumulator
function Transform.subAccumulator(accumulator, transform)
	accumulator.n = accumulator.n - 1
	accumulator.positionV3 = accumulator.positionV3 - transform.positionV3
	accumulator.orientation_X_V3 = accumulator.orientation_X_V3 - vector3(1,0,0):rotate(transform.orientationQ)
	accumulator.orientation_Y_V3 = accumulator.orientation_Y_V3 - vector3(0,1,0):rotate(transform.orientationQ)
	accumulator.orientation_Z_V3 = accumulator.orientation_Z_V3 - vector3(0,0,1):rotate(transform.orientationQ)
end

-- average an accumulator and return the average transform
function Transform.averageAccumulator(accumulator, transform)
	if transform == nil then transform = {} end
	transform.positionV3 = accumulator.positionV3 * (1/accumulator.n)
	local X = (accumulator.orientation_X_V3 * (1/accumulator.n)):normalize()
	local Y = (accumulator.orientation_Y_V3 * (1/accumulator.n)):normalize()
	local Z = (accumulator.orientation_Z_V3 * (1/accumulator.n)):normalize()
	transform.orientationQ = Transform.fromTo2VecQuaternion(vector3(1,0,0), X, vector3(0,1,0), Y)
	return transform
end

-------------------------------------------------------------------
-- Average Quaternion 
-- In the accumulator, the accumulation of a quaternion is implemented by accumulating the unit vectors in XYZ axis rotated by this quaternion
-- So at last it is needed to calculate the quaternion back from two destiny vectors and the source vectors
function Transform.fromToQuaternion(vec1, vec2)
	-- assuming vec1 and vec2 are normal vectors
	if vec1 == vec2 then return quaternion() end
	local axis = vector3(vec1):cross(vec2)
	-- if vec1 == -vec2 then they cancel each other and axis is 0
	if axis:length() == 0 then
		local helper = vector3(1,0,0)
		if (helper:cross(vec1)):length() == 0 then helper = vector3(0,1,0) end
		axis = vec1:cross(helper)
		local angle = math.pi
		return quaternion(angle, axis:normalize())
	end
	-- if everything is normal
	local angle = math.acos(vec1:dot(vec2))
	return quaternion(angle, axis:normalize())
end

function Transform.fromTo2VecQuaternion(vec1_from, vec1_to, vec2_from, vec2_to)
	local rotate1 = Transform.fromToQuaternion(vec1_from, vec1_to)
	local vec2_middle = vector3(vec2_to):rotate(rotate1:inverse())
	local rotate2 = Transform.fromToQuaternion(vec2_from, vec2_middle)
	return rotate1 * rotate2
end

return Transform