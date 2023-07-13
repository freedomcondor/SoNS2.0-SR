-- This function deep copies a table
-- input: table
-- output: a new table that contains exactly the same as the input table

-- This is useful for lua assigns table by only the pointer
-- For example:
--[[
	a = {test = "test"}
	b = a
	c = DeepCopy(a)
	a.test = "test2"
	print(b.test, c.test)

	b.test will be test2, and c.test will be test
--]]

function DeepCopy(table)
	local new_table
	if type(table) ~= "table" then
		return table
	else
		new_table = {}
		for i, v in pairs(table) do
			new_table[DeepCopy(i)] = DeepCopy(v)
		end
	end
	return new_table
end

return DeepCopy
