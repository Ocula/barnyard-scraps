local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Signal = require(Knit.Library.Signal) 

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Interface = require(Knit.Modules.Interface.get)

local Items         = Interface:GetComponent("Game/NPC/Vendor/Items")
local StatPanel     = Interface:GetComponent("Game/NPC/Vendor/StatPanel") -- feed a viewport signal 
local BuyPanel      = Interface:GetComponent("Game/NPC/Vendor/BuyPanel") 
local Sections      = Interface:GetComponent("Game/NPC/Vendor/Sections")

local Size = Interface:GetUtilityBuild("Size") 
local StrokeSize = Interface:GetUtilityBuild("1DSize")

return function(props)
    local Selected = props.Selected 
    local NPCName = props.NPC.Name 
    local UpdateViewport = Signal.new() 

    local Vendor = New "Frame" {
        Name = "Vendor",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(173, 145, 133),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Visible = props.Visible, 
        Parent = props.Parent, 
        Position = UDim2.fromScale(0.5, 0.5),
        Size = Size(Value(UDim2.fromOffset(850, 550))),
    
        [Children] = {
            New "UICorner" {
                Name = "UICorner",
                CornerRadius = UDim.new(0.1, 0),
            },
    
            New "Frame" {
                Name = "Header",
                AnchorPoint = Vector2.new(0, 1),
                BackgroundColor3 = Color3.fromRGB(69, 218, 78),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.025, 0.05),
                Rotation = -3,
                Size = UDim2.fromScale(0.4, 0.1),
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
    
                    New "TextLabel" {
                        Name = "TextLabel",
                        FontFace = Font.new("rbxassetid://12187375716"),
                        Text = NPCName.."'s Stand",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextScaled = true,
                        TextSize = 14,
                        TextWrapped = true,
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0),
                        Size = UDim2.fromScale(0.95, 1),
                        ZIndex = 5,
    
                        [Children] = {
                            New "UIStroke" {
                                Name = "UIStroke",
                                Color = Color3.fromRGB(76, 76, 76),
                                Thickness = StrokeSize(3),
                            },
                        }
                    },
    
                    New "ImageLabel" {
                        Name = "Bubble",
                        Image = "rbxassetid://14629577704",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = 4,
                    },
    
                    New "ImageLabel" {
                        Name = "Texture",
                        Image = "rbxassetid://14005215526",
                        ImageColor3 = Color3.fromRGB(48, 101, 0),
                        ImageTransparency = 0.9,
                        ResampleMode = Enum.ResamplerMode.Pixelated,
                        ScaleType = Enum.ScaleType.Tile,
                        TileSize = UDim2.fromOffset(512, 512),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = 3,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(1, 0),
                            },
                        }
                    },
                }
            },

            Items {
                Interact = props.NPC.Interact, 
                Selected = Selected, 
            },

            StatPanel {
                Selected = Selected, 
                Update = UpdateViewport, 
            },

            BuyPanel {
                BuySignal = props.Buy, 
            },

            Sections {
                Sections = props.NPC.Interact.Sections,
                SectionButtonSignal = props.SectionButtonSignal
            },
    
            New "UIStroke" {
                Name = "UIStroke",
                Color = Color3.fromRGB(76, 76, 76),
                Thickness = StrokeSize(8),
            },
    
            New "ImageLabel" {
                Name = "ProduceStroke",
                Image = "rbxassetid://14631282957",
                ImageColor3 = Color3.fromRGB(76, 76, 76),
                ScaleType = Enum.ScaleType.Fit,
                AnchorPoint = Vector2.new(0, 1),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(0.4, 0.3),
                ZIndex = 0,
    
                [Children] = {
                    New "ImageLabel" {
                        Name = "Produce",
                        Image = "rbxassetid://14630885537",
                        ScaleType = Enum.ScaleType.Fit,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                    },
                }
            },
    
            New "ImageLabel" {
                Name = "Texture",
                Image = "rbxassetid://14005215526",
                ImageColor3 = Color3.fromRGB(122, 75, 53),
                ImageTransparency = 0.8,
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
        }
    }

    return Vendor
end 