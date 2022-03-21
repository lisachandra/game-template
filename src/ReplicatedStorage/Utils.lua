local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local function CreateUtils()
	local IsClient = RunService:IsClient()

	local Player, PlayerGui, Mouse
	do
		if IsClient then
			Player = Players.LocalPlayer
			PlayerGui = Player.PlayerGui
			Mouse = Player:GetMouse()
		end
	end

	local Utils = {}

	type GenericTable = { [any]: any }

	function Utils.clone<T>(tbl: T): T
		-- selene: allow(incorrect_standard_library_use)
		assert(type(tbl) == "table")

		local new = {}

		for key, value in pairs(tbl :: GenericTable) do
			if type(value) == "table" then
				new[key] = Utils.clone(value)
			else
				new[key] = value
			end
		end

		return new
	end

	function Utils.getLength(tbl: GenericTable): number
		local entries = 0
		for k, _v in pairs(tbl) do
			if tonumber(k) and tonumber(k) > entries then
				entries = tonumber(k)
			else
				entries += 1
			end
		end

		return entries
	end

	function Utils.merge<T>(t1: T, t2: GenericTable): T
		for key, value in pairs(t2) do
			(t1 :: GenericTable)[key] = value
		end

		return t1
	end

	function Utils.flexibleFind(tbl: GenericTable, v: any): any?
		for key, value in pairs(tbl) do
			if value == v then
				return key
			end
		end
	end

	function Utils.insert<T>(t1: T, T: any): T
		table.insert(t1 :: any, T)
		return t1
	end

	if IsClient then
		function Utils.isHoveringOver(Parent: GuiObject): GuiObject?
			local Elements = PlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y)

			for _index, element in pairs(Elements) do
				if element.Parent == Parent then
					return element
				end
			end
		end
	end

	return Utils
end

return CreateUtils
