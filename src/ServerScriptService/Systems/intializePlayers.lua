local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Hooks = script.Parent.Parent.Hooks

local Janitor = require(Packages.Janitor)
local Matter = require(Shared.Matter)

local useProfile = require(Hooks.useProfile)

local Components = require(Shared.Components)

local function PlayerAdded(world: Matter.World, player: Player)
    print("initalizing player:", player.Name)

    player:SetAttribute("serverEntityId", world:spawn(Components.PlayerData({
        Player = player,
        Janitor = Janitor.new(),
    })))
end

local function initializePlayers(world: Matter.World)
    for _index, player: Player in Matter.useEvent(Players, "PlayerAdded") do
        PlayerAdded(world, player)
    end

    for _index, player: Player in Matter.useEvent(Players, "PlayerRemoving") do
        print("removing player:", player.Name)

        local id: number = player:GetAttribute("serverEntityId")
        local PlayerData = world:get(id, Components.PlayerData)

        PlayerData.Janitor:Destroy()
        world:despawn(id)
    end

    for _index, player: Player in Players:GetPlayers() do
        local id: number = player:GetAttribute("serverEntityId"); if id then
            local profile = useProfile(player)
            local PlayerData = profile and world:get(id, Components.PlayerData); if PlayerData then
                PlayerData.Janitor:Add(profile, "Release", "Profile")
            end
        else
            PlayerAdded(world, player)
        end
    end
end

return initializePlayers
