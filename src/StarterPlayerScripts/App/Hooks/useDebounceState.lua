--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local useDebounceCallback = require(script.Parent.useDebounceCallback)

type Dispatch<A> = (action: A) -> ()
type SetStateAction<S> = S | ((prevState: S) -> ())

local function useDebounceState<T>(
    initialState: T,
    options: useDebounceCallback.UseDebounceOptions?
): (T, Dispatch<SetStateAction<T>>)
    local state, setState = React.useState(initialState)
    return state, (useDebounceCallback(setState, options).run :: any) :: Dispatch<SetStateAction<T>>
end

return useDebounceState
