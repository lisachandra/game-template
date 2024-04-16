local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local React = require(Packages.React)
local Sift = require(Packages.Sift)

local e = React.createElement

--[[
    https://discord.com/channels/385151591524597761/895437663040077834/917872256305221682

	props = {
		ItemCount: number = how many items are in the scroller
		ItemHeight: state<number> = how many pixels tall each item is
		RenderItem(index: number): function = Takes the index of what item it is, returns Instance(s) to mount in the list (aka a component with an index as the prop)
	}
]]

type props = {
    template: React.ReactNode?,

    native: table?,
    itemNative: table?,

    ItemCount: number,
    ItemHeight: number,

    RenderItem: (index: number) -> React.ReactNode,
}

local function VirtualScroller(props: props)
    props.native = props.native or {}
    props.itemNative = props.itemNative or {}

    local WindowSize, setWindowSize = React.useState(Vector2.zero)
    local CanvasPosition, setCanvasPosition = React.useState(Vector2.zero)

    local numItems = props.ItemCount
    local itemHeight = props.ItemHeight

    local elements; do
        local minIndex = 0
		local maxIndex = -1

		if numItems > 0 then
			minIndex = 1 + math.floor(CanvasPosition.Y / itemHeight)
			maxIndex = math.ceil((CanvasPosition.Y + WindowSize.Y) / itemHeight)
            -- Add extra on either side for seamless load
			minIndex = math.clamp(minIndex - 1, 1, numItems)
			maxIndex = math.clamp(maxIndex + 1, 1, numItems)
		end

        -- Dict for stable keys
		local items = table.create(maxIndex - minIndex + 1)
		for index = minIndex, maxIndex do
			items[index] = true
		end

        elements = {}; for index in items do
            elements[`Index_{index}`] = e("Frame", Sift.Dictionary.merge(
                {
                    BackgroundTransparency = 1,
                    BackgroundColor3 = Color3.fromRGB(math.random(10, 255), math.random(10, 255), math.random(10, 255)),
                },
                props.itemNative,
                {
                    LayoutOrder = index,
                    Size = UDim2.new(1, 0, 0, itemHeight),
                    Position = UDim2.new(0, 0, 0, (index - 1) * itemHeight),
    
                    children = { props.RenderItem(index) },
                }
            ))
        end
    end

    local mergedProps = if props.template then props.native else Sift.Dictionary.merge({
        ClipsDescendants = true,
		Visible = true,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.new(),
		BorderSizePixel = 0,
		BorderColor3 = Color3.fromRGB(10,10,13),
		BackgroundColor3 = Color3.fromRGB(46, 46, 46),
		ScrollBarImageColor3 = Color3.fromRGB(64, 64, 64),
		ScrollBarThickness = 12,
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
    }, props.native)

    return e((props.template or "ScrollingFrame") :: any, Sift.Dictionary.merge(mergedProps, {
        CanvasSize = UDim2.fromOffset(0, numItems * itemHeight),

        [React.Change.CanvasPosition] = React.useCallback(function(rbx: ScrollingFrame)
            -- Exit if the canvas hasn't moved enough to warrant rendering new items
			local distance = (CanvasPosition - rbx.CanvasPosition).Magnitude
			local minimum = itemHeight

			if distance < minimum then return end

			setCanvasPosition(rbx.CanvasPosition)
        end, { CanvasPosition, itemHeight } :: Array<any>),

        [React.Change.AbsoluteWindowSize] = function(rbx: ScrollingFrame)
            setWindowSize(rbx.AbsoluteWindowSize)
        end,

        children = elements,
    }))
end

return VirtualScroller
