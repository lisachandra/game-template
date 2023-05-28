local RunService = game:GetService("RunService")

local Packages = script.Parent.Parent.Packages

local Rodux = require(Packages.Rodux)

local initialState
local creators
local reducers
local middlewares

export type ClientState = { debugEnabled: boolean }
export type ServerState = {}

export type Store = typeof(Rodux.Store.new())

type Action = {
    type: string,
    value: any?,
}

function reducer(state, action: Action)
    local newState = {}; for key, reducer in reducers do
        newState[key] = reducer(state[key], action)
    end

    return newState
end

if RunService:IsClient() then
    initialState = { debugEnabled = false } :: ClientState
    creators = {}
    reducers = {}
    middlewares = { Rodux.thunkMiddleware }
else
    initialState = {} :: ServerState
    creators = {}
    reducers = {}
    middlewares = { Rodux.thunkMiddleware }
end

return {
    store = Rodux.Store.new(reducer, initialState, middlewares),
    creators = creators,
}
