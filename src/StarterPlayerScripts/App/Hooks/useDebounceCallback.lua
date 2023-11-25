--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local SetTimeout = require(ReplicatedStorage.Shared.SetTimeout)

local useLatest = require(script.Parent.useLatest)

export type UseDebounceOptions = SetTimeout.DebounceOptions & { wait: number? }
export type UseDebounceResult<T> = {
    run: SetTimeout.Debounced<T>,
    cancel: () -> (),
    flush: () -> (),
    pending: () -> boolean,
}

local function useDebounceCallback<T>(
    callback: T,
    options: UseDebounceOptions?
): UseDebounceResult<T>
    local options = options or {}
    local callbackRef = useLatest(callback)

    local debounced = React.useMemo(function()
        return SetTimeout.debounce(function(...: unknown)
            return callbackRef.current(...)
        end, options.wait, options)
    end, {}) :: SetTimeout.Debounced<T>

    React.useEffect(function()
        return function()
            debounced.cancel()
        end
    end, {})

    return {
        run = debounced,
        cancel = debounced.cancel,
        flush = debounced.flush,
        pending = debounced.pending,
    }
end

return useDebounceCallback
