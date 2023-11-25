--!nonstrict
local React = require(game:GetService("ReplicatedStorage").Packages.React)

local function useProperty(...: string): (table, ...unknown)
    local properties = table.pack(...)

    local values, setValues = React.useState({})

    local events = React.useMemo(function()
        local events = {}; for index, property in properties do
            events[React.Change[property]] = function(rbx: Instance)
                setValues(function(values)
                    local update = table.clone(values)
                    update[index] = rbx[property]

                    return update
                end)
            end
        end
    end, properties)

    local results = React.useMemo(function()
        return { events, table.unpack(table.clone(values)) }
    end, { values, events })

    return table.unpack(results)
end

return useProperty
