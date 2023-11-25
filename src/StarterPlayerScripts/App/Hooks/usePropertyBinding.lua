--!nonstrict
local React = require(game:GetService("ReplicatedStorage").Packages.React)

local function usePropertyBinding(...: string): (table, ...React.Binding<unknown>)
    local properties = table.pack(...)

    local bindings, bindingSetters = React.useMemo(function()
        local bindings: Array<React.Binding<unknown>> = {}
        local setBindings: Array<((value: unknown) -> ())> = {}

        for index in properties do
            local binding, setBinding = React.createBinding(nil :: any)

            bindings[index] = binding
            setBindings[index] = setBinding
        end

        return bindings, setBindings
    end, properties)

    local events = React.useMemo(function()
        local events = {}; for index, property in properties do
            events[React.Change[property]] = function(rbx: Instance)
                bindingSetters[index](rbx[property])
            end
        end

        return events
    end, properties)

    local results = React.useMemo(function()
        return { events, table.unpack(table.clone(bindings)) }
    end, { bindings, events })

    return table.unpack(results)
end

return usePropertyBinding
