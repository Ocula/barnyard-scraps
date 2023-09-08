local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Interface = require(Knit.Modules.Interface.get)

return function(props)

    -- Content can be fed into this. 

    return New "Frame" {
        Name = props.Title,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(847, 648),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        Visible = false,
    
        [Children] = {
            New "Frame" {
                Name = "Holder",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(1, 1),
    
                [Children] = {
                    New "Frame" {
                        Name = "Holder",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
    
                        [Children] = {
                            New "Frame" {
                                Name = "Border",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = Color3.fromRGB(74, 219, 81),
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(1, 1),
    
                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(0.1, 0),
                                    },
    
                                    New "ImageLabel" {
                                        Name = "Texture",
                                        Image = "rbxassetid://14005215526",
                                        ImageColor3 = Color3.fromRGB(145, 251, 124),
                                        ImageTransparency = 0.2,
                                        ResampleMode = Enum.ResamplerMode.Pixelated,
                                        ScaleType = Enum.ScaleType.Tile,
                                        TileSize = UDim2.fromOffset(800, 800),
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Size = UDim2.fromScale(1, 1),
    
                                        [Children] = {
                                            New "UICorner" {
                                                Name = "UICorner",
                                                CornerRadius = UDim.new(0.1, 0),
                                            },
                                        }
                                    },
    
                                    New "UIStroke" {
                                        Name = "UIStroke",
                                        Color = Color3.fromRGB(76, 76, 76),
                                        Thickness = 8,
                                    },
                                }
                            },
    
                            New "Frame" {
                                Name = "Content",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5, 0.575),
                                Size = UDim2.fromScale(0.95, 0.8),
    
                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(0.1, 0),
                                    },

                                    --TODO: add Content frame stuff
                                }
                            },
    
                            New "Frame" {
                                Name = "Header",
                                AnchorPoint = Vector2.new(0.5, 0),
                                BackgroundColor3 = Color3.fromRGB(13, 188, 5),
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5, 0.025),
                                Size = UDim2.fromScale(0.95, 0.125),
    
                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(0.5, 0),
                                    },
    
                                    New "TextLabel" {
                                        Name = "Text",
                                        FontFace = Font.new(
                                            "rbxassetid://12187375716",
                                            Enum.FontWeight.Bold,
                                            Enum.FontStyle.Normal
                                        ),
                                        Text = props.Title,
                                        TextColor3 = Color3.fromRGB(255, 255, 255),
                                        TextScaled = true,
                                        TextSize = 14,
                                        TextWrapped = true,
                                        TextXAlignment = Enum.TextXAlignment.Left,
                                        AnchorPoint = Vector2.new(0, 0.5),
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = UDim2.fromScale(0.025, 0.5),
                                        Size = UDim2.fromScale(0.5, 0.85),
                                    },
                                }
                            },
                        }
                    },
                }
            },
        }
    }
end 