--!nonstrict
local React = require(game:GetService("ReplicatedStorage").Packages.React)
local useLatestCallback = require(script.Parent.useLatestCallback)

type Binding<T> = React.Binding<T> & {
    subscribe: (self: React.Binding<T>, callback: (newValue: T) -> ()) -> (),
    update: (self: React.Binding<T>, newValue: T) -> (),
}

local function useBindingConnection<T>(binding: React.Binding<T>, callback: (value: T) -> ())
    local binding: Binding<T> = binding :: Binding<T>
    local listenerCallback = useLatestCallback(callback)

    React.useEffect(function()
        listenerCallback(binding:getValue())
        return binding:subscribe(listenerCallback)
    end, { binding })
end

return useBindingConnection
