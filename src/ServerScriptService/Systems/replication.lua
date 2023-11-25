local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Packages = ReplicatedStorage.Packages

local BridgeNet2 = require(Packages.BridgeNet2)
local Matter = require(Shared.Matter)
local Sift = require(Packages.Sift)

local Components = require(Shared.Components)
local Bridges = require(Shared.Bridges)
local Bridges: Bridges.Bridges<Bridges.ServerBridge> = Bridges

local REPLICATED_COMPONENTS = {
	"PlayerData",
	"Tag",
}

local LOCAL_REPLICATED_COMPONENTS = {}

local EXCLUDED = {
	PlayerData = {
		"Janitor",
	},
}

local NONE = HttpService:GenerateGUID(false)
local TIME_REPLICATE = 0.3

local replicatedComponents: Array<Matter.Component<any>> = {}
local localReplicatedComponents: Array<Matter.Component<any>> = {}

for _index, name in ipairs(REPLICATED_COMPONENTS) do
	table.insert(replicatedComponents, Components[name])
end

for _index, name in ipairs(LOCAL_REPLICATED_COMPONENTS) do
	table.insert(localReplicatedComponents, Components[name])
end

local mergedReplicatedComponents = Sift.Array.push(replicatedComponents, table.unpack(localReplicatedComponents))
local hasReceived: Array<Player> = {}

type payload = Dictionary<Dictionary<{ data: table? }>>

local function dictionaryDifference(old, new, none): table
	local difference = {}; for key, value in old do
		if value ~= new[key] then
			difference[key] = if new[key] == nil then none else new[key]
		end
	end

	return difference
end

local function replication(world: Matter.World)
	local payloads: Map<Player, payload> = {}
	local initialized: Array<Player> = {}

	if Matter.useThrottle(TIME_REPLICATE) then
		Bridges.Time:Fire(BridgeNet2.AllPlayers(), { os.clock() } :: table)
	end

	for entityId, PlayerData in world:query(Components.PlayerData) do
		if not table.find(hasReceived, PlayerData.Player) then
			Bridges.MatterReplication:Fire(PlayerData.Player, { {}, NONE })

			table.insert(hasReceived, PlayerData.Player)
			table.insert(initialized, PlayerData.Player)

			PlayerData.Janitor:Add(function()
				local index = table.find(hasReceived, PlayerData.Player); if index then
					table.remove(hasReceived, index)
				end
			end)
			
			for _index, component in mergedReplicatedComponents do
				local isLocalComponent = table.find(localReplicatedComponents, component)
				local name = `{component}`

				for playerEntityId, _PlayerData in world:query(Components.PlayerData) do
					if isLocalComponent and entityId ~= playerEntityId then continue end

					local key = `{playerEntityId}`
					local payload = payloads[PlayerData.Player] or {} :: payload
					local component = world:get(playerEntityId, component)

					if payload[key] == nil then
						payload[key] = {}
					end

					local excluded = {}; if EXCLUDED[name] then
						for _index, key in EXCLUDED[name] do
							excluded[key] = Matter.None
						end
					end

					payload[key][name] = { data = component:patch(excluded) }
					payloads[PlayerData.Player] = payload
				end
			end
		end
	end

	for _index, component in mergedReplicatedComponents do
		local isLocalComponent = table.find(localReplicatedComponents, component)
		local name = `{component}`

		for entityId, record in world:queryChanged(component) do
			if world:contains(entityId) then
				local Tag = world:get(entityId, Components.Tag)
				local Component = Tag and world:get(entityId, Components[Tag.Component])

				if not Component then
					continue
				end
			end

			for playerEntityId, PlayerData in world:query(Components.PlayerData) do
				if table.find(initialized, PlayerData.Player) or
					(isLocalComponent and entityId ~= playerEntityId)
				then continue end

				local payload = payloads[PlayerData.Player] or {} :: payload
				local key = `{entityId}`

				if payload[key] == nil then
					payload[key] = {}
				end

				if record.new then
					local excluded = {}; if EXCLUDED[name] then
						for _index, key in EXCLUDED[name] do
							excluded[key] = Matter.None
						end
					end

					payload[key][name] = if record.old then {
						data = dictionaryDifference(record.old, record.new:patch(excluded), NONE),
					} else { data = record.new:patch(excluded) }
				else
					payload[key][name] = {}
				end

				payloads[PlayerData.Player] = payload
			end
		end
	end

	if next(payloads) then
		for Player, payload in payloads do
			if table.find(initialized, Player) then
				print("sending initial payload to:", Player, payload)
			end

			Bridges.MatterReplication:Fire(Player, { payload })
		end
	end
end

return {
	system = replication,
	priority = math.huge,
}
