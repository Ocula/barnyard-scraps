local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Utility = require(Knit.Library.Utility) 

local Zone = {}
Zone.__index = Zone


function Zone.new(Model)

    local self = setmetatable({
        Zones = {},
        Object = Model, 
    }, Zone)

    for i, v in pairs(Model:GetAttributes()) do 
        self[i] = v 
    end 

    self:GetZones() 

    return self
end

function Zone:GetZones()
    for i, v in self.Object:GetDescendants() do 
        if v:IsA("BasePart") then 
            table.insert(self.Zones, v) 
        end 
    end 
end 

function Zone:isPlayerInsideZone(Player)
    local HumRoot = Utility:GetHumanoidRootPart(Player)

    if HumRoot then 
        local OverlapParams = OverlapParams.new()
        OverlapParams.FilterType = Enum.RaycastFilterType.Include 
        OverlapParams:AddToFilter(self.Zones)

        local SpatialQuery = workspace:GetPartsInPart(HumRoot, OverlapParams) 

        if #SpatialQuery > 0 then 
            return true 
        end 
    end 
end 

function Zone:Destroy()
    
end


return Zone
