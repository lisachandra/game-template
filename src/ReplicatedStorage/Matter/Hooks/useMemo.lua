-- https://github.com/LastTalon/matter-hooks/blob/main/lib/useMemo.lua#L31

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Shared.Matter)
local Sift = require(Packages.Sift)

local function useMemo<T...>(
	callback: () -> T...,
	dependencies: Array<unknown>,
	discriminator: unknown?
): T...
	local storage = Matter.useHookState(discriminator)

	if storage.value == nil or not Sift.Array.equals(dependencies, storage.dependencies) then
		storage.dependencies = dependencies
		storage.value = { callback() }
	end

	return unpack(storage.value)
end

return useMemo
