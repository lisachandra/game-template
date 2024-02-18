local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = script.Parent.Parent

local Animations = ReplicatedStorage.Animations
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local ProfileService = require(ServerScriptService.ProfileService)
local Promise = require(Packages.Promise)
local Janitor = require(Packages.Janitor)
local Matter = require(Shared.Matter)

local useProfile = require(Shared.Matter.Hooks.useProfile)

local Components = require(Shared.Matter.Components)
local Utils = require(Shared.Utils)
local Bridges = require(Shared.Bridges)
local Bridges: Bridges.Bridges<Bridges.ServerBridge> = Bridges

local LOAD_TIMEOUT = 60
local IS_STUDIO = RunService:IsStudio()
local ANIMATION_IDS = {}

type Humanoid = Utils.humanoid

for _index, Animation in Animations:GetDescendants() do
    if Animation:IsA("Animation") then
        table.insert(ANIMATION_IDS, Animation.AnimationId)
    end
end

local function WaitForPlayerLoaded(Player: Player)
    return Promise.new(function(resolve, reject)
        local disconnected = false
        local connection: RBXScriptConnection = Bridges.MatterReplication:Connect(function(player: Player, loaded)
            if Player == player and type(loaded) == "boolean" then
                while true do
                    if disconnected then break end

                    local profile = useProfile(Player.UserId, Player); if profile then
                        resolve(profile); break
                    end

                    task.wait(1)
                end
            end
        end) :: any

        task.delay(LOAD_TIMEOUT, function()
            disconnected = true
            connection:Disconnect()
            reject()
        end)
    end)
end

local function PlayerOwnsAsset(Player: Player, assetId: number)
    return IS_STUDIO and Promise.resolve(true) or Promise.new(function(resolve)
        resolve(MarketplaceService:PlayerOwnsAsset(Player, assetId))
    end)
end

local function PlayerAdded(world: Matter.World, Player: Player)
    print("initalizing player:", Player.Name)

    PlayerOwnsAsset(Player, 102611803):andThen(function(isEmailVerified)
        if not isEmailVerified then
            Player:Kick("Please verify your email to play!"); return
        end

        local janitor = Janitor.new()

        local entityId = world:spawn(Components.Tag({
            Value = "Player",
            Component = "PlayerData",
        }))
        
        Player:SetAttribute("serverEntityId", entityId)

        WaitForPlayerLoaded(Player):andThen(function(profile: ProfileService.Profile)
            print("spawning player:", Player.Name)

            janitor:Add(profile, "Release", "Profile")
            world:insert(entityId,
                Components.PlayerData({
                    Player = Player,
                    Janitor = janitor,
                } :: Components.PlayerData),

                Components.Action({
                    value = "",
                    responded = true,
                } :: Components.Action),

                Components.StateMachines()
            )
        end):catch(function()
            Player:Kick("Load timeout, please rejoin and try again!")
        end)
    end)
end

local function initializePlayers(world: Matter.World)
    for _index, Player: Player in Matter.useEvent(Players, "PlayerAdded") do
        PlayerAdded(world, Player)
    end

    for _index, Player: Player in Matter.useEvent(Players, "PlayerRemoving") do
        print("removing Player:", Player.Name)

        local entityId: number? = Player:GetAttribute("serverEntityId"); if entityId and world:contains(entityId) then
            local PlayerData = world:get(entityId, Components.PlayerData); 
            
            world:despawn(entityId)
            
            if PlayerData then
                PlayerData.Janitor:Destroy()
            end
        end
    end
end

return {
    system = initializePlayers,
    priority = 1,
}
