--!nonstrict

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Packages = script.Parent.Parent.Packages
local Shared = script.Parent

local Matter = require(Shared.Matter)
local Plasma = require(Packages.Plasma)

local Rodux = require(Shared.Rodux)
local Components = require(Shared.Components)

local instanceKeys = { PlayerData = "Player" }

local function Start(container: Instance)
	local world = Matter.World.new()
	local debugger = Matter.Debugger.new(Plasma)

	function debugger.findInstanceFromEntity(id: number)
		if not world:contains(id) then return end

		for key: string, component: Matter.Component<any> in Components do
			if not instanceKeys[key] then continue end

			local componentInstance = world:get(id, component); if componentInstance then
				return componentInstance[instanceKeys[key]]
			end
		end

		return
	end

	function debugger.authorize(player: Player)
		local role = player:GetRoleInGroup(4272924); if role == "Developers" or role == "Owner" then
			return true
		end

		return
	end

	local loop = Matter.Loop.new(world, Rodux.store, debugger:getWidgets())

    local systems = {}; for _i, system in container:GetChildren() do
        table.insert(systems, require(system))
    end

	loop:scheduleSystems(systems)
	debugger:autoInitialize(loop)

	loop:begin({
		default = RunService.Heartbeat,
		Stepped = RunService.Stepped,
	})

	if RunService:IsClient() then
		UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.F4 then
				Rodux.store:dispatch(function(store: Rodux.Store)
                    debugger:toggle()

                    store:dispatch({
                        type = "debugEnabled",
                        value = debugger.enabled,
                    })
                end)
			end
		end)
	end

	return world, Rodux.store
end

return Start
