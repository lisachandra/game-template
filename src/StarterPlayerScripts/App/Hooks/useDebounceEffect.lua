--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local useDebounceCallback = require(script.Parent.useDebounceCallback)
local useUpdate = require(script.Parent.useUpdate)
local useUpdateEffect = require(script.Parent.useUpdateEffect)

local function useDebounceEffect(
    effect: () -> (() -> ())?,
    dependencies: Array<unknown>?,
    options: useDebounceCallback.UseDebounceOptions?
)
    local update = useUpdate()
    local debounce = useDebounceCallback(update, options)

    React.useEffect(function()
        return debounce.run()
    end, dependencies)

    useUpdateEffect(effect, { update })
end

return useDebounceEffect
