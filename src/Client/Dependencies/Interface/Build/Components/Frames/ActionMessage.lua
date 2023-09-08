local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--
local Interface = require(Knit.Modules.Interface.get)
--
local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local HUDButton = Interface:GetComponent("Buttons/HUDButton")
local ButtonTheme = Interface:GetTheme("Buttons/CircleButton") 
local ActionMessageTheme = Interface:GetTheme("Frames/ActionMessage")

local StrokeSize = Interface:GetUtilityBuild("1DSize")

local AssetLibrary = require(Knit.Library.AssetLibrary) 

return function(props)
    assert(props.Body, "Message UI must be provided with a body.")
    
    if props.Color then 
        assert(props.Color.Background and props.Color.Trim and props.Color.Texture, "Color property provided must be a theme element.")
    else 
        props.Color = ActionMessageTheme.Default 
    end 

    --Y:", props.Body)

    local Actions = {
        Capture = Value(false),
        Choose = Value(false),
    }

    local captureRef = Value() 
    local captureTries = 0 

    if props.Choose then 
        Actions.Choose:set(true) 
    end 

    if props.Capture then 
        Actions.Choose:set(false)
        Actions.Capture:set(true) 
    end 

    local position = Computed(function(Use)
        if Use(props.Visible) then 
            return UDim2.fromScale(0.5,0.5)
        else 
            return UDim2.fromScale(0.5,-0.25)
        end 
    end)

    local positionSpring = Spring(position, 25, .5)
    local parentZIndex = 5 

    local Selected = Value("Yes")

    -- we can have this calibrate frame size to allow 4 both possibilities. 

    return New "Frame" {
        Name = "Message",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = parentZIndex, 
        Position = positionSpring, 
        Size = UDim2.fromScale(0.65, 0.4),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
    
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
                    Name = "Container",
                    BackgroundColor3 = props.Color.Background,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = parentZIndex + 1, 
                    Size = UDim2.fromScale(1, 1),
    
                [Children] = {
                    New "UIStroke" {
                        Name = "UIStroke",
                        Color = Color3.fromRGB(76, 76, 76),
                        Thickness = StrokeSize(8),
                    },

                    New "ImageLabel" {
                        Name = "Texture",
                        Image = "rbxassetid://14005215526",
                        ImageColor3 = props.Color.Texture,
                        ImageTransparency = 0.6,
                        ResampleMode = Enum.ResamplerMode.Pixelated,
                        ScaleType = Enum.ScaleType.Tile,
                        TileSize = UDim2.fromScale(1, 1.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        ZIndex = parentZIndex + 2, 
                        Size = UDim2.fromScale(1, 1),
        
                        [Children] = {
                        New "UICorner" {
                            Name = "UICorner",
                            CornerRadius = UDim.new(0.1, 0),
                        },
                        }
                    },
        
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.1, 0),
                    },
        
                    New "Frame" {
                        Name = "Header",
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = props.Color.Trim,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        ZIndex = parentZIndex + 3, 
                        Position = UDim2.fromScale(0.5, 0.04),
                        Size = UDim2.fromScale(0.95, 0.175),
    
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
                            Text = props.Header or "Header",
                            TextColor3 = Color3.fromRGB(255, 255, 255),
                            TextScaled = true,
                            TextSize = 14,
                            TextWrapped = true,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AnchorPoint = Vector2.new(0, 0.5),
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            ZIndex = parentZIndex + 4, 
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.fromScale(0.025, 0.5),
                            Size = UDim2.fromScale(0.95, 0.85),
                        },
                    }
                },
    
                New "Frame" {
                    Name = "Text",
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundColor3 = props.Color.Trim,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = parentZIndex + 3, 
                    Position = UDim2.fromScale(0.5, 0.255),
                    Size = UDim2.fromScale(0.95, 0.705),
    
                    [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.1, 0),
                    },
    
                    New "TextLabel" {
                        Name = "Text",
                        FontFace = Font.new(
                            "rbxasset://fonts/families/FredokaOne.json",
                            Enum.FontWeight.Medium,
                            Enum.FontStyle.Normal
                        ),
                        Text = props.Body,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextScaled = true,
                        ZIndex = parentZIndex + 4, 
                        TextSize = 32,
                        TextWrapped = true,
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.1),
                        Size = UDim2.fromScale(0.85, 0.35),
                    },
                    }
                },
    
                New "Frame" {
                    Name = "Actions",
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundColor3 = Color3.fromRGB(245, 202, 88),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = parentZIndex + 4, 
                    Position = UDim2.fromScale(0.5, 0.625),
                    Size = UDim2.fromScale(0.95, 0.3),
    
                    [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.1, 0),
                    },
    
                    New "Frame" {
                        Name = "Capture",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        ZIndex = parentZIndex + 5, 
                        Size = UDim2.fromScale(0.2, 1),
                        Visible = Actions.Capture,
    
                        [Children] = {
                            New "Frame" {
                                Name = "Box",
                                AnchorPoint = Vector2.new(0.5, 0),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5, 0),
                                Size = UDim2.fromScale(4, 1),
        
                                [Children] = {
                                    New "TextBox" {
                                        [Ref] = captureRef, 

                                        Name = "TextBox",
                                        FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                                        MultiLine = false,
                                        PlaceholderColor3 = Color3.fromRGB(255, 200, 140),
                                        PlaceholderText = props.CapturePlaceholderText or "Type here!",
                                        ClearTextOnFocus = true, 
                                        Text = "",
                                        TextColor3 = Color3.fromRGB(255, 255, 255),
                                        TextScaled = true,
                                        ShowNativeInput = false, 
                                        TextSize = 14,
                                        TextWrapped = true,
                                        ZIndex = parentZIndex + 5, 
                                        AnchorPoint = Vector2.new(0, 0.5),
                                        BackgroundColor3 = props.Color.Trim, 
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = UDim2.fromScale(0, 0.5),
                                        Size = UDim2.fromScale(1, 0.6),

                                        [OnEvent "FocusLost"] = function(enter)
                                            if props.Capture then 
                                                if #Peek(captureRef).Text > 0 then 
                                                    Actions.Capture:set(false) 
                                                    Actions.Choose:set(true) 

                                                    props.Body:set("Are you sure you want to rename your save to '"..Peek(captureRef).Text.."'?")
                                                else 
                                                    local Text = "The name you entered was blank! Try again."
                                                    captureTries += 1/3 -- my lil cheat lol

                                                    if captureTries > 1 then 
                                                        Text = Text .. " ("..tostring(math.floor(captureTries))..")"
                                                    end 

                                                    props.Body:set(Text) 
                                                    Peek(captureRef):CaptureFocus() 
                                                end 
                                            end
                                        end,--]]
            
                                        [Children] = {
                                            New "UICorner" {
                                                Name = "UICorner",
                                            },
                                        }
                                    },
    
                            New "Frame" {
                                Name = "TextBoxFrame",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = Color3.fromRGB(255, 175, 0),
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                ZIndex = parentZIndex + 4, 
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(1.05, 0.65),
    
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
    
                    New "UIListLayout" {
                        Name = "UIListLayout",
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    },
    
                    New "Frame" {
                        Name = "Options",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(0.6, 1),
                        Visible = Actions.Choose,
    
                        [Children] = {
                            New "Frame" {
                                Name = "Left",
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                BackgroundTransparency = 1, 
                                Size = UDim2.fromScale(1, 1),
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,

                                [Children] = {
                                    HUDButton {
                                        AnchorPoint = Vector2.new(0.5,0.5),
                                        Position = UDim2.fromScale(0.5,0.5), 

                                        Name = "Checkmark",
                                        HoverName = "", 
                                        Size = UDim2.fromScale(1,1),

                                        MouseButton1Up = function()
                                            props.Result:Fire(true) 
                                            props.Choose(true, props.Visible, captureRef) 
                                        end, 
                                    }
                                }
                            },
        
                            New "Frame" {
                                Name = "Right",
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                BackgroundTransparency = 1, 
                                Size = UDim2.fromScale(1, 1),
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,

                                [Children] = {
                                    HUDButton {
                                        AnchorPoint = Vector2.new(0.5,0.5),
                                        Position = UDim2.fromScale(0.5,0.5), 

                                        Name = "Exit", 
                                        HoverName = "", 
                                        Size = UDim2.fromScale(1,1), 

                                        MouseButton1Up = function()
                                            props.Result:Fire(false) 
                                            props.Choose(false, props.Visible) 
                                        end, 
                                    }
                                }
                            },
        
                            New "UIListLayout" {
                                Name = "UIListLayout",
                                Padding = UDim.new(0.1, 0),
                                FillDirection = Enum.FillDirection.Horizontal,
                                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                SortOrder = Enum.SortOrder.LayoutOrder,
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