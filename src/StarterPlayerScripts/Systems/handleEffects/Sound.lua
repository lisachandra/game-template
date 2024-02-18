local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local SoundSystem = require(Shared.SoundSystem)

local function Sound(_world, sound: Sound, location: BasePart?)
    SoundSystem.Play(sound, location)
end

return Sound
