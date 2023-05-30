local RunService = game:GetService("RunService")

local Packages = script.Parent.Parent.Packages

local Rodux = require(Packages.Rodux)

local initialState: ClientState | ServerState
local creators: Dictionary<creator>
local reducers: Dictionary<reducer>
local middlewares: Array<middleware>

type middleware = (nextDispatch: (action: action) -> (), store: Store) -> ((action: action) -> ())
type creator = (...any) -> action
type reducer = (key: string, action: action) -> any
type action = table & { type: string }

export type ClientState = { debugEnabled: boolean }
export type ServerState = {}

export type Store = typeof(Rodux.Store.new(nil :: any, nil :: any, nil :: any, nil :: any))

local function reducer(state, action: action)
    local newState = {}; for key, reducer in reducers do
        newState[key] = reducer(state[key], action)
    end

    return newState
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

return {
    store = Rodux.Store.new(reducer, initialState :: table, middlewares :: table, {
        reportReducerError = function(prevState, action, errorResult)
            error(string.format("Received error: %s\n\n%s", errorResult.message, errorResult.thrownValue))
        end,

        reportUpdateError = function(prevState, currentState, lastActions, errorResult)
            error(string.format("Received error: %s\n\n%s", errorResult.message, errorResult.thrownValue))
        end,
    }),

    creators = creators,
}
