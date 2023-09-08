local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Maid = require(Knit.Library.Maid) 

local Collect = {}
Collect.__index = Collect


function Collect.new(packagedPrompt)
    local self = setmetatable(packagedPrompt, Collect)

    self.Cleanup = Maid.new() 

    return self
end

function Collect:Show()
    local GameController = Knit.GetController("GameController")
    local Prompt = self.Object 
    local Bin = GameController:GetBin(self.MetaData)

    self.Cleanup:GiveTask(Observer(Bin):onChange(function()
        Prompt.ObjectText = tostring(Peek(Bin)) 
    end)) 

    Prompt.ObjectText = Peek(Bin) 
end

function Collect:Hide()
    self:Destroy() 
end 

function Collect:Triggered()
    warn("Collecting") 
    local PlayerService = Knit.GetService("PlayerService")
    PlayerService:RequestBinCollect()
end 

function Collect:TriggerEnded()

end

function Collect:Destroy()
    self.Cleanup:DoCleaning() 
end


return Collect
