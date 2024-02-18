local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared

local Matter = require(Shared.Matter)

local Machine = require(Shared.Matter.Machine)
local Components = require(Shared.Matter.Components)
local Utils = require(Shared.Utils)

local IS_CLIENT = RunService:IsClient()

local machines: Dictionary<Storage<any, any>> = {}

export type Actions<U> = Machine.Actions<U>
export type Machine<T, U> = Machine.Machine<T, U>
export type Storage<T, U> = Machine.Storage<T, U>
export type States<T, U> = Machine.States<T, U>

export type Return<T, U> = {
    changed: () -> Matter.ChangeRecord<{ state: T, context: U }>?,
    matches: (stateToMatch: T) -> boolean,
    send: (type: string, payload: table?) -> (),
    stop: () -> (),
    can: (type: string) -> boolean,

    snapshot: { state: T, context: U },
}

local function getStorage<T, U>(world: Matter.World, entityId: number, machine: Machine<T, U>, actions: Actions<U>?): (Storage<T, U>, string)
    local StateMachines = world:get(entityId, Components.StateMachines)

    if IS_CLIENT then
        return StateMachines[machine.id] or {}, machine.id
    end

    local discriminator = `{entityId}_{machine.id}`
    local storage = (machines[discriminator] or {}) :: Storage<T, U>

    if not storage.initiated then
        storage.initiated = true
        storage.actions = actions :: Actions<U>
        machines[discriminator] = storage

        world:insert(entityId, StateMachines:patch({
            [machine.id] = {
                state = machine.initial,
                context = machine.context,
            },
        } :: Components.StateMachines))
    end

    return storage, discriminator
end

local function getSnapshot<T, U>(
    world: Matter.World,
    entityId: number,
    machine: Machine<T, U>
): { state: T, context: U }
    local StateMachines = world:get(entityId, Components.StateMachines)
    return StateMachines[machine.id]
end

local function useMachine<T, U>(
    entityId: number,
    machine: Machine<T, U>,
    actions: Actions<U>?
): Return<T, U>?
    local world = Utils.GetWorld(entityId)
    local storage, discriminator = getStorage(world, entityId, machine, actions)

    local function findState(stateToFind: T, states: States<T, U>?): States<T, U>?
        local parentStates: { states: Map<T, States<T, U>> } = states or machine

        if not parentStates.states then
            return
        end

        for state, states in parentStates.states do
            if state == stateToFind then
                return states
            end

            local foundState = findState(state, states); if foundState then
                return foundState
            end
        end

        return findState(stateToFind, parentStates :: States<T, U>)
    end

    local function stop()
        assert(not IS_CLIENT, "Cannot stop state machine on client")

        local StateMachines = if world:contains(entityId) then world:get(entityId, Components.StateMachines) else nil

        storage.initiated = false
        machines[discriminator] = nil

        if StateMachines then
            world:insert(entityId, StateMachines:patch({
                [machine.id] = Matter.None,
            } :: Components.StateMachines))
        end
    end

    local function send(type: string, payload: table?)
        assert(not IS_CLIENT, "Cannot transition state machine on client")

        local snapshot = getSnapshot(world, entityId, machine)
        local currentState = findState(snapshot.state)
        local nextState = currentState and currentState.on[type]

        if not nextState then
            warn(`Attempted to transition state machine {discriminator} to {type} but no transition was found`)
            print("Snapshot:", snapshot)
            return
        end

        local newSnapshot = {}
        local newContext: U?

        for _index, action in nextState.actions do
            newContext = storage.actions[action](snapshot.context, payload or {})
        end

        newSnapshot.state = nextState.target

        if newContext then
            newSnapshot.context = newContext
        end

        local StateMachines = world:get(entityId, Components.StateMachines)
        world:insert(entityId, StateMachines:patch({
            [machine.id] = newSnapshot,
        } :: Components.StateMachines))
    end

    local function can(type: string): boolean
        local snapshot = getSnapshot(world, entityId, machine)
        local currentState = findState(snapshot.state)
        local nextState = currentState and currentState.on[type]

        return nextState ~= nil
    end

    local function matches(stateToMatch: T): boolean
        local snapshot = getSnapshot(world, entityId, machine)

        if snapshot.state == stateToMatch then
            return true
        end

        local currentState = findState(snapshot.state); if not (currentState and currentState.states) then
            return false
        end

        local path = { stateToMatch }; while true do
            local stateToFind = table.remove(path, 1)

            for state in currentState.states do
                if state == stateToFind then
                    return true
                end

                table.insert(path, state)
            end

            if #path < 0 then
                break
            end
        end

        return false
    end

    local function changed(): Matter.ChangeRecord<{ state: T, context: U }>?
        if not world:contains(entityId) then
            return
        end

        for playerEntityId, record in world:queryChanged(Components.StateMachines) do
            if playerEntityId == entityId then
                return {
                    old = record.old and record.old[machine.id],
                    new = record.new and record.new[machine.id],
                }
            end
        end

        return
    end

    local snapshot = getSnapshot(world, entityId, machine); if not snapshot then
        return
    end

    return {
        changed = changed,
        matches = matches,
        send = send,
        stop = stop,
        can = can,

        snapshot = snapshot,
    }
end

return useMachine
