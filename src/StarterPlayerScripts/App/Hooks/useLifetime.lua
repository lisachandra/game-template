--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.React)

local useEventConnection = require(script.Parent.useEventConnection)

local function useLifetime(dependencies: Array<unknown>?)
    local dependencies = dependencies or {}
    local lifetime, setLifetime = React.useBinding(0)

    useEventConnection(RunService.Heartbeat, function(dt)
        setLifetime(lifetime:getValue() + dt)
    end)

    React.useEffect(function()
        setLifetime(0)
    end, dependencies)

    return lifetime
end

return useLifetime
