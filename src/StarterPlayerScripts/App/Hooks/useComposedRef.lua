--!nonstrict
local React = require(game:GetService("ReplicatedStorage").Packages.React)
local useLatestCallback = require(script.Parent.useLatestCallback)

export type RefFunction<T> = (rbx: T?) -> ()

local function composeRefs<T>(...: RefFunction<T>): RefFunction<T>
    local refsDefined = table.pack(...)
    
    return function(rbx)
        for ref in refsDefined do
            ref(rbx)
        end
    end
end

local function useComposedRef<T>(...: RefFunction<T>): RefFunction<T>
    local refs = table.pack(...)
    local composedRef = React.useMemo(function()
        return composeRefs(table.unpack(refs))
    end, refs)
    
    return useLatestCallback(composedRef)
end

return useComposedRef
