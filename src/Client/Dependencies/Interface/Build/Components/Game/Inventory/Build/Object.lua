local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Interface = require(Knit.Modules.Interface.get)
local InterfaceController = Knit.GetController("Interface") 

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local ViewportFrame = Interface:GetComponent("Frames/ViewportFrame")

local StrokeSize = Interface:GetUtilityBuild("1DSize") 

return function(props)
    local Object = props.Object 
    local Rotate = props.Rotate or Value(0) 
    local Visible = props.Visible 
    local Selected = props.Selected 
    local ItemId = props.ItemId 
    local Highlighted = Value(false) 

    local Maid = props.Maid 

    return New "Frame" {
        Name = props.Title,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0.9, 0.9),
        LayoutOrder = props.LayoutOrder or 0, 
        SizeConstraint = Enum.SizeConstraint.RelativeXX,
        ZIndex = 5,
    
        [Children] = {
            New "Frame" {
                Name = "Amount",
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1, 
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.955, 0),
                Size = UDim2.fromScale(0.45, 0.2),
                ZIndex = 6, 
            
                [Children] = {
                    New "TextLabel" {
                        Name = "Amount",
                        FontFace = Font.new(
                            "rbxasset://fonts/families/FredokaOne.json",
                            Enum.FontWeight.Bold,
                            Enum.FontStyle.Normal
                        ),
                        Text = props.Data.Amount,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextScaled = true,
                        TextSize = 14,
                        TextWrapped = true,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 100, 100),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(255, 100, 100),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = 8,
            
                        [Children] = {
                            New "UITextSizeConstraint" {
                                Name = "UITextSizeConstraint",
                                MaxTextSize = 48,
                            },
            
                            New "UIStroke" {
                                Name = "UIStroke",
                                Color = Color3.fromRGB(36, 179, 0),
                                Thickness = 3,
                            },
                        }
                    },
            
                    New "Frame" {
                        Name = "Background",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(94, 193, 52),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = 5,
            
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(1, 0),
                            },

                            New "UIStroke" {
                                Name = "UIStroke",
                                Color = Computed(function(Use)
                                    if Use(Selected) == ItemId then 
                                        return Color3.fromRGB(251, 255, 27)
                                    end
        
                                    if Use(Highlighted) then 
                                        return Color3.fromRGB(255,255,255)
                                    end 
        
                                    return Color3.fromRGB(76, 76, 76)
                                end),
                                Thickness = StrokeSize(8),
                            },
            
                            New "ImageLabel" {
                                Name = "ImageLabel",
                                Image = "rbxassetid://14465129538",
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Size = UDim2.fromScale(1, 1),
                                ZIndex = 6,
                            },
                        }
                    },
                }
            },

            New "Frame" {
                Name = "Frame",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(1, 216, 249),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.875, 0.875),
                ZIndex = 5,
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.125, 0),
                    },
    
                    New "UIStroke" {
                        Name = "Select",
                        Color = Computed(function(Use)
                            if Use(Selected) == ItemId then 
                                return Color3.fromRGB(251, 255, 27)
                            end

                            if Use(Highlighted) then 
                                return Color3.fromRGB(255,255,255)
                            end 

                            return Color3.fromRGB(76, 76, 76)
                        end), 

                        Thickness = StrokeSize(8)
                    },

                    New "ImageLabel" {
                        Name = "Texture",
                        Image = "rbxassetid://14080052911",
                        ImageTransparency = 0.925,
                        ResampleMode = Enum.ResamplerMode.Pixelated,
                        ScaleType = Enum.ScaleType.Tile,
                        TileSize = UDim2.fromScale(0.75, 0.75),
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

                    -- Add ViewportFrame support
                    ViewportFrame {
                        Object = Object, 
                        Rotate = Rotate,

                        ZIndex = 7, 
                        Visible = Visible, 
                    },
    
                    -- Title Text
                    New "Frame" {
                        Name = "Frame",
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(5, 184, 255),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.7),
                        Size = UDim2.fromScale(0.9, 0.25),
                        ZIndex = 6,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.25, 0),
                            },
    
                            New "TextLabel" {
                                Name = "TextLabel",
                                FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                                Text = props.Title,
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
                                Size = UDim2.fromScale(0.9, 0.9),
                                ZIndex = 6,
    
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
    
            New "TextButton" {
                Name = "Button",
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                Text = "",
                TextColor3 = Color3.fromRGB(0, 0, 0),
                TextSize = 14,
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.85, 0.85),
                ZIndex = 7,

                [OnEvent "MouseEnter"] = function()
                    Highlighted:set(true)
                end,

                [OnEvent "MouseLeave"] = function()
                    Highlighted:set(false)
                end, 

                [OnEvent "MouseButton1Down"] = function()

                end, 

                [OnEvent "MouseButton1Up"] = function()
                    if props.MouseButton1Up then 
                        props.MouseButton1Up()
                    end 
                end, 
            },
        }
    }
end 