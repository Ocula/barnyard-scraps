local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--
local Interface = require(Knit.Modules.Interface.get)
--
local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Signal = require(Knit.Library.Signal)
local Maid = require(Knit.Library.Maid)

local NumberObject = Interface:GetComponent("Game/Number")

local Number = {}
Number.__index = Number

-- @Ocula 
-- Handles grouping number bbguis so that we save space and time.
function Number.new(class: string, radius: number?, max: number?, lifetime: number?)
    local self = setmetatable({
        Radius = radius or 5, 
        Combined = Signal.new(), 
        Lifetime = lifetime or 3, 

        Maximum = max or 500, 

        Class = class, 

        Numbers = {}, 

        Total = 0, 

        _activeObjects = 0 
    }, Number)

    self.Theme = Interface:GetTheme("Game/Numbers")

    return self
end

function Number:GetAnchors()
    local compiledList = {}

    for i, v in self.Numbers do 
        table.insert(compiledList, v.Anchor) 
    end 

    return compiledList
end 

function Number:SpatialQuery(anchor)
    local anchors = self:GetAnchors() 

    local spatialParams = OverlapParams.new() 
    spatialParams:AddToFilter(anchors) 
    spatialParams.FilterType = Enum.RaycastFilterType.Include  

    local spatialQuery = workspace:GetPartBoundsInRadius(anchor.Position, self.Radius, spatialParams)

    --warn("Queried:", spatialQuery, anchors) 

    return spatialQuery 
end 

-- @Ocula 
-- If a > b then combine b into a, vice versa. 
function Number:Combine(a, b)
    -- check range 
    local aPos = Peek(a.Position)
    local bPos = Peek(b.Position) 

    local mag = (aPos - bPos).Magnitude 
    
    if mag <= self.Radius then
        local amountA, amountB = Peek(a.Amount), Peek(b.Amount)
        
        if amountA > amountB then 
            b.Destroy() 

            a.Amount:set(amountA + amountB) 
            a.Pop:set(true) 
            b.Position:set(Peek(a.Position))
        else
            a.Destroy() 

            b.Amount:set(amountA + amountB) 
            b.Pop:set(true) 
            a.Position:set(Peek(b.Position))
        end
    end
end 

function Number:Add(From: Vector3, Position: Vector3, Amount: number)
    local NumberController = Knit.GetController("NumberController")

    local Cleaner = Maid.new()

    local newNumber = {
        Position = Value(From),
        Amount = Value(Amount), 

        Visible = Value(false), -- set 
        Hidden = Signal.new(), 

        Pop = Value(false), 

        Theme = self.Theme, 

        isCombining = false, 
    }

    newNumber.Destroy = function()
        self.Numbers[newNumber.Anchor] = nil 
        self._activeObjects -= 1 

        task.delay(0.1, function()
            newNumber.Visible:set(false)
        end)

        task.delay(0.2, function()
            Cleaner:DoCleaning()
        end) 
    end

    newNumber.Object, newNumber.Anchor = NumberObject {
        Position = newNumber.Position,
        Amount = newNumber.Amount, 
        Visible = newNumber.Visible, 
        Hidden = newNumber.Hidden, 
        Theme = newNumber.Theme[self.Class],

        Pop = newNumber.Pop, 

        Cleaner = Cleaner, 

        Parent = NumberController:GetBin()
    }

    Cleaner:GiveTask(newNumber.Object) 
    Cleaner:GiveTask(newNumber.Anchor) 

    newNumber.Visible:set(true) 
    newNumber.Position:set(Position) 

    -- do a combine check 
    local Query = self:SpatialQuery(newNumber.Anchor) 

    for _, anchor in Query do 
        local number = self.Numbers[anchor] 

        if number then 
            self:Combine(newNumber, number) 
        end
    end

    self._activeObjects += 1 
    self.Numbers[newNumber.Anchor] = newNumber 

    task.delay(self.Lifetime, function()
        newNumber.Destroy() 
    end)

    self.Total += Amount 

    return newNumber 
end

function Number:Clean()
    --warn(self.Class, "TOTAL", self.Total) 
    
    for i, v in pairs(self.Numbers) do
        v.Destroy() 
    end

    self.Numbers = {} 
    self.Total = 0
end

function Number:Destroy()
    self:Clean() 
end


return Number
