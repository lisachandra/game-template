local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local t = require(Packages.t)

local playCheck = t.tuple(
    t.instanceIsA("Sound", {}),
    t.optional(t.instanceIsA("BasePart", {}) :: any),
    t.optional(t.boolean :: any),
    t.optional(t.callback :: any)
)

local DynamicSoundHandler = require(script.DynamicSoundHandler)

local SoundSystem = {}

function SoundSystem.Play(sound: Sound, location: BasePart?, useReverb: boolean?, play: ((sound: Sound, play: () -> ()) -> ())?)
    local success, msg = playCheck(sound, location, useReverb, play); if not success then
        warn(msg, debug.traceback()); return
    end

    if location then
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
    else
        SoundService:PlayLocalSound(sound)
    end
end

return SoundSystem
