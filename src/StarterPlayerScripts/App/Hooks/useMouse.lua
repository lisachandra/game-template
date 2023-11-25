--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)

local useEventConnection = require(script.Parent.useEventConnection)

local function useMouse(callback: ((mouse: Vector2) -> ())?): React.Binding<Vector2>
    local mouse, setMouse = React.useBinding(Vector2.one)

    useEventConnection(UserInputService.InputChanged, function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch
        then
            setMouse(UserInputService:GetMouseLocation()); if callback then
                callback(UserInputService:GetMouseLocation())
            end
        end
    end)

    React.useMemo(function()
        setMouse(UserInputService:GetMouseLocation())
    end, {})

    React.useEffect(function()
        if callback then
            callback(mouse:getValue())
        end
    end, {})

    return mouse
end

return useMouse
