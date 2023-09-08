--[[

    Save UI
    
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Interface = require(Knit.Modules.Interface.get)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Save = {}
Save.__index = Save

local ExitButton = Interface:GetClass("Game/Exit") 

function Save.new(parent)
    local self = setmetatable({
        -- create a button here for main menu 
        Visible = Value(false), 
        Saves = Value({}), -- will be blank if there aren't any saves to load.
        Frozen = Value(false), 
    }, Save)

    self.Object = Interface:GetComponent("Save-screen/SaveMenu")({
        Visible = self.Visible, 
        Saves = self.Saves, 
        Frozen = self.Frozen
    })

    local ExitButton = ExitButton.new(self.Object, function()
        self:Toggle(false)
    end, Value(UDim2.fromScale(0.95,0)))

    self:Load() 

    self.Object.Parent = parent 

    return self
end

function Save:Freeze()
    self.Frozen:set(true) 
end 

function Save:Thaw()
    self.Frozen:set(false)
end 

function Save:isVisible()
    return Peek(self.Visible) 
end 

function Save:Load()
    Knit.GetService("PlayerService"):GetPlayerSaves():andThen(function(saves)
        if not saves then 
            saves = {}
        end 

        self.Saves:set(saves) -- updates saves. 
    end):catch(error)
end 

function Save:Toggle(bool: boolvalue)
    --[[if bool then 
        self:Load() 
    end--]]

    local Interface = Knit.GetController("Interface")
    Interface.Game.HUD:Toggle(not bool)

    self.Visible:set(bool) 
end 

function Save:Destroy()
    
end


return Save
