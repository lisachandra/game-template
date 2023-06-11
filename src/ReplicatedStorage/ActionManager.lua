local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = script.Parent.Parent

local Packages = ReplicatedStorage.Packages

local GoodSignal = require(script.Parent.GoodSignal)
local Sift = require(Packages.Sift)

local IS_CLIENT = RunService:IsClient()

local Array = Sift.Array

local inputs: Array<Control> = {}

local ActionManager = {}
ActionManager.__index = ActionManager

ActionManager.pressed = {} :: Array<string>
ActionManager._actions = {} :: Dictionary<Controls>
ActionManager._actionPressed = GoodSignal.new() :: GoodSignal.Signal<string, boolean>

local function getControls()
    local controlsPressed: Array<string> = {}

    for guid, controls in ActionManager._actions do
        if Array.every(controls, function(enum)
            return Array.includes(inputs, enum)
        end) then
            table.insert(controlsPressed, guid)
        end
    end

    return controlsPressed
end

function ActionManager.new(controls: Controls)
    if IS_CLIENT then
        local GUID = HttpService:GenerateGUID(false)
        ActionManager._actions[GUID] = controls

        return setmetatable({
            guid = GUID,
        }, ActionManager)
    end

    return controls :: any
end

function ActionManager:Connect(callback: (began: boolean) -> ())
    return ActionManager._actionPressed:Connect(function(guid, began)
        if guid == self.guid then
            callback(began)
        end
    end)
end

if IS_CLIENT then
    UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
        if gameProcessedEvent or
            input.KeyCode == Enum.KeyCode.Unknown or
            input.UserInputType == Enum.UserInputType.None
        then return end
    
        local inputValue = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or
            input.UserInputType ~= Enum.UserInputType.None and input.UserInputType
    
        if inputValue then
            table.insert(inputs, inputValue)
    
            local controlsPressed = getControls(); if #controlsPressed > 0 then
                controlsPressed = Array.removeValues(controlsPressed, table.unpack(ActionManager.pressed))
                ActionManager.pressed = Array.push(ActionManager.pressed, table.unpack(controlsPressed))
    
                for _index, guid in controlsPressed do
                    ActionManager._actionPressed:Fire(guid, true)
                end
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input: InputObject, _gameProcessedEvent: boolean)
        if input.KeyCode == Enum.KeyCode.Unknown or
            input.UserInputType == Enum.UserInputType.None
        then return end
    
        local inputValue = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or
            input.UserInputType ~= Enum.UserInputType.None and input.UserInputType
    
        local index = if inputValue then table.find(inputs, inputValue) else nil; if index then
            table.remove(inputs, index)

            local controlsPressed = getControls(); if #ActionManager.pressed > 0 then
                local difference = Array.difference(ActionManager.pressed, controlsPressed)
                ActionManager.pressed = Array.removeValues(ActionManager.pressed, table.unpack(difference))

                for _index, guid in difference do
                    ActionManager._actionPressed:Fire(guid, false)
                end
            end
        end
    end)
end

export type Control = Enum.KeyCode | Enum.UserInputType
export type Controls = Array<Control>
export type Action = typeof(ActionManager.new({} :: Controls))

return ActionManager
