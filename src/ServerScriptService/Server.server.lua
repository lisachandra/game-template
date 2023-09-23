local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Start = require(Shared.Start)

require(Shared.Bridges)
require(Packages.ReactTemplate)
Start(script.Parent.Systems)
