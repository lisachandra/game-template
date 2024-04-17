local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local Matter = require(Shared.Matter)

local Bridges = require(Shared.Bridges)
local Bridges: Bridges.Bridges<Bridges.ClientBridge> = Bridges

local processors: Dictionary<(...any) -> ()> = {}; for _index, processor in script:GetChildren() do
	processors[processor.Name] = require(processor) :: any
end

local function handleEffects(world: Matter.World)
	local iterator = Matter.useEvent(Bridges, "Replication"); while true do
		local args = table.pack(iterator()); if args.n > 0 then
			local _index, processor: string = table.remove(args, 1), table.remove(args[1], 1) :: any
			processors[processor](world, table.unpack(args[1]))
		else
			break
		end
	end
end

return handleEffects
