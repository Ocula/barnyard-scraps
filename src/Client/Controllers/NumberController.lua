local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--
local Interface = require(Knit.Modules.Interface.get)
--
local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local NumberController = Knit.CreateController { 
    Name = "NumberController",
    Classes = {}, 
}

local Number = Interface:GetClass("Game/Number")

function NumberController:Add(Class: string, Position: Vector3, Amount: number)
    local NumberObject = self:GetClass(Class) 
    NumberObject:Add(Position, Amount) 

    return NumberObject
end 

function NumberController:GetClass(class: string, radius: number?, max: number?) 
    if not self.Classes[class] then 
        self.Classes[class] = Number.new(class, radius or 5, max) 
    end 

    return self.Classes[class]
end

function NumberController:GetBin()
    return self.Bin 
end 

function NumberController:KnitStart()
    local Bin = Knit.GetController("Interface"):GetBin() 

    local Numbers = New "Folder" {
        Parent = Bin, 
        Name = "Numbers", 
    }

    self.Bin = Numbers 
end


function NumberController:KnitInit()
    
end


return NumberController
