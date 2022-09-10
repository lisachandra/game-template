local Server = script.Parent.Parent.Server

local Components = require(Server:FindFirstChild("Components"))

export type Component<T> = Components.Component<T>
export type PlayerData = Component<Components.PlayerData>

return {}
