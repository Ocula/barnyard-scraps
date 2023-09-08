--[[ Debug Service ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Knit = require(ReplicatedStorage.Packages.Knit)

local DebugService = Knit.CreateService {
    Name = "DebugService",
    Testing = false, -- set to false for public server 
    Client = {
        Domino = Knit.CreateSignal(), 
    },
}

function DebugService:isTestingMode()
    return self.Testing
end 

function DebugService:KnitStart()
    
end


function DebugService:KnitInit()
    
end


return DebugService
