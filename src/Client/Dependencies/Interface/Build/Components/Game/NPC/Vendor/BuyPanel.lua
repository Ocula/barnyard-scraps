local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Interface = require(Knit.Modules.Interface.get)

local StrokeSize = Interface:GetUtilityBuild("1DSize")

return function(props)
    local BuySignal = props.BuySignal 

    return New "Frame" {
        Name = "BuyPanel",
        BackgroundColor3 = Color3.fromRGB(92, 188, 97),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.605, 0.675),
        Size = UDim2.fromScale(0.37, 0.285),
        ZIndex = 4,
    
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
    
            New "Frame" {
                Name = "Data",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(154, 231, 115),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.875, 0.75),
                ZIndex = 4,
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.1, 0),
                    },
    
                    New "ImageLabel" {
                        Name = "Icon",
                        Image = "rbxassetid://14631514963",
                        ImageColor3 = Color3.fromRGB(0, 193, 249),
                        ImageTransparency = 0.6,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        Visible = false,
                        ZIndex = 4,
                    },
    
                    New "TextButton" {
                        Name = "Buy",
                        FontFace = Font.new(
                            "rbxasset://fonts/families/FredokaOne.json",
                            Enum.FontWeight.Bold,
                            Enum.FontStyle.Normal
                        ),
                        Text = "Buy (Placeholder)",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextScaled = true,
                        TextSize = 14,
                        TextWrapped = true,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = 7,
    
                        [OnEvent "MouseButton1Up"] = function()
                            BuySignal:Fire() 
                        end, 

                        [Children] = {
                            New "UITextSizeConstraint" {
                                Name = "UITextSizeConstraint",
                                MaxTextSize = 30,
                            },
                        }
                    },
                }
            },
        }
    }
end 