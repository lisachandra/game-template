local React = require(game:GetService("ReplicatedStorage").Packages.React)

local function useEventConnection<T...>(
	event: RBXScriptSignal<T...>, -- Can also include | Signal.Signal<T...> if you're using a custom signal type
	callback: (T...) -> (),
	dependencies: { any }
)
	local cachedCallback = React.useMemo(function()
		return callback
	end, dependencies)

	React.useEffect(function()
		local connection = event:Connect(cachedCallback)

		return function()
			connection:Disconnect()
		end
	end, { event, cachedCallback } :: Array<any>)
end

return useEventConnection
