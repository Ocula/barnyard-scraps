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
local Hydrate, Attribute = Fusion.Hydrate, Fusion.Attribute

local Text = Interface:GetComponent("Frames/Text") 
local ZoneTheme = Interface:GetTheme("Game/Zones")

return function(props)

    local Visible = props.Visible 

    return New "Frame" {
        Name = "Frame",
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 35),
        Size = UDim2.fromOffset(350, 150),
    
        [Children] = {
            Text {
                Name = "Body",
                Position = UDim2.fromScale(0, 0.35),
                Size = UDim2.fromScale(1, 0.65),

                Delay = 0.15, 

                Text = props.Body, 
                FontSize = 56, 
                Color = ZoneTheme[props.Body], 
                Visible = Visible, 
                --Font doesn't need to be set it's automatically at FredokaOne
            },

            Text {
                Name = "Header",
                Position = UDim2.fromScale(0, 0.1),
                Size = UDim2.fromScale(1,0.35),

                Text = props.Header, 
                Font = Font.new("rbxassetid://12187375716"),
                FontSize = 48, 
                Visible = Visible, --not needed right now. 
            },
        }
    }
end 