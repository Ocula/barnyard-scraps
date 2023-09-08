-- exit button
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(Knit.Library.Maid)
local Signal = require(Knit.Library.Signal) 

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Interface = require(Knit.Modules.Interface.get)

local ExitButton = Interface:GetComponent("Buttons/ExitButton")

local Exit = {}
Exit.__index = Exit

function Exit.new(Parent: Instance, Callback, Position: UDim2?) 
    local self = setmetatable({
        ExitSignal = Signal.new(), 
        Maid = Maid.new(), 
    }, Exit)

    self.Object = ExitButton {
        Size = Value(Vector2.new(100,100)),
        Position = Position, 
        Parent = Parent, 

        ExitSignal = self.ExitSignal, 
    }

    self.Maid:GiveTask(self.ExitSignal:Connect(function()
        if Callback then 
            Callback() 
        else 
            Parent.Visible = false 
        end 
    end)) 

    self.Maid:GiveTask(self.Object) 

    return self
end

function Exit:GetExitSignal()
    return self.ExitSignal
end 

function Exit:Destroy()
    self.Maid:DoCleaning() 
end


return Exit
