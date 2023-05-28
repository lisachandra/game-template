local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Matter = require(Packages.Matter)
local Sift = require(Packages.Sift)

type storage = {
	dependencies: Array<any>?,
}

local function useDependency(callback: (last: Array<any>?, new: Array<any>?) -> (), dependencies: Array<any>?, discriminator: string)
	local storage: table = Matter.useHookState(discriminator, function()
		return true
	end)

	if
		((storage.dependencies and dependencies) and Sift.Array.equals(dependencies, storage.dependencies))
		or (storage.dependencies == nil or dependencies == nil)
	then
		callback(storage.dependencies, dependencies)
	end

	storage.dependencies = dependencies
end

return useDependency
