local function defaultEqualityFn(newState, oldState)
	return newState == oldState
end

local function useCustomSelector(
	hooks,
	selector: (state: table) -> any,
	equalityFn: ((newState: table, oldState: table) -> boolean)?,
	context
)
	local store = hooks.useContext(context)
	local mappedState, setMappedState = hooks.useState(function()
		return selector(store:getState())
	end)

	if equalityFn == nil then
		equalityFn = defaultEqualityFn
	end

	hooks.useEffect(function()
		local storeChanged = store.changed:connect(function(newState, _oldState)
			local newMappedState = selector(newState)

			if not equalityFn(newMappedState, mappedState) then
				setMappedState(newMappedState)
			end
		end)

		return function()
			storeChanged:disconnect()
		end
	end, {})

	return mappedState
end

return useCustomSelector
