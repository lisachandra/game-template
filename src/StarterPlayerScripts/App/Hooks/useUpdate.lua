--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local function useUpdate()
    local state, setState = React.useState({})

    return React.useCallback(function()
        setState({})
    end, { state })
end

return useUpdate
