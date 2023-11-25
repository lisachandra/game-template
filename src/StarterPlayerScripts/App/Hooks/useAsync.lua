--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LuauPolyfill = require(ReplicatedStorage.Packages.LuauPolyfill)
local React = require(ReplicatedStorage.Packages.React)

local useAsyncCallback = require(script.Parent.useAsyncCallback)

type Promise<T> = LuauPolyfill.Promise<T>

local function useAsync<T>(callback: () -> Promise<T>, deps: Array<unknown>)
    local state, asyncCallback = useAsyncCallback(callback)

    React.useEffect(function()
        asyncCallback()
    end, deps)

    return state.value, state.status, state.message
end

return useAsync
