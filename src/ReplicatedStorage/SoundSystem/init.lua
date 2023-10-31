local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = script.Parent.Parent

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local t = require(Packages.t)
local BridgeNet2 = require(Packages.BridgeNet2)

local Bridges = require(Shared.Bridges)
local Bridges: Bridges.Bridges<Bridges.ClientBridge & Bridges.ServerBridge> = Bridges

local playCheck = t.tuple(
    t.instanceIsA("Sound", {}),
    t.optional(t.instanceIsA("BasePart", {}) :: any),
    t.optional(t.boolean :: any),
    t.optional(t.callback :: any)
)

local DynamicSoundHandler = require(script.DynamicSoundHandler)
local SoundSystem = {}

function SoundSystem.Play(sound: Sound, location: BasePart?, useReverb: boolean?, play: ((sound: Sound, play: () -> ()) -> ())?)
    do
        local success, msg = playCheck(sound, location, useReverb, play); if not success then
            warn(msg, debug.traceback()); return
        end
    end

    if location then
        if RunService:IsServer() then
            Bridges.Replication:Fire(BridgeNet2.AllPlayers(), { "Sound", sound, location } :: Array<any>); return
        end

        if useReverb == nil or useReverb then
            local name = `{sound.Parent}_{sound.Name}`
            DynamicSoundHandler:Play(name, location, play)
        else
            sound = sound:Clone()
            sound.PlayOnRemove = true
            sound.Parent = location

            if play then
                play(sound, function()
                    sound:Destroy()
                end)
            else
                sound:Destroy()
            end
        end
    elseif RunService:IsClient() then
        SoundService:PlayLocalSound(sound)
    end
end

return SoundSystem
