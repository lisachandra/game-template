local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Packages = script.Parent.Parent.Packages

local Matter = require(Packages.Matter)
local Plasma = require(Packages.Plasma)

local Rodux = require(script.Parent.Rodux)
local Components = require(script.Parent.Components)

local instanceKeys = { PlayerData = "Player" }

local function Start(container: Instance)
	local world = Matter.World.new()
	local debugger = Matter.Debugger.new(Plasma)

	function debugger.findInstanceFromEntity(id: number)
		if not world:contains(id) then return end

		for key in Components do
			if not instanceKeys[key] then continue end

			local component = world:get(id, Components[key]); if component then
				return component[instanceKeys[key]]
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
				Rodux.store:dispatch(function(store)
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
