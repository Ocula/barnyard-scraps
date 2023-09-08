local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Interface = require(Knit.Modules.Interface.get)

local Dialogue = {}
Dialogue.__index = Dialogue


function Dialogue.new(Package)
    local self = setmetatable({

    }, Dialogue)

    return self
end

-- @Ocula
-- Dialogue will always interpret an *ordered* speaking table.
function Dialogue:Speak(Tree: table) -- 
    for i, v in ipairs(Tree) do 
        print("Speak:", v)
    end 
end 


function Dialogue:Destroy()
    
end


return Dialogue
