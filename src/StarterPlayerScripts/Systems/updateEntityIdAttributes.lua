local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Packages = ReplicatedStorage.Packages

local Matter = require(Packages.Matter)

local Components = require(Shared.Components)

local function updateEntityIdAttributes(world: Matter.World)
	for id, record in world:queryChanged(Components.PlayerData) do
		if record.new then
			record.new.Player:SetAttribute("clientEntityId", id)
		end
	end
end

return updateEntityIdAttributes