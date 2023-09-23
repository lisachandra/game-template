local React = require(game:GetService("ReplicatedStorage").Packages.React)

local function useToggleState(default: boolean): {
	on: boolean,
	enable: () -> (),
	disable: () -> (),
	toggle: () -> (),
}
	local toggled, setToggled = React.useState(default)

	local enable = React.useCallback(function()
		setToggled(true)
	end, {})

	local disable = React.useCallback(function()
		setToggled(false)
	end, {})

	local toggle = React.useCallback(function()
		setToggled(function(currentToggled)
			return not currentToggled
		end)
	end, {})

	return {
		on = toggled,
		enable = enable,
		disable = disable,
		toggle = toggle,
	}
end

return useToggleState
