local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Interface = require(Knit.Modules.Interface.get)

return function (props) 
    local Transparency = Spring(props.Transparency, 25, 0.6)

    return New "Folder" {
        Name = "Chicken",
        Parent = props.PlayerGui, 

        [Children] = {
            New "SurfaceGui" {
                Adornee = props.Adornee.LegR, 

                Face = props.Face, 
                Name = "LegR",
                AlwaysOnTop = true,
                ClipsDescendants = true,
                PixelsPerStud = 16.7,
                SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

                [Children] = {
                    New "Frame" {
                        Name = "Frame",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1, 1),

                        [Children] = {
                            New "ImageLabel" {
                                Name = "LegR",
                                Image = "rbxassetid://14283852930",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundTransparency = 1,
                                Position = UDim2.fromScale(0.61, 0.856),
                                Size = UDim2.fromScale(0.085, 0.085),

                                ImageTransparency = Transparency,
                            },
                        }
                    },
                }
            },

            New "SurfaceGui" {
                Adornee = props.Adornee.LegL, 

                Face = props.Face, 
                Name = "LegL",
                AlwaysOnTop = true,
                ClipsDescendants = true,
                PixelsPerStud = 16.7,
                SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

                [Children] = {
                    New "Frame" {
                        Name = "Frame",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = 0,

                        [Children] = {
                            New "ImageLabel" {
                                Name = "LegL",
                                Image = "rbxassetid://14283853071",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundTransparency = 1,
                                Position = UDim2.fromScale(0.346, 0.9),
                                Size = UDim2.fromScale(0.085, 0.085),

                                ImageTransparency = Transparency,
                            },
                        }
                    },
                }
            },

            New "SurfaceGui" {
                Adornee = props.Adornee.Headtail, 
                Face = props.Face, 

                Name = "Headtail",
                AlwaysOnTop = true,
                ClipsDescendants = true,
                PixelsPerStud = 16.7,
                SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

                [Children] = {
                    New "Frame" {
                        Name = "Frame",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1, 1),

                        [Children] = {
                            New "ImageLabel" {
                                Name = "Headtail",
                                Image = "rbxassetid://14283853323",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundTransparency = 1,
                                Position = UDim2.fromScale(0.37, 0.17),
                                Size = UDim2.fromScale(0.249, 0.22),

                                ImageTransparency = Transparency,
                            },
                        }
                    },
                }
            },

            New "SurfaceGui" {
                Adornee = props.Adornee.Body, 
                Face = props.Face, 

                Name = "Body",
                AlwaysOnTop = true,
                ClipsDescendants = true,
                PixelsPerStud = 16.7,
                SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

                [Children] = {
                    New "Frame" {
                        Name = "Frame",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1, 1),

                        [Children] = {
                            New "ImageLabel" {
                                Name = "Body",
                                Image = "rbxassetid://14283877155",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundTransparency = 1,
                                Position = UDim2.fromScale(0.401, 0.582),
                                Size = UDim2.fromScale(0.512, 0.706),

                                ImageTransparency = Transparency,
                            },
                        }
                    },
                }
            },

            New "SurfaceGui" {
                Adornee = props.Adornee.Backtail, 
                Face = props.Face, 

                Name = "Backtail",
                AlwaysOnTop = true,
                ClipsDescendants = true,
                PixelsPerStud = 16.7,
                SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

                [Children] = {
                    New "Frame" {
                        Name = "Frame",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1, 1),

                        [Children] = {
                            New "ImageLabel" {
                                Name = "Backtail",
                                Image = "rbxassetid://14283855092",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundTransparency = 1,
                                Position = UDim2.fromScale(0.726, 0.687),
                                Size = UDim2.fromScale(0.275, 0.295),

                                ImageTransparency = Transparency,
                            },
                        }
                    },
                }
            },

            New "SurfaceGui" {
                Adornee = props.Adornee.Arm, 
                Face = props.Face, 

                Name = "Arm",
                AlwaysOnTop = true,
                ClipsDescendants = true,
                PixelsPerStud = 16.7,
                SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

                [Children] = {
                    New "Frame" {
                        Name = "Frame",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1, 1),

                        [Children] = {
                            New "ImageLabel" {
                                Name = "Arm",
                                Image = "rbxassetid://14283853241",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundTransparency = 1,
                                Position = UDim2.fromScale(0.546, 0.551),
                                Size = UDim2.fromScale(0.256, 0.23),
                                ZIndex = 2,

                                ImageTransparency = Transparency,
                            },
                        }
                    },
                }
            },

            New "SurfaceGui" {
                Adornee = props.Adornee.Background, 
                Face = props.Face, 

                Name = "Background",
                AlwaysOnTop = true,
                ClipsDescendants = true,
                PixelsPerStud = 16.7,
                SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            
                [Children] = {
                    New "Frame" {
                        Name = "Frame",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(0, 207, 255),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1, 1),

                        BackgroundTransparency = Transparency,
                    },
                }
            } 
        }
    }
end 