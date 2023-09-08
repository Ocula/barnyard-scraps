local ReplicatedStorage = game:GetService("ReplicatedStorage") 
local Knit = require(ReplicatedStorage.Packages.Knit)

local Interface = require(Knit.Modules.Interface.get)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate, Attribute = Fusion.Hydrate, Fusion.Attribute

local InterfaceController = Knit.GetController("Interface") 

return function(props) 
    return New "Frame" {
        Name = props.Name, 
        LayoutOrder = props.LayoutOrder or 0, 
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(100, 100),
        ZIndex = 5,

        [Attribute "MouseHover"] = props.Name, 

        [Children] = {
            New "Frame" {
                Name = "Container",
                BackgroundColor3 = Computed(function(Use)
                    if Use(props.Selected) == props.Name then 
                        return Color3.fromRGB(255, 215, 0)
                    else
                        return Color3.fromRGB(255, 167, 0)
                    end
                end),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                ZIndex = 5,
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(1, 0),
                    },
    
                    New "ImageLabel" {
                        Name = "Icon",
                        Image = props.Image,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1 * (props.IconSizeOffset or 1), 1 * (props.IconSizeOffset or 1)),
                        ZIndex = 5,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(1, 0),
                            },
                        }
                    },
    
                    New "UIStroke" {
                        Name = "UIStroke",
                        Color = Color3.fromRGB(255, 255, 255),
                        Thickness = Computed(function(Use)
                            if Use(props.Selected) == props.Name then 
                                return 2.5
                            else 
                                return 0 
                            end 
                        end),
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
                    if props.MouseButton1Down then 
                        props.MouseButton1Down() 
                    end 
                end, 
 
                [OnEvent "MouseButton1Up"] = function()
                    if props.MouseButton1Up then 
                        props.MouseButton1Up() 
                    end 

                    if Peek(props.Selected) == props.Name then 
                        props.Selected:set("")
                        return 
                    end 
                    
                    props.Selected:set(props.Name) -- inventory is always observing tool select
                end, 
            },
        }
    }
end