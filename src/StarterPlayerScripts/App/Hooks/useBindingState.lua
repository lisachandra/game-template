--!nonstrict
local React = require(game:GetService("ReplicatedStorage").Packages.React)
local useBindingConnection = require(script.Parent.useBindingConnection)

local function useBindingState<T>(binding: React.Binding<T>): T
    local value, setValue = React.useState(binding:getValue())
    useBindingConnection(binding, setValue)

    return value
end

return useBindingState
