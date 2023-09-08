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
local FormatNumber = require(Knit.Library.FormatNumber).Main
local Formatter = FormatNumber.NumberFormatter.with()
    :RoundingMode(FormatNumber.RoundingMode.HALF_EVEN) 

local StrokeSize = Interface:GetUtilityBuild("1DSize")

local function round(n)
    return math.floor(n + 0.5)
end

--TODO: index props!
return function (props)

    local AmountSpring = Spring(props.Corn, 12, 1)

    local LastAmount = Peek(props.Corn) 
    local lastTick = tick() 

    local Pop = Computed(function(Use)
        local Goal = Use(props.Corn)   
        local At = Use(AmountSpring) 

        local Difference = Goal - At 
        local TotalDifference = Goal - LastAmount 

        if Difference < 0.05 then -- reached goal essentially 
            LastAmount = Goal 
            return 0 
        else 
            if tick() - lastTick > .1 then
                lastTick = tick()
                local currentAt = At - LastAmount 

                return (math.random(50,100)) * (0.02 * (currentAt / TotalDifference))  
            else 
                return 0
            end
        end 
    end)

    local PopSpring = Spring(Pop, 15, 1) 

    -- Visiblity

    local VisibilityOffset = Value(1)
    local Visibility = props.Visible 

    local VisibilitySpring = Spring(VisibilityOffset, 25, .6)  

    local Visible = Computed(function(Use)
        local hudVisible = Use(Visibility.Parent)
        local selfVisible = Use(Visibility.Corn) 

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


    return New "Frame" {
        Name = "Corn",
        BackgroundColor3 = Color3.fromRGB(247, 231, 56),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        LayoutOrder = 1,
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
                Name = "Texture",
                Image = "rbxassetid://14005223523",
                ImageColor3 = Color3.fromRGB(255, 177, 0),
                ImageTransparency = 0.7,
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
    
            New "TextLabel" {
                Name = "Title",
                FontFace = Font.new(
                    "rbxassetid://12187375716",
                    Enum.FontWeight.Bold,
                    Enum.FontStyle.Normal
                ),
                Text = "corn",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextScaled = true,
                TextSize = 14,
                TextStrokeTransparency = 0,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Right,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0, -0.4),
                Size = UDim2.fromScale(1, 0.6),
                Visible = false,
                ZIndex = 7,
    
                [Children] = {
                    New "UIStroke" {
                        Name = "UIStroke",
                        Color = Color3.fromRGB(255, 180, 0),
                        Thickness = StrokeSize(5),
                    },
                }
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
                ZIndex = 5,
    
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
                Name = "Amount",
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
                        Name = "TextLabel",
                        FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                        Text = Computed(function(Use)
                            --TODO: format numbers 
                            return Formatter:Format(round(Use(AmountSpring)))
                        end),
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextScaled = true,
                        TextSize = 14,
                        TextWrapped = true,
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.15, 0.5),
                        Size = Computed(function(Use)
                            local PopSpringSet = Use(PopSpring)
                            return UDim2.fromScale(0.8 + (PopSpringSet / 2), 0.75 + PopSpringSet)
                        end), --TODO: add pop
                        ZIndex = 6,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(1, 0),
                            },
    
                            New "UIStroke" {
                                Name = "UIStroke",
                                Color = Color3.fromRGB(255, 180, 0),
                                Thickness = StrokeSize(5),
                            },
                        }
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
                Name = "Icon",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(-0.01, 0.5),
                ZIndex = 5, 
                Size = Computed(function(Use) 
                    local add = Use(PopSpring) + Use(IconOffsetSpring)
                    return UDim2.fromScale(1.85 + add, 1.75 + add)
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

                        --TODO: index functions here for toggling shop
                        [Attribute "MouseHover"] = "Corn", 

                        [OnEvent "MouseEnter"] = function()
                            IconOffset:set(.2)
                        end, 

                        [OnEvent "MouseLeave"] = function()
                            IconOffset:set(0) 
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
                        Image = "rbxassetid://14475755524",
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
                        Name = "OrangeStroke",
                        Image = "rbxassetid://14465549248",
                        ImageColor3 = Color3.fromRGB(80, 80, 80),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Rotation = -10,
                        Size = UDim2.fromScale(1, 1),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        ZIndex = 5,
                    },
    
                    New "ImageLabel" {
                        Name = "WhiteStroke",
                        Image = "rbxassetid://14465816909",
                        ImageColor3 = Color3.fromRGB(76, 76, 76),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Rotation = -10,
                        Size = UDim2.fromScale(1, 1),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        ZIndex = 6,
                    },
                }
            },
    
            New "Frame" {
                Name = "Background",
                BackgroundColor3 = Color3.fromRGB(247, 231, 56),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 2,
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(1, 0),
                    },
                }
            },
        }
    }
end 