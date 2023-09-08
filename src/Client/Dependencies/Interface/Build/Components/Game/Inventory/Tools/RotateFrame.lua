local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Interface = require(Knit.Modules.Interface.get)

local ViewportFrame = Interface:GetComponent("Frames/ViewportFrame")

local DominoSource = ReplicatedStorage.Assets.Inactive.Domino

return function(props) 
    local min, max = 0.05, 0.9 
    local sliderPosition = props.SliderPosition

    local position = Computed(function(Use)
        return UDim2.fromScale(Use(sliderPosition),0.5) 
    end) 

    local positionSpring = Spring(position, 30, .85) 
    local textBoxReference = Value()

    local dominoObject = DominoSource:Clone() 

    props.Signals.PreviewUpdate:Connect(function(newObject) 
        if newObject then 
            dominoObject.Color = newObject.Color 
            dominoObject.Transparency = newObject.Transparency 
        else 
            dominoObject.Transparency = 1
        end 
    end) 
    
    return New "Frame" {
        Name = "Rotation",
        Visible = props.Visible, 
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.95, 0.5),
        Size = UDim2.fromScale(0.15, 0.375),

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
                        Name = "Preview",
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 139, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.135),
                        Size = UDim2.fromScale(0.925, 0.925),
                        SizeConstraint = Enum.SizeConstraint.RelativeXX,
                        ZIndex = 3,

                        [Children] = {
                            New "Frame" {
                                Name = "Border",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = Color3.fromRGB(255, 175, 0),
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(0.85, 0.85),
                                ZIndex = 5,

                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(0.1, 0),
                                    },

                                    New "ImageLabel" {
                                        Name = "Texture",
                                        Image = "rbxassetid://14080052911",
                                        ImageTransparency = 0.925,
                                        ResampleMode = Enum.ResamplerMode.Pixelated,
                                        ScaleType = Enum.ScaleType.Tile,
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Size = UDim2.fromScale(1, 1),
                                        ZIndex = 4,
                                    
                                        [Children] = {
                                            New "UICorner" {
                                                Name = "UICorner",
                                                CornerRadius = UDim.new(0.1, 0),
                                            },
                                    
                                            New "UICorner" {
                                                Name = "UICorner",
                                                CornerRadius = UDim.new(0.125, 0),
                                            },
                                        }
                                    },

                                    ViewportFrame {
                                        Stagnant = true, 
                                        Rotate = props.Rotate, 
                                        Radians = true, 
                                        Object = dominoObject, 
                                        ZIndex = 5, 
                                    }

                                }
                            },

                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.1, 0),
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
                                Text = "Rotation Station",
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
                        Name = "Slider",
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 139, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.825),
                        Size = UDim2.fromScale(0.925, 0.15),
                        ZIndex = 3,

                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.25, 0),
                            },

                            New "Frame" {
                                Name = "Y",
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                LayoutOrder = 1,
                                Size = UDim2.fromScale(1, 0.95),
                                ZIndex = 5,
                            },

                            New "Frame" {
                                Name = "Drag",
                                AnchorPoint = Vector2.new(0, 0.5),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 0.8,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.125, 0.5),
                                Size = UDim2.fromScale(0.6, 0.8),
                                ZIndex = 5,

                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(0.25, 0),
                                    },

                                    New "Frame" {
                                        Name = "TotalFrame",
                                        AnchorPoint = Vector2.new(0.5, 0.5),
                                        BackgroundColor3 = Color3.fromRGB(225, 130, 0),
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = UDim2.fromScale(0.5, 0.5),
                                        Size = UDim2.fromScale(0.9, 0.25),
                                        ZIndex = 5,

                                        [Children] = {
                                            New "UICorner" {
                                                Name = "UICorner",
                                                CornerRadius = UDim.new(1, 0),
                                            },

                                            New "Frame" {
                                                Name = "DragFrame",
                                                AnchorPoint = Vector2.new(0.5, 0.5),
                                                BackgroundColor3 = Color3.fromRGB(247, 242, 200),
                                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                                BorderSizePixel = 0,
                                                Position = positionSpring, 
                                                Size = UDim2.fromScale(0.125, 0.125),
                                                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                                                ZIndex = 5,

                                                [Children] = {
                                                    New "UICorner" {
                                                        Name = "UICorner",
                                                        CornerRadius = UDim.new(1, 0),
                                                    },

                                                    New "TextButton" {
                                                        Name = "TextButton",
                                                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                                                        Text = "",
                                                        TextColor3 = Color3.fromRGB(0, 0, 0),
                                                        TextSize = 14,
                                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                                        BackgroundTransparency = 1,
                                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                                        BorderSizePixel = 0,
                                                        Size = UDim2.fromScale(1, 1),
                                                        ZIndex = 7,

                                                        [OnEvent "MouseButton1Down"] = function()
                                                            props.Signals.MouseButton1Down:Fire()
                                                        end, 
                                                    },
                                                }
                                            },

                                            New "TextButton" {
                                                Name = "TextButton",
                                                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                                                Text = "",
                                                TextColor3 = Color3.fromRGB(0, 0, 0),
                                                TextSize = 14,
                                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                                BackgroundTransparency = 1,
                                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                                BorderSizePixel = 0,
                                                Size = UDim2.fromScale(1, 1),
                                                ZIndex = 6,

                                                [OnEvent "MouseButton1Down"] = function()
                                                    props.Signals.MouseButton1Down:Fire()
                                                end, 
                                            },
                                        }
                                    },
                                }
                            },

                            New "Frame" {
                                Name = "Number",
                                AnchorPoint = Vector2.new(0, 0.5),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 0.8,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.75, 0.5),
                                Size = UDim2.fromScale(0.225, 0.8),
                                ZIndex = 5,

                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(0.25, 0),
                                    },

                                    New "TextBox" {
                                        Name = "TextBox",
                                        FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                                        PlaceholderText = "360",
                                        Text = Computed(function(Use)
                                            return tostring(Use(props.Rotate)) 
                                        end),
                                        TextColor3 = Color3.fromRGB(255, 255, 255),
                                        TextScaled = true,
                                        TextSize = 14,
                                        TextWrapped = true,
                                        ClearTextOnFocus = true, 
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Size = UDim2.fromScale(1, 1),
                                        ZIndex = 5,

                                        [Ref] = textBoxReference, 

                                        [OnEvent "FocusLost"] = function()
                                            local box = Peek(textBoxReference)
                                            local text = box.Text 

                                            props.Signals.RequestRotate:Fire(text) 
                                        end, 

                                        [Children] = {
                                            New "UITextSizeConstraint" {
                                                Name = "UITextSizeConstraint",
                                                MaxTextSize = 24,
                                            },
                                        }
                                    },
                                }
                            },

                            New "TextLabel" {
                                Name = "TextLabel",
                                FontFace = Font.new(
                                    "rbxasset://fonts/families/Bangers.json",
                                    Enum.FontWeight.Bold,
                                    Enum.FontStyle.Normal
                                ),
                                Text = "Y",
                                TextColor3 = Color3.fromRGB(255, 255, 255),
                                TextScaled = true,
                                TextSize = 18,
                                TextStrokeColor3 = Color3.fromRGB(198, 123, 0),
                                TextStrokeTransparency = 0,
                                TextWrapped = true,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Size = UDim2.fromScale(0.125, 1),
                                ZIndex = 5,

                                [Children] = {
                                    New "UITextSizeConstraint" {
                                        Name = "UITextSizeConstraint",
                                        MaxTextSize = 24,
                                    },
                                }
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
end 