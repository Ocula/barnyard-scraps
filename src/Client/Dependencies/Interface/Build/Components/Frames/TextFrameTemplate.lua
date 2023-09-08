-- Text Frame for generating blocks of text in a UI element.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService") 
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Interface = require(Knit.Modules.Interface.get)

local TextSize = Interface:GetUtilityBuild("1DSize")

return function(props)
    local ScaledFontSize = TextSize(props.FontSize or 56) 
    local Font = props.Font or Font.new("rbxasset://fonts/families/FredokaOne.json")
    local TextAbsoluteSize = TextService:GetTextSize(props.Text, Peek(ScaledFontSize), Enum.Font.FredokaOne, Vector2.new(1980,50)) -- make sure text dont wrap

    local Visible = props.Visible
    local hasBeenVisible = false 
    
    Observer(Visible):onChange(function()
        hasBeenVisible = true 
    end)

    local Position = Computed(function(Use)
        local isVisible = Use(Visible) 

        if isVisible then 
            return UDim2.new(0,0,0,0)
        else 
            if hasBeenVisible then 
                return UDim2.new(0,0,-1.25,0) 
            else 
                return UDim2.new(0,0,1,0)
            end 
        end 
    end) 

    local PosSpring = Spring(Position, 25, .4) 

    return New "Frame" {
        Name = "TextTemplate",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Size = Computed(function()
            local Abs = TextAbsoluteSize
            return UDim2.new(0,Abs.X + Abs.X*0.05, 0, 50)
        end),
    
        [Children] = {
            New "TextLabel" {
                Name = "TextLabel",
                FontFace = Font,
                --RichText = true,
                Text = props.Text,
                TextColor3 = props.Color or Color3.fromRGB(255, 255, 255),
                TextSize = ScaledFontSize,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = Computed(function(Use)
                    return Use(PosSpring) 
                end), 
                Size = UDim2.fromScale(1, 1),

                [Children] = {
                    New "UIStroke" {
                        Thickness = TextSize(4), 
                        Color = Color3.fromRGB(76,76,76),
                    },
                }
            },
        }
    }
end 