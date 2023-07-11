local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Remotes = ReplicatedStorage.Remotes
local Packages = ReplicatedStorage.Packages

local Matter = require(Shared.Matter)
local Sift = require(Packages.Sift)

local Components = require(Shared.Components)

local SERVER_TIME_REPLICATE_INTERVAL = 0.1

local REPLICATED_COMPONENTS = {
	"PlayerData",
}


local LOCAL_REPLICATED_COMPONENTS = {
	"Server",
}

local EXCLUDED = {
	PlayerData = {
		"Janitor",
	},
}

local replicatedComponents: Array<Matter.Component<any>> = {}
local localReplicatedComponents: Array<Matter.Component<any>> = {}

for _index, name in ipairs(REPLICATED_COMPONENTS) do
	table.insert(replicatedComponents, Components[name])
end

for _index, name in ipairs(LOCAL_REPLICATED_COMPONENTS) do
	table.insert(localReplicatedComponents, Components[name])
end

local mergedReplicatedComponents = Sift.Array.push(replicatedComponents, table.unpack(localReplicatedComponents))

type payload = Dictionary<Dictionary<{ data: table }>>

local function replication(world: Matter.World)
	local replicateServerTime = Matter.useThrottle(SERVER_TIME_REPLICATE_INTERVAL)

	for entityId, PlayerData, Server in world:query(Components.PlayerData, Components.Server) do
		if replicateServerTime then
			world:insert(entityId, Server:patch({
				Time = os.clock(),
			} :: Components.Server))
		end
	end

	for _index, Player: Player in Matter.useEvent(Players, "PlayerAdded") do
		local payload: payload = {}

		for entityId, entityData in world do
			local entityPayload = {}
			payload[`{entityId}`] = entityPayload

			for component, componentData in entityData do
				if table.find(replicatedComponents, component) then
					local name = `{component}`
					local excluded = {}; if EXCLUDED[name] then
						for _index, key in EXCLUDED[name] do
							excluded[key] = Matter.None
						end
					end

					entityPayload[name] = { data = componentData:patch(excluded) }
				end
			end
		end

		print("Sending initial payload to", Player)
		Remotes.MatterRemote:FireClient(Player, payload)
	end

	local payloads: Dictionary<payload> = {}

	for _index, component in mergedReplicatedComponents do
		local isLocalComponent = table.find(localReplicatedComponents, component)

		for entityId, record in world:queryChanged(component) do
			for playerEntityId, PlayerData in world:query(Components.PlayerData) do
				if isLocalComponent and entityId ~= playerEntityId then continue end

				local userId = `{PlayerData.Player.UserId}`
				local payload = payloads[userId] or {} :: payload

				local key = `{entityId}`
				local name = `{component}`

				if payload[key] == nil then
					payload[key] = {}
				end

				if world:contains(entityId) then
					local excluded = {}; if EXCLUDED[name] then
						for _index, key in EXCLUDED[name] do
							excluded[key] = Matter.None
						end
					end

					payload[key][name] = { data = record.new and record.new:patch(excluded) :: any }
				end

				payloads[userId] = payload
			end
		end
	end

	if next(payloads) then
		for userId, payload in payloads do
			local Player = Players:GetPlayerByUserId(tonumber(userId))

			Remotes.MatterRemote:FireClient(Player, payload)
		end
	end
end

return {
	system = replication,
	priority = math.huge,
}
