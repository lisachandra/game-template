local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestEZ = require(ReplicatedStorage.TestEZ)

TestEZ.TestBootstrap:run({ ReplicatedStorage.RoactRouter }, TestEZ.Reporters.TextReporter)