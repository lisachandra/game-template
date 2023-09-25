local ReplicatedStorage = script.Parent.Parent.Parent

local Packages = ReplicatedStorage.Packages

local React = require(Packages.React)

local RouterContext = require(script.Parent.RouterContext)

local function useRouter()
    return React.useContext(RouterContext)
end

return useRouter
