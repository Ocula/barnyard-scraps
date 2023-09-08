local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService") 

local Knit = require(ReplicatedStorage.Packages.Knit)
local ItemIndexService = Knit.GetService("ItemIndexService") 

local Maid = require(Knit.Library.Maid) 

local Object = {}
Object.__index = Object


function Object.new(Data, BaseCFrame) 
    if Data.SandboxSize then 
        Data.SandboxSize = Vector3.new(Data.SandboxSize.X,0,Data.SandboxSize.Z) -- all sandbox sizes without Y value just to keep it clean. 
    end 

    local object = ItemIndexService:GetBuild(Data.ItemId)

    if object then
        local collisionParts = {}
        local maidObject = Maid.new() 

        local objectInstance = object.Object 
        local worldCF = BaseCFrame * Data.CFrame:Inverse() 

        local attributes = objectInstance:GetAttributes() 

        local TotalDominos = 0 

        for i, v in objectInstance:GetDescendants() do 
            if CollectionService:HasTag(v, "CollisionPart") then 
                local relativeCF = v.CFrame:ToObjectSpace(objectInstance.PrimaryPart.CFrame) 
                local collPart = v:Clone()

                collPart.Parent = workspace.game.server.bin 
                collPart.CFrame = worldCF * relativeCF:Inverse() 
                collPart.Transparency = 0.8
                collPart.CanCollide = false
                collPart.CollisionGroup = "CollisionParts"

                collisionParts[collPart] = relativeCF 

                maidObject:GiveTask(collPart) 
            end

            if CollectionService:HasTag(v, "Domino") then 
                TotalDominos += 1
            end
        end 

        local self = setmetatable({
            ItemId = Data.ItemId,
            CFrame = Data.CFrame, 
            Config = Data.Config, 

            SandboxSize = Data.SandboxSize or Vector3.new(50,0,50); 

            SpecialId = Data.SpecialId, 

            Total = TotalDominos, 
            
            --
            _collisionParts = collisionParts,
            _maid = maidObject
        }, Object)

        for i, v in attributes do 
            self[i] = v 
        end 

        return self
    end
end

function Object:GetTotal()
    return self.Total 
end 

function Object:Package()
    return {
        ItemId = self.ItemId,
        CFrame = self.CFrame, 
        Config = self.Config, 

        SpecialId = self.SpecialId 
    }
end 

function Object:Update(Data)
    for k, v in Data do -- table values will always be new.
        self[k] = v 
    end 
end

function Object:Destroy()

    self._maid:DoCleaning() 
end


return Object
