local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local NPC = require(Knit.Modules.NPC) 
local Signal = require(Knit.Library.Signal) 

local NPCService = Knit.CreateService {
    Name = "NPCService",
    Client = {
        Update = Knit.CreateSignal(), 
        Load = Knit.CreateSignal(), 
    },

    Entities = {}, 
    Updated = Signal.new(), 
}

function NPCService:Add(NPC)
    self.Entities[NPC.GUID] = NPC 
end 

function NPCService:KnitStart()
    -- Alfred 
    local PlayerService = Knit.GetService("PlayerService")

    PlayerService:GetPlayerAddedSignal():Connect(function(newPlayer)
        local Compressed = {}

        for i, v in self.Entities do 
            table.insert(Compressed, v:Package())
        end 

        self.Client.Load:Fire(newPlayer, Compressed) 
    end)
end


function NPCService:KnitInit()
    local Alfred = NPC.new("Alfred") 
    local Lionel = NPC.new("Lionel")
    local Cluck = NPC.new("CluckNorris")
    local Moolivia = NPC.new("Moolivia") 

    self:Add(Lionel)
    self:Add(Cluck)
    self:Add(Moolivia)
    self:Add(Alfred) 
end


return NPCService
