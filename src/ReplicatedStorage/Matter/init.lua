local Packages = script.Parent.Parent.Packages

local Matter: Matter = require(Packages.Matter) :: any

export type World = typeof(Matter.World.new())
export type Loop = typeof(Matter.Loop.new())
export type Component<T> = typeof(Matter.component("", (nil :: unknown) :: T))
export type ComponentInstance<T> = typeof(((nil :: unknown) :: Component<T>)())

export type ChangeRecord<T> = {
    old: ComponentInstance<T>?,
    new: ComponentInstance<T>?,
}

return Matter
