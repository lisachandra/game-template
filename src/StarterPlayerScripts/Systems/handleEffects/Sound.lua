local PlayerScripts = script.Parent.Parent.Parent
local SoundSystem = require(PlayerScripts.SoundSystem)

local function Sound(_world, sound: Sound, location: BasePart?)
    SoundSystem.Play(sound, location)
end

return Sound
