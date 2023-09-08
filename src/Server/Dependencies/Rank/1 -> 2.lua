-- When players graduate from first rank to 2nd rank, we want to remind them that in order to rank up more they have to topple more.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ExperienceService = Knit.GetService("ExperienceService") 

local Upgrade = {}

function Upgrade.Get()
    -- returns a function 

    return function(player)
        -- do all of our stuff here 
    end 
end 

function Upgrade.Check(player)
    if player.Rank == 1 and ExperienceService:isEligibleForRankUp(player) then 
        return true 
    end 

    return false 
end 

return Upgrade 