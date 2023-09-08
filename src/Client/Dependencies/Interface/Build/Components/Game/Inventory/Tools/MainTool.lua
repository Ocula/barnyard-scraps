-- Handles the creation of all of the Edit UI buttons.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Interface = require(Knit.Modules.Interface.get)

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local ToolButton = Interface:GetComponent("Buttons/ToolButton") 

local AssetLibrary = require(Knit.Library.AssetLibrary) 

return function(props)
    return ToolButton {
        Name = props.Name, 
        LayoutOrder = props.LayoutOrder, 
        Image = AssetLibrary.get(
            props.Name.."Tool"
        ).ID,
        IconSizeOffset = props.IconSizeOffset or 0.8, 
        Selected = props.Selected, 

        MouseButton1Down = props.MouseButton1Down, 
    }
end