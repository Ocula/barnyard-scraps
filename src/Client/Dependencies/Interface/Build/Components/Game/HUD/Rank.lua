local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate, Attribute = Fusion.Hydrate, Fusion.Attribute
local Interface = require(Knit.Modules.Interface.get)

local StrokeSize = Interface:GetUtilityBuild("1DSize")

function round(n)
    return math.floor(n + 0.5)
end 

function lerpPosition(min, max, point) 
    return min * (1 - point) + (max * point)
end 

--TODO: index props! and experience bar stuff!
--TODO: lerp clamp the bar so that player can see 0 through to 20%
return function(props)

    local Rank = props.Rank 

    local ExperienceSpring = Spring(props.Experience, 25, .6)
    local PercentageSpring = Spring(props.Experience, 25, 1) 

    local BarPosition = Computed(function(Use)
        local exp = Use(ExperienceSpring) 
        return -1 + lerpPosition(0.2, 1, exp) -- can pass this to a clamp lerp 
    end)

    -- Visiblity

    local VisibilityOffset = Value(1)
    local Visibility = props.Visible 

    local VisibilitySpring = Spring(VisibilityOffset, 25, .6)  

    local Visible = Computed(function(Use)
        local hudVisible = Use(Visibility.Parent)
        local selfVisible = Use(Visibility.Rank) 

        local visOffset = 1 

        if hudVisible == false or selfVisible == false then 
            visOffset = (0)  
        end 

        VisibilityOffset:set(visOffset) 

        if Use(VisibilitySpring) <= 0.1 then 
            return false 
        else 
            return true 
        end 
    end)

    -- Icon Offset

    local IconOffset = Value(0)
    local IconOffsetSpring = Spring(IconOffset, 25, .6)

    local IconRotate = Value(0)
    local IconRotateSpring = Spring(IconRotate, 25, .25) 


    -- Max
    

    return New "Frame" {
        Name = "Rank",
        BackgroundColor3 = Color3.fromRGB(8, 236, 246),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Visible = Visible, 
        Position = UDim2.fromScale(0, -0.0229),
        Size = Computed(function(Use)
            local VisibilitySpringSet = Use(VisibilitySpring)
            return UDim2.fromScale(1 * VisibilitySpringSet, 0.25 * VisibilitySpringSet)
        end),
        SizeConstraint = Enum.SizeConstraint.RelativeXX,
    
        [Children] = {
            New "UICorner" {
                Name = "UICorner",
                CornerRadius = UDim.new(1, 0),
            },
    
            New "ImageLabel" {
                Name = "Light",
                Image = "rbxassetid://14466215948",
                TileSize = UDim2.fromOffset(512, 512),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 4,
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(1, 0),
                    },
                }
            },
    
            New "Frame" {
                Name = "WhiteStroke",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 5,
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(1, 0),
                    },
    
                    New "UIStroke" {
                        Name = "UIStroke",
                        Color = Color3.fromRGB(76, 76, 76),
                        Thickness = StrokeSize(8),
                    },
                }
            },
    
            New "Frame" {
                Name = "OrangeStroke",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                ZIndex = 2,
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(1, 0),
                    },
    
                    New "UIStroke" {
                        Name = "UIStroke",
                        Color = Color3.fromRGB(255, 180, 0),
                        Thickness = StrokeSize(15),
                    },
                }
            },
    
            New "Frame" {
                Name = "Background",
                BackgroundColor3 = Color3.fromRGB(199, 187, 242),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 2,
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(1, 0),
                    },

                    New "ImageLabel" {
                        Name = "Texture",
                        Image = "rbxassetid://14005215526",
                        ImageColor3 = Color3.fromRGB(74, 95, 218),
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
    
            New "Frame" {
                Name = "Icon",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                ZIndex = 5, 
                Rotation = IconRotateSpring, 
                Position = UDim2.fromScale(-0.01, 0.5),
                Size = Computed(function(Use) 
                    local IconOffsetSpringSet = Use(IconOffsetSpring)
                    return UDim2.fromScale(1.7 + IconOffsetSpringSet, 1.7 + IconOffsetSpringSet)
                end),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
    
                [Children] = {
                    New "ImageButton" {
                        Name = "ImageButton",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = 10,

                        [Attribute "MouseHover"] = "Rank", 

                        -- INDEX STUFF HERE FOR TOGGLING SHOP / EFFECTS

                        [OnEvent "MouseEnter"] = function()
                            IconOffset:set(.2)
                            IconRotate:set(10) 
                        end, 

                        [OnEvent "MouseLeave"] = function()
                            IconOffset:set(0) 
                            IconRotate:set(0)
                        end, 

                        [OnEvent "MouseButton1Down"] = function()
                            IconOffset:set(-.2)
                        end, 

                        [OnEvent "MouseButton1Up"] = function()
                            IconOffsetSpring:addVelocity(1)
                            IconOffset:set(0) 
                        end, 
                    },

                    New "ImageLabel" {
                        Name = "Icon",
                        Image = "rbxassetid://14475577808",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Rotation = -10,
                        Size = UDim2.fromScale(1, 1),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        ZIndex = 7,
                    },
    
                    New "ImageLabel" {
                        Name = "WhiteStroke",
                        Image = "rbxassetid://14475521488",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Rotation = -10,
                        Size = UDim2.fromScale(1, 1),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        Visible = false,
                        ZIndex = 6,
                    },
    
                    New "ImageLabel" {
                        Name = "BlueStroke",
                        Image = "rbxassetid://14475595982",
                        ImageColor3 = Color3.fromRGB(76, 76, 76),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Rotation = -10,
                        Size = UDim2.fromScale(0.95, 0.95),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        ZIndex = 5,
                    },
                }
            },
    
            New "Frame" {
                Name = "Rank",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 5,
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(1, 0),
                    },
    
                    New "TextLabel" {
                        Name = "Title",
                        FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                        Text = Rank,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextScaled = true,
                        TextSize = 14,
                        TextWrapped = true,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.525, 0.25),
                        Size = UDim2.fromScale(0.6, 0.325),
                        ZIndex = 6,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(1, 0),
                            },
    
                            New "UIStroke" {
                                Name = "UIStroke",
                                Color = Color3.fromRGB(182, 169, 251),
                                Thickness = StrokeSize(3.5),
                            },
                        }
                    },
    
                    New "Frame" {
                        Name = "Experience",
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(180, 163, 255),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Position = UDim2.fromScale(0.525, 0.5),
                        Size = UDim2.fromScale(0.65, 0.4),
                        ZIndex = 6,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(1, 0),
                            },
    
                            New "Frame" {
                                Name = "Bar",
                                AnchorPoint = Vector2.new(0,0.5),
                                BackgroundColor3 = Color3.fromRGB(33, 218, 255),
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = Computed(function(Use)
                                    return UDim2.fromScale(Use(BarPosition), 0.5)
                                end),
                                Size = UDim2.fromScale(1, 1),
                                ZIndex = 6,
    
                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(1, 0),
                                    },
    
                                    New "TextLabel" {
                                        Name = "Percentage",
                                        FontFace = Font.new(
                                            "rbxasset://fonts/families/FredokaOne.json",
                                            Enum.FontWeight.Bold,
                                            Enum.FontStyle.Normal
                                        ),
                                        Text = Computed(function(Use)
                                            local Percentage = tostring(math.floor(Use(PercentageSpring) * 100)).."%"

                                            if Use(props.Max) then 
                                                Percentage = "MAX"
                                            end 

                                            return Percentage 
                                        end),
                                        TextColor3 = Color3.fromRGB(255, 255, 255),
                                        TextScaled = true,
                                        TextSize = 14,
                                        TextWrapped = true,
                                        TextXAlignment = Enum.TextXAlignment.Right,
                                        AnchorPoint = Computed(function(Use)
                                            return Vector2.new(if Use(props.Max) then 0.5 else 1, 0.5)
                                        end),
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = Computed(function(Use)
                                            return UDim2.fromScale(if Use(props.Max) then 0.5 else 1, 0.5)
                                        end),
                                        Size = UDim2.fromScale(1.75, 1),
                                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                        ZIndex = 6,
    
                                        [Children] = {
                                            New "UIStroke" {
                                                Name = "UIStroke",
                                                Color = Color3.fromRGB(24, 200, 243),
                                                Thickness = StrokeSize(3.5),
                                            },
                                        }
                                    },
                                }
                            },
                        }
                    },
    
                    New "ImageLabel" {
                        Name = "ExperienceCover",
                        Image = "rbxassetid://14464506622",
                        ImageColor3 = Color3.fromRGB(199, 187, 242),
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.525, 0.485),
                        Size = UDim2.fromScale(0.71, 0.425),
                        ZIndex = 6,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(1, 0),
                            },
                        }
                    },
    
                    New "Frame" {
                        Name = "BarStroke",
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(180, 163, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Position = UDim2.fromScale(0.525, 0.5),
                        Size = UDim2.fromScale(0.65, 0.4),
                        ZIndex = 8,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(1, 0),
                            },
    
                            New "UIStroke" {
                                Name = "UIStroke",
                                Color = Color3.fromRGB(154, 154, 247),
                                Thickness = StrokeSize(3.5),
                            },
                        }
                    },
                }
            },
        }
    }
end 