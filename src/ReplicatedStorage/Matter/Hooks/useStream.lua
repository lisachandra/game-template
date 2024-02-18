-- https://github.com/LastTalon/matter-hooks/blob/main/lib/useStream.lua#L170

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Shared.Matter)
local Sift = require(Packages.Sift)

export type StreamOptions = {
	descendants: boolean?,
	attribute: string?,
}

export type StreamInEvent = {
	adding: true,
	removing: false,
	descendant: boolean,
	instance: Instance,
}

export type StreamOutEvent = {
	adding: false,
	removing: true,
	descendant: boolean,
	instance: Instance,
}

export type StreamEvent = StreamInEvent | StreamOutEvent

local function streamInEvent(instance: Instance, descendant: boolean?): StreamInEvent
	return {
		adding = true,
		removing = false,
		descendant = if descendant ~= nil then descendant else false,
		instance = instance,
	}
end

local function streamOutEvent(instance: Instance, descendant: boolean?): StreamOutEvent
	return {
		adding = false,
		removing = true,
		descendant = if descendant ~= nil then descendant else false,
		instance = instance,
	}
end

type NormalizedOptions = {
	descendants: boolean,
	attribute: string,
}

local function normalizeOptions(options: StreamOptions?): NormalizedOptions
	return {
		descendants = if options and options.descendants ~= nil then options.descendants else false,
		attribute = if options and options.attribute then options.attribute else "serverEntityId",
	}
end

local function cleanup(storage)
	storage.addedConnection:Disconnect()
	storage.removingConnection:Disconnect()
	for _, connections in storage.trackedInstances do
		connections.addedConnection:Disconnect()
		connections.removingConnection:Disconnect()
	end
end

local function useStream(id: unknown, options: StreamOptions?): () -> (number?, StreamEvent)
	local storage = Matter.useHookState(id, cleanup)

	if not storage.queue then
		local options = normalizeOptions(options)
		storage.queue = {} :: Array<StreamEvent>
		storage.trackedInstances = {}

		storage.addedConnection = workspace.DescendantAdded:Connect(function(instance: Instance)
			if instance:GetAttribute(options.attribute) ~= id then
				return
			end

			Sift.Array.push(storage.queue, streamInEvent(instance))

			if not options.descendants then
				return
			end
			if storage.trackedInstances[instance] then
				return
			end

			storage.trackedInstances[instance] = {
				addedConnection = instance.DescendantAdded:Connect(function(instance: Instance)
					Sift.Array.push(storage.queue, streamInEvent(instance, true))
				end),

				removingConnection = instance.DescendantRemoving:Connect(
					function(instance: Instance)
						Sift.Array.push(storage.queue, streamOutEvent(instance, true))
					end
				),
			}

			for _, descendant in instance:GetDescendants() do
				Sift.Array.push(storage.queue, streamInEvent(descendant, true))
			end
		end)

		storage.removingConnection = workspace.DescendantRemoving:Connect(
			function(instance: Instance)
				if instance:GetAttribute(options.attribute) ~= id then
					return
				end

				Sift.Array.push(storage.queue, streamOutEvent(instance))

				if not options.descendants then
					return
				end

				for _, descendant in instance:GetDescendants() do
					Sift.Array.push(storage.queue, streamOutEvent(descendant, true))
				end

				local connections = storage.trackedInstances[instance]
				if not connections then
					return
				end

				connections.addedConnection:Disconnect()
				connections.removingConnection:Disconnect()
			end
		)
	end

	local index = 0
	return function(): (number?, StreamEvent)
		index += 1

        local value = storage.queue[1]
		storage.queue = Sift.Array.shift(storage.queue)

		if value then
			return index, value
        end
		return nil, (nil :: unknown) :: StreamEvent
	end
end

return useStream
