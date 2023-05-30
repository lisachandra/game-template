local Packages = script.Parent.Parent.Packages

local Matter: Matter = require(Packages.Matter) :: any

export type World = typeof(Matter.World.new())
export type Loop = typeof(Matter.Loop.new())
export type Component<T> = typeof(Matter.component(nil, (nil :: any) :: T))
export type ComponentInstance<T> = typeof(((nil :: any) :: Component<T>)())

return Matter
