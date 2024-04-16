local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local React = require(Packages.React)

local History = require(script.Parent.History)
local RouterContext = require(script.Parent.RouterContext)

local e = React.createElement

type props = {
    history: History.History?,
    children: table?,
}

local Router: React.StatelessFunctionalComponent<props>

function Router(props)
    local history = React.useRef(History.new()); if not history.current then
        return
    end

    local location, setLocation = React.useState(history.current.location)

    React.useEffect(function()
        local listener = history.current.onChanged:Connect(function()
            setLocation(history.current.location)
        end)

        return function()
            listener:Disconnect()
        end
    end, {})

    return e(RouterContext.Provider, {
        value = {
            location = location,
            history = history.current
        },
    }, props.children)
end

return Router
