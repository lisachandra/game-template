--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.React)

local useEventConnection = require(script.Parent.useEventConnection)
local useValue = require(script.Parent.useValue)

export type Timer = {
	value: React.Binding<number>,

	start: () -> (),
	stop: () -> (),
	reset: () -> (),
	set: (value: number) -> (),
}

local function useTimer(initialValue: number?): Timer
	local initialValue = initialValue or 0

	local value, setValue = React.useBinding(initialValue)
	local started = useValue(true)

	useEventConnection(RunService.Heartbeat, function(dt: number)
		if started.current then
			setValue(value:getValue() + dt)
		end
	end)

	local start = React.useCallback(function()
		started.current = true
	end, {})

	local stop = React.useCallback(function()
		started.current = false
	end, {})

	local reset = React.useCallback(function()
		setValue(0)
	end, {})

	local set = React.useCallback(function(value: number)
		setValue(value)
	end, {})

	return {
		value = value,

		start = start, 
		stop = stop, 
		reset = reset, 
		set = set,
	}
end

return useTimer
