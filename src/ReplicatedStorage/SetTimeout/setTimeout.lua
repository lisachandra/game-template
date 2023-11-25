local RunService = game:GetService("RunService")

local function setTimeout(callback: () -> (), timeout: number)
    local timer = 0

    local connection; connection = RunService.Heartbeat:Connect(function(dt)
        timer += dt

        if timer >= timeout then
            connection:Disconnect()
            callback()
        end
    end)
    
    return function()
        connection:Disconnect()
    end
end

return setTimeout
