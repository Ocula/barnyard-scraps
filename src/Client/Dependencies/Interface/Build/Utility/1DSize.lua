-- A Computed state object that will always return the true size given the original Resolution intent.
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

local Resolution = Interface:GetUtilityBuild("FixedResolution")

return function(size) -- TODO: change all Thickness properties to a Stroke Value. We
    local InterfaceController = Knit.GetController("Interface") 
    
    if type(size) == "number" then 
        size = Value(size) 
    end 

    return Computed(function(Use)
        local currentSize = Use(size)
        local fixedResolution = Peek(Resolution)
        
        local currentViewportSize = Use(InterfaceController.ViewportSize)
        
        local targetAspectRatio = currentViewportSize.X / currentViewportSize.Y 
        local originalAspectRatio = fixedResolution.X / fixedResolution.Y 
        
        local widthScale = currentViewportSize.X / fixedResolution.X
        local heightScale = currentViewportSize.Y / fixedResolution.Y
        
        local aspectRatio = targetAspectRatio / originalAspectRatio
        local scale = math.min(widthScale, heightScale, aspectRatio)
        
        local scaledSize = currentSize * scale 
        
        return scaledSize 
    end)
end 