--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerScripts = script.Parent.Parent.Parent

local useEventConnection = require(script.Parent.useEventConnection)
local React = require(ReplicatedStorage.Packages.React)

local ActionManager = require(PlayerScripts.ActionManager)

local useValue = require(script.Parent.useValue)

local function useInput(inputs: ActionManager.Inputs)
    local action = useValue(ActionManager.new(inputs))
    local held, setHeld = React.useState(false)

    useEventConnection(action.current.Connect, function(held: boolean)
        setHeld(held)
    end)

    React.useEffect(function()
        return function()
            action.current:Destroy()
        end
    end, {})

    return held
end

return useInput
