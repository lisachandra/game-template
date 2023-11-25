--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local useValue = require(script.Parent.useValue)

local function useUpdateEffect(effect: () -> (() -> ())?, dependencies: Array<unknown>?)
    local isMounted = useValue(false)

    React.useEffect(function()
        if isMounted.current then
            return effect()
        else
            isMounted.current = true
        end

        return
    end, dependencies)
end

return useUpdateEffect
