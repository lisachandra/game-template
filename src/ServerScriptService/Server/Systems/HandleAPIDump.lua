local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:FindFirstChild("Packages")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")

local Hooks = script.Parent.Parent.Hooks
local Server = script.Parent.Parent.Server

local Promise = require(Packages:FindFirstChild("Promise"))

local ProxyService = require(Server:FindFirstChild("ProxyService"))

local useDependency = require(Hooks:FindFirstChild("useDependency"))

local GetAPIDump = Remotes:FindFirstChild("GetAPIDump")

local Proxy = ProxyService:New(
	"https://proxyservice000.herokuapp.com/",
	"996055c035b020519245b6851c41e97a5dd3156e9b659467f375d32980bd9bdf"
)

local GetAsync
do
	local Get = Promise.promisify(function(url, nocache, headers, overrideProto)
		return Proxy:Get(url, nocache, headers, overrideProto)
	end)

	GetAsync = function(url, nocache, headers, overrideProto)
		return Promise.retry(Get, math.huge, url, nocache, headers, overrideProto)
	end
end

local function HandleAPIDump()
	useDependency(function()
		GetAPIDump.OnServerInvoke = function()
			return false
		end :: any

		GetAsync("https://setup.roblox.com/versionQTStudio"):andThen(function(Version)
			GetAsync("https://setup.roblox.com/" .. Version.body .. "-API-Dump.json"):andThen(function(APIDump)
				GetAPIDump.OnServerInvoke = function()
					return APIDump.body
				end
			end)
		end)
	end, {})
end

return HandleAPIDump
