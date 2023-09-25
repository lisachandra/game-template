local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local React = require(Packages.React)
local Matter = require(Shared.Matter)

export type context = {
    world: Matter.World,
    entityId: number,
    scale: React.Binding<number>,
}

return React.createContext({} :: context)
