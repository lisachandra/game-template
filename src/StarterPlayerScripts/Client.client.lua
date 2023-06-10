local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local StarterPlayerScripts = script.Parent

local Start = require(Shared.Start)

local Replicate = require(StarterPlayerScripts.Replicate)

local world, store = Start(StarterPlayerScripts.Systems)
Replicate(world, store)
