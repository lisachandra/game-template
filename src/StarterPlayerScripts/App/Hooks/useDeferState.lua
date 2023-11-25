--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local useDeferCallback = require(script.Parent.useDeferCallback)
local useLatest = require(script.Parent.useLatest)

type Dispatch<A> = (action: A) -> ()
type SetStateAction<S> = S | ((prevState: S) -> ())

type useDeferState = (
    (<T>(initialState: T | (() -> T)) -> (T, Dispatch<SetStateAction<T>>)) &
    (<T>(initialState: nil) -> (T?, Dispatch<SetStateAction<T?>>))
) 

local function resolve<T>(value: T | ((state: T) -> T), state: T): T
    return if type(value) == "function" then value(state) else value
end

local useDeferState: useDeferState = function<T>(initialState)
    local state, innerSetState = React.useState(initialState :: T)
    local deferredSetState, cancel = useDeferCallback(innerSetState)

    local latestState = useLatest(state)

    local setState = React.useCallback(function(value: SetStateAction<T>)
        latestState.current = resolve(value, latestState.current)
        deferredSetState(latestState.current)
    end, {})

    React.useEffect(function()
        return cancel
    end, {})

    return state, setState
end :: useDeferState

return useDeferState
