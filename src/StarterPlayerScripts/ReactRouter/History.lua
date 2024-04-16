local Shared = game:GetService("ReplicatedStorage").Shared

local GoodSignal = require(Shared.GoodSignal)

local History = {}
History.__index = History

function History.new(initialEntries: Array<string>?, initialIndex: number?)
	local initialEntries = initialEntries or { "/" }
	local initialIndex = initialIndex or #initialEntries

	local entries: Array<HistoryEntry> = {}

	for _, path in ipairs(initialEntries) do
		table.insert(entries, {
			path = path,
			state = {},
		})
	end

	return setmetatable({
		location = entries[initialIndex],
		onChanged = GoodSignal.new() :: GoodSignal.Signal<string, table>,

		_entries = entries,
		_index = initialIndex,
	}, History)
end

function History:_removeFutureEntries()
    self = self :: History

	if #self._entries > self._index then
		for index = self._index + 1, #self._entries do
			self._entries[index] = nil
		end
	end
end

function History:push(path: string, state: table?)
    self = self :: History
	self:_removeFutureEntries()

	local entry = {
		path = path,
		state = state or {},
	}

	table.insert(self._entries, entry)
	self._index = #self._entries

	self.location = entry
	self.onChanged:Fire(entry.path, entry.state)
end

function History:replace(path: string, state: table?)
    self = self :: History
	self:_removeFutureEntries()

	local entry = {
		path = path,
		state = state or {},
	}

	self._entries[#self._entries] = entry

	self.location = entry
	self.onChanged:Fire(entry.path, entry.state)
end

function History:go(offset: number)
    self = self :: History
	self._index = math.clamp(self._index + offset, 1, #self._entries)

	self.location = self._entries[self._index]
	self.onChanged:Fire(self.location.path, self.location.state)
end

function History:goBack()
    self = self :: History
	return self:go(-1)
end

function History:goForward()
    self = self :: History
	return self:go(1)
end

function History:goToStart()
    self = self :: History
	return self:go(-(self._index - 1))
end

function History:goToEnd()
    self = self :: History
	return self:go(#self._entries - self._index)
end

export type History = typeof(History.new())
export type HistoryEntry = { path: string, state: table }

return History
