local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = script.Parent.Parent

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Shared.Matter)
local Plasma = require(Packages.Plasma)

local Rodux = require(Shared.Rodux)
local Components = require(Shared.Components)

local function Start(container: Instance)
	local world = Matter.World.new()
	local debugger = Matter.Debugger.new(Plasma)

	function debugger.findInstanceFromEntity(entityId: number)
		if not world:contains(entityId) then return end

		local Tag = world:get(entityId, Components.Tag); if Tag.Value == "Player" then
			local PlayerData = world:get(entityId, Components.PlayerData); if PlayerData then
				return PlayerData.Player.Character
			end
		end

		return
	end

	function debugger.authorize(Player: Player)
		local role = Player:GetRoleInGroup(4272924); if role == "Developers" or role == "Owner" then
			return true
		end

		return
	end

	local loop = Matter.Loop.new(world, Rodux.store, debugger:getWidgets())

    local systems = {}; for _index, system in container:GetChildren() do
        table.insert(systems, require(system) :: any)
    end

	Rodux.store:dispatch(function(store: Rodux.Store)
		store:dispatch({
			type = "world",
			value = world,
		})

		loop:scheduleSystems(systems)
		debugger:autoInitialize(loop)

		loop:begin({
			default = RunService.Heartbeat,
			Stepped = RunService.Stepped,
		})
	end)

	if RunService:IsClient() then
		UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.F4 then
				Rodux.store:dispatch(function(store: Rodux.Store)
                    store:dispatch({
						type = "debugEnabled",
						value = not debugger.enabled,
                    })
					
					debugger:toggle()
                end)
			end
		end)
	end

	return world, Rodux.store
end

return Start
