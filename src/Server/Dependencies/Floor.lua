-- Floor Class
-- Server-Sided:
--[[ 

    @.new() -- Create new Floor class based on given Part. 
    @SetTaken()
    @GetTaken() 

]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Octree = require(ReplicatedStorage.Shared.Octree) 

local Maid = require(ReplicatedStorage.Shared.Maid) 

local Floor = {}
Floor.__index = Floor

local back = Vector3.new(0, -1, 0)
local top = Vector3.new(0, 0, -1)
local right = Vector3.new(-1, 0, 0)

function Floor.new(part: BasePart): array
    -- get grid 
    local Grid = part:GetAttribute("Grid") or Vector2.new(5,5) 

    -- split part up into grid 
    local canvasSize = part.Size 
    local cf = part.CFrame * CFrame.fromMatrix(-back*canvasSize/2, right, top, back)
    local size = Vector2.new((canvasSize * right).magnitude, (canvasSize * top).magnitude)

    local self = setmetatable({
        --Owner = 
        GUID = HttpService:GenerateGUID(), 
        Active = true,
        Rotation = part.CFrame.Rotation,
        GridUnit = math.sqrt(Grid.X * Grid.Y), 
        Object = part, 
        Canvas = {CFrame = cf, Size = size},

        _maid = Maid.new(), 
        _reconcile = {}, 
    }, Floor)

    return self
end

function Floor:AddFloor() -- should be able to edit all floors on the same Y-position so that they're all in the same floor. 
end 

function Floor:GetGridUnit()
    return self.GridUnit 
end

function Floor:GetPlace(pos: CFrame) -- given CFrame, find the best placement point. 

end

function Floor:Reconcile()
    local current = self:Package()
    local _log = {} 

    for i, v in pairs(current) do
        if type(v) ~= "table" then 
            if self._reconcile[i] ~= v then 
                _log[i] = v 
                self._reconcile[i] = v 
            end 
        else 
            -- always send table values 
            _log[i] = v 
        end 
    end

    return _log 
end 

function Floor:Package()
    return {
        GUID = self.GUID, 
        Active = self.Active, 
        Rotation = self.Object.CFrame.Rotation, 
        GridUnit = self.GridUnit, 
        Canvas = self.Canvas, 
        Object = self.Object, 
    }
end 


function Floor:Destroy()
    self._maid:DoCleaning() 
end


return Floor
