--[[ Handle all Domino Logic ]]
-- This service should only check the amount of dominos that the player client is reporting checks out on the server for authentication.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(ReplicatedStorage.Shared.Maid)
local Binder = require(ReplicatedStorage.Shared.Binder)

local DominoService = Knit.CreateService {
    Name = "DominoService",
    Client = {
        SetStartingDomino = Knit.CreateSignal(), 
        Update = Knit.CreateSignal(), 
    },
    Dominos = {},
    
    Rewards = {
        Toppled = 1, 
        Halfway = 0.5, 
        Upright = 0, 
    }, 

    Standards = {
        Corn = 0.2, 
    }
}

-- @Ocula
-- Topple Data is sent here:
-- > {Dominos = {Toppled = 10, Halfway = 3, Upright = 30}, Sets = {ItemId = AmountFallen, etc}}
function DominoService.Client:Receive(player, toppleData) 
    local PlayerService = Knit.GetService("PlayerService")
    local BuildService = Knit.GetService("BuildService") 

    local PlayerObject = PlayerService:GetPlayer(player) 
    local Sandbox = BuildService.Sandboxes[PlayerObject._ownedSandbox]

    if Sandbox then
        local cleanData, discrepancies = self.Server:CheckServerData(toppleData, Sandbox)

        if cleanData and #discrepancies == 0 then 
            return self.Server:Process(PlayerObject, cleanData) 
        else 
            warn("Player has been flagged:", player)
            return false 
        end 
    end 
end 

-- @Ocula
-- Update the state of sandboxes to other players within the sandboxes. 
function DominoService.Client:ProcessState(player, state)
    local PlayerService = Knit.GetService("PlayerService") 
    local BuildService = Knit.GetService("BuildService") 

    local Player = PlayerService:GetPlayer(player)

    local Sandbox = BuildService:GetSandbox(Player.Sandbox)
    
    for i, v in pairs(game.Players:GetPlayers()) do 
        if Sandbox then 
            if Sandbox:isPlayerInside(v) then 
                self.Server.Client.Update:Fire(v, player.userId, Sandbox.GUID, state)
            end 
        end 
    end 
end 

-- @Ocula
-- Only needs to return the ItemId and Total amount of Dominos inside of the set
function DominoService.Client:GetSetFromObjectId(player, objectId)
    return self.Server:GetSetFromObjectId(player, objectId) 
end 

function DominoService:GetSetFromObjectId(player, objectId)
    local PlayerService = Knit.GetService("PlayerService")
    local BuildService = Knit.GetService("BuildService") 

    local Player = PlayerService:GetPlayer(player) 

    if Player then 
        local Sandbox = BuildService.Sandboxes[Player.Sandbox] 

        if Sandbox then
            local Object = Sandbox.Objects[objectId] 

            if Object then 
                return Object.ItemId, Object:GetTotal(), Object.Price 
            end 
        end 
    end 
end 


function DominoService:CheckServerData(Data, Sandbox)
    local Discrepancies = {}

    -- Check sets 
    -- > Check if object exists 
    -- > Check if data is plausible: 
    for i, v in Data.Sets do 
        if type(v) == "table" then 
            if Sandbox.Objects[i] then 
                continue 
            end 

            Data.Sets[i] = nil 
            table.insert(Discrepancies, v.ObjectId) 
        end
    end

    -- check totals line up

    return Data, Discrepancies 

    -- Check objects 
end 

-- Process
-- > {Sets = {[ObjectId] = {Toppled = #, isToppled = bool}, Total = #, Toppled = #}, Dominos = {Toppled = #, Halfway = #, Upright = #, Total = #}}
function DominoService:Process(Player, Data)
    local BuildService = Knit.GetService("BuildService") 

    local Totals = {
        Sets = Data.Sets.Total, 
        Dominos = Data.Dominos.Total 
    }

    local Percentages = {
        Toppled = Data.Dominos.Toppled / Totals.Dominos,
        Halfway = Data.Dominos.Halfway / Totals.Dominos, 
        Upright = Data.Dominos.Upright / Totals.Dominos, 
    }

    local Base_Data = {
        Corn = 0, 
        Experience = (Percentages.Toppled * Totals.Dominos * self.Rewards.Toppled) + (Percentages.Halfway * Totals.Dominos * self.Rewards.Halfway), 
    }

    for objectId, v in Data.Sets do 
        if type(v) == "table" then 
            local itemId, _total, Price = self:GetSetFromObjectId(Player.Player, objectId) 

            if v.isToppled then 
                Base_Data.Corn += math.floor((Price or 5) * self.Standards.Corn) -- receive 40% of the original price back with full topple 
            else
                if v.Toppled > (v.Total * 0.5) then 
                    Base_Data.Corn += math.floor((Price or 5) / 2) * self.Standards.Corn -- receive 40% of half the original price back with half-topple 
                end 
            end
        end 
    end 

    local Modifiers = {
        Experience = {
            _multiplier = 1, 
        }, 
        Corn = {
            _multiplier = 1, 
        },
    }

    if Percentages.Toppled >= 0.9 then 
        Modifiers.Experience.Toppled = true
        Modifiers.Experience._multiplier += 1 
    elseif Percentages.Toppled < 0.9 and Percentages.Toppled > 0.75 then 
        Modifiers.Experience.Halfway = true 
        Modifiers.Experience._multiplier += 0.5 
    end 

    if Percentages.Upright > 0.9 then -- maybe a negative modifier?
        warn("Some kind of 0.5x multiplier maybe")
    end 

    local Corn = Base_Data.Corn 
    Corn *= Modifiers.Corn._multiplier
    Corn = math.floor(Corn) 

    local Experience = Base_Data.Experience
    Experience *= Modifiers.Experience._multiplier 

    warn("Experience to reward:", Experience, "\nCorn:", Corn, "\nModifiers:", Modifiers, "\nBase Data:", Base_Data)--]]

    Player:AddBin("Corn", Corn)
    Player:Give("Experience", Experience) 

    return Base_Data, Modifiers
end 

function DominoService:KnitStart()

end


function DominoService:KnitInit()
    
end


return DominoService
