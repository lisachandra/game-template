export type Actions<U> = Dictionary<(context: U, event: table) -> U?>

export type States<T = string, U = table> = {
    states: Map<T, States<T, U>>,
    on: Dictionary<{
        actions: { string },
        target: T,
    }>,
}

export type Machine<T = string, U = table> = {
    id: string,
    initial: T,
    context: U,

    states: Map<T, States<T, U>>,
}

export type Storage<T = string, U = table> = {
    initiated: boolean,
    actions: Actions<U>,
}

local Machine = {}

--[[
    This function should only be used as a utility function for creating a new machine (not using it),
    therefore the lazy types.
]]
function Machine.createMovementMachine<T, U>(
    useMachine: (...any) -> ...any,
    entityId: number,
    machine: Machine<T, U>
): any
    local function next(context, event: { state: any })
        return {
            changed = os.clock(),
            previous = context.value,
            value = event.state,
        }
    end

    return useMachine(entityId, machine, {
        next = next,

        walk = function(context, _event)
            return next(context, { state = "Humanoid" })
        end,

        stun = function(context, _event)
            return next(context, { state = "Stunned" })
        end,
    })
end

return Machine
