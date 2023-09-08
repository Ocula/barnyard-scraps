local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Interface = require(Knit.Modules.Interface.get)

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

return function(props) 
    return New "ScrollingFrame" {
        Name = props.Name or "Scroll",
        ScrollBarImageTransparency = 1,
        ScrollBarThickness = props.ScrollBarThickness or 6,
        Active = true,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,

        AutomaticCanvasSize = props.AutomaticCanvasSize or Enum.AutomaticSize.Y,

        ZIndex = props.ZIndex or 1,
        BackgroundTransparency = props.BackgroundTransparency or 1,
        CanvasSize = props.CanvasSize or UDim2.fromOffset(0,0), 
        Position = props.Position or UDim2.fromScale(0,0.05),
        Size = props.Size or UDim2.fromScale(1,1),

        --
        SelectionBehaviorDown = Enum.SelectionBehavior.Stop,
        SelectionBehaviorLeft = Enum.SelectionBehavior.Stop,
        SelectionBehaviorRight = Enum.SelectionBehavior.Stop,
        SelectionBehaviorUp = Enum.SelectionBehavior.Stop,

        [Children] = props.Children, 
    }
end 