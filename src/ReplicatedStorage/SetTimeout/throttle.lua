local debounce = require(script.Parent.debounce)

export type ThrottleOptions = {
    leading: boolean?,
    trailing: boolean?,
}

local function throttle<T>(callback: T, wait: number?, options: ThrottleOptions?)
    local wait = wait or 0
    local options = options or { leading = true, trailing = true }

    return debounce(callback, wait, {
        leading = options.leading,
        trailing = options.trailing,
        maxWait = wait,
    })
end

return throttle
