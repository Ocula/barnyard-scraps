--[[
    Section header - handles button and page movement. 
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Interface = require(Knit.Modules.Interface.get)

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

return function(props)
    assert(props.LayoutOrder, "No LayoutOrder provided for dividing section!")
    assert(props.Name, "No Divider Title provided in props.Name!")

    return New "Frame" {
        Name = "Divider",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Parent = props.Parent, 
        LayoutOrder = props.LayoutOrder,
        Size = UDim2.fromScale(1, 0.25),
        SizeConstraint = Enum.SizeConstraint.RelativeXX,
        ZIndex = 5,
    
        [Children] = {
            New "Frame" {
                Name = "Frame",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 219, 73),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.85, 0.85),
                ZIndex = 5,
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.25, 0),
                    },

                    New "UIStroke" {
                        Name = "UIStroke",
                        Color = Color3.fromRGB(255, 199, 107),
                        Thickness = 2,
                    },

                    New "ImageLabel" {
                        Name = "Texture",
                        Image = "rbxassetid://14005215526",
                        ImageColor3 = Color3.fromRGB(248, 180, 105),
                        ImageTransparency = 0.8,
                        ResampleMode = Enum.ResamplerMode.Pixelated,
                        ScaleType = Enum.ScaleType.Tile,
                        TileSize = UDim2.fromOffset(512, 512),
                        BackgroundColor3 = Color3.fromRGB(242, 121, 129),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = 5,
                    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.1, 0),
                            },
                        }
                    }
                }
            },
    
            New "TextLabel" {
                Name = "TextLabel",
                FontFace = Font.new(
                    "rbxassetid://12187375716",
                    Enum.FontWeight.Bold,
                    Enum.FontStyle.Normal
                ),
                Text = props.Name, -- change
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextScaled = true,
                TextSize = 14,
                TextWrapped = true,
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromScale(1, 0.8),
                ZIndex = 5,
            },
        }
    }
end 