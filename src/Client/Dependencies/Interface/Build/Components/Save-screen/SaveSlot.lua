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
local CircleButton = Interface:GetComponent("Buttons/CircleButton") 

return function(props) 
    return New "Frame" {
        Name = "Save",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 0.3),
        LayoutOrder = props.LayoutOrder or 0, 
    
        [Children] = {
        New "Frame" {
            Name = "Frame",
            BackgroundColor3 = props.Color, 
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.025, 0),
            Size = UDim2.fromScale(0.95, 1),
            ZIndex = 2,
    
            [Children] = {
                New "UICorner" {
                    Name = "UICorner",
                    CornerRadius = UDim.new(0.25, 0),
                },
        
                New "Frame" {
                    Name = "Image",
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Computed(function(Use)
                        local h, s, v = Use(props.Color):ToHSV()
                        return Color3.fromHSV(
                            h, 
                            s, 
                            v + 0.03
                        )
                    end),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 0,
                    Position = UDim2.fromScale(0.99, 0.5),
                    Size = UDim2.fromScale(0.9, 0.9),
                    SizeConstraint = Enum.SizeConstraint.RelativeYY,
                    ZIndex = 3,
        
                    [Children] = {
                        New "UICorner" {
                            Name = "UICorner",
                            CornerRadius = UDim.new(0.25, 0),
                        },
                    }
                },
    
                New "Frame" {
                    Name = "Actions",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1, 
                    Position = UDim2.fromScale(0.425, 0),
                    Size = UDim2.fromScale(0.425, 1),
        
                    [Children] = {
                        New "UIGridLayout" {
                            Name = "UIGridLayout",
                            CellSize = UDim2.fromScale(0.3, 1),
                            SortOrder = Enum.SortOrder.LayoutOrder,
                        },

                        ForPairs(props.Actions, function(Use, _, value)
                            return _, New "Frame" {
                                Name = "Frame",
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                LayoutOrder = value.LayoutOrder, 
                                Size = UDim2.fromOffset(100, 100),
                                ZIndex = 3,

                                [Children] = { 
                                    CircleButton {
                                        ButtonLock = if value.Locked then Value(true) else value.ButtonLock, 
                                        MouseButton1Down = value.MouseButton1Down or function() end,
                                        MouseButton1Up = value.MouseButton1Up or function() end, 
                                        Color = value.Color, 
                                        Image = value.Icon, 
                                        IconSize = value.IconSize or 0.8, 
                                        IconColor = Computed(function(Use)
                                            local h, s, v = Use(value.Color):ToHSV()

                                            return Color3.fromHSV(
                                                if value.Locked then
                                                    h
                                                else 
                                                    0
                                                , 
                                                if value.Locked then 
                                                    s 
                                                else 
                                                    0, 
                                                if value.Locked then
                                                    v + 0.1
                                                else 
                                                    1
                                            )
                                        end),
                                        LayoutOrder = value.LayoutOrder, 
                                        ZIndex = 4, 

                                        Size = UDim2.fromScale(0.95,0.95), 

                                        -- hover sizing
                                        Hover = not value.Locked, 
                                        PrimarySize = Value(UDim2.fromScale(0.9,0.9)), 
                                        PrimarySizeOffset = Value(0), 
                                    }
                                } 
                            }
                        end, Fusion.cleanup), 
                    }
                },
    
            New "Frame" {
                Name = "NamePlate",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                BackgroundTransparency = 1, 
                Position = UDim2.fromScale(0.025, 0),
                Size = UDim2.fromScale(0.375, 1),
    
                [Children] = {
                New "Frame" {
                    Name = "NameText",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.fromScale(0, 0.3),
                    Size = UDim2.fromScale(1, 0.35),
    
                    [Children] = {
                    New "TextLabel" {
                        Name = "Text",
                        FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                        Text = props.NameText,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextScaled = true,
                        TextSize = 32,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextWrapped = true,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(0.9, 1),
                        ZIndex = 4,
                    },
    
                    New "TextLabel" {
                        Name = "Shadow",
                        FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                        Text = props.NameText,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        TextScaled = true,
                        TextSize = 32,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextWrapped = true,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0.5, 1, 0.5, 1),
                        Size = UDim2.fromScale(0.9, 1),
                        ZIndex = 3,
                    },
    
                    New "Frame" {
                        Name = "NameFrame",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Computed(function(Use)
                            local color = Use(props.Color) 
                            local h, s, v = color:ToHSV() 
                            local newhue = if h == 0 then 0.02 else h 
                        
                            return Color3.fromHSV(newhue - 0.02, s, v+0.15) -- always get a shadow of the main color of the button. 
                        end),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1, 1.1),
                        ZIndex = 2,
    
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
                    Name = "TimeStamp",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.fromScale(0, 0.75),
                    Size = UDim2.fromScale(1, 0.25),
    
                    [Children] = {
                    New "TextLabel" {
                        Name = "Text",
                        FontFace = Font.new(
                            "rbxasset://fonts/families/FredokaOne.json",
                            Enum.FontWeight.Regular,
                            Enum.FontStyle.Italic
                        ),
                        Text = props.Timestamp or "n/a",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextScaled = true,
                        TextSize = 32,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextWrapped = true,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(0.9, 1),
                        ZIndex = 4,
                    },
    
                    New "TextLabel" {
                        Name = "Shadow",
                        FontFace = Font.new(
                        "rbxasset://fonts/families/FredokaOne.json",
                        Enum.FontWeight.Regular,
                        Enum.FontStyle.Italic
                        ),
                        Text = props.Timestamp or "n/a",
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        TextScaled = true,
                        TextSize = 32,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextWrapped = true,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0.5, 1, 0.5, 1),
                        Size = UDim2.fromScale(0.9, 1),
                        ZIndex = 3,
                    },
    
                    New "Frame" {
                        Name = "NameFrame",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Computed(function(Use)
                            local color = Use(props.Color) 
                            local h, s, v = color:ToHSV() 
                            local newhue = if h == 0 then 0.02 else h 
                        
                            return Color3.fromHSV(newhue - 0.02, s, v+0.15) -- always get a shadow of the main color of the button. 
                        end),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1, 1.1),
                        ZIndex = 2,
    
                        [Children] = {
                        New "UICorner" {
                            Name = "UICorner",
                            CornerRadius = UDim.new(1, 0),
                        },
                        }
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