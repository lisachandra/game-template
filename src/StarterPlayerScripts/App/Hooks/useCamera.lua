--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local useEventConnection = require(script.Parent.useEventConnection)

local function useCamera()
    local camera, setCamera = React.useState(workspace.CurrentCamera)

    useEventConnection(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
        if workspace.CurrentCamera then
            setCamera(workspace.CurrentCamera)
        end
    end)

    return camera
end

return useCamera
