-- https://github.com/LastTalon/matter-hooks/blob/main/lib/useChange.lua#L23

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Shared.Matter)
local Sift = require(Packages.Sift)

local function useChange(dependencies: { unknown }, discriminator: unknown?): boolean
	local storage = Matter.useHookState(discriminator)
	local previous = storage.dependencies
	storage.dependencies = dependencies
	
	return not Sift.Array.equals(dependencies, previous)
end

return useChange
