local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:FindFirstChild("Packages")

local Janitor = require(Packages:FindFirstChild("Janitor"))
local Matter = require(Packages:FindFirstChild("Matter"))

type Janitor = Janitor.Janitor

type Components = {
	PlayerData: new<PlayerData>,
}

export type Component<T> = {
	patch: (self: any, newData: table) -> Component<T>,
} & T

export type PlayerData = {
	Player: Player,
	Janitor: Janitor,
}

type new<T> = (data: T?) -> Component<T>

local COMPONENTS = {
	"PlayerData",
}

local Components: Components = {} :: Components

for _, name in COMPONENTS do
	Components[name] = Matter.component(name) :: any
end

return Components
