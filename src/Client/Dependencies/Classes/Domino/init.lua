
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService") 
local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(Knit.Library.Maid) 
local Signal = require(Knit.Library.Signal) 

local Arrow = require(Knit.Library.Arrow) 

local Sound = Knit.GetController("Sound") 
local DominoController = Knit.GetController("DominoController") 
local InterfaceController = Knit.GetController("Interface")

local DominoService = Knit.GetService("DominoService") 

local Domino = {}
Domino.__index = Domino

local Epsilon = 10e-6 

function Domino.new(object)
    -- proper check
    if not object:isDescendantOf(workspace) or not object.Parent:GetAttribute("ID") or object.Parent:GetAttribute("Preview") then 
        return {
            _ShellClass = true, 
        }
    end 

    local self = setmetatable({
        Object = object, 
        State = "Upright", 

        Ready = false, 
        Awake = false, 

        Maid = Maid.new(), 
        AnchorMaid = Maid.new(), 

        UpVector = Vector3.new(0,1,0),
        Direction = Vector3.new(1,0,0), 
        Position = object.Position, 

        PushMagnitude = 10, 

        StateChanged = Signal.new(), 
        DirectionChosen = Signal.new(), 
        Falling = Signal.new(), 

        StateOptions = {
            ["Upright"] = {Min = 0.9, Max = math.huge},  
            ["Halfway"] = {Min = 0.4, Max = 0.9 - Epsilon},
            ["Toppled"] = {Min = -(math.huge), Max = 0.4 - Epsilon}, 
        },

        StateOffset = 0, 

        SavedCFrame = object.CFrame, 

        _unanchorNearby = false, 

    }, Domino)

    self:SetPhysics()
    --object.CollisionFidelity = "Box" 

    self._overlapParams = DominoController.OverlapParams 
    self.RayParams = DominoController.RaycastParams 

    local velocityChanged = object:GetPropertyChangedSignal("Velocity") 

    self.Maid:GiveTask(velocityChanged:Connect(function() -- will only check for manual pushes. 
        self:CheckState() 
    end)) -- if velocity changes we check the state of the domino methinks.

    return self
end

function InterpolateDirectionVectors(vector1, vector2, t)
    local angle = math.acos(vector1:Dot(vector2))
    local interpolatedDirection = (vector1 * math.sin((1 - t) * angle) + vector2 * math.sin(t * angle)) / math.sin(angle)
    return interpolatedDirection
end

function Domino:GetUpVector()
    if not self.Object.Parent:FindFirstChild("Stair", true) then return end 
    -- figure out if we're standing on top of a stair.
    local hitObjects = self.Object.Parent:GetChildren() 
    local castForward = self:Cast(hitObjects, self.Object.CFrame.XVector.Unit, 10) -- get anything in front 
    local castBackward = self:Cast(hitObjects, -self.Object.CFrame.XVector.Unit, 10) -- get anything in back
    --local castDown = self:Cast(hitObjects, -self.Object.CFRame.YVector, 5) -- get floor 

    local proceedCast = nil 

    if castForward or castBackward then -- go with the one that has a stair instance 
        if castForward then 
            if castForward.Instance.Name == "Stair" or CollectionService:HasTag(castForward.Instance, "Stair") then 
                proceedCast = castForward 
            end 
        end 

        if proceedCast == nil then 
            if castBackward then 
                if castBackward.Instance.Name == "Stair" or CollectionService:HasTag(castBackward.Instance, "Stair")  then 
                    proceedCast = castBackward
                end 
            end
        end 

        if proceedCast then 
            -- check if its a stair 
            --local CollectionService = game:GetService("CollectionService") 

            --local YVector = Vector3.new(0,1,0) 
            --local StairLook = proceedCast.Normal 

            --local InterpolatedDirection = InterpolateDirectionVectors(YVector, StairLook, 0.5) 

            self.StateOptions = {
                ["Upright"] = {Min = 0.98, Max = math.huge},  
                ["Toppled"] = {Min = -math.huge, Max = 0.98},
                --["Halfway"] = {Min = -(math.huge), Max = 0.75}, 
            }

            --self.StairObject = true 
        end 
    end 
end

function Domino:Cast(hitArray: table, direction: Vector3, distance: number)
    local Params = RaycastParams.new() 
    Params.FilterType = Enum.RaycastFilterType.Include 
    Params:AddToFilter(hitArray) 

    local Cast = workspace:Blockcast(self.Object.CFrame, self.Object.Size, direction * distance, Params)

    return Cast 
end 

function Domino:Raycast(hit: table, direction: Vector3, distance: number)
    local Params = RaycastParams.new() 
    Params.FilterType = Enum.RaycastFilterType.Include 
    Params:AddToFilter(hit) 

    local Cast = workspace:Raycast(self.Object.Position, direction * distance, Params)

    return Cast 
end

function Domino:SetPhysics()
    self.Object.CustomPhysicalProperties = PhysicalProperties.new(self.Object:GetAttribute("Density") or 1,0.75,0) 
end

function Domino:ResetVelocity()
    self.Object.Velocity = Vector3.new()
    self.Object.AssemblyAngularVelocity = Vector3.new(0,0,0) 
end 

function Domino:Reset()
    self:Anchor() 
    self:ResetVelocity() 

    if DominoController._debug then 
        self.Object.Color = Color3.new(1,1,1)
    end 

    if self.Object.CFrame == self.SavedCFrame then 
        return false 
    end 

    self.Object.CFrame = self.SavedCFrame
    return true 
end 

function Domino:Update()
    self.SavedCFrame = self.Object.CFrame
end 

function Domino:Pulse() 
    self.Object.Velocity = Vector3.new(0,-0.08,0) 
end 

function Domino:Anchor()
    if DominoController._debug then 
        self.Object.Color = Color3.new(0.607843, 1, 0.607843)
    end 

    self.wasInBounds = nil 
    self._debounce = nil 
    self.Object.Anchored = true 
    self.Flagged = nil 
end 

function Domino:GetVelocity()
    return self.Object.Velocity.Magnitude 
end 

function Domino:UpdateDirection() 
    self.Direction = self.Object.CFrame.XVector -- direction   
end

function Domino:UpdateCurrentPosition()
    local currentPosition = self.Object.Position 
    local mag = (self.Position - currentPosition).Magnitude 

    self.Position = self.Object.Position 
    self.Traveled = mag 
end

function Domino:Flag()
    if DominoController._debug then 
        self.Object.Color = Color3.new(0.270588, 0.662745, 0.984313)
    end 

    self.Flagged = tick() 
end 

function Domino:Deflag()
    if DominoController._debug then 
        self.Object.Color = Color3.new(1,1,1)
    end 

    self.Flagged = nil 
end 

function Domino:GetDirection()
    local Dominos = CollectionService:GetTagged("Domino") 
    local Hit = self:Raycast(Dominos, self.Object.CFrame.XVector.Unit, 3)

    if not Hit then 
        --Hit = self:Raycast(Dominos, -self.Object.CFrame.XVector.Unit, 3)
        self.Direction = -self.Object.CFrame.XVector
    else 
        self.Direction = self.Object.CFrame.XVector 
    end 
end 

function Domino:Push()
    if self.Object.Anchored then 
        self:Unanchor()
    end 

    --self:UpdateDirection() 
    -- push magnitude 

    self.Object.Velocity = self.Direction.Unit * self.PushMagnitude --

    -- if we wake nearby dominos, we can use them to wake the next few. 

    -- 
end

function Domino:CreateVisual(cf, origin) 
    local part = Instance.new("Part")
    part.Parent = workspace.game.client.fix 
    part.Anchored = true 
    part.CanCollide = false 
    part.Size = Vector3.new(.25,.25,(origin - cf).Magnitude)
    part.Color = Color3.new(0,1,0) 

    local pos = (cf + origin) / 2 
    local to = cf 

    part.CFrame = CFrame.new(pos, to) 
end

function Domino:SetWeld(object)
    self.WeldCover = object 
end

function Domino:Paint(color)
    local object = self.Object
    object.Color = color 
end

function Domino:SetTransparency(num: number)
    local object = self.Object
    object.Transparency = num 
end

function Domino:Unanchor()
    if self._debounce then return end 
    self._debounce = true

    self:GetUpVector() 

    self.UpVector = self.Object.CFrame.YVector 

    self.Object.AssemblyAngularVelocity = Vector3.new(0,0,0)
    self.Object.Velocity = Vector3.new(0,0,0) 

    self.Object.Anchored = false 

    --[[
    self.AnchorMaid:GiveTask(self.Object.Touched:Connect(function(hit)
        local Play = InterfaceController.Game.Menus.Inventory.Play
        local Loaded = Play.Loaded 

        if Loaded then 
            if hit.Name == "Domino" then 
                Sound:Play("Pop")
                self.AnchorMaid:DoCleaning() 
            end 
        end 
    end))--]]
end 

function Domino:GetDot()
    local dotCheck = self.Object.CFrame.YVector:Dot(self.UpVector) -- anything below or under 0.4 is likely toppled to the ground. 

    return dotCheck 
end 

function Domino:CheckAsleep()
    local state = self:CheckState() 

    if state == "Upright" then 
        return false 
    end 

    return true 
end 

function Domino:GetSet()
    local Set = self.Object.Parent 
    local ID = Set:GetAttribute("ID") 

    if ID then 
        local GameController = Knit.GetController("GameController") 
        return GameController:GetSetFromObjectId(ID) 
    end 
end 

function Domino:SetState(state: string)
    local lastState = self.State 
    self.State = state 

    if lastState ~= state then 
        if lastState == "Upright" and state == "Toppled" then 
            DominoController.CurrentCount += 1 
            DominoController.Updated:Fire(DominoController.CurrentCount / DominoController.TotalCount)
        elseif (lastState == "Halfway" and state == "Toppled") or (lastState == "Upright" and state == "Halfway") then 
            DominoController.CurrentCount += 0.5
            DominoController.Updated:Fire(DominoController.CurrentCount / DominoController.TotalCount)
        end 
    end 
end 

-- we need a really fast way of checking state and i think it's literally this:
-- it's technically three calculations but they're all inexpensive.
-- much cheaper than checking magnitude of domino. 

local printDeb = tick() 

function Domino:CheckState()
    local dotCheck = self:GetDot() 

    if self.Object:GetAttribute("DotObject") then 
        if tick() - printDeb > 0.1 then 
            warn("DotCheck:", dotCheck, self.State, self.Object.Velocity.Magnitude) 
            printDeb = tick()
        end 
    end 

    if dotCheck then 
        for state, range in self.StateOptions do 
            if dotCheck >= range.Min and dotCheck <= range.Max then
                self:SetState(state) 
                return state 
            end 
        end 
    else
        return self.State 
    end 
end 

function Domino:Destroy()
    self.Maid:DoCleaning() 
end


return Domino
