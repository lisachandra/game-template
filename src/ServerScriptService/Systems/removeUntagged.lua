local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local Matter = require(Shared.Matter)

local Components = require(Shared.Matter.Components)

local function removeUntagged(world: Matter.World)
	for entityId, record in world:queryChanged(Components.Tag) do
		if not record.new and record.old and world:contains(entityId) then
			world:despawn(entityId)
		end
	end
end

return removeUntagged
