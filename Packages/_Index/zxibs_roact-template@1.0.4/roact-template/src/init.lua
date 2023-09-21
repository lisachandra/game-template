local RunService = game:GetService("RunService")

local RoactTemplate = {}

local APIDump; if RunService:IsClient() then
	local success; success, APIDump = require(script.Parent:FindFirstChild("APIDump")):await(); if success then
		for classIndex, Class in APIDump.Classes do
			if Class.Tags and table.find(Class.Tags, "Service") then
				APIDump.Classes[classIndex] = nil
			else
				for propertyIndex, Property in Class.Members do
					if
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
		
		local Type: typeof(({} :: Roact).Type)
		RoactTemplate.None = newproxy(false)
		RoactTemplate.Wrap = newproxy(false)
		
		local function getType(Roact)
			for type in Roact.createElement("") do
				if tostring(type) == "RoactType" then
					return type
				end
			end
		end
		
		local function fetchProperties(container: table, class: string, instance: Instance)
			for _index, Class in APIDump.Classes do
				if Class.Name == class then
					for _index, Property in Class.Members do
						container[Property] = instance[Property]
					end
		
					if Class.Superclass then
						return fetchProperties(container, Class.Superclass, instance)
					end
				end
			end
		
			return container
		end
		
		function RoactTemplate.fromInstance(Roact: Roact, instance: Instance): RoactElementFn<table>
			Type = Type or getType(Roact)
		
			local defaultProps = fetchProperties({}, instance.ClassName, instance)
			local defaultChildren = {}
		
			local instanceChildren = instance:GetChildren()
			local children = {}
		
			for _index, child in instanceChildren do
				defaultChildren[child.Name] = RoactTemplate.fromInstance(Roact, child)
			end
		
			for key, element in defaultChildren do
				children[key] = Roact.createElement(element)
			end
		
			return function(props: table)
				props[Roact.Children] = props[Roact.Children] or {}
		
				for key, child in props[Roact.Children] do
					props[Roact.Children][key] = if Type.of(child) then
						child
					elseif child[RoactTemplate.Wrap] then
						Roact.createElement(
							child.component,
							merge(child.props, { [child.key] = defaultChildren[key] })
						)
					else Roact.createElement(defaultChildren[key], child)
				end
		
				props[Roact.Children] = merge(children, props[Roact.Children], RoactTemplate.None)
		
				return Roact.createElement(instance.ClassName, merge(defaultProps, props, RoactTemplate.None))
			end
		end
		
		function RoactTemplate.wrapped<P>(component: RoactElementFn<P>, props: P?, templateKey: any?)
			return {
				[RoactTemplate.Wrap] = true,
				component = component,
				props = props or {},
				key = templateKey or "template",
			}
		end
	else
		game:GetService("Players").LocalPlayer:Kick("Error fetching api.")
	end
else
	require(script.Parent:FindFirstChild("APIDump"))
end

return RoactTemplate
