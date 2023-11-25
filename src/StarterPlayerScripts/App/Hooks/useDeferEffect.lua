--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local useDeferCallback = require(script.Parent.useDeferCallback)

local function useDeferEffect(callback: () -> (), dependencies: Array<unknown>?)
    local deferredCallback, cancel = useDeferCallback(callback)

    React.useEffect(function()
        deferredCallback(); return cancel
    end, dependencies)
end

return useDeferEffect
