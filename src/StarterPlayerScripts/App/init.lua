local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Camera = workspace.CurrentCamera

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared
local Hooks = script.Hooks

local ReactRouter = require(Shared.ReactRouter)
local React = require(Packages.React)
local Sift = require(Packages.Sift)

local Context = require(script.Context)

local useEventConnection = require(Hooks.useEventConnection)

local ViewportSizeChanged = Camera:GetPropertyChangedSignal("ViewportSize")

local e = React.createElement

local function computeScale(viewportSize: Vector2): number
    local multiplier = 1 / 1080
    local scale = if viewportSize.Y < viewportSize.X then
        multiplier * viewportSize.Y
    else multiplier * viewportSize.X

    return scale
end

local function App(props: Context.context)
    local scale, setScale = React.useBinding(computeScale(Camera.ViewportSize))

    useEventConnection(ViewportSizeChanged, function()
        setScale(computeScale(Camera.ViewportSize))
    end, {})

    return e(ReactRouter.Router, {}, {
        Provider = e(Context.Provider, { value = Sift.Dictionary.merge(props, { scale = scale }) }, {
            App = e("ScreenGui", {
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                IgnoreGuiInset = true,
                ResetOnSpawn = false,
                Enabled = true,
            }, {})
        })
    })
end

return { render = App, computeScale = computeScale }
