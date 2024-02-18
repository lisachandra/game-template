--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local GoodSignal = require(ReplicatedStorage.Shared.GoodSignal)

local useLatest = require(script.Parent.useLatest)

type Signal<T...> = RBXScriptSignal<T...> | GoodSignal.Signal<T...>
type Connection = RBXScriptConnection | GoodSignal.Connection

type useEventConnection = (
	(<T...>(
		event: Signal<T...>,
		callback: (Connection, T...) -> (),
		options: { passInConnection: true, once: boolean? }?
	) -> ()) &
	(<T...>(
		event: Signal<T...>,
		callback: (T...) -> (),
		options: { passInConnection: false?, once: boolean? }?
	) -> ())
)

local useEventConnection = function<T...>(
	event: Signal<T...>,
	callback: () -> (),
	options: { passInConnection: boolean?, once: boolean? }?
)	
	local isRBXScriptSignal = typeof(event) == "RBXScriptSignal"
	local options = {
		passInConnection = options and options.passInConnection or false,
		once = options and options.once or false,
	}

	local callbackRef = useLatest(callback)

	React.useEffect(function()
		local canDisconnect = true
		local connection; connection = (event.Connect :: any)(event, function(...)
			if isRBXScriptSignal and not connection.Connected then
				return
			end

			if options.once then
				connection:Disconnect()
				canDisconnect = false
			end

			if options.passInConnection then
				callbackRef.current(connection, ...)
			else
				callbackRef.current(...)
			end
		end)

		return function()
			if canDisconnect then
				connection:Disconnect()
			end
		end
	end, { event, options.passInConnection, options.once })
end

return useEventConnection :: useEventConnection
