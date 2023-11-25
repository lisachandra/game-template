--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local useValue = require(script.Parent.useValue)

local function useLatestCallback<T>(callback: T): T
    local callbackRef = useValue(callback); return React.useCallback(function(args)
        return callbackRef.current(args)
    end, {}) :: any
end

return useLatestCallback
