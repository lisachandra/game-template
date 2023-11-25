--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.React)

local useLatest = require(script.Parent.useLatest)
local useValue = require(script.Parent.useValue)

local function useDeferCallback<T...>(
    callback: (T...) -> ()
): ((T...) -> (), () -> ())
    local callbackRef = useLatest(callback)
    local connectionRef = useValue((nil :: any) :: RBXScriptConnection)

    local cancel = React.useCallback(function()
        if connectionRef.current then
            connectionRef.current:Disconnect()
        end

        connectionRef.current = nil
    end, {})

    local execute = React.useCallback(function(...: unknown)
        local args = table.pack(...)
        cancel()

        connectionRef.current = RunService.Heartbeat:Once(function()
            connectionRef.current = nil
            callbackRef.current(table.unpack(args))
        end)
    end, {})  
    
    return execute, cancel
end

return useDeferCallback
