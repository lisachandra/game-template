local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Server = script.Parent.Parent

local ProfileService = require(Server.ProfileService)
local Matter = require(Shared.Matter)

type storage = {
    profile: ProfileService.Profile?,
    loading: boolean?,
    loaded: boolean?,
}

local function useProfile(player: Player): ProfileService.Profile?
    local discriminator = "Player_" .. tostring(player.UserId)
    local storage = Matter.useHookState(discriminator, function(_storage: storage)
        if player:FindFirstAncestorOfClass("DataModel") then
            return true
        end

        return
    end)

    if not storage.loading then
        print("loading profile for player:", player.Name)

        task.spawn(function()
            storage.loading = true
            storage.profile = ProfileService.Store:LoadProfileAsync(discriminator)
            storage.loaded = true

            print("profile", (storage.profile and "loaded for player:" or "failed to load for player:"), player.Name)
        end)
    elseif storage.loaded then
        if storage.profile then
            print("setting up profile for player:", player.Name)

            storage.profile:AddUserId(player.UserId)
            storage.profile:Reconcile()
        else
            player:Kick("Profile failed to load, please rejoin")
        end
    end

    return storage.profile
end

return useProfile
