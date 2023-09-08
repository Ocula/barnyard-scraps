--[[

    Game HUD -> Main UI
    
    Buttons that will essentially connect us to the rest of the Menu objects. 
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

local HUD = {}
HUD.__index = HUD

local HUDComponent = Interface:GetComponent("Game/HUD/Build")

function HUD.new(parent) 
    local self = setmetatable({
        Visibility = {
            Parent  = Value(false), 
            
            Edit        = Value(false), 
            Backpack    = Value(true), 
            Settings    = Value(true), 
            Shop        = Value(true),
            Teleport    = Value(true), 

            Corn        = Value(true), 
            Rank        = Value(true), 

            PlayPanel   = {
                Panel       = Value(false), 

                Play        = Value(true), 
                Pause       = Value(true),
                SetStart    = Value(true)
            }
        },

        PanelSelect = Value(""), 

        Toggles = {
            Edit = Value(false), 

            Play = Value(false),
            Pause = Value(false),
            SetStart = Value(false), 
        },

        Locks = {
            Master = Value(false), 
            
            SetStart = Value(false),
            Pause = Value(true), 
            Play = Value(false), 
        },
    

        Data = {
            Corn = Value(0),
            Experience = Value(0),
            Rank = Value("Chickadee"), -- default set

            Max = Value(false), 
        }, 
    }, HUD)

    self.Visibility.PlayPanel.Parent = Computed(function(Use)
        if Use(self.Visibility.Parent) == false then 
            return false 
        end 

        return Use(self.Visibility.PlayPanel.Panel) 
    end)

    self.Object = HUDComponent {
        Parent = parent, 

        Corn = self.Data.Corn, 
        Experience = self.Data.Experience, 
        Rank = self.Data.Rank,

        PanelSelect = self.PanelSelect, 

        Locks = self.Locks, --TODO: add in menu buttons

        Max = self.Data.Max,

        Visibility = self.Visibility, 
        Toggles = self.Toggles, 
    }

    return self
end

function HUD:Lock(button: string, bool: boolean)
    if not self.Locks[button] then warn("No button found for:", button) end 

    self.Locks[button]:set(bool) 
end 

function HUD:SelectPanel(name: string, toggleBool: boolean?) 
    local Panel = self.PanelSelect 
    local Toggle = self.Toggles[name] 

    if Toggle then 
        Toggle:set(toggleBool) 
    end 

    Panel:set(name) 

    if toggleBool then 
        for nameCheck, state in self.Toggles do 
            if nameCheck ~= name and nameCheck ~= "Edit" then 
                state:set(false) 
            end 
        end 
    end 
end 

function HUD:Toggle(bool: boolean)
    self.Visibility.Parent:set(bool) 
end 


function HUD:Destroy()
    
end


return HUD
