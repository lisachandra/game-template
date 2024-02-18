-- https://github.com/LastTalon/matter-hooks/blob/main/lib/useReducer.lua#L75

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Shared.Matter)
local Sift = require(Packages.Sift)

local function useReducer<S, A>(
	reducer: (state: S, action: A) -> S,
	initialState: S,
	discriminator: unknown?
): (S, (action: A) -> ())
	local storage = Matter.useHookState(discriminator)

	if storage.state == nil then
		storage.state = initialState
	end

	local dependencies = { storage.state }

	if not Sift.Array.equals(dependencies, storage.dependencies) then
		storage.dependencies = dependencies
		storage.dispatch = function(action: A)
			storage.state = reducer(storage.state, action)
		end
	end

	return storage.state, storage.dispatch
end

return useReducer
