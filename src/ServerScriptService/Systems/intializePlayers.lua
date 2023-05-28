local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Janitor = require(Packages.Janitor)
local Matter = require(Packages.Matter)

local Components = require(Shared.Components)
local ComponentTypes = require(Shared.ComponentTypes)

local function initializePlayers(world: Matter.World)
    for _index, player: Player in Matter.useEvent(Players, "PlayerAdded") do
        player:SetAttribute("serverEntityId", world:spawn(Components.PlayerData({
            Player = player,
            Janitor = Janitor.new(),
        })))
    end

    for _index, player: Player in Matter.useEvent(Players, "PlayerRemoving") do
        local id: number = player:GetAttribute("serverEntityId") 
        local PlayerData: ComponentTypes.PlayerData = world:get(id, Components.PlayerData)

        PlayerData.Janitor:Destroy()
        world:despawn(id)
    end
end

return initializePlayers
