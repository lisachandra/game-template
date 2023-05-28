local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Packages = ReplicatedStorage.Packages
local Remotes = ReplicatedStorage.Remotes

local Matter = require(Packages.Matter)

local Components = require(Shared.Components)

local MatterRemote: RemoteEvent = Remotes.MatterRemote

local REPLICATED_COMPONENTS = {
	"PlayerData",
}

local replicatedComponents = {}

for _index, name in REPLICATED_COMPONENTS do
	replicatedComponents[Components[name]] = true
end

local function replication(world: Matter.World)
	for _index, player: Player in Matter.useEvent(Players, "PlayerAdded") do
		local payload = {}

		for entityId, entityData in world do
			local entityPayload = {}
			payload[tostring(entityId)] = entityPayload

			for component, componentData in entityData do
				if replicatedComponents[component] then
					entityPayload[tostring(component)] = { data = componentData }
				end
			end
		end

		print("Sending initial payload to", player)
		MatterRemote:FireClient(player, payload)
	end

	local changes = {}

	for component in replicatedComponents do
		for entityId, record in world:queryChanged(component) do
			local key = tostring(entityId)
			local name = tostring(component)

			if changes[key] == nil then
				changes[key] = {}
			end

			if world:contains(entityId) then
				changes[key][name] = { data = record.new }
			end
		end
	end

	if next(changes) then
		MatterRemote:FireAllClients(changes)
	end
end

return {
	system = replication,
	priority = math.huge,
}