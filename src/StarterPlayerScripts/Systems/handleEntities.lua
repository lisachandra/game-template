local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local Matter = require(Shared.Matter)

local Components = require(Shared.Components)

local function handleEntities(world: Matter.World)
	for entityId, record in world:queryChanged(Components.PlayerData) do
		if not record.old and record.new then
			record.new.Player:SetAttribute("clientEntityId", entityId)
		end
	end

	for entityId, record in world:queryChanged(Components.Tag) do
		if not record.new and record.old then
			world:despawn(entityId)
		end
	end
end

return handleEntities
