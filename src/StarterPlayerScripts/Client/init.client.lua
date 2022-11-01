local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:FindFirstChild("Packages")

local Promise = require(Packages:FindFirstChild("Promise"))
local ReplicaController = require(Packages:FindFirstChild("ReplicaService"))

local Player = Players.LocalPlayer
if not Player.Character then
	Player.CharacterAdded:Wait()
end

local systems = {}
local modules = script.Systems:GetChildren()

local function merge(a, b, none)
	local new = table.clone(a)
	for k, v in b do
		if none ~= nil and v == none then
			new[k] = nil
		end

		new[k] = v
	end

	return new
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
