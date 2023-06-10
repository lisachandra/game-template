local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes
local Shared = ReplicatedStorage.Shared

local MatterRemote: RemoteEvent = Remotes.MatterRemote

local Matter = require(Shared.Matter)
local Rodux = require(Shared.Rodux)

local Components = require(Shared.Components)

type payload = Dictionary<Dictionary<{ data: table }>>

local function Replicate(world: Matter.World, store: Rodux.Store)
	local function debugPrint(...)
		local state: Rodux.ClientState = store.getState(store :: any)

		if state.debugEnabled then
			print("Replication>", ...)
		end
	end

	local entityIdMap: Dictionary<number> = {}

	MatterRemote.OnClientEvent:Connect(function(entities: payload)
		for serverEntityId, componentMap in entities do
			local clientEntityId = entityIdMap[serverEntityId]

			if clientEntityId and next(componentMap) == nil then
				world:despawn(clientEntityId)
				entityIdMap[serverEntityId] = nil
				debugPrint(`Despawn {clientEntityId}s{serverEntityId}`)

				continue
			end

			local componentsToInsert: Array<Matter.ComponentInstance<any>> = {}
			local componentsToRemove: Array<Matter.Component<any>> = {}

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

				debugPrint(`Spawn {clientEntityId}s{serverEntityId} with {table.concat(insertNames, ",")}`)
			else
				if #componentsToInsert > 0 then
					world:insert(clientEntityId, unpack(componentsToInsert))
				end

				if #componentsToRemove > 0 then
					world:remove(clientEntityId, unpack(componentsToRemove))
				end

				debugPrint(`Modify {clientEntityId}s{serverEntityId} adding {
					if #insertNames > 0 then table.concat(insertNames, ", ") else "nothing"
				}, removing {
					if #removeNames > 0 then table.concat(removeNames, ", ") else "nothing"
				}`)
			end
		end
	end)
end

return Replicate
