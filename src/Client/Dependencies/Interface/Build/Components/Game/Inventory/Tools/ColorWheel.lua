-- Handles the creation of all of the Edit UI buttons.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Interface = require(Knit.Modules.Interface.get)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local AssetLibrary = require(Knit.Library.AssetLibrary) 

local Slider = Interface:GetComponent("Game/Inventory/Tools/ColorSlider") 
local Size = Interface:GetUtilityBuild("Size")

return function(props, signals) 

    local circleReference = Value()
    local sliderLayout = 0 

    local frameAbsPos, frameAbsSize = Value(), Value() 

    local colorWheel
    local pickerFrame = Value() 

    local frameSpring = Spring(props.FramePosition, 25, .8) 

    colorWheel = New "Frame" {
        Name = "Color",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.95, 0.5),
        Size = Size(Value(Vector2.new(335, 680))),

        Visible = props.Visible, 
    
        [Children] = {
            New "Frame" {
                Name = "Container",
                BackgroundColor3 = Color3.fromRGB(245, 169, 35),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 2,
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.1, 0),
                    },
    
                    New "ImageLabel" {
                        Name = "Texture",
                        Image = "rbxassetid://14005215526",
                        ImageColor3 = Color3.fromRGB(255, 229, 0),
                        ImageTransparency = 0.6,
                        ResampleMode = Enum.ResamplerMode.Pixelated,
                        ScaleType = Enum.ScaleType.Tile,
                        TileSize = UDim2.fromScale(2.5, 1.5),
                        BackgroundColor3 = Color3.fromRGB(242, 121, 129),
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
                        Name = "Circle",
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 139, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.135),
                        Size = UDim2.fromScale(0.925, 0.925),
                        SizeConstraint = Enum.SizeConstraint.RelativeXX,
                        ZIndex = 3,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(1, 0),
                            },

                            New "TextButton" {
                                Name = "Button",
                                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                                Text = "",
                                TextColor3 = Color3.fromRGB(0, 0, 0),
                                TextSize = 14,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Size = UDim2.fromScale(1, 1),
                                ZIndex = 5,

                                [OnEvent "MouseButton1Down"] = function()
                                    signals.MouseButton1Down:Fire() 
                                end,

                                [OnEvent "MouseButton1Up"] = function()
                                    signals.MouseButton1Up:Fire() 
                                end,

                                [OnEvent "MouseLeave"] = function()
                                    signals.MouseLeave:Fire() 
                                end,
                            },
    
                            New "ImageLabel" {
                                Name = "Image",
                                Image = "rbxassetid://14046927397",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(0.8, 0.8),
                                ZIndex = 6,

                                [Ref] = circleReference, 

                                [Children] = {
                                    New "Frame" {
                                        Name = "Picker",
                                        AnchorPoint = Vector2.new(0.5, 0.5),
                                        BackgroundColor3 = props.Picked, 
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = frameSpring,
                                        Size = UDim2.fromScale(0.1, 0.1),
                                        SizeConstraint = Enum.SizeConstraint.RelativeXX,
                                        ZIndex = 6,

                                        [Ref] = pickerFrame, 
            
                                        [Children] = {
                                            New "UIStroke" {
                                                Name = "UIStroke",
                                                Color = Color3.fromRGB(255, 255, 255),
                                                Thickness = 10, 
                                            },

                                            New "UICorner" {
                                                Name = "UICorner",
                                                CornerRadius = UDim.new(1, 0),
                                            },
                                        }
                                    },
                                }
                                
                            },
    
                            New "Frame" {
                                Name = "Border",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = props.Picked,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(0.85, 0.85),
                                ZIndex = 5,
    
                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(1, 0),
                                    },
                                }
                            },
                        }
                    },
    
                    New "Frame" {
                        Name = "Header",
                        BackgroundColor3 = Color3.fromRGB(255, 139, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.028, 0.015),
                        Size = UDim2.fromScale(0.95, 0.1),
                        ZIndex = 3,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.5, 0),
                            },
    
                            New "TextLabel" {
                                Name = "HeaderText",
                                FontFace = Font.new(
                                    "rbxassetid://12187375716",
                                    Enum.FontWeight.Bold,
                                    Enum.FontStyle.Normal
                                ),
                                Text = "Paint Bucket",
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
                                Size = UDim2.fromScale(0.9, 0.8),
                                ZIndex = 4,
                            },
                        }
                    },
    
                    New "Frame" {
                        Name = "Sliders",
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 139, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.6),
                        Size = UDim2.fromScale(0.925, 0.275),
                        ZIndex = 3,
    
                        [Children] = {
                            New "Frame" {
                                Name = "Container",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(1, 1),
                                ZIndex = 5,
    
                                [Children] = {
                                    New "UIGridLayout" {
                                        Name = "UIGridLayout",
                                        CellPadding = UDim2.new(),
                                        CellSize = UDim2.fromScale(1, 0.33),
                                        FillDirection = Enum.FillDirection.Vertical,
                                        SortOrder = Enum.SortOrder.LayoutOrder,
                                    },

                                    ForPairs(props.Sliders, function(use, name, value)
                                        local FrameReferences = {}

                                        return name, Slider({
                                            Title = name, 
                                            TextBox = Value("255"), 
                                            Name = name, 
                                            LayoutOrder = if name:lower() == "r" then 1 elseif name:lower() == "g" then 2 else 3, 
                                            FrameRef = FrameReferences,
                                        }, signals.SliderSignals) 
                                    end, Fusion.cleanup) 
                                }
                            },
    
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.1, 0),
                            },
                        }
                    },
                }
            },
    
            New "Frame" {
                Name = "Highlight",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(-2, -2),
                Size = UDim2.new(1, 4, 1, 4),
                ZIndex = 0,
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.1, 0),
                    },
                }
            },
    
            New "Frame" {
                Name = "Shadow",
                BackgroundColor3 = Color3.fromRGB(198, 145, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, 1, 1, 1),
                ZIndex = 0,
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.1, 0),
                    },
                }
            },
        }
    }

    return colorWheel, Peek(pickerFrame) 
end