while true do
    if game:IsLoaded() then break end
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local StarterPlayerScripts = script.Parent

local Start = require(Shared.Start)

local Replicate = require(StarterPlayerScripts:WaitForChild("Replicate"))

for _index, name in { "Packages" } do
    ReplicatedStorage:WaitForChild(name)
end

local world, store = Start(StarterPlayerScripts:WaitForChild("Systems"))
Replicate(world, store)
