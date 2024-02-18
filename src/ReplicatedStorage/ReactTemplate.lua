local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = script.Parent.Parent

local Packages = ReplicatedStorage.Packages
local Shared = script.Parent

local ReactTemplate = {}

local APIDump; if not RunService:IsClient() then
	require(Shared.APIDump); return ReactTemplate
end

local success; success, APIDump = require(Shared.APIDump):await(); if not success then
	Players.LocalPlayer:Kick("Error fetching api."); return ReactTemplate
end

local React = require(Packages.React)

APIDump = table.clone(APIDump)
ReactTemplate._Wrap = newproxy(false)
ReactTemplate._Link = newproxy(false)
ReactTemplate._LinkContext = React.createContext({} :: LinkContext)

type ReactElement<T = table> = React.StatelessFunctionalComponent<T>
export type LinkContext = {
	value: ReactElement,
}

for classIndex, Class in APIDump.Classes do
	if Class.Tags and table.find(Class.Tags, "Service") then
		APIDump.Classes[classIndex] = nil; continue
	end

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

function ReactTemplate.fromInstance(instance: Instance)
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

	local function processChild(key: string, child: any)
		return if child[ReactTemplate._Wrap] then
			React.createElement(child.element, child.props)
		elseif child == React.None or child["$$typeof"] then
			child else React.createElement(defaultChildren[key], child)
	end

	return React.memo(function(props: any)
		local propChildren = props.children or {}

		for key, child in propChildren do
			child = type(child) == "table" and child or {}
			propChildren[key] = if child[ReactTemplate._Link] then
				React.createElement(
					ReactTemplate._LinkContext.Provider,
					{ value = defaultChildren[key] },
					{ [key] = processChild(key, child.element) } 
				)
			else processChild(key, child)
		end

		props.children = merge(children, propChildren, React.None)

		return React.createElement(instance.ClassName, merge(defaultProps, props, React.None))
	end) :: any
end

function ReactTemplate.Wrap<T>(element: ReactElement, props: table, children: table?)
	if children then
		props = table.clone(props)
		props.children = children
	end

	return {
		[ReactTemplate._Wrap] = true,
		element = element,
		props = props,
	}
end

function ReactTemplate.Link<T>(element: table | ReactElement)
	return {
		[ReactTemplate._Link] = true,
		element = element,
	}
end

function ReactTemplate.useLinkedTemplate()
	local LinkContext = React.useContext(ReactTemplate._LinkContext)
	return LinkContext and LinkContext.value
end

return ReactTemplate
