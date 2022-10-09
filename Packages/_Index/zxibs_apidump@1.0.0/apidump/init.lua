local Promise = script.Parent:FindFirstChild("Promise"); return Promise.new(function(resolve)
    local HttpService = game:GetService("HttpService")
    local RunService = game:GetService("RunService"); if RunService:IsClient() then
        resolve(HttpService:JSONDecode(script:WaitForChild("GetAPIDump"):InvokeServer()))
    else
        local APIDump = HttpService:GetAsync("https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/API-Dump.json")

        local GetAPIDump = Instance.new("RemoteFunction")
        GetAPIDump.Name = "GetAPIDump"
        GetAPIDump.OnServerInvoke = function()
            return APIDump
        end :: any

        GetAPIDump.Parent = script

        resolve(HttpService:JSONDecode(APIDump))
    end    
end)
