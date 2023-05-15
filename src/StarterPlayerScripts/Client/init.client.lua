--!nonstrict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:FindFirstChild("Packages")

local Promise = require(Packages:FindFirstChild("Promise"))
local ReplicaController = require(Packages:FindFirstChild("ReplicaService"))

local Player = Players.LocalPlayer
if not Player.Character then
	Player.CharacterAdded:Wait()
end

local systems: { system } = {}
local modules: { ModuleScript } = script.Systems:GetChildren()

type system = {
	priority: number,
	run: () -> boolean,
	name: string,
}

local function merge<A, B>(a: A, b: B, none: any?): A & B
	assert(type(a) == "table")
	assert(type(b) == "table")

	local new = table.clone(a)
	for k, v in b do
		if none ~= nil and v == none then
			new[k] = nil
		end

		new[k] = v
	end

	return new :: any
end

for _index, module in modules do
	table.insert(systems, merge(require(module), { name = module.Name }))
end

table.sort(systems, function(systemA, systemB)
	return systemA.priority < systemB.priority
end)

for _i, system in ipairs(systems) do
	local success, err = Promise.try(system.run):await()
	if not success then
		error("Error in system: " .. system.name .. "\n" .. tostring(err))
	end
end

ReplicaController.RequestData()
