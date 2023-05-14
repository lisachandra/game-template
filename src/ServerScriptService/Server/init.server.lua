local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Server = script.Server

local Packages = ReplicatedStorage:FindFirstChild("Packages")

local Janitor = require(Packages:FindFirstChild("Janitor"))
local Matter = require(Packages:FindFirstChild("Matter"))
local Components = require(Server:FindFirstChild("Components"))

-- Intialize APIDump
require(Packages._Index["zxibs_apidump@1.0.2"]["apidump"])

local world = Matter.World.new()
local loop = Matter.Loop.new(world)

local function onPlayerAdded(Player: Player)
	Player:SetAttribute(
		"entityId",
		world:spawn(Components.PlayerData({
			Player = Player,
			Janitor = Janitor.new(),
		}))
	)
end

local systems = {}
for _i, system in script.Systems:GetChildren() do
	if system.ClassName == "ModuleScript" then
		table.insert(systems, require(system))
	end
end

loop:scheduleSystems(systems)
loop:begin({
	default = RunService.Heartbeat,
})

for _index, Player in Players:GetPlayers() do
	onPlayerAdded(Player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(Player)
    local id: number = Player:GetAttribute("entityId") 

    local PlayerData: Types.PlayerData = world:get(id, Components.PlayerData)

    PlayerData.Janitor:Destroy()
	world:despawn(id)
end)
