--[[
    Records all actions so we can go back in time. (CMD + Z)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Signal = require(Knit.Library.Signal) 

local HistoryController = Knit.CreateController { 
    Name = "HistoryController",
    History = {},

    _actionCompleted = Signal.new() 
}

function HistoryController:Record(snapshot)
    local timestamp = snapshot:GetTimestamp() 

end 

function HistoryController:Revert() -- goes back to the last snapshot 
    
end 

function HistoryController:KnitStart()
    local Snapshot = require(script.Snapshot) 

    self._actionCompleted:Connect(function(action)
        local newSnapshot = Snapshot.new(action) 
    end)
end


function HistoryController:KnitInit()
    
end


return HistoryController
