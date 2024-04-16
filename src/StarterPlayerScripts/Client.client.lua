if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PlayerScripts = script.Parent

_G.__DEV__ = RunService:IsStudio()
_G.__COMPAT_WARNINGS__ = RunService:IsStudio()
_G.__TEST__ = false

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)

local Start = require(Shared.Matter.Start)
local Bridges = require(Shared.Bridges)
local Bridges: Bridges.Bridges<Bridges.ClientBridge> = Bridges

local Replicate = require(PlayerScripts:WaitForChild("Replicate"))

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

local world, store = Start(PlayerScripts:WaitForChild("Systems"))
Replicate(world, store)

while true do
    if LocalPlayer:GetAttribute("clientEntityId") then
        break
    end

    task.wait(1)
end

local App = require(PlayerScripts.App)

ReactRoblox.createRoot(Instance.new("Folder"))
    :render(ReactRoblox.createPortal(React.createElement(
        App.render, {
            world = world,
            entityId = LocalPlayer:GetAttribute("clientEntityId"),
        } :: App.Context
    ), PlayerGui))
