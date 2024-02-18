local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local GoodSignal = require(Shared.GoodSignal)
local Janitor = require(Packages.Janitor)
local Matter = require(Shared.Matter)

local COMPONENT_TEMPLATES = table.freeze({})

type Signal<T...> = GoodSignal.Signal<T...>
type Janitor = Janitor.Janitor

type Components = {
	Templates: typeof(COMPONENT_TEMPLATES),

	PlayerData: Matter.Component<PlayerData>,
	NPCData: Matter.Component<NPCData<any>>,
	StateMachines: Matter.Component<StateMachines>,
	Action: Matter.Component<Action>,
	Tag: Matter.Component<Tag>,
}

export type Tags = "Player" | "NPC"

export type PlayerData = {
	Player: Player,
	Janitor: Janitor,
}

export type Tag = {
	Value: Tags,
	Component: string,
}

export type StateMachines = Dictionary<{
	state: unknown,
	context: unknown,
}>

export type Action = {
	value: string,
	responded: boolean,
}

export type NPCData<T> = {
	Effect: { value: string, args: table, responded: boolean }?,

	Model: Model,
	Object: T,
	Janitor: Janitor,
}

local COMPONENTS = {
	"PlayerData",
	"NPCData",
	"StateMachines",
	"Action",
	"Tag",
}

local Components = {} :: Components
Components.Templates = COMPONENT_TEMPLATES

for _index, name: string in ipairs(COMPONENTS) do
	Components[name] = Matter.component(name, COMPONENT_TEMPLATES[name] or {})
end

return Components
