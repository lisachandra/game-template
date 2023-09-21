local Packages = script.Parent.Parent.Packages
local Shared = script.Parent

local Janitor = require(Packages.Janitor)
local Matter = require(Shared.Matter)

local COMPONENT_TEMPLATES = table.freeze({})

type Janitor = Janitor.Janitor

type Components = {
	Templates: typeof(COMPONENT_TEMPLATES),

	PlayerData: Matter.Component<PlayerData>,
	Tag: Matter.Component<Tag>,
}

export type Tags = "Player"

export type PlayerData = {
	Player: Player,
	Janitor: Janitor,
}

export type Tag = {
	Value: Tags,
	Component: string,
}

local COMPONENTS = {
	"PlayerData",
	"Tag",
}

local Components = {} :: Components
Components.Templates = COMPONENT_TEMPLATES

for _index, name: string in ipairs(COMPONENTS) do
	Components[name] = Matter.component(name, COMPONENT_TEMPLATES[name] or {})
end

return Components
