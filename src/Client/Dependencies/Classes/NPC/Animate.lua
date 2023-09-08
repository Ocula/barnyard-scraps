local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--
local Interface = require(Knit.Modules.Interface.get)
--
local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Animate = {}
Animate.__index = Animate


function Animate.new()
    local self = setmetatable({}, Animate)
    return self
end


function Animate:Destroy()
    
end


return Animate
