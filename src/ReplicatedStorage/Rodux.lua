local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Packages = ReplicatedStorage.Packages

local React = require(Packages.React)
local Matter = require(Shared.Matter)
local Rodux = require(Packages.Rodux)

local initialState: ClientState | ServerState
local creators: Dictionary<any>
local middlewares: Array<any>

local store

export type Action<Type > = Rodux.Action<Type >
export type AnyAction = Rodux.AnyAction 
export type ActionCreator<Type, Action, Args...> = Rodux.ActionCreator<Type, Action, Args...>
export type Reducer<State , Action > = Rodux.Reducer<State , Action >
export type Store<State > = Rodux.Store<State >
export type ThunkAction<ReturnType, State > = Rodux.ThunkAction<ReturnType, State >
export type ThunkfulStore<State > = Rodux.ThunkfulStore<State >

export type ClientState = {
    debugEnabled: boolean,
    world: Matter.World,

    ui: {},
}

export type ServerState = {
    world: Matter.World,
}

local function reducer(state: Dictionary<any>, action: AnyAction)
    local newState = table.clone(state); if action.type == "ui" then
        local paths = action.key:split(".")
        local value = newState
        local self, key

        for _index, path in paths do
            self = value
            key = path
            value = value[path]
        end

        self[key] = action.value
    else
        newState[action.type] = action.value
    end

    return newState
end

local function useState(key: string)
    local value = React.useMemo(function()
        local state: ClientState = store:getState()
    
        local paths = key:split(".")
        local value = state

        for _index, path in paths do
            value = value[path]
        end

        return value
    end, { key })

    local value, setValue = React.useState(value)

    local setState = React.useCallback(function(newValue)
        store:dispatch({
            type = "ui",
            key = key,
            value = newValue,
        })
    end, { key })

    React.useEffect(function()
        return store.changed:connect(function(newState: ClientState)
            local paths = key:split(".")
            local newValue = newState

            for _index, path in paths do
                newValue = newValue[path]
            end

            if newValue ~= value then
                setValue(newValue)
            end
        end).disconnect
    end, { value })

    return value, setState
end

if RunService:IsClient() then
    initialState = {
        debugEnabled = false,
        ui = {},
    } :: ClientState

    creators = {}
    middlewares = {}
else
    initialState = {} :: ServerState
    creators = {}
    middlewares = {}
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
    store = store,
    useState = useState,
    creators = creators,
}
