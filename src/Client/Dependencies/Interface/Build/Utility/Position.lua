-- A Computed state object that will always return the true position given the original Resolution intent.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local InterfaceController = Knit.GetController("Interface") 

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Interface = require(Knit.Modules.Interface.get)
local Resolution = Interface:GetUtilityBuild("FixedResolution")

return function(position)
    return Computed(function(Use)
        local currentPosition = Use(position) 
        local fixedResolution = Peek(Resolution) 

        local scaleSet = Vector2.new(0,0)

        if typeof(currentPosition) == "UDim2" then 
            scaleSet = Vector2.new(currentPosition.X.Scale, currentPosition.Y.Scale) 
            currentPosition = Vector2.new(currentPosition.X.Offset, currentPosition.Y.Offset) 
        else 
            assert(typeof(currentPosition) == "Vector2", "Given Size variable needs to be either a UDim2 value or Vector2 ("..typeof(currentPosition)..")")   
        end 

        local currentViewportSize = Use(InterfaceController.ViewportSize)
        local ratio = currentViewportSize / fixedResolution 

        local rescale = Vector2.new(currentPosition.X * ratio.X, currentPosition.Y * ratio.Y) 

        return UDim2.new(scaleSet.X, rescale.X, scaleSet.Y, rescale.Y) 
    end)
end 

--[[
<3 little tutorial 

local Interface = require(Knit.Modules.Interface.get) 
local SizeUtility = Interface:GetUtility("Size") 

return function(props)

    return New "Frame" {
        Size = SizeUtility(UDim2.new(0,300,0,300))

        [Children] = { 

        }
    }
end

--]]