local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

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

local Size = Interface:GetUtilityBuild("Size") 
local Size1D = Interface:GetUtilityBuild("1DSize")

return function(props)
    local Text = props.Text 
    local Position = props.Position 

    local PositionSpring = Spring(Position, 25, .8)

    local TextLabelOffset = Size1D(Value(28))
    local FontSize = Size1D(Value(28))

    local BaseVectorSize = Value(UDim2.fromOffset(15,40))
    local BaseSize = Size(BaseVectorSize) 

    local SizeProp = Computed(function(Use)
        local GetBaseSize = Peek(BaseSize) 
        local currentText = Use(Text) 

        local size = TextService:GetTextSize(currentText, Use(FontSize), Enum.Font.FredokaOne, Vector2.new(400,GetBaseSize.Y))

        return UDim2.new(0, GetBaseSize.X.Offset + size.X,  0, GetBaseSize.Y.Offset)
    end)

    return New "Frame" {
        Name = "Mouse",
        BackgroundColor3 = Color3.fromRGB(76, 76, 76),
        BackgroundTransparency = 1,
        Visible = Computed(function(Use)
            return Use(Text) ~= ""
        end),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,

        Position = Computed(function(Use)
            local PositionSpringSet = Use(PositionSpring) 
            return UDim2.fromOffset(PositionSpringSet.X + 5,PositionSpringSet.Y)
        end),
        
        Size = SizeProp,
    
        [Children] = {
            New "TextLabel" {
                Name = "TextLabel",
                FontFace = Font.new(
                    "rbxasset://fonts/families/FredokaOne.json",
                    Enum.FontWeight.Bold,
                    Enum.FontStyle.Normal
                ),
                Text = Text, 
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = FontSize,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = Computed(function(Use)
                    local OffsetX = Use(TextLabelOffset)
                    return UDim2.fromOffset(OffsetX, 0)
                end),
                Size = UDim2.fromScale(1, 1),
                ZIndex = 21,
            },
    
            New "Frame" {
                Name = "Tail",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(Peek(SizeProp).Y.Offset/2,0), 
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Size = UDim2.fromScale(1,1),
                ZIndex = 19,
    
                [Children] = {
                    New "ImageLabel" {
                        Name = "ImageLabel",
                        Image = "rbxassetid://14680815182",
                        ImageColor3 = Color3.fromRGB(76, 76, 76),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(0.5, 1),
                    },
                }
            },
    
            New "Frame" {
                Name = "Background",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(76, 76, 76),
                Position = UDim2.fromOffset(Peek(SizeProp).Y.Offset/2,0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 20,
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0, 7),
                    },
                }
            },
        }
    }
end 