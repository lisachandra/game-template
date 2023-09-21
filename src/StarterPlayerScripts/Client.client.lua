if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = script.Parent

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Roact: Roact = require(Packages.Roact) :: any

local Start = require(Shared.Start)
local Bridges = require(Shared.Bridges)
local Bridges: Bridges.Bridges<Bridges.ClientBridge> = Bridges

local Replicate = require(StarterPlayerScripts:WaitForChild("Replicate"))

for _index, name in { "Configurations", "Animations", "Sounds", "UITemplates" } do
    ReplicatedStorage:WaitForChild(name)
end

while true do
    if LocalPlayer:GetAttribute("serverEntityId") then
        break
    end

    task.wait(1)
end

Bridges.MatterReplication:Fire(true)

local world, store = Start(StarterPlayerScripts:WaitForChild("Systems"))
Replicate(world, store)

while true do
    if LocalPlayer:GetAttribute("clientEntityId") then
        break
    end

    task.wait(1)
end

--[[Roact.mount(Roact.createElement(require(StarterPlayerScripts.App), {
    entityId = LocalPlayer:GetAttribute("clientEntityId"),
    world = world,
    store = store,
}), PlayerGui, "App")]]
