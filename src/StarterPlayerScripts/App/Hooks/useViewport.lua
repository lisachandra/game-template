--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local useCamera = require(script.Parent.useCamera)
local useEventConnection = require(script.Parent.useEventConnection)

local function useViewport(listener: ((viewport: Vector2) -> ())?)
    local camera = useCamera()
    local viewport, setViewport = React.useBinding(Vector2.one)

    if camera then
        useEventConnection(camera:GetPropertyChangedSignal("ViewportSize"), function()
            setViewport(camera.ViewportSize); if listener then
                listener(camera.ViewportSize)
            end
        end)
    end

    React.useMemo(function()
        if camera then
            setViewport(camera.ViewportSize)
        end
    end, { camera })

    React.useEffect(function()
        if listener then
            listener(viewport:getValue())
        end
    end, { camera })

    return viewport
end

return useViewport
