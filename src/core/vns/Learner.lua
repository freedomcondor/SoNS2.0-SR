-- Learner ------------------------------
-- This module tries to make a robot receives the code of a whole behavior block from another robot,
-- and dynamically inserted it into its own behavior tree on the fly.
-- It works with dynamic behavior tree

-- Working in progress - return in mns3.0
------------------------------------------------------

local Learner = {}

function Learner.step(vns, BTchildren)

end

function Learner.create_learner_node(vns, option)
	-- option = {
	-- }
	return { type = "sequence", dynamic = true, children = {
		function(BTchildren)
			Learner.step(vns, BTchildren)
		end,
	}}
end

return Learner