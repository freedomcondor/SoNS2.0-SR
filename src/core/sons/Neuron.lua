-- Neuron---------------------------------------------
-- Neuron make a robot works as a neuron, draw input from neighour robots and output to neighour robot

-- Working in progress
------------------------------------------------------

logger.register("Neuron")

local Neuron = {}

function Neuron.create(sons)
	sons.neuron = {input = {}}
end

function Neuron.reset(sons)
	sons.neuron = {input = {}}
end

function Neuron.step(sons)
	if sons.allocator.target == nil then return end
	if sons.allocator.target.neuron == nil then return end

	for _, msgM in ipairs(sons.Msg.getAM("ALLMSG", "neuron_data")) do
		if sons.allocator.target.neuron.input ~= nil and
		   sons.allocator.target.neuron.input[msgM.dataT.id] == true then
			sons.neuron.input[msgM.dataT.id] = msgM.dataT.output
		end
	end

	sons.neuron.output = sons.allocator.target.neuron.output(sons.neuron.input)

	sons.Msg.send("ALLMSG", "neuron_data",
		{
			id = sons.allocator.target.neuron.id,
			output = sons.neuron.output,
		}
	)
end

function Neuron.create_neuron_node(sons)
	return function()
		Neuron.step(sons)
		return false, true
	end
end

return Neuron