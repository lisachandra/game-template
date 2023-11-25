local Promise = require(game:GetService("ReplicatedStorage").Packages.Promise)

local function setCountdown(callback: (secondsLeft: number) -> (), countdown: number, interval: number?)
    local interval = interval or 1
    local array = {}; for index = countdown, 0, -1 do
        table.insert(array, index)
    end
    
    return Promise.each(function(_value, index: number)
        callback(countdown - (index - 1))
        return Promise.delay(interval)
    end)
end

return setCountdown
