local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Server = script.Parent.Parent

local ProfileService = require(Server.ProfileService)
local Promise = require(Packages.Promise)

local LoadProfileAsync = Promise.promisify(function(profile_key: string)
    return ProfileService.Store:LoadProfileAsync(profile_key)
end)

local profiles: Dictionary<storage> = {}

type storage = {
    profile: ProfileService.Profile?,
    loading: boolean?,
}

local function useProfile(player: Player): ProfileService.Profile?
    local discriminator = `Player_{player.UserId}`
    local storage = profiles[discriminator] or {} :: any

    if not storage.loading then
        print("loading profile for player:", player.Name)

        storage.loading = true
        profiles[discriminator] = storage
        LoadProfileAsync(discriminator):andThen(function(profile: ProfileService.Profile?)
            print("profile", (profile and "loaded for player:" or "failed to load for player:"), player.Name)

            storage.profile = profile; if profile then
                print("setting up profile for player:", player.Name)

                profile:AddUserId(player.UserId)
                profile:Reconcile()
                profile:ListenToRelease(function()
                    print("profile released for:", player.Name)
                    profiles[discriminator] = nil
                end)
            else
                player:Kick("Profile failed to load, please rejoin")
            end    
        end)
    end

    return storage.profile
end

return useProfile
