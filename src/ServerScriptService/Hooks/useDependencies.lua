local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Shared.Matter)
local Sift = require(Packages.Sift)

type array = Array<unknown>

type storage = {
	dependencies: array?,
}

local function useDependencies(callback: (old: array?, new: array?) -> (), dependencies: array?, discriminator: string)
	local storage: table = Matter.useHookState(discriminator, function()
		return true
	end)

	if
		((storage.dependencies and dependencies) and not Sift.Array.equals(dependencies, storage.dependencies))
		or (storage.dependencies == nil or dependencies == nil)
	then
		callback(storage.dependencies, dependencies)
	end

	storage.dependencies = dependencies
end

return useDependencies
