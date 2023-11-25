--!nonstrict
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = script.Parent.Parent

local Packages = ReplicatedStorage.Packages

local GoodSignal = require(script.Parent.GoodSignal)
local Sift = require(Packages.Sift)

local IS_CLIENT = RunService:IsClient()

local Array = Sift.Array

local ActionManager = {}
ActionManager.__index = ActionManager

ActionManager.inputs = {} :: Array<Input>
ActionManager.held = {} :: Array<string>
ActionManager._objects = {} :: Array<Action>
ActionManager._actionPressed = GoodSignal.new() :: GoodSignal.Signal<string, boolean>

local function getInputs()
    local inputsPressed: Array<string> = {}

    for _index, action in ActionManager._objects do
        if Array.every(action.inputs, function(enum)
            return Array.includes(ActionManager.inputs, enum)
        end) then
            table.insert(inputsPressed, action.guid)
        end
    end

    return inputsPressed
end

function ActionManager.new(inputs: Inputs)
    if IS_CLIENT then
        for _index, action in ActionManager._objects do
            if Array.equals(action.inputs, inputs) then
                action.users += 1; return action
            end
        end

        local self = setmetatable({
            guid = HttpService:GenerateGUID(false),
            inputs = inputs,
            users = 1,
        }, ActionManager)

        table.insert(ActionManager._objects, self)

        return self
    end

    return inputs :: any
end

function ActionManager:Connect(callback: (held: boolean) -> ())
    self = self :: Action

    return ActionManager._actionPressed:Connect(function(guid, held)
        if guid == self.guid then
            callback(held)
        end
    end)
end

function ActionManager:Destroy()
    self = self :: Action
    self.users -= 1; if self.users >= 1 then
        return
    end

    local index = table.find(ActionManager._objects, self); if index then
        table.remove(ActionManager._objects, index)
    end
end

if IS_CLIENT then
    UserInputService.InputBegan:Connect(function(input: InputObject, _gameProcessedEvent)
        if input.UserInputType == Enum.UserInputType.None then return end
    
        local inputValue = if input.KeyCode ~= Enum.KeyCode.Unknown then input.KeyCode
            elseif input.UserInputType ~= Enum.UserInputType.None then input.UserInputType else nil

        if inputValue then
            table.insert(ActionManager.inputs, inputValue)
    
            local inputsPressed = getInputs(); if #inputsPressed > 0 then
                inputsPressed = Array.removeValues(inputsPressed, table.unpack(ActionManager.held))
                ActionManager.held = Array.push(ActionManager.held, table.unpack(inputsPressed))
    
                for _index, guid in inputsPressed do
                    ActionManager._actionPressed:Fire(guid, true)
                end
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input: InputObject, _gameProcessedEvent)
        if input.UserInputType == Enum.UserInputType.None then return end
    
        local inputValue = if input.KeyCode ~= Enum.KeyCode.Unknown then input.KeyCode
            elseif input.UserInputType ~= Enum.UserInputType.None then input.UserInputType else nil

        local index = if inputValue then table.find(ActionManager.inputs, inputValue) else nil; if index then
            table.remove(ActionManager.inputs, index)

            local inputsPressed = getInputs(); if #ActionManager.held > 0 then
                local difference = Array.difference(ActionManager.held, inputsPressed)
                ActionManager.held = Array.removeValues(ActionManager.held, table.unpack(difference))

                for _index, guid in difference do
                    ActionManager._actionPressed:Fire(guid, false)
                end
            end
        end
    end)
end

export type Input = Enum.KeyCode | Enum.UserInputType
export type Inputs = Array<Input>
export type Action = typeof(ActionManager.new({} :: Inputs))

return ActionManager
