local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Camera = workspace.CurrentCamera

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared
local Hooks = script.Hooks

local ReactRouter = require(Shared.ReactRouter)
local React = require(Packages.React)
local Sift = require(Packages.Sift)

local Context = require(script.Context)

local useViewport = require(Hooks.useViewport)

local e = React.createElement

local BASE = {
    X = 1920,
    Y = 1080,
    REM = 16,
}

export type Context = Context.context

local function computeScale(viewport: Vector2): number
    local multiplier = 1 / BASE.Y
    local scale = if viewport.Y < viewport.X then
        multiplier * viewport.Y
    else multiplier * viewport.X

    return scale
end

local function computeRem(viewport: Vector2): number
    local width = math.log(viewport.X / BASE.X, 2)
    local height = math.log(viewport.Y / BASE.Y, 2)
    local centered = width + (height - width) * .5

    return math.max(BASE.REM * 2 ^ centered, 1)
end

local function App(props: Context.context)
    local scale, setScale = React.useBinding(0)
    local rem, setRem = React.useBinding(0)

    local viewport = useViewport(function(viewport: Vector2)
        setScale(computeScale(Camera.ViewportSize))
        setRem(computeRem(Camera.ViewportSize))
    end)

    return e(ReactRouter.Router, {}, {
        Provider = e(Context.Provider, { value = Sift.Dictionary.merge(props, {
            scale = scale,
            rem = rem,
            viewport = viewport,
        }) }, {
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
