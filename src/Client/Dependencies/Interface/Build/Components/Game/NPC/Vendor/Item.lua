local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local QuickIndex = require(Knit.Library.QuickIndex) 

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Interface = require(Knit.Modules.Interface.get)

local StrokeSize = Interface:GetUtilityBuild("1DSize")

local ViewportFrame = Interface:GetComponent("Frames/ViewportFrame")

return function (props)
    local Selected = props.Selected 

    local ItemId = props.ItemId

    local Object = QuickIndex:GetBuild(ItemId) 

    local ObjectData = {
        Name = Object.Object.Name, 
        Price = Object.Object:GetAttribute("Price"),
    }

    local Instance = Object.Object:Clone() 
    Instance:SetPrimaryPartCFrame(CFrame.new(0,0,0))

    -- clean object
    for i, v in Instance:GetChildren() do 
        if v.Name == "CollisionPart" then 
            v:Destroy() 
        end 
    end 

    return New "Frame" {
        Name = props.Name,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(100, 100),
        ZIndex = 4,
    
        [Children] = {
            New "Frame" {
                Name = "Background",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(20, 229, 255),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.85, 0.85),
                ZIndex = 0, 
            
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.1, 0),
                    },
                }
            },

            New "Frame" {
                Name = "Data",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Computed(function(Use)
                    if Use(Selected) == ItemId then 
                        return Color3.fromRGB(54, 255, 141)
                    else 
                        return Color3.fromRGB(54, 231, 255)
                    end
                end),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.85, 0.85),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                ZIndex = 4,
    
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
    
                    New "ImageLabel" {
                        Name = "Icon",
                        Image = "rbxassetid://14631514963",
                        ImageColor3 = Color3.fromRGB(0, 193, 249),
                        ImageTransparency = 0.6,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        Visible = false,
                        ZIndex = 4,
                    },
    
                    New "ImageLabel" {
                        Name = "Bubble",
                        Image = "rbxassetid://14641776232",
                        ImageColor3 = Color3.fromRGB(243, 248, 243),
                        ScaleType = Enum.ScaleType.Fit,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = 6,
                    },
    
                    New "Frame" {
                        Name = "Price",
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 212, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.65),
                        Size = UDim2.fromScale(0.95, 0.15),
                        ZIndex = 8,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.5, 0),
                            },
    
                            New "TextLabel" {
                                Name = "TextLabel",
                                FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                                Text = ObjectData.Price.." 🌽",
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
                                Size = UDim2.fromScale(0.975, 0.75),
                                ZIndex = 9,
    
                                [Children] = {
                                    New "UIStroke" {
                                        Name = "UIStroke",
                                        Color = Color3.fromRGB(255, 177, 0),
                                        Thickness = StrokeSize(3),
                                    },
                                }
                            },
                        }
                    },

                    New "ImageButton" {
                        Name = "ImageButton",
                        Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
                        ImageTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = 10,

                        [OnEvent "MouseButton1Up"] = function()
                            Selected:set(ItemId) 
                        end
                    },
    
                    New "Frame" {
                        Name = "ObjectName",
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(0, 191, 255),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.825),
                        Size = UDim2.fromScale(0.95, 0.15),
                        ZIndex = 8,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.5, 0),
                            },
    
                            New "TextLabel" {
                                Name = "TextLabel",
                                FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                                Text = ObjectData.Name,
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
                                Size = UDim2.fromScale(0.975, 0.75),
                                ZIndex = 9,
                            },
                        }
                    },
                }
            },

            ViewportFrame {
                Object = Instance,
                Visible = Value(true), -- TODO: optimize this  
                Size = UDim2.fromScale(1, 0.85),
                ZIndex = 3, 
            }
        }
    }
end 