local RunService = game:GetService("RunService")
local ReplicatedStorage = script.Parent.Parent

local Shared = ReplicatedStorage.Shared
local Packages = ReplicatedStorage.Packages

local Matter = require(Shared.Matter)
local React = require(Packages.React)
local Rodux = require(Packages.Rodux)
local Sift = require(Packages.Sift)

local updaters: Dictionary<(newValue: any) -> ()> = {}

local initialState: ClientState | ServerState
local creators: Dictionary<creator>
local reducers: Dictionary<reducer>
local middlewares: Array<middleware>

local store: Store

type middleware = (nextDispatch: (action: action) -> (), store: Store) -> ((action: action) -> ())
type creator = (...any) -> action
type reducer = (key: string, action: action) -> any
type action = table & { type: string }

export type ClientState = {
    debugEnabled: boolean,
    world: Matter.World,
    serverTime: number,
}

export type ServerState = {}

export type Store = typeof(Rodux.Store.new(nil :: any, nil :: any, nil :: any, nil :: any))

local function createReducer(key: string)
    return function(value: any?, action: action)
        if action.type == key then
            return action.value
        end

        return value
    end
end

local function reducer(state: Dictionary<any>, action: action)
    local newState = {}; for key, reducer in reducers do
        newState[key] = reducer(state[key], action)
    end

    return newState
end

local function useState(key: string)
    local state = store:getState()
    local value, update = React.useState(state[key])

    updaters[key] = update

    return value
end

if RunService:IsClient() then
    initialState = { debugEnabled = false } :: ClientState
    creators = {}
    reducers = {}
    middlewares = { Rodux.thunkMiddleware :: any }

    for _index, key in {
        "world",
        "debugEnabled",
        "serverTime",
    } do
        reducers[key] = createReducer(key)
    end
else
    initialState = {} :: ServerState
    creators = {}
    reducers = {}
    middlewares = { Rodux.thunkMiddleware :: any }
end

store = Rodux.Store.new(reducer, initialState, middlewares, {
    reportReducerError = function(prevState, action, errorResult)
        error(`Received error: {errorResult.message}\n\n{errorResult.thrownValue}`)
    end,

    reportUpdateError = function(prevState, currentState, lastActions, errorResult)
        error(`Received error: {errorResult.message}\n\n{errorResult.thrownValue}`)
    end,
})

store.changed.connect(store.changed :: any, function(new, old)
    for key, update in updaters do
        if type(new[key]) == "table" and type(old[key]) == "table" then
            if not Sift.Dictionary.equals(new[key], old[key]) then
                update(new[key])
            end
        else
            update(new[key])
        end
    end
end)

return {
    store = store :: Store,
    useState = useState,
    creators = creators,
}
