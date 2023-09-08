-- SERVER-SIDE NPC OBJECT
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService") 

local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(Knit.Library.Maid) 

local NPC = {}
NPC.__index = NPC

local Data = script:WaitForChild("Data") 

function NPC.new(Name: string) 
    local self = setmetatable({
        Name = Name, 
        GUID = "npc-entity-testing"..HttpService:GenerateGUID(false), 
        Maid = Maid.new(), 
    }, NPC)

    self:Set() 

    return self
end

function NPC:Set()
    local ItemIndexService = Knit.GetService("ItemIndexService") 
    warn("looking for:", self.Name)
    local Module = table.clone(require(Data:FindFirstChild(self.Name))) 

    for i, v in Module do
        self[i] = v 
    end

    -- get character position
    local Character = ItemIndexService:GetVendor(self.Character)

    if Character then 
        local Primary = Character.Object.PrimaryPart 
        self.Position = Primary.Position 
    end 
end 

-- @Ocula
-- Prompt the NPC to move to a new position (Vector3)
-- This will replicate to all players that can see this NPC. 
-- 
function NPC:Move(Position: Vector3) -- if player can see this NPC, then the client will interpret this update as a
    -- run or movement to a new position. we can also manipulate client-side only positions from the server. 
    -- client-side manipulation of NPC position will always take priority.
end 

function NPC:Package()
    return {
        IsVendor = self.IsVendor, 
        Name = self.Name, 
        GUID = self.GUID, 
        Dialogue = self.Dialogue, 
        Character = self.Character,
        Interact = self.Interact, 
        Stage = self.Stage, 
    }
end


function NPC:hasAccess(player)
    local hasAccess = false -- always assume the player doesn't!

    if self.Rank then -- rank check!

    end 
end 

function NPC:GetPosition()

end 


function NPC:Destroy()
    self.Maid:DoCleaning() 
end


return NPC
