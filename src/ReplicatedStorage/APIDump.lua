local ReplicatedStorage = script.Parent.Parent

local Packages = ReplicatedStorage.Packages

local Promise = require(Packages.Promise)

return Promise.new(function(resolve)
    local HttpService = game:GetService("HttpService")
    local RunService = game:GetService("RunService"); if not RunService:IsRunning() then
        local APIDump = HttpService:GetAsync("https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/API-Dump.json")
        local APIDump = HttpService:JSONDecode(APIDump)

        resolve(APIDump)
    elseif RunService:IsClient() then
        resolve(script:WaitForChild("GetAPIDump"):InvokeServer())
    else
        local APIDump = HttpService:GetAsync("https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/API-Dump.json")
        local APIDump = HttpService:JSONDecode(APIDump)

        local GetAPIDump = Instance.new("RemoteFunction")
        GetAPIDump.Name = "GetAPIDump"
        GetAPIDump.OnServerInvoke = function()
            return APIDump
        end :: any

        GetAPIDump.Parent = script

        resolve(APIDump)
    end    
end)
