local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Interface = require(Knit.Modules.Interface.get)

return function(props)
    local Object = New "ProximityPrompt" {
        Name = "ProximityPrompt",
        ActionText = "Talk",
        ObjectText = props.Name, 
        Parent = props.Parent, 
        Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally,
        KeyboardKeyCode = props.Keycode or Enum.KeyCode.E, 
        GamepadKeyCode = props.GamepadCode or Enum.KeyCode.ButtonL2,
        RequiresLineOfSight = false,
        Style = Enum.ProximityPromptStyle.Custom,
        UIOffset = Vector2.new(0, 10),
    }

    Object:SetAttribute("HideBackground", true)

    Object:SetAttribute("KeycodeBackground", Color3.fromRGB(1255, 195, 49))
    Object:SetAttribute("KeystrokeColor", Color3.fromRGB(76, 76, 76))
    Object:SetAttribute("Trim", Color3.fromRGB(76,76,76))

    return Object 
end 