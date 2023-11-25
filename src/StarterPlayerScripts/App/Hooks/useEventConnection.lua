--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local GoodSignal = require(ReplicatedStorage.Shared.GoodSignal)

local function useEventConnection<T...>(
	event: RBXScriptSignal<T...> | GoodSignal.Signal<T...>,
	callback: (T...) -> (),
	dependencies: Array<unknown>?
)
	local cachedCallback = React.useMemo(function()
		return callback
	end, dependencies)

	React.useEffect(function()
		local connection = (event.Connect :: any)(event, cachedCallback)

		return function()
			connection:Disconnect()
		end
	end, { event, cachedCallback })
end

return useEventConnection
