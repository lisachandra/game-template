--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LuauPolyfill = require(ReplicatedStorage.Packages.LuauPolyfill)
local Promise = require(ReplicatedStorage.Packages.Promise)
local React = require(ReplicatedStorage.Packages.React)

local useValue = require(script.Parent.useValue)

type Promise<T> = LuauPolyfill.Promise<T>
type PromiseStatus = "Started" | "Resolved" | "Cancelled" | "Rejected"

export type AsyncState<T> = {
    status: "Started",
    message: any?,
    value: any?
} | {
    status: "Resolved",
    message: any?,
    value: T,
} | {
    status: "Cancelled" | "Rejected",
    message: unknown,
    value: any?
}

type AnyAsyncState<T> = {
    status: PromiseStatus,
    message: unknown?,
    value: T?,
}

export type AsyncCallback<T, U...> = (U...) -> Promise<T>

local function useAsyncCallback<T, U...>(
    callback: AsyncCallback<T, U...>
): (AsyncState<T>, AsyncCallback<T, U...>)
    local state, setState = React.useState({ status = Promise.Status.Started } :: AnyAsyncState<T>)
    local currentPromise = useValue(Promise.new() :: Promise<T>)

    local execute = React.useCallback(function(...: T)
        currentPromise.current:cancel()

        if state.status ~= Promise.Status.Started then
            setState({ status = Promise.Status.Started })
        end

        local promise: Promise<T> = (callback :: any)(...)

        promise:andThen(function(value)
            setState({ status = promise:getStatus(), value = value, })
        end, function(message: unknown?)
            setState({ status = promise:getStatus(), message = message })
        end)

        currentPromise.current = promise

        return promise
    end, { callback })

    React.useEffect(function()
        return function()
            currentPromise.current:cancel()
        end
    end)

    return state :: AsyncState<T>, execute
end

return useAsyncCallback
