local function lock(t: { [any]: any }, name: string)
	local userdata = newproxy(true)
	local metatable = getmetatable(userdata)

	function metatable:__tostring()
		return name
	end

	function metatable:__newindex(key, value)
		error(("%s.%s cannot be assigned to %s (%s)"):format(name, tostring(key), tostring(value), typeof(value)))
	end

	function metatable:__index(key)
		local value = t[key]

		if value ~= nil and not (type(key) == "string" and key:sub(1, 1):match("_")) then
			if type(value) == "function" then
				return function(_t, ...)
					return value(t, ...)
				end
			else
				return value
			end
		end

		error(("%s (%s) is not a valid member of %s"):format(tostring(key), typeof(key), name))
	end

	metatable.__metatable = "This metatable is locked"

	return userdata
end

export type SimpleState<T> = {
	Subscribe: (self: any, callback: (new: T, old: T) -> ()) -> () -> (),
	Set: (self: any, new: T) -> (),
	Get: (self: any) -> T,
}

local SimpleState = {}
SimpleState.__index = SimpleState

function SimpleState.new<T>(initialValue: T): SimpleState<T>
	return lock(
		setmetatable({
			_value = initialValue,
		}, SimpleState) :: any,
		("SimpleState<%s>"):format(typeof(initialValue))
	) :: any
end

function SimpleState:Subscribe<T>(callback: (T) -> ()): () -> ()
	table.insert(self, callback)

	return function()
		local index = table.find(self, callback)

		if index then
			table.remove(self, index)
		end
	end
end

function SimpleState:Set<T>(new: T): ()
	local callbacks = #self
	local old = self._value

	self._value = new

	if callbacks > 0 then
		local callbacksTable = table.move(self, 1, callbacks, 1, table.create(callbacks))

		for index = 1, callbacks do
			task.defer(callbacksTable[index], new, old)
		end
	end
end

function SimpleState:Get<T>(): T
	return self._value
end

return SimpleState
