--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local useThrottleCallback = require(script.Parent.useThrottleCallback)

type Dispatch<A> = (action: A) -> ()
type SetStateAction<S> = S | ((prevState: S) -> ())

local function useThrottleState<T>(
    initialState: T,
    options: useThrottleCallback.UseThrottleOptions?
): (T, Dispatch<SetStateAction<T>>)
    local state, setState = React.useState(initialState)
    return state, (useThrottleCallback(setState, options).run :: any) :: Dispatch<SetStateAction<T>>
end

return useThrottleState
