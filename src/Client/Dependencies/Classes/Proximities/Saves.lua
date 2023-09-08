local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Saves = {}
Saves.__index = Saves


function Saves.new(PackagedPrompt)
    local self = setmetatable(PackagedPrompt, Saves)
    return self
end

function Saves:Show()

end 

function Saves:Hide()
    local Interface = Knit.GetController("Interface")

    if Peek(Interface.Game.Menus.Save.Visible) then 
        Interface.Game.Menus.Save:Toggle(false) 
    end
end 

function Saves:Triggered()

end 

function Saves:TriggerEnded()
    local Interface = Knit.GetController("Interface")
    
    -- toggle 
    local isOpen = Peek(Interface.Game.Menus.Save.Visible) 

    if isOpen then 
        Interface.Game.Menus.Save:Toggle(false) 
    else 
        Interface.Game.Menus.Save:Toggle(true) 
    end 
end

function Saves:Destroy()
    
end


return Saves
