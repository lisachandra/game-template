--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local HookConnector = require(ReplicatedStorage.Shared.Matter.HookConnector)
local MatterUseMachine = require(ReplicatedStorage.Shared.Matter.Hooks.useMachine)

local machines: Dictionary<{ current: MatterUseMachine.Return<any, any> }> = {}

export type States<T = string, U = table> = MatterUseMachine.States<T, U>
export type Machine<T = string, U = table> = MatterUseMachine.Machine<T, U>

local function useMachine<T, U>(entityId: number, machine: Machine<T, U>)
    local discriminator = `{entityId}_{machine.id}`
    local machineValue = (machines[discriminator] or {}) :: { current: MatterUseMachine.Return<T, U> }

    machines[discriminator] = machineValue

    local request: HookConnector.Request<MatterUseMachine.Return<T, U>>
    request = HookConnector.requests[discriminator] or {
        hook = "useMachine",
        params = { entityId, machine },
        callback = function(returned)
            machineValue.current = returned
        end,
    }

    HookConnector.requests[discriminator] = request

    React.useEffect(function()
        return function()
            HookConnector.requests[discriminator] = nil
            machines[discriminator].current = nil :: any
            machines[discriminator] = nil
        end
    end, {})

    return machineValue
end

return useMachine
