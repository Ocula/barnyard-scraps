local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Interface = require(Knit.Modules.Interface.get)

local Item = Interface:GetComponent("Game/NPC/Vendor/Item")
local StrokeSize = Interface:GetUtilityBuild("1DSize")

return function (props)
    local Objects = props.Interact.Items
    local Sales = props.Interact.Sale 
    local Selected = props.Selected

    return New "Frame" {
        Name = "Objects",
        BackgroundColor3 = Color3.fromRGB(193, 153, 110),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.025, 0.09),
        Size = UDim2.fromScale(0.55, 0.875),
        ZIndex = 2,
    
        [Children] = {
            New "UICorner" {
                Name = "UICorner",
                CornerRadius = UDim.new(0.1, 0),
            },
    
            New "ScrollingFrame" {
                Name = "ScrollingFrame",
                ScrollBarThickness = 0,
                Active = true,
                AnchorPoint = Vector2.new(0.5, 0.5),
                AutomaticCanvasSize = Enum.AutomaticSize.Y, 
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,

                CanvasSize = UDim2.fromOffset(0,0),
                
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.95, 0.9),
                ZIndex = 3,
    
                [Children] = {
                    New "UIGridLayout" {
                        Name = "UIGridLayout",
                        CellPadding = UDim2.new(),
                        CellSize = UDim2.fromScale(210 / 466.95, 210 / 466.95),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    },

                    ForPairs(Objects, function(Use, key, value)
                        return key, Item {
                            Sales = Sales, 
                            ItemId = value,
                            Selected = Selected,
                        }
                    end, Fusion.cleanup)
                }
            },
    
            New "UIStroke" {
                Name = "UIStroke",
                Color = Color3.fromRGB(76, 76, 76),
                Thickness = StrokeSize(8),
            },
        }
    }
end