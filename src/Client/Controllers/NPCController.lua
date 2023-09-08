local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local NPC = require(Knit.Modules.Classes.NPC) 

local NPCController = Knit.CreateController { 
    Name = "NPCController",
    Entities = {}, 
}   

function NPCController:Process(Update: string, Entity: table, Data: table)
    -- check if we're visible to the entity. 
    local isPlayerVisible = Entity:isVisible() 

    if isPlayerVisible then 
        if Update == "Move" then 
            Entity:Move(Data) 
        elseif Update == "Speak" then 
            Entity:Speak(Data) 
        elseif Update == "Hide" then 
            Entity:Hide() 
        end 
    else
        if Update == "Show" then 
            Entity:Show()
        end 
    end 
end

function NPCController:Get(id: string)
    return self.Entities[id] 
end 

function NPCController:KnitStart()
    local NPCService = Knit.GetService("NPCService")

    local function checkEntity(Data)
        local Entity = self:Get(Data.GUID)

        if not Entity then
            Entity = NPC.new(Data) 
            self.Entities[Data.GUID] = Entity 

            Entity:Show() -- testing 
        end

        return Entity
    end 

    NPCService.Update:Connect(function(Update, Data)
        local Entity = checkEntity(Data) 
        self:Process(Update, Entity, Data) 
    end)

    NPCService.Load:Connect(function(Data)
        for _, v in Data do 
            checkEntity(v)
        end 
    end)
end

function NPCController:KnitInit()
    
end

return NPCController
