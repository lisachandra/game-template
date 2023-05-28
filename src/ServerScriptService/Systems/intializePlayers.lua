local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Janitor = require(Packages.Janitor)
local Matter = require(Packages.Matter)

local Components = require(Shared.Components)
local Types = require(Shared.Types)

local function initializePlayers(world)
    for _index, player: Player in Matter.useEvent(Players, "PlayerAdded") do
        player:SetAttribute("serverEntityId", world:spawn(Components.PlayerData({
            Player = player,
            Janitor = Janitor.new(),
        })))
    end

    for _index, player: Player in Matter.useEvent(Players, "PlayerRemoving") do
        local id: number = player:GetAttribute("serverEntityId") 
        local PlayerData: Types.PlayerData = world:get(id, Components.PlayerData)

        PlayerData.Janitor:Destroy()
        world:despawn(id)
    end
end

return initializePlayers
