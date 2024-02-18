local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shared = ReplicatedStorage.Shared
local Packages = ReplicatedStorage.Packages

local Promise = require(Packages.Promise)
local Sift = require(Packages.Sift)

local Components = require(Shared.Matter.Components)
local Utils = require(Shared.Utils)
local Bridges = require(Shared.Bridges)
local Bridges: Bridges.Bridges<Bridges.ServerBridge> = Bridges

export type humanoid = Utils.humanoid
export type Character = Utils.Character
export type Promise<T> = Utils.Promise<T>

local CyclicUtils = {}

if RunService:IsServer() then
    local useProfile = require(Shared.Matter.Hooks.useProfile)

    function CyclicUtils.WaitForProfile(userId: number): Promise<useProfile.Profile>
        return Promise.new(function(resolve, reject)
            local stamp = os.time()
    
            while true do
                if os.time() - stamp > 120 then
                    reject(); break
                end
    
                local profile = useProfile(userId); if profile then
                    resolve(profile)
                end
    
                task.wait(1)
            end
        end)
    end
end

function CyclicUtils.FireEffect(entityId: number, args: table)
    local world = Utils.GetWorld(entityId)
    local NPCData, PlayerData = world:get(entityId, Components.NPCData, Components.PlayerData)

    if NPCData then
        world:insert(entityId, NPCData:patch({
            Effect = { value = args[1], args = Sift.Array.shift(args), responded = false },
        } :: Components.NPCData<any>))
    elseif PlayerData then
        Bridges.Replication:Fire(PlayerData.Player, args)
    end
end

function CyclicUtils.GetServerEntityId(entityId: number): number
    local world = Utils.GetWorld(entityId); if not world then return nil :: any end
    local NPCData, PlayerData = world:get(entityId, Components.NPCData, Components.PlayerData)
    local Instance = NPCData and NPCData.Model or PlayerData.Player

    return Instance:GetAttribute("serverEntityId")
end

function CyclicUtils.GetNPCHumanoid(entityId: number): humanoid?
    local world = Utils.GetWorld(entityId)
    local NPCData = world and world:get(entityId, Components.NPCData)
    return NPCData and Utils.GetHumanoid(NPCData.Model)
end

return CyclicUtils
