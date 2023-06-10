local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Remotes = ReplicatedStorage.Remotes
local Packages = ReplicatedStorage.Packages

local Matter = require(Shared.Matter)
local Sift = require(Packages.Sift)

local Components = require(Shared.Components)

local MatterRemote: RemoteEvent = Remotes.MatterRemote

local REPLICATED_COMPONENTS = {
	"PlayerData",
}

local LOCAL_REPLICATED_COMPONENTS = {}

local replicatedComponents: { [Matter.Component<any>]: boolean } = {}
local localReplicatedComponents: { [Matter.Component<any>]: boolean } = {}

for _index, name: string in ipairs(REPLICATED_COMPONENTS) do
	replicatedComponents[Components[name]] = true
end

for _index, name: string in ipairs(LOCAL_REPLICATED_COMPONENTS) do
	localReplicatedComponents[Components[name]] = true
end

local mergedReplicatedComponents = Sift.Dictionary.merge(replicatedComponents, localReplicatedComponents) 

type payload = Dictionary<Dictionary<{ data: table }>>

local function replication(world: Matter.World)
	for _index, player: Player in Matter.useEvent(Players, "PlayerAdded") do
		local payload: payload = {}

		for entityId, entityData in world do
			local entityPayload = {}
			payload[`{entityId}`] = entityPayload

			for component, componentData in entityData do
				if replicatedComponents[component] then
					entityPayload[`{component}`] = { data = componentData }
				end
			end
		end

		print("Sending initial payload to", player)
		MatterRemote:FireClient(player, payload)
	end

	local payloads: Dictionary<payload> = {}

	for component in mergedReplicatedComponents do
		local isLocalComponent = table.find(component, localReplicatedComponents) and true or false

		for entityId, record in world:queryChanged(component) do
			for _index, PlayerData in world:query(Components.PlayerData) do
				local playerEntityId = PlayerData.Player:GetAttribute("serverEntityId")

				if isLocalComponent and entityId ~= playerEntityId then continue end

				local userId = `{PlayerData.Player.UserId}`
				local payload = payloads[userId] or {} :: payload

				local key = `{entityId}`
				local name = `{component}`

				if payload[key] == nil then
					payload[key] = {}
				end

				if world:contains(entityId) then
					payload[key][name] = { data = record.new :: any }
				end

				payloads[userId] = payload
			end
		end
	end

	if next(payloads) then
		for userId, payload in payloads do
			local player = Players:GetPlayerByUserId(tonumber(userId))

			MatterRemote:FireClient(player, payload)
		end
	end
end

return {
	system = replication,
	priority = math.huge,
}
