--[[
    Component with everything inside of an Inventory section page.
]]

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

return function(props)

    local offsetSize = Value(0) 

    local size = Computed(function(Use)
        local sizeEdit = UDim2.fromScale(1,1) 
        
        if props.Size then 
            sizeEdit = Use(props.Size)
        end 

        local offsetSizeSet = Use(offsetSize)

        return UDim2.fromScale(sizeEdit.X.Scale + offsetSizeSet, sizeEdit.Y.Scale + offsetSizeSet) 
    end) 

    local springSize = Spring(size, 25, 0.6) 
    local LayoutOrder = props.LayoutOrder 
    local colorTheme = props.Theme 

    return New "Frame" {
        Name = "Page",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        LayoutOrder = LayoutOrder,
        Parent = props.Parent, 
        Size = springSize,
        SizeConstraint = Enum.SizeConstraint.RelativeXX,
        ZIndex = 5,
    
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
                        Name = "Shadow",
                        BackgroundColor3 = colorTheme.Shadow,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.075, 0.075),
                        Size = UDim2.new(0.85, 2, 0.85, 2),
                        ZIndex = 4,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.1, 0),
                            },
                        }
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
                        ZIndex = 6,

                        [OnEvent "MouseButton1Down"] = function()
                            offsetSize:set(-0.05) 

                            if props.MouseButton1Down then 
                                props.MouseButton1Down(size) 
                            end 

                        end, 

                        [OnEvent "MouseButton1Up"] = function()
                            offsetSize:set(0) 

                            if props.MouseButton1Up then 
                                props.MouseButton1Up(size) 
                            end 
                        end,

                        [OnEvent "MouseEnter"] = function()
                            offsetSize:set(0.05) 
                        end, 

                        [OnEvent "MouseLeave"] = function()
                            offsetSize:set(0) 
                        end
                    },
    
                    New "Frame" {
                        Name = "Highlight",
                        BackgroundColor3 = colorTheme.Highlight,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0.075, -2, 0.075, -2),
                        Size = UDim2.new(0.85, 2, 0.85, 2),
                        ZIndex = 4,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.1, 0),
                            },
                        }
                    },
    
                    New "Frame" {
                        Name = "Container",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = colorTheme.Main,
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
                                Name = "Icon",
                                Image = props.Image, 
                                ImageTransparency = 0,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Size = UDim2.fromScale(1, 1),
                                ZIndex = 5,
    
                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(0.1, 0),
                                    },
                                }
                            },
                        }
                    },
                }
            },
            
            New "TextLabel" {
                Name = "SectionName",
                FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                Text = props.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextScaled = true,
                TextSize = 18,
                TextStrokeColor3 = colorTheme.Trim, 
                TextStrokeTransparency = 0,
                TextWrapped = true,
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.6, 0.6),
                ZIndex = 5,
            }
        }
    }
end 