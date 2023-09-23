local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Camera = workspace.CurrentCamera

local Packages = ReplicatedStorage.Packages

local React = require(Packages.React)
local Sift = require(Packages.Sift)

local Context = require(script.Context)

local e = React.createElement

local DEFAULT_SCALE = 1
local DEFAULT_HEIGHT = 720

local function App(props: Context.context)
    local scale, setScale = React.useBinding(0)

    React.useEffect(function()
        local connection; connection = Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            local multiplier = DEFAULT_SCALE / DEFAULT_HEIGHT
            local size = Camera.ViewportSize

            setScale(
                if size.Y < size.X then
                    multiplier * size.Y
                else multiplier * size.X
            )
        end)

        return function()
            connection:Disconnect()
        end
    end, {})

    return e(Context.Provider, { value = Sift.Dictionary.merge(props, { scale = scale }) }, {
        App = e("ScreenGui", {
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            IgnoreGuiInset = true,
            ResetOnSpawn = false,
            Enabled = true,
        }, {

        })
    })
end

return App
