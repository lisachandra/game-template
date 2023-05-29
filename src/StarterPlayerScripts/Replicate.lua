local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local RemoteEvent = Remotes:WaitForChild("MatterRemote")

local Matter = require(Packages:WaitForChild("Matter"))

local Components = require(Shared:WaitForChild("Components"))
local Rodux = require(Shared:WaitForChild("Rodux"))

type payload = Dictionary<Dictionary<{ data: table }>>

local function Replicate(world: Matter.World, store: Rodux.Store)
	local function debugPrint(...)
		local state: Rodux.ClientState = store:getState()

		if state.debugEnabled then
			print("Replication>", ...)
		end
	end

	local entityIdMap: Dictionary<number> = {}

	RemoteEvent.OnClientEvent:Connect(function(entities: payload)
		for serverEntityId, componentMap in entities do
			local clientEntityId = entityIdMap[serverEntityId]

			if clientEntityId and next(componentMap) == nil then
				world:despawn(clientEntityId)
				entityIdMap[serverEntityId] = nil
				debugPrint(string.format("Despawn %ds%d", clientEntityId, serverEntityId))
				continue
			end

			local componentsToInsert = {}
			local componentsToRemove = {}

			local insertNames: Array<string> = {}
			local removeNames: Array<string> = {}

			for name, container in componentMap do
				if container.data then
					table.insert(componentsToInsert, Components[name](container.data))
					table.insert(insertNames, name)
				else
					table.insert(componentsToRemove, Components[name])
					table.insert(removeNames, name)
				end
			end

			if clientEntityId == nil then
				clientEntityId = world:spawn(unpack(componentsToInsert))

				entityIdMap[serverEntityId] = clientEntityId

				debugPrint(
					string.format("Spawn %ds%d with %s", clientEntityId, serverEntityId, table.concat(insertNames, ","))
				)
			else
				if #componentsToInsert > 0 then
					world:insert(clientEntityId, unpack(componentsToInsert))
				end

				if #componentsToRemove > 0 then
					world:remove(clientEntityId, unpack(componentsToRemove))
				end

				debugPrint(
					string.format(
						"Modify %ds%d adding %s, removing %s",
						clientEntityId,
						serverEntityId,
						if #insertNames > 0 then table.concat(insertNames, ", ") else "nothing",
						if #removeNames > 0 then table.concat(removeNames, ", ") else "nothing"
					)
				)
			end
		end
	end)
end

return Replicate
