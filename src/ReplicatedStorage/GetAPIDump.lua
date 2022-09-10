--#selene: allow(multiple_statements)
-- Only includes level 0 properties and classes (not services)

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = script.Parent.Parent

local Packages = ReplicatedStorage:FindFirstChild("Packages")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")

local Promise = require(Packages:FindFirstChild("Promise"))

local GetAPIDump = Remotes:FindFirstChild("GetAPIDump")

return Promise.new(function(resolve)
    local APIDump; for _i = 1, math.huge do
        APIDump = GetAPIDump:InvokeServer(); if APIDump then break end

        task.wait(0.5)
    end

    APIDump = HttpService:JSONDecode(APIDump)

    for classIndex, Class in APIDump.Classes do
        if Class.Tags and table.find(Class.Tags, "Service") then
            APIDump.Classes[classIndex] = nil
        else
            for propertyIndex, Property in Class.Members do
                if Property.MemberType ~= "Property"
                    or (Property.Tags and (table.find(Property.Tags, "NotScriptable") or table.find(Property.Tags, "ReadOnly")))
                    or ((type(Property.Security) == "string" and Property.Security ~= "None") or Property.Security.Read ~= "None" or Property.Security.Write ~= "None")
                then
                    Class.Members[propertyIndex] = nil
                else
                    Class.Members[propertyIndex] = Property.Name
                end
            end
        end
    end
    
    resolve(APIDump)
end)
