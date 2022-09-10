local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:FindFirstChild("Packages")

local Matter = require(Packages:FindFirstChild("Matter"))

type storage = {
	dependencies: Array<any>?,
}

local function dependenciesDifferent(dependencies, lastDependencies)
	local length = 0

	for index, dependency in dependencies do
		length += 1

		if dependency ~= lastDependencies[index] then
			return true
		end
	end

	for _ in lastDependencies do
		length -= 1
	end

	if length ~= 0 then
		return true
	end

	return false
end

local function cleanup()
	return true
end

local function useDependency(callback: (last: table?, new: table?) -> (), dependencies: table?, discriminator: any?)
	local storage: table = Matter.useHookState(discriminator, cleanup)

	if (storage.dependencies and dependenciesDifferent(dependencies, storage.dependencies)) or storage.dependencies == nil then
		callback(storage.dependencies, dependencies)
	end

	storage.dependencies = dependencies
end

return useDependency
