local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Animations = ReplicatedStorage.Animations
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Promise = require(Packages.Promise)
local Janitor = require(Packages.Janitor)
local Matter = require(Shared.Matter)

local Components = require(Shared.Components)
local Bridges = require(Shared.Bridges)
local Bridges: Bridges.Bridges<Bridges.ServerBridge> = Bridges

local IS_STUDIO = RunService:IsStudio()
local ANIMATION_IDS = {}

local LOAD_TIMEOUT = 60

for _index, Animation in Animations:GetDescendants() do
    if Animation:IsA("Animation") then
        table.insert(ANIMATION_IDS, Animation.AnimationId)
    end
end

local function WaitForPlayerLoaded(Player: Player)
    return Promise.new(function(resolve, reject)
        local connection: RBXScriptConnection = Bridges.MatterReplication:Connect(function(player: Player, loaded)
            if Player == player and type(loaded) == "boolean" then
                resolve()
            end
        end) :: any

        task.delay(LOAD_TIMEOUT, function()
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
        if isEmailVerified then
            local janitor = Janitor.new()

            local entityId = world:spawn(Components.Tag({
                Value = "Player",
                Component = "PlayerData",
            }))
            
            Player:SetAttribute("serverEntityId", entityId)

            WaitForPlayerLoaded(Player):andThen(function()
                print("spawning player:", Player.Name)

                world:insert(entityId,
                    Components.PlayerData({
                        Player = Player,
                        Janitor = janitor,
                    } :: Components.PlayerData)
                )
            end):catch(function()
                Player:Kick("Load timeout, please rejoin and try again!")
            end)
        else
            Player:Kick("Please verify your email to play!")
        end
    end)
end

local function initializePlayers(world: Matter.World)
    for _index, Player: Player in Matter.useEvent(Players, "PlayerAdded") do
        PlayerAdded(world, Player)
    end

    for _index, Player: Player in Matter.useEvent(Players, "PlayerRemoving") do
        print("removing Player:", Player.Name)

        local entityId: number? = Player:GetAttribute("serverEntityId"); if entityId then
            local PlayerData = world:get(entityId, Components.PlayerData)

            world:despawn(entityId)
            PlayerData.Janitor:Destroy()
        end
    end
end

return {
    system = initializePlayers,
    priority = 1,
}
