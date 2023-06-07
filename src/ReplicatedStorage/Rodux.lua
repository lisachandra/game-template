local RunService = game:GetService("RunService")

local Packages = script.Parent.Parent.Packages

local RoactHooks = require(Packages.RoactHooks)
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

export type ClientState = { debugEnabled: boolean }
export type ServerState = {}

export type Store = typeof(Rodux.Store.new(nil :: any, nil :: any, nil :: any, nil :: any))

local function reducer(state: Dictionary<any>, action: action)
    local newState = {}; for key, reducer in reducers do
        newState[key] = reducer(state[key], action)
    end

    return newState
end

local function useState(hooks: RoactHooks.Hooks, key: string)
    local state = store:getState()
    local value, update = hooks.useState(state[key])

    updaters[key] = update

    return value
end

if RunService:IsClient() then
    initialState = { debugEnabled = false } :: ClientState
    creators = {}
    reducers = {}
    middlewares = { Rodux.thunkMiddleware :: any }
else
    initialState = {} :: ServerState
    creators = {}
    reducers = {}
    middlewares = { Rodux.thunkMiddleware :: any }
end

store = Rodux.Store.new(reducer, initialState, middlewares, {
    reportReducerError = function(prevState, action, errorResult)
        error(("Received error: %s\n\n%s"):format(errorResult.message, errorResult.thrownValue))
    end,

    reportUpdateError = function(prevState, currentState, lastActions, errorResult)
        error(("Received error: %s\n\n%s"):format(errorResult.message, errorResult.thrownValue))
    end,
})

store.changed.connect(store :: any, function(new, old)
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
    store = store,
    useState = useState,
    creators = creators,
}
