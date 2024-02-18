local setTimeout = require(script.Parent.setTimeout)

export type DebounceOptions = {
    leading: boolean?,
    trailing: boolean?,
    maxWait: number?,
}

export type Debounced<T> = typeof(setmetatable({} :: {
    cancel: () -> (),
    flush: () -> unknown,
    pending: () -> boolean,
}, { __call = (nil :: unknown) :: T }))

local function debounce<T>(callback: T, wait: number?, options: DebounceOptions?): Debounced<T>
    local wait = wait or 0
    local callback = callback
    local options: DebounceOptions = options or { leading = false, trailing = true }

    local lastCallTime = 0
    local lastInvokeTime = 0
    local lastArgs: Array<unknown>?
    local result: unknown?
    local cancelTimeout: (() -> ())?

    local function invoke(time: number)
        local args = lastArgs
        lastArgs = nil
        lastInvokeTime = time
        result = (callback :: any)(args and table.unpack(args))

        return result
    end


    local function remainingWait(time: number)
        local timeSinceLastCall = time - lastCallTime
        local timeSinceLastInvoke = time - lastInvokeTime
        local timeWaiting = wait - timeSinceLastCall

        return if options.maxWait then math.min(timeWaiting, options.maxWait - timeSinceLastInvoke) else timeWaiting
    end

    local function shouldInvoke(time: number)
        local timeSinceLastCall = time - lastCallTime
        local timeSinceLastInvoke = time - lastInvokeTime

        return (
            not lastCallTime or
            timeSinceLastCall >= wait or
            timeSinceLastCall < 0 or
            (options.maxWait and timeSinceLastInvoke >= options.maxWait)
        )
    end

    local function trailingEdge(time: number)
        cancelTimeout = nil; if options.trailing and lastArgs then
            return invoke(time)
        end

        lastArgs = nil; return result
    end

    local function timerExpired()
        local time = os.clock()

        if shouldInvoke(time) then
            return trailingEdge(time)
        end

        cancelTimeout = setTimeout(timerExpired, remainingWait(time)); return
    end

    local function leadingEdge(time: number)
        lastInvokeTime = time
        cancelTimeout = setTimeout(timerExpired, wait)
        
        return if options.leading then invoke(time) else result
    end

    local function cancel()
        if cancelTimeout then
            cancelTimeout()
        end

        cancelTimeout = nil
        lastInvokeTime = 0
        lastArgs = nil
        lastCallTime = 0
    end

    local function flush()
        return if cancelTimeout == nil then result else trailingEdge(os.clock())
    end

    local function pending()
        return cancelTimeout ~= nil
    end

    local function debounced(...: unknown)
        local time = os.clock()
        local isInvoking = shouldInvoke(time)

        lastArgs = table.pack(...)
        lastCallTime = time

        if isInvoking then
            if not cancelTimeout then
                return leadingEdge(lastCallTime)
            end

            if options.maxWait then
                cancelTimeout = setTimeout(timerExpired, wait)
                return invoke(lastCallTime)
            end
        end

        if not cancelTimeout then
            cancelTimeout = setTimeout(timerExpired, wait)
        end

        return result
    end
    
    return (setmetatable({ cancel = cancel, flush = flush, pending = pending }, {
        __call = function(_self, ...: unknown)
            return debounced(...)
        end,
    }) :: unknown) :: Debounced<T>
end

return debounce
