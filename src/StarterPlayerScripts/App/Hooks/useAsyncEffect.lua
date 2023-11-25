--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LuauPolyfill = require(ReplicatedStorage.Packages.LuauPolyfill)
local React = require(ReplicatedStorage.Packages.React)

type Promise<T> = LuauPolyfill.Promise<T>

local function useAsyncEffect(effect: () -> Promise<unknown>, deps: Array<unknown>?)
    React.useEffect(function()
        local promise = effect(); return function()
            promise:cancel()
        end
    end)
end

return useAsyncEffect
