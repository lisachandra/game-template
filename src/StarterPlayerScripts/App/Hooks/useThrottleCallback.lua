--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local SetTimeout = require(ReplicatedStorage.Shared.SetTimeout)

local useDebounceCallback = require(script.Parent.useDebounceCallback)
local useLatest = require(script.Parent.useLatest)

export type UseThrottleOptions = SetTimeout.ThrottleOptions & { wait: number? }

local function UseThrottleCallback<T>(
    callback: T,
    options: UseThrottleOptions?
): useDebounceCallback.UseDebounceResult<T>
    local options = options or {}

    local callbackRef = useLatest(callback)

    local throttled = React.useMemo(function()
        return SetTimeout.throttle(function(...: unknown)
            return callbackRef.current(...)
        end, options.wait, options)
    end)

    React.useEffect(function()
        return throttled.cancel
    end, {})

    return {
        run = throttled,
        cancel = throttled.cancel,
        flush = throttled.flush,
        pending = throttled.pending,
    }
end

return UseThrottleCallback
