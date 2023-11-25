local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = script.Parent.Parent

local Packages = ReplicatedStorage.Packages

local ProfileService = require(ServerScriptService.ProfileService)
local Promise = require(Packages.Promise)

local LoadProfileAsync = Promise.promisify(function(profile_key: string)
    return ProfileService.Store:LoadProfileAsync(profile_key)
end)

local profiles: Dictionary<storage> = {}

export type ProfileStore = ProfileService.ProfileStore
export type Profile = ProfileService.Profile
export type Data = ProfileService.Data

type storage = {
    profile: ProfileService.Profile?,
    loading: boolean?,
}

local function useProfile(userId: number, Player: Player?): ProfileService.Profile?
    local name = if Player then Player.Name else tostring(userId)
    local discriminator = `Player_{userId}`
    local storage = profiles[discriminator] or {} :: any

    if not storage.loading then
        print("loading profile for Player:", name)

        storage.loading = true
        profiles[discriminator] = storage
        LoadProfileAsync(discriminator):andThen(function(profile: ProfileService.Profile?)
            print("profile", (profile and "loaded for Player:" or "failed to load for Player:"), name)

            storage.profile = profile; if profile then
                print("setting up profile for Player:", name)

                profile:AddUserId(userId)
                profile:Reconcile()
                profile:ListenToRelease(function()
                    print("profile released for:", name)
                    profiles[discriminator] = nil
                end)
            elseif Player then
                Player:Kick("Profile failed to load, please rejoin")
            end    
        end)
    end

    return storage.profile
end

return useProfile
