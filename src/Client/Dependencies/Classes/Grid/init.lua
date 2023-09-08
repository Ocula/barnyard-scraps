local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--
local Interface = require(Knit.Modules.Interface.get)
--
local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Maid = require(Knit.Library.Maid)


local Grid = {}
Grid.__index = Grid

function Grid.new(Box, Unit)
    
    local self = setmetatable({
        Unit = Unit, 
        Points = {}, 
        Object = Box, 

        Grid = {}, 
        GridSize = Unit, 
        Objects = {}, 
        Maid = Maid.new(),
    }, Grid)

    self.debug = Instance.new("Part")
    self.debug.Parent = workspace.game.client.bin
    self.debug.CanCollide = false 
    self.debug.CanQuery = false 
    self.debug.Anchored = true 
    self.debug.Transparency = 1

    self:Create() 

    return self
end

function Grid:Create()
    if self.GridModel then return end 

    local GridModel = New "Model" {
        Name = "Grid", 
        Parent = workspace.game.client.bin 
    }

    self.Model = GridModel 

    local Object = self.Object 
    local GridSize = self.GridSize

    local numCellsX = math.floor(Object.Size.X / GridSize)
	local numCellsZ = math.floor(Object.Size.Z / GridSize)
	local cellSizeX = Object.Size.X / numCellsX
	local cellSizeZ = Object.Size.Z / numCellsZ

	for i = 1, numCellsX do
		for j = 1, numCellsZ do
			local offsetX = (i - 0.5) * cellSizeX - Object.Size.X / 2
			local offsetZ = (j - 0.5) * cellSizeZ - Object.Size.Z / 2

			local cellPosition = Object.CFrame:pointToWorldSpace(Vector3.new(offsetX, Object.Size.Y / 2, offsetZ))
			
			local x,y,z = Object.CFrame:ToOrientation() 

			local cellCFrame = CFrame.new(cellPosition) * CFrame.Angles(x,y,z)
			
            local point = require(script.Point).new(cellCFrame, Vector3.new(GridSize,0.1,GridSize), GridModel)
            
            self.Points[point.Object] = {
                Position = cellCFrame,
                Point = point, 
            }

            table.insert(self.Objects, point.Object)

            self.Maid:GiveTask(point) 
		end
	end

    self.Maid:GiveTask(GridModel) 
end 

function Grid:GetClosest(Position: Vector3) -- dont be mad, i'm too lazy to setup a grid table. memory also would be angry.
    -- x, y, z -> so
    -- round Position points to nearest Unit position
    local closest = math.huge 
    local point 

    for i, v in self.Points do 
        local magCheck = (v.Position - Position).Magnitude 
        if magCheck < closest then 
            closest = magCheck 
            point = v 
        end 
    end 

    return point 
end 

function Grid:GetPointObjects()
    local objects = {}

    for obj, _ in self.Points do
        table.insert(objects, obj) 
    end

    return objects 
end 

function Grid:GetPointsInBlock(cf: CFrame, Perimeter: Vector3)
    local Params = OverlapParams.new()
    Params.FilterType = Enum.RaycastFilterType.Include 
    Params:AddToFilter(self.Objects) 

    local x,y,z = self.Object.CFrame:ToOrientation() 

    local Query = workspace:GetPartBoundsInBox(cf * CFrame.new(0,-1, 0), Perimeter - Vector3.new(1,0,1), Params)

    self.debug.CFrame = cf * CFrame.new(0,-1,0)
    self.debug.Size = Perimeter 

    --warn("Query:", Query, self.Objects) 

    if #Query > 0 then 
        local Points = {}

        for i, v in Query do 

            local obj = self.Points[v] 
            Points[i] = obj 

        end 

        return Points
    end 

    return false  
end 

function Grid:HidePoints()
    for i, v in self.Points do 
        v.Point:Hide() 
    end 
end

function Grid:Show(cf: CFrame, Size: Vector3)
    -- Get nearby points 
    --local Points = self:GetPointsInBlock(cf, Size) 
    local Points = self:GetPointsInBlock(cf, Size) 

    if Points then 
        self:HidePoints() 

        for i, v in Points do 
            v.Point:Show()

            --[[
            if magnitude <= SizeMag * 2 then 
                v.Point:Show() 

                if magnitude > SizeMag then 
                    v.Point:Float() 
                else 
                    v.Point:Sink() 
                end
            else
                if magnitude > 15 then 
                    v.Point:Hide() 
                end 
            end--]]
        end 
    end 
end 

function Grid:Hide()
    self:HidePoints() 
end 

function Grid:Destroy()
    self.Maid:DoCleaning()
end


return Grid
