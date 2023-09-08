local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local DominoController = Knit.GetController("DominoController") 
local DominoService = Knit.GetService("DominoService") 

local Set = {}
Set.__index = Set

function Set.new(object)

    if not object:isDescendantOf(workspace) then 
        return {_ShellClass = true}
    end 

    local self = setmetatable({
        ObjectId = object:GetAttribute("ID"), 
        Object = object, 

        Base = object.PrimaryPart,

        Toppling = false,   
        Loaded = false, 
    }, Set)

    DominoService:GetSetFromObjectId(self.ObjectId):andThen(function(itemId, total, price) 
        self.ItemId = itemId 
        self.Price = price 
        self.Total = total 
        self.Loaded = true 
    end):catch(error) 

    return self
end

function Set:GetDomino(Reference)
    for i, v in pairs(self.Object:GetChildren()) do 
        if v.Name == "Domino" then 
            local ref = v:GetAttribute("Reference")
            if ref then 
                if ref == Reference then 
                    return v 
                end 
            end 
        end 
    end 
end

function Set:Unanchor()
    local set = self.Object 

    set.PrimaryPart:SetAttribute("Toppling", true) 

	for i, v in set:GetChildren() do 
        if v.Name == "Domino" or v.Name == "Stair" then 
            v.Anchored = false 
        end 
    end 
end 

function Set:GetVelocity()
    local Total = 0 
    local Speed = 0 

    for i, v in self.Object:GetChildren() do 
        if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part") then 
            local currentSpeed = v.Velocity.Magnitude 

            if currentSpeed > 0 then 
                Speed += currentSpeed 
                Total += 1 
            end 
        end 
    end 

    return (Speed / Total) 
end 

function Set:Destroy()
    
end


return Set
