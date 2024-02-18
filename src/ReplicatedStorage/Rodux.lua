local RunService = game:GetService("RunService")
local ReplicatedStorage = script.Parent.Parent

local Shared = ReplicatedStorage.Shared
local Packages = ReplicatedStorage.Packages

local React = require(Packages.React)
local Matter = require(Shared.Matter)
local Rodux = require(Packages.Rodux)

local hooks: Dictionary<(newValue: any) -> ()> = {}

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

    ui: {},
}

export type ServerState = {
    world: Matter.World,
}

-- FIXME: shit rodux type checking
export type Store = any

local function createReducer(key: string)
    return function(value: any?, action: action)
        if action.type == key then
            return action.value
        end

        return value
    end
end

local function reducer(state: Dictionary<any>, action: action)
    local newState = {}; if action.type == "ui" then
        newState.ui = table.clone(state.ui)

        local paths = action.key:split(".")
        local value = newState.ui
        local self, key

        for _index, path in paths do
            self = value
            key = path
            value = value[path]
        end

        self[key] = action.value

        local updateHookValue = hooks[action.key]; if updateHookValue then
            updateHookValue(action.value)
        end
    else
        for key, reducer in reducers do
            newState[key] = reducer(state[key], action)
        end
    end

    return newState
end

local function useUIState(key: string)
    local value = React.useMemo(function()
        local state: ClientState = store:getState()
    
        local paths = key:split(".")
        local value = state.ui

        for _index, path in paths do
            value = value[path]
        end

        return value
    end, {})

    local value, setValue = React.useState(value)

    local setState = React.useCallback(function(newValue)
        store:dispatch({
            type = "ui",
            key = key,
            value = newValue,
        })
    end, {})

    React.useEffect(function()
        local prevHook = hooks[key]
    
        hooks[key] = function(newValue)
            if prevHook then
                prevHook(newValue)
            end

            setValue(newValue)
        end

        return function()
            hooks[key] = nil
        end
    end, {})

    return value, setState
end

if RunService:IsClient() then
    initialState = {
        debugEnabled = false,
        ui = {},
    } :: ClientState

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

    for _index, key in {
        "world",
    } do
        reducers[key] = createReducer(key)
    end
end

store = Rodux.Store.new(reducer, initialState, middlewares, {
    reportReducerError = function(prevState, action, errorResult)
        error(`Received error: {errorResult.message}\n\n{errorResult.thrownValue}`)
    end,

    reportUpdateError = function(prevState, currentState, lastActions, errorResult)
        error(`Received error: {errorResult.message}\n\n{errorResult.thrownValue}`)
    end,
})

return {
    store = store :: Store,
    useUIState = useUIState,
    creators = creators,
}
