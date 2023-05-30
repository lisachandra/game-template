local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local ProfileService: ProfileService = require(Packages.ProfileService) :: any

local ProfileStore = ProfileService.GetProfileStore("game-template", ({} :: any) :: Data)

export type ProfileStore = typeof(ProfileStore)
export type Profile = typeof(ProfileStore:LoadProfileAsync(""))
export type Data = {}

return {
    Service = ProfileService,
    Store = ProfileStore :: ProfileStore,
}
