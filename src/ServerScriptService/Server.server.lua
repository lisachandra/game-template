local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Start = require(Shared.Start)

require(Packages.RoactTemplate)
Start(script.Parent.Systems)
