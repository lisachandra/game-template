--!nonstrict
local React = require(game:GetService("ReplicatedStorage").Packages.React)

local useValue = require(script.Parent.useValue)
local usePrevious = require(script.Parent.usePrevious)

local function isStrictEqual(a: unknown, b: unknown): boolean
    return a == b
end

local function useLatest<T>(value: T, predicate: usePrevious.isStrictEqual?)
    local predicate = predicate or isStrictEqual
    local ref = useValue(value)

    React.useMemo(function()
        if not predicate(ref.current, value) then
            ref.current = value
        end
    end, { value })

    return ref
end

return useLatest
