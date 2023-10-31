local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = script.Parent.Parent

local Packages = ReplicatedStorage.Packages
local Shared = script.Parent

local ReactTemplate = {}

local APIDump; if RunService:IsClient() then
	local success; success, APIDump = require(Shared.APIDump):await(); if success then
		APIDump = table.clone(APIDump)

		for classIndex, Class in APIDump.Classes do
			if Class.Tags and table.find(Class.Tags, "Service") then
				APIDump.Classes[classIndex] = nil
			else
				for propertyIndex, Property in Class.Members do
					if Property.Name == "Name" or
						Property.MemberType ~= "Property"
						or (Property.Tags and (table.find(Property.Tags, "NotScriptable") or table.find(
							Property.Tags,
							"ReadOnly"
						)))
						or (
							(type(Property.Security) == "string" and Property.Security ~= "None")
							or Property.Security.Read ~= "None"
							or Property.Security.Write ~= "None"
						)
					then
						Class.Members[propertyIndex] = nil
					else
						Class.Members[propertyIndex] = Property.Name
					end
				end
			end
		end
		
		local function merge(into: table, from: table, none: any?)
			local new = table.clone(into)
		
			for key, value in from do
				if value == none then
					value = nil
				end
				new[key] = value
			end
		
			return new
		end
		
		local function fetchProperties(container: table, class: string, instance: Instance)
			for _index, Class in APIDump.Classes do
				if Class.Name == class then
					for _index, Property in Class.Members do
						container[Property] = (instance :: any)[Property]
					end
		
					if Class.Superclass then
						return fetchProperties(container, Class.Superclass, instance)
					end
				end
			end
		
			return container
		end

		local React = require(Packages.React)
		
		function ReactTemplate.fromInstance(instance: Instance): React.StatelessFunctionalComponent<table>
			local defaultProps = fetchProperties({}, instance.ClassName, instance)
			local defaultChildren = {}
		
			local instanceChildren = instance:GetChildren()
			local children = {}
		
			for _index, child in instanceChildren do
				defaultChildren[child.Name] = ReactTemplate.fromInstance(child)
			end
		
			for key, element in defaultChildren do
				children[key] = React.createElement(element)
			end
		
			return React.memo(function(props: React.ElementProps<React.StatelessFunctionalComponent<table>>)
				local propChildren = props.children or {}
		
				for key, child in propChildren do
					propChildren[key] = if child == React.None or child["$$typeof"] then
						child else React.createElement(defaultChildren[key], child)
				end
		
				props.children = merge(children, propChildren, React.None)
		
				return React.createElement(instance.ClassName, merge(defaultProps, props, React.None))
			end) :: any
		end
	else
		Players.LocalPlayer:Kick("Error fetching api.")
	end
else
	require(Shared.APIDump)
end

return ReactTemplate
