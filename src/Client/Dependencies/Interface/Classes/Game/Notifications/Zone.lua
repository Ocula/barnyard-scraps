local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(Knit.Library.Maid) 

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

local Zone = {}
Zone.__index = Zone

local ZoneComponent = Interface:GetComponent("Game/Notifications/Zone")

function Zone.new(Data)
    local InterfaceController = Knit.GetController("Interface") 

    local self = setmetatable({
        Zone = Data.Name, 
        Lifetime = Data.Lifetime or 3, 
        Visible = Value(false),

        Maid = Maid.new(), 
    }, Zone)

    self.Object = ZoneComponent {
        Body = self.Zone, 
        Visible = self.Visible, 
        Header = "You're in", 
    }

    self.Object.Parent = InterfaceController:GetBin() 

    self.Maid:GiveTask(self.Object) 

    return self
end

function Zone:Show()
    self.Visible:set(true) 

    task.delay(self.Lifetime, function()
        if Peek(self.Visible) then 
            self:Hide()
            task.wait(1) 
            self:Destroy() 
        end 
    end)
end 

function Zone:Hide(_rush)
    self.Visible:set(false) 

    if not _rush then 
        task.wait(3) 
    end 
end 

function Zone:Destroy()
    if Peek(self.Visible) then 
        self:Hide(true)
    end 

    self.Maid:DoCleaning() 
end


return Zone
