local RunService = game:GetService("RunService")

local React = require(game:GetService("ReplicatedStorage").Packages.React)

local function useClock(): React.Binding<number>
	local clockBinding, setClockBinding = React.useBinding(0)

	React.useEffect(function()
		local stepConnection = RunService.PostSimulation:Connect(function(delta)
			setClockBinding(clockBinding:getValue() + delta)
		end)

		return function()
			stepConnection:Disconnect()
		end
	end, {})

	return clockBinding
end

return useClock
