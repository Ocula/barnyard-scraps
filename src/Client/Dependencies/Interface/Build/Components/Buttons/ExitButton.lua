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

local StrokeSize = Interface:GetUtilityBuild("1DSize") 

return function(props)
    local Parent = props.Parent
    local Size = props.Size 
    local Rotate = props.Rotate or Value(6) 
    local ZIndex = props.ZIndex or Value(8) -- always on top

    --

    local Pop = Value(0) 
    local PopSpring = Spring(Pop, 25, .6)

    -- 

    local Position = props.Position or Value(UDim2.fromScale(1,0))
    local ExitSignal = props.ExitSignal 

    -- 

    local AbsoluteSizeChange = Parent:GetPropertyChangedSignal("AbsoluteSize")
    local AbsoluteSize = Value(Parent.AbsoluteSize)
    local OriginalSize = Peek(AbsoluteSize) 

    AbsoluteSizeChange:Connect(function()
        AbsoluteSize:set(Parent.AbsoluteSize)
    end)

    return New "Frame" {
        Name = "Exit",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Parent = Parent, 
        Position = Computed(function(Use)
            if Position then 
                return Use(Position) 
            else 
                return UDim2.fromScale(1, 0)
            end 
        end),
        
        Size = Computed(function(Use)
            return UDim2.fromScale(Use(PopSpring) + 0.175, Use(PopSpring) + 0.175)
        end),--[[Computed(function(Use)
            local size = Use(Size) -- Vector2
            local parentSize = Use(AbsoluteSize) 
            local scale = parentSize / OriginalSize
            local scalePoint = (size.Y / OriginalSize.Y) * scale.Y

            warn("ScalePoint:", scalePoint)

            return UDim2.fromScale(scalePoint + (Use(PopSpring) * scalePoint), scalePoint + (Use(PopSpring) * scalePoint)) 
        end)--]]

        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        ZIndex = ZIndex,
    
        [Children] = {
            New "Frame" {
                Name = "Exit",
                BackgroundColor3 = Color3.fromRGB(243, 124, 106),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                LayoutOrder = 2,
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                ZIndex = Computed(function(Use)
                    return Peek(ZIndex) + 2 
                end),
    
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
                        ZIndex = Computed(function(Use)
                            return Peek(ZIndex) + 2 
                        end),
    
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
                        ZIndex = Computed(function(Use)
                            return Peek(ZIndex) + 3
                        end),

                        [OnEvent "MouseEnter"] = function()
                            Pop:set(.025)  
                        end, 

                        [OnEvent "MouseLeave"] = function()
                            Pop:set(0) 
                        end,

                        [OnEvent "MouseButton1Down"] = function()
                            Pop:set(-0.03) 
                        end, 

                        [OnEvent "MouseButton1Up"] = function()
                            Pop:set(0) 

                            ExitSignal:Fire(Parent) 
                        end, 
                    },
    
                    New "ImageLabel" {
                        Name = "IconStroke",
                        Image = "rbxassetid://14628993846",
                        ImageColor3 = Color3.fromRGB(76, 76, 76),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Rotation = Rotate,
                        Size = UDim2.fromScale(0.875, 0.875),
                        ZIndex = Computed(function(Use)
                            return Peek(ZIndex) + 3
                        end),
                    },
    
                    New "ImageLabel" {
                        Name = "ImageLabel",
                        Image = "rbxassetid://14465129538",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = Computed(function(Use)
                            return Peek(ZIndex) + 2 
                        end),
                    },
    
                    New "ImageLabel" {
                        Name = "Icon",
                        Image = "rbxassetid://14628993046",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Rotation = Rotate,
                        Size = UDim2.fromScale(0.875, 0.875),
                        ZIndex = Computed(function(Use)
                            return Peek(ZIndex) + 4
                        end),
                    },
                }
            },
        }
    }
end 