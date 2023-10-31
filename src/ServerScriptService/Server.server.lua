local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local Start = require(Shared.Start)

require(Shared.Bridges)
require(Shared.ReactTemplate)
Start(script.Parent.Systems)
