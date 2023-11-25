--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local useThrottleCallback = require(script.Parent.useThrottleCallback)
local useUpdate = require(script.Parent.useUpdate)
local useUpdateEffect = require(script.Parent.useUpdateEffect)

local function useThrottleEffect(
    effect: () -> (() -> ())?,
    dependencies: Array<unknown>?,
    options: useThrottleCallback.UseThrottleOptions?
)
    local update = useUpdate()

    local throttle = useThrottleCallback(update, options)

    React.useEffect(function()
        return throttle.run()
    end, dependencies)

    useUpdateEffect(effect, { update })
end

return useThrottleEffect
