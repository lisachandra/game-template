local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Packages = ReplicatedStorage.Packages

local Janitor = require(Packages.Janitor)
local Matter = require(Shared.Matter)

local Components = require(Shared.Matter.Components)

local function handleEntities(world: Matter.World)
	for entityId, record in world:queryChanged(Components.PlayerData) do
		if not (not record.old and record.new) then
			if record.old and not record.new then
				record.old.Janitor:Destroy()
			end

			continue
		end

		local PlayerData = record.new

		PlayerData.Player:SetAttribute("clientEntityId", entityId)
		world:insert(entityId, PlayerData:patch({
			Janitor = Janitor,
		}))
	end

	for entityId, record in world:queryChanged(Components.NPCData) do
		if not (not record.old and record.new) then
			if record.old and not record.new then
				record.old.Janitor:Destroy()
			end

			continue
		end

		local NPCData = record.new
		local Janitor = Janitor.new()

		NPCData.Model:SetAttribute("clientEntityId", entityId)
		world:insert(entityId, NPCData:patch({
			Janitor = Janitor,
		}))
	end

	for entityId, record in world:queryChanged(Components.Tag) do
		if not record.new and record.old and world:contains(entityId) then
			world:despawn(entityId)
		end
	end
end

return handleEntities
