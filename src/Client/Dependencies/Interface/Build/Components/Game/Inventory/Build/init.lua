local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--
local Interface = require(Knit.Modules.Interface.get)
--
local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local ToolButton = Interface:GetComponent("Game/Inventory/Tools/MainTool") 

local Size = Interface:GetUtilityBuild("Size")
local StrokeSize = Interface:GetUtilityBuild("1DSize") 

return function (props)
    local Build = props.Build 
    local Visible = props.Visible 

    local Buttons = Build.Buttons 
    local Pages = Build.Pages
    local SectionHeaders = Build.Sections

    return New "Frame" {
        Name = "Inventory",
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Visible = Visible, 
        Parent = props.Parent, 
        Position = UDim2.new(0, 20, 0.5, 0),
        Size = Size(Value(UDim2.fromOffset(439, 898))),
    
        [Children] = {
            New "Frame" {
                Name = "Container",
                BackgroundColor3 = Color3.fromRGB(245, 169, 35),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
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
                        TileSize = UDim2.fromScale(2.5, 1),
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
                        Name = "SectionsBackground",
                        BackgroundColor3 = Color3.fromRGB(232, 140, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.6, 0.01),
                        Size = UDim2.fromScale(0.375, 0.605),
                        ZIndex = 3,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.1, 0),
                            },
                        }
                    },
    
                    New "Frame" {
                        Name = "Actions",
                        BackgroundColor3 = Color3.fromRGB(232, 140, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Position = UDim2.fromScale(0.6, 0.625),
                        Size = UDim2.fromScale(0.375, 0.35),
                        ZIndex = 4,
    
                        [Children] = {
                            New "Frame" {
                                Name = "Tools",
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0, 0.15),
                                Size = UDim2.fromScale(1, 0.85),
    
                                [Children] = {
                                    New "UIListLayout" {
                                        Name = "UIListLayout",
                                        Padding = UDim.new(0, 2),
                                        SortOrder = Enum.SortOrder.LayoutOrder,
                                        VerticalAlignment = Enum.VerticalAlignment.Center,
                                    },
    
                                    New "Frame" {
                                        Name = "Bottom",
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        LayoutOrder = 3,
                                        Position = UDim2.fromScale(0, 0.66),
                                        Size = UDim2.fromScale(1, 0.3),
                                        ZIndex = 5,
    
                                        [Children] = {
                                            New "UIGridLayout" {
                                                Name = "UIGridLayout",
                                                CellPadding = UDim2.fromScale(0.025, 0),
                                                CellSize = UDim2.fromScale(0.425, 1),
                                                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                                SortOrder = Enum.SortOrder.LayoutOrder,
                                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                            },

                                            ToolButton {
                                                Name = "Paint",
                                                Selected = props.Tool, 
                                            },
                                        }
                                    },
    
                                    New "Frame" {
                                        Name = "Middle",
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        LayoutOrder = 2,
                                        Position = UDim2.fromScale(0, 0.33),
                                        Size = UDim2.fromScale(1, 0.3),
                                        ZIndex = 5,
    
                                        [Children] = {
                                            New "UIGridLayout" {
                                                Name = "UIGridLayout",
                                                CellPadding = UDim2.fromScale(0.025, 0),
                                                CellSize = UDim2.fromScale(0.425, 1),
                                                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                                SortOrder = Enum.SortOrder.LayoutOrder,
                                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                            },

                                            ToolButton {
                                                Name = "Rotate",
                                                Selected = props.Tool,
                                                LayoutOrder = 0, 
                                            },

                                            ToolButton {
                                                Name = "Move",
                                                Selected = props.Tool,
                                                LayoutOrder = 1, 
                                            },
                                        }
                                    },
    
                                    New "Frame" {
                                        Name = "Top",
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        LayoutOrder = 1,
                                        Size = UDim2.fromScale(1, 0.3),
                                        ZIndex = 5,
    
                                        [Children] = {
                                            New "UIGridLayout" {
                                                Name = "UIGridLayout",
                                                CellPadding = UDim2.fromScale(0.025, 0),
                                                CellSize = UDim2.fromScale(0.425, 1),
                                                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                                SortOrder = Enum.SortOrder.LayoutOrder,
                                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                            },

                                            ToolButton {
                                                Name = "Place",
                                                Selected = props.Tool,
                                                LayoutOrder = 0, 
                                            },

                                            ToolButton {
                                                Name = "Delete",
                                                Selected = props.Tool,
                                                LayoutOrder = 1, 
                                            },
                                        }
                                    },
                                }
                            },
    
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.1, 0),
                            },
    
                            New "Frame" {
                                Name = "ToolsHeader",
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0, 0.0125),
                                Size = UDim2.fromScale(1, 0.25),
                                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                                ZIndex = 5,
    
                                [Children] = {
                                    New "Frame" {
                                        Name = "Frame",
                                        AnchorPoint = Vector2.new(0.5, 0.5),
                                        BackgroundColor3 = Color3.fromRGB(255, 193, 1),
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
                                        }
                                    },
    
                                    New "TextLabel" {
                                        Name = "TextLabel",
                                        FontFace = Font.new(
                                            "rbxassetid://12187375716",
                                            Enum.FontWeight.Bold,
                                            Enum.FontStyle.Normal
                                        ),
                                        Text = "tools",
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
                            },
    
                            New "ImageLabel" {
                                Name = "Texture",
                                Image = "rbxassetid://14080052911",
                                ImageColor3 = Color3.fromRGB(255, 238, 0),
                                ImageTransparency = 0.95,
                                ResampleMode = Enum.ResamplerMode.Pixelated,
                                ScaleType = Enum.ScaleType.Tile,
                                TileSize = UDim2.fromScale(1, 0.25),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(-0.05, -0.05),
                                Size = UDim2.fromScale(5, 6),
                                ZIndex = 4,
    
                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(0.1, 0),
                                    },
                                }
                            },
                        }
                    },
    
                    New "ScrollingFrame" {
                        Name = "PageButtons",
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        CanvasSize = UDim2.new(),
                        ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
                        ScrollBarImageTransparency = 1,
                        ScrollBarThickness = 0,
                        Active = true,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.6, 0.02),
                        Size = UDim2.fromScale(0.375, 0.58),
                        ZIndex = 4,
                        SelectionBehaviorDown = Enum.SelectionBehavior.Stop,
                        SelectionBehaviorLeft = Enum.SelectionBehavior.Stop,
                        SelectionBehaviorRight = Enum.SelectionBehavior.Stop,
                        SelectionBehaviorUp = Enum.SelectionBehavior.Stop,
    
                        [Children] = {
                            New "Frame" {
                                Name = "Content",
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Size = UDim2.fromScale(1, 1),
    
                                [Children] = {
                                    New "UIListLayout" {
                                        Name = "UIListLayout",
                                        Padding = UDim.new(0.01, 0),
                                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                        SortOrder = Enum.SortOrder.LayoutOrder,
                                    },

                                    ForValues(SectionHeaders, function(use, value)
                                        return value
                                    end, Fusion.cleanup),

                                    ForValues(Buttons, function(use, value)
                                        return value
                                    end, Fusion.cleanup) 
                                }
                            },
                        }
                    },
    
                    New "Frame" {
                        Name = "Content",
                        BackgroundColor3 = Color3.fromRGB(224, 107, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.028, 0.065),
                        Size = UDim2.fromScale(0.54, 0.925),
                        ZIndex = 3,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.1, 0),
                            },
    
                            New "ImageLabel" {
                                Name = "Texture",
                                Image = "rbxassetid://14047322147",
                                ImageTransparency = 0.95,
                                ResampleMode = Enum.ResamplerMode.Pixelated,
                                ScaleType = Enum.ScaleType.Tile,
                                TileSize = UDim2.fromScale(1, 0.25),
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
                                }
                            },
    
                            New "ImageLabel" {
                                Name = "Border",
                                Image = "rbxassetid://14047375842",
                                ImageColor3 = Color3.fromRGB(235, 141, 0),
                                ScaleType = Enum.ScaleType.Slice,
                                SliceCenter = Rect.new(256, 256, 768, 768),
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(1.03, 1),
                                ZIndex = 6,
                            },
    
                            New "Frame" {
                                Name = "PageHolder",
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                ClipsDescendants = true,
                                Size = UDim2.fromScale(1, 1),
                                ZIndex = 5,
    
                                [Children] = {
                                    props.PageLayout, 

                                    ForValues(Pages, function(use, value)
                                        return value
                                    end, Fusion.cleanup)
                                }
                            },
                        }
                    },
    
                    New "Frame" {
                        Name = "Header",
                        BackgroundColor3 = Color3.fromRGB(235, 141, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.028, 0.008),
                        Size = UDim2.fromScale(0.54, 0.05),
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
                                Text = "Basic",
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
    
                    New "UIStroke" {
                        Name = "UIStroke",
                        Color = Color3.fromRGB(76, 76, 76),
                        Thickness = StrokeSize(8),
                    },
                }
            },
        }
    }
end 