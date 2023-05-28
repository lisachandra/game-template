local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local Components = require(Shared.Components)

local function updateEntityIdAttributes(world)
	for id, record in world:queryChanged(Components.PlayerData) do
		if record.new then
			record.new.Player:SetAttribute("clientEntityId", id)
		end
	end
end

return updateEntityIdAttributes
