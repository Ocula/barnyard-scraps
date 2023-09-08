local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Interface = require(Knit.Modules.Interface.get)

local SectionButton = Interface:GetComponent("Buttons/SectionButton") 

local StrokeSize = Interface:GetUtilityBuild("1DSize")


return function (props)
    local Sections = props.Sections 
    local ButtonSignal = props.SectionButtonSignal 

    return New "Frame" {
        Name = "Sections",
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Color3.fromRGB(245, 183, 5),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.475, 0.05),
        Rotation = 3,
        Size = UDim2.fromScale(0.5, 0.1),
        ZIndex = 2,
    
        [Children] = {
            New "UICorner" {
                Name = "UICorner",
                CornerRadius = UDim.new(0.1, 0),
            },
    
            New "UIStroke" {
                Name = "UIStroke",
                Color = Color3.fromRGB(76, 76, 76),
                Thickness = StrokeSize(8),
            },
    
            New "ImageLabel" {
                Name = "Bubble",
                Image = "rbxassetid://14629577704",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 2,
            },
    
            New "ImageLabel" {
                Name = "Texture",
                Image = "rbxassetid://14005223523",
                ImageColor3 = Color3.fromRGB(255, 253, 1),
                ImageTransparency = 0.7,
                ResampleMode = Enum.ResamplerMode.Pixelated,
                ScaleType = Enum.ScaleType.Tile,
                TileSize = UDim2.fromOffset(512, 512),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 2,
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.1, 0),
                    },
                }
            },
    
            New "Frame" {
                Name = "Content",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                ZIndex = 4, 
                Size = UDim2.fromScale(1, 1),
    
                [Children] = {

                    ForPairs(Sections, function(Use, key, value)
                        local Object = SectionButton {
                            Filter = value, 
                            ButtonSignal = ButtonSignal
                        }

                        return key, Object 
                    end, Fusion.cleanup),

                    New "UIListLayout" {
                        Name = "UIListLayout",
                        Padding = UDim.new(0.05, 0),
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    },
                }
            },
        }
    }
end 