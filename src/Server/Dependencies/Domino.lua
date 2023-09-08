local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(ReplicatedStorage.Shared.Maid)

local Domino = {}
Domino.__index = Domino


function Domino.new(obj)
    local self = setmetatable({
        Object = obj,

        _maid = Maid.new()
    }, Domino)

    self._maid:GiveTask(obj) 

    return self
end

function Domino:Unanchor()
    self.Object.Anchored = false 
end

function Domino:Destroy()
    self._maid:DoCleaning() 
end


return Domino
