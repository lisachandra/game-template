local Packages = script.Parent.Parent.Packages
local Shared = script.Parent

local Janitor = require(Packages.Janitor)
local Matter = require(Shared.Matter)

local COMPONENT_TEMPLATES = table.freeze({})

type Janitor = Janitor.Janitor

type Components = {
	Templates: typeof(COMPONENT_TEMPLATES),

	PlayerData: Matter.Component<PlayerData>,
}

type PlayerData = {
	Player: Player,
	Janitor: Janitor,
}

local COMPONENTS = {
	"PlayerData",
}

local Components = {} :: Components
Components.Templates = COMPONENT_TEMPLATES

for _index, name in COMPONENTS do
	Components[name] = Matter.component(name, COMPONENT_TEMPLATES[name] or {})
end

return Components
