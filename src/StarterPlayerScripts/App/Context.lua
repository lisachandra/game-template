local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local React = require(Packages.React)
local Matter = require(Shared.Matter)
local Rodux = require(Shared.Rodux)

export type context = {
    world: Matter.World,
    store: Rodux.Store,
    entityId: number,
    scale: React.Binding<number>,
}

return React.createContext({} :: context)
