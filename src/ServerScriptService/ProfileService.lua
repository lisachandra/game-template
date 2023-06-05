local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local ProfileService: ProfileService = require(Packages.ProfileService) :: any

export type Data = {}

local ProfileStore = ProfileService.GetProfileStore("PlayerData", ({} :: any) :: Data)

export type ProfileStore = typeof(ProfileStore)
export type Profile = typeof(ProfileStore:LoadProfileAsync(""))

return {
    Service = ProfileService,
    Store = ProfileStore :: ProfileStore,
}
