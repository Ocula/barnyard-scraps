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

return function(props)
    local Filter = props.Filter 
    local ButtonSignal = props.ButtonSignal 

    local Size = Vector2.new(1.5, 1.5) 
    local Pop = Value(0)
    local PopSpring = Spring(Pop, 25, .6) 

    return New "Frame" {
        Name = Filter,
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(95, 233, 243),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Position = UDim2.fromScale(0, 0.5),
        Size = Computed(function(Use)
            local PopSpringSet = Use(PopSpring) 
            return UDim2.fromScale(Size.X + PopSpringSet, Size.Y + PopSpringSet)
        end),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        ZIndex = 5,
    
        [Children] = {
            New "UICorner" {
                Name = "UICorner",
                CornerRadius = UDim.new(1, 0),
            },
    
            New "Frame" {
                Name = "WhiteStroke",
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
    
                    New "UIStroke" {
                        Name = "UIStroke",
                        Color = Color3.fromRGB(76, 76, 76),
                        Thickness = StrokeSize(8),
                    },
                }
            },
    
            New "ImageButton" {
                Name = "Button",
                Image = "rbxassetid://14465236652",
                ImageTransparency = 1,
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                ZIndex = 6,

                [Attribute "MouseHover"] = Filter, 

                [OnEvent "MouseEnter"] = function()
                    Pop:set(0.05)
                end,

                [OnEvent "MouseLeave"] = function()
                    Pop:set(0) 
                end, 

                [OnEvent "MouseButton1Up"] = function()
                    Pop:set(0)

                    ButtonSignal:Fire()
                end, 

                [OnEvent "MouseButton1Down"] = function()
                    Pop:set(-0.05) 
                end, 

            },
    
            New "ImageLabel" {
                Name = "IconStroke",
                Image = "rbxassetid://14465315283",
                ImageColor3 = Color3.fromRGB(76, 76, 76),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.875, 0.875),
                Visible = false,
                ZIndex = 6,
            },
    
            New "ImageLabel" {
                Name = "ImageLabel",
                Image = "rbxassetid://14465129538",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 5,
            },
    
            New "ImageLabel" {
                Name = "Icon",
                Image = "rbxassetid://14465236652",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.7, 0.7),
                Visible = false,
                ZIndex = 7,
            },
        }
    }
end 