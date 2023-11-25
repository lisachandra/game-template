-- https://github.com/littensy/set-timeout

local debounce = require(script.debounce)
local throttle = require(script.throttle)

export type DebounceOptions = debounce.DebounceOptions
export type Debounced<T> = debounce.Debounced<T>

export type ThrottleOptions = throttle.ThrottleOptions

return {
    setCountdown = require(script.setCountdown),
    setInterval = require(script.setInterval),
    setTimeout = require(script.setTimeout),
    throttle = require(script.throttle),
    debounce = require(script.debounce),
}