--!nonstrict
local React = require(game:GetService("ReplicatedStorage").Packages.React)
local useValue = require(script.Parent.useValue)

export type Predicate<T> = (previous: T | unknown, current: T) -> boolean
export type isStrictEqual = (a: unknown, b: unknown) -> boolean

local function isStrictEqual(a: unknown, b: unknown): boolean
    return a == b
end

local function usePrevious<T>(value: T, predicate: isStrictEqual?): T | unknown
    local predicate = predicate or isStrictEqual
    local previousRef = useValue((nil :: unknown) :: T)
    local currentRef = useValue((nil :: unknown) :: T)

    React.useMemo(function()
        if not predicate(currentRef.current, value) then
            previousRef.current = currentRef.current
            currentRef.current = value
        end
    end, { value })

    return previousRef.current
end

return usePrevious
