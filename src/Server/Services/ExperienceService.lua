local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ExperienceService = Knit.CreateService {
    Name = "ExperienceService",
    Client = {},

    Limit = 10, 
}

local EXP_CONST = 0.02

local function round(number)
    return math.floor(number / 50 + 0.5) * 50
end

function ExperienceService:GetExperience(rank) 
    return round((((rank - 1)/EXP_CONST) ^ 2)) 
end 

function ExperienceService:GetRank(exp)
    local rank = math.floor(EXP_CONST * math.sqrt(exp)) + 1

    if rank >= self.Limit then 
        return self.Limit, true 
    end 

    return rank
end 

function ExperienceService:GetRankName(exp) --TODO: update so that this has a safety net
    local rankNumber = self:GetRank(exp) 

    --warn("Looking for:", rankNumber, self.Ranks)

    local rankName = self.Ranks[rankNumber].Name 

    return rankName 
end 

function ExperienceService:isEligibleForRankUp(player)
    local Experience = player.Experience 

    if self:GetRank(Experience) > player.Rank then 
        return true 
    end
end

function ExperienceService:KnitStart()
    self.Ranks = require(Knit.Modules.Rank).get() 
end


function ExperienceService:KnitInit()
    
end


return ExperienceService

--[[

function getexp(level)
    return (level/0.12)^2
end 

function getlvl(exp)
    return 0.12 * math.sqrt(exp) 
end 


for i = 1,100 do 
    local amountneededforNextLevel = getexp(i+1)
    local curr = getexp(i)

    print(amountneededforNextLevel - curr) 
end

]]