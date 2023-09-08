local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Interface = require(Knit.Modules.Interface.get)

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

return function(props)
    local _add 

    if not props.Type then 
        _add = New "UIGridLayout" {
            Name = "ContentOrganizer",
            CellSize = props.ContentSize,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }
    else
        local _newObject = {
            Name = "ContentOrganizer"
        }
        
        for index, value in props.TypeProperties do 
            _newObject[index] = value 
        end 

        _add = New (props.Type) (_newObject)
    end 

    return New "Frame" {
        Name = "Content",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),

        [Children] = {
            _add,
            unpack(props.Children)
        },
    }
end 