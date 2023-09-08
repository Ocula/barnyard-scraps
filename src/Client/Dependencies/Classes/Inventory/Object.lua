local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Interface = require(Knit.Modules.Interface.get)

local Signal = require(Knit.Library.Signal)
local Utility = require(Knit.Library.Utility) 
local QuickIndex = require(Knit.Library.QuickIndex) 
local Maid = require(Knit.Library.Maid) 

local ObjectComponent = Interface:GetComponent("Game/Inventory/Build/Object")

local Object = {}
Object.__index = Object

local function cleanObject(Object)
    for i, v in Object:GetChildren() do 
        if v.Name == "CollisionPart" then 
            v:Destroy() 
        end 
    end 
    
    return Object
end 

function Object.new(Selected, Data) 
    local Item = QuickIndex:GetBuild(Data.ItemId)
    if not Item then return end 

    local self = setmetatable({
        Request = Selected.ObjectRequest, 

        Selected = Selected.Object,
        Visible = Value(true), 
        ItemId = Data.ItemId, 
        Instance = cleanObject(Item.Object:Clone()),
        Maid = Maid.new(),
        Data = {}, 
    }, Object)

    for i, v in Data do 
        self.Data[i] = Value(v) 
    end 

    self.Object = ObjectComponent {
        Maid = self.Maid, 
        
        Data = self.Data, 
        Object = self.Instance, 
        Visible = self.Visible, 
        Selected = self.Selected,
        ItemId = self.ItemId, 
        Title = self.Instance.Name, 

        MouseButton1Up = function()
            self.Request:Fire(Data.ItemId)
        end
    }

    self.Maid:GiveTask(self.Object) 

    return self
end

function Object:SetParent(Parent: Instance)
    self.Object.Parent = Parent 
end 

function Object:Destroy()
    self.Maid:DoCleaning() 
end


return Object



