--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local SetTimeout = require(ReplicatedStorage.Shared.SetTimeout)

local useLatestCallback = require(script.Parent.useLatestCallback)
local useValue = require(script.Parent.useValue)

local function useTimeout(callback: () -> (), delay: number?)
    local callbackMemo = useLatestCallback(callback)
    local cancel = useValue((nil :: unknown) :: () -> ())

    local clear = React.useCallback(function()
        if cancel.current then
            cancel.current()
        end
    end, {})

    React.useEffect(function()
        if not delay then return end

        cancel.current = SetTimeout.setTimeout(callbackMemo, delay)
        return clear
    end, { delay })

    return clear
end

return useTimeout
