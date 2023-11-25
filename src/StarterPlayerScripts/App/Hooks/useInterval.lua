--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local useLatestCallback = require(script.Parent.useLatestCallback)
local SetTimeout = require(ReplicatedStorage.Shared.SetTimeout)
local useValue = require(script.Parent.useValue)

local function useInterval(callback: () -> (), delay: number?, immediate: boolean?)
    local immediate = if immediate == nil then false else immediate

    local callbackMemo = useLatestCallback(callback)
    local cancel = useValue((nil :: any) :: () -> ())

    local clear = React.useCallback(function()
        if cancel.current then
            cancel.current()
        end
    end)

    React.useEffect(function()
        if not delay then return end
        if immediate then
            callbackMemo()
        end

        cancel.current = SetTimeout.setInterval(callbackMemo, delay)
        return clear
    end, { delay })

    return clear
end

return useInterval
