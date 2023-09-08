local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Utility = require(Knit.Library.Utility) 

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

local TextFrame = Interface:GetComponent("Frames/TextFrameTemplate")

return function(props)
    local Split = Utility.splitString(props.Text, " ")
    local Visible = props.Visible 

    local hasShown = false 

    local currentVisibilities = {}

    for i, v in Split do 
        currentVisibilities[v:lower()] = Value(false) 
    end 

    Observer(Visible):onChange(function()
        local isVisible = Peek(Visible) 

        if isVisible then 
            if props.Delay then 
                task.wait(props.Delay)
            end 

            for i, v in currentVisibilities do
                v:set(true)
                task.wait(0.066) 
            end 
        else
            if props.Delay then 
                task.wait(props.Delay)
            end 

            for i, v in currentVisibilities do
                v:set(false)
                task.wait(0.066) 
            end 
        end 

        if hasShown and not isVisible then 
            return 
        elseif not hasShown and isVisible then 
            hasShown = true 
        end 
    end)

    return New "Frame" {
        Name = "Text",
        BackgroundColor3 = Color3.fromRGB(255, 174, 180),
        BackgroundTransparency = 1, --TODO change to 1, @ 0.75 for testing.
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = props.Position,
        Size = props.Size,
    
        [Children] = {
            New "UIListLayout" {
                Name = "UIListLayout",
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            },

            ForValues(Split, function(use, value)
                return TextFrame {
                    Font = props.Font, 
                    FontSize = props.FontSize, 
                    Color = props.Color, 
                    Text = value, 
                    Visible = currentVisibilities[value:lower()],
                }
            end, Fusion.cleanup)
        }
    }
end 