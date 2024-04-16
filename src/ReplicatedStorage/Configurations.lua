local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local React = require(Packages.React)
local GoodSignal = require(Shared.GoodSignal)
local ActionManager = require(StarterPlayerScripts.ActionManager)

local Configurations: Dictionary<any> = {}

local IS_RUNNING = RunService:IsRunMode()
local IS_STUDIO = RunService:IsStudio()
local IS_CLIENT = RunService:IsClient()

local changed: GoodSignal.Signal<string, any> = GoodSignal.new()

--HACK: tricking the dumbass typechecker
if IS_CLIENT and (IS_STUDIO and IS_RUNNING or not IS_STUDIO) then
	ActionManager = require(Players.LocalPlayer.PlayerScripts:WaitForChild("ActionManager")) :: any
end

local function getEnum(str: string)
	local paths = str:split(".")
	local input = Enum :: any

	for _index, path in paths do
		if path == "Enum" then
			continue
		end

		input = (input :: any)[path]
	end

	return input
end

local function getEnums(str: string)
	local keys = str:gsub("%s", ""):split(",")
	local enums = {}

	for _index, key in keys do
		table.insert(enums, getEnum(key))
	end

	return enums
end

local function getControls(str: string)
	return IS_CLIENT and ActionManager.new(getEnums(str)) or str
end

local function setConfig(self, key, value)
	changed:Fire(`{self}_{key}`, value)
	self[key] = if key == "controls" then
		getControls(value)
	elseif type(value) == "string" and value:find("Enum") then 
		getEnums(value)
	else value
end

local function setValue(self, key, value)
	changed:Fire(`{self}_{key}`, value)
	self[key] = if type(value) == "string" and value:find("Enum") then 
		getEnums(value)
	else value
end

local function processConfig(Folder: Folder, Storage: table)
	for _index, Configuration in Folder:GetChildren() do
		if Configuration:IsA("Configuration") then
			Storage[Configuration.Name] = {}

			if IS_STUDIO then
				Configuration.AttributeChanged:Connect(function(key)
					setConfig(Storage[Configuration.Name], key, Configuration:GetAttribute(key))
				end)
			end

			for key, value in Configuration:GetAttributes() do
				setConfig(Storage[Configuration.Name], key, value)
			end
		elseif Configuration:IsA("ValueBase") then
			local Configuration: ValueBase & { Value: any } = Configuration :: any
			setValue(Storage, Configuration.Name, Configuration.Value)

			if IS_STUDIO then
				Configuration:GetPropertyChangedSignal("Value"):Connect(function()
					setValue(Storage, Configuration.Name, Configuration.Value)
				end)
			end
		elseif Configuration:IsA("Folder") then
			Storage[Configuration.Name] = {}
			processConfig(Configuration, Storage[Configuration.Name])
		end
	end
end

local function useState(self: table, key: string)
	local value, setValue = React.useState(self[key])
	local hookKey = `{self}_{key}`

	React.useEffect(function()
		local connection = changed:Connect(function(keyString: string, newValue)
			if keyString == hookKey then
				setValue(newValue)
			end
		end)

		return function()
			connection:Disconnect()
		end
	end, { hookKey })

	return value
end

for _index, Folder: Folder in ReplicatedStorage.Configurations:GetChildren() do
	Configurations[Folder.Name] = {}
	processConfig(Folder, Configurations[Folder.Name])
end

export type Configurations = {}

return setmetatable(Configurations :: Configurations, {
	__index = {
		useState = useState,
		_changed = changed,
	},
})
