local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared

local Start = require(Shared.Matter.Start)

require(Shared.Bridges)
require(Shared.APIDump)
Start(script.Parent.Systems)
