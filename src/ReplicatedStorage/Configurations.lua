local RunService = game:GetService("RunService")
local ReplicatedStorage = script.Parent.Parent

local ActionManager = require(script.Parent.ActionManager)

local Configurations: Dictionary<any> = {}

local IS_STUDIO = RunService:IsStudio()

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
	return ActionManager.new(getEnums(str))
end

local function setConfig(self, key, value)
	self[key] = if key == "controls" then
		getControls(value)
	elseif type(value) == "string" and value:find("Enum") then 
		getEnums(value)
	else value
end

local function setValue(self, key, value)
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

for _index, Folder: Folder in ReplicatedStorage.Configurations:GetChildren() do
	Configurations[Folder.Name] = {}
	processConfig(Folder, Configurations[Folder.Name])
end

type Configurations = {}

return Configurations :: Configurations
