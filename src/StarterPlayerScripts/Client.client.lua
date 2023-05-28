local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local Start = require(Shared:WaitForChild("Start"))

local Replicate = require(script.Parent.Replicate)

local world, store = Start(script.Parent.Systems)
Replicate(world, store)
