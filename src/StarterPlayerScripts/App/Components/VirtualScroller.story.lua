local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)

local VirtualScroller = require(script.Parent.VirtualScroller)

local e = React.createElement

local controls = {
    ids = 500,
    height = 60,
}

type props = {
    controls: typeof(controls),
}

return {
    controls = controls,
    story = function(parent: GuiObject, props: props)
        local ids = tonumber(props.controls.ids) or controls.ids
        local height = tonumber(props.controls.height) or controls.height

        local items = table.create(ids)

        for index = 1, ids do
            items[index] = HttpService:GenerateGUID(false)
        end
        
        local tree = ReactRoblox.createRoot(Instance.new("Folder"))
        tree:render(ReactRoblox.createPortal(e(VirtualScroller, {
            native = {
                Size = UDim2.fromScale(0.7, 0.7),
                Position = UDim2.fromScale(0.15, 0.15),
            },

            ItemHeight = height,
            ItemCount = ids,

            RenderItem = function(index: number)
                return e("TextLabel", {
                    Size = UDim2.fromScale(1, 1),
                    Text = `ID # {index} = {items[index]}`,
                    BackgroundTransparency = index % 2 == 0 and 0.9 or 0.8,
                    TextColor3 = Color3.new(1, 1, 1),
                    TextSize = 45,
                    TextXAlignment = Enum.TextXAlignment.Left,

                    children = {
                        e("UIPadding", {
                            PaddingLeft = UDim.new(0, 30),
                        })
                    },
                })
            end,
        }), parent))

        return function()
            tree:unmount()
        end
    end,
}
