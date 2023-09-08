-- Pathfinding Service for NPCs (and also character runs)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PathService = Knit.CreateService {
    Name = "PathService",
    Client = {},
}


function PathService:KnitStart()
    
end


function PathService:KnitInit()
    
end


return PathService
