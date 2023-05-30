local Packages = script.Parent.Parent.Packages
local Shared = script.Parent

local Janitor = require(Packages.Janitor)
local Matter = require(Shared.Matter)

type Janitor = Janitor.Janitor

type Components = {
	PlayerData: Matter.Component<PlayerData>,
}

type PlayerData = {
	Player: Player,
	Janitor: Janitor,
}

local COMPONENTS = {
	"PlayerData",
}

local Components: Components = {} :: Components

for _index, name in COMPONENTS do
	Components[name] = Matter.component(name) :: any
end

return Components
