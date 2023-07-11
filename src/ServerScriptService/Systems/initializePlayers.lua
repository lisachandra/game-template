local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = script.Parent.Parent

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Hooks = ServerScriptService.Hooks

local Janitor = require(Packages.Janitor)
local Matter = require(Shared.Matter)

local useProfile = require(Hooks.useProfile)

local Components = require(Shared.Components)

local function PlayerAdded(world: Matter.World, player: Player)
    print("initalizing player:", player.Name)

    local janitor = Janitor.new()
    
    local entityId = world:spawn(
        Components.PlayerData({
            Player = player,
            Janitor = janitor,
        } :: Components.PlayerData),

        Components.Server()
    )

    player:SetAttribute("serverEntityId", entityId)
end

local function initializePlayers(world: Matter.World)
    for _index, player: Player in Matter.useEvent(Players, "PlayerAdded") do
        PlayerAdded(world, player)
    end

    for _index, player: Player in Matter.useEvent(Players, "PlayerRemoving") do
        print("removing player:", player.Name)

        local id: number = player:GetAttribute("serverEntityId")
        local PlayerData = world:get(id, Components.PlayerData)

        world:despawn(id)
        PlayerData.Janitor:Destroy()
    end

    for _index, PlayerData in world:query(Components.PlayerData) do
        local profile = useProfile(PlayerData.Player); if profile and not PlayerData.Janitor:Get("Profile") then
            PlayerData.Janitor:Add(profile, "Release", "Profile")
        end
    end
end

return {
    system = initializePlayers,
    priority = 1,
}
