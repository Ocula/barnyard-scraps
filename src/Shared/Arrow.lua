-- Arrow.lua
-- > For pointing guidance <3
-- > Uses in-game: Choosing starting domino starting direction, 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(Knit.Library.Maid) 

local Arrow = {}
Arrow.__index = Arrow

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Inactive = Assets:WaitForChild("Inactive") 
local ArrowObject = Inactive:WaitForChild("Arrow")

function Arrow.new(data) 
    local self = setmetatable({
        Object = ArrowObject:Clone(), 
        
        Subject = nil, 
        FollowObject = nil, 
        To = CFrame.new(),
        
        AnimationOffset = 3,
        Distance = 2.5, 
        Scale = 1, 
        Move = tick(), 

        Maid = Maid.new(), 

        LerpBool = data.Lerp or true, 
        _pointFromSubjectLookVector = data.PointFromLookVector or false, 
    }, Arrow)
    
    self._storedSize = self.Object.Size 

    return self
end

function Arrow:Anchor(subject: Instance) 
    self.Subject = subject 
end 

function Arrow:PointTo(cf: CFrame) 
    self.To = cf 
end 

function Arrow:Follow(instance: Instance)
    self.FollowObject = instance 
end 

function Arrow:PointFromLookVector()
    self._pointFromSubjectLookVector = true 
end 

function Arrow:SetScale(num: number)
    self.Scale = num 
    self.Object.Size = self._storedSize * Vector3.new(num, num, num) 
end 

function Arrow:SetAnimationOffset(num: number)
    self.AnimationOffset = num 
end 

function Arrow:Start()
    self.Maid:GiveTask(game:GetService("RunService").Heartbeat:Connect(function(dt)
        self:Update() 
    end))
end

function Arrow:Stop()
    self.Maid:DoCleaning() 
    self:Hide() 
end 

function Arrow:Show()
    self.Object.Parent = workspace.game.client.bin -- most times these will be created on the client, but sometimes we'll have 'em on the server.
end 

function Arrow:Hide()
    self.Object.Parent = nil 
end 

function Arrow:SetDistance(distance: number)
    self.Distance = distance or 0
end 

function Arrow:Update()
    if not self.Subject then 
        self:Hide()
        return 
    else 
        self:Show() 
    end 

    local _to = self.To 

    self.Move = tick() 

    if self.FollowObject ~= nil then 
        _to = self.FollowObject.CFrame 
    end 

    if self._pointFromSubjectLookVector then 
        _to = CFrame.new(self.Subject.Position, self.Subject.CFrame.lookVector + self.Subject.Position) * CFrame.new(1.5,0,0) 
    end 

    if self.Direction then 
        _to = CFrame.new(self.Subject.Position, self.Direction + self.Subject.Position) * CFrame.Angles(0,math.pi/2,0) * CFrame.new(1.5,0,0) 
    end 

    if self.Subject and self.Object then 
        local origin = self.Subject.Position 
        local toPos = _to.Position 
        local direction = (toPos - origin).Unit 

        local arrowPos = origin + ((self.Subject.Size.Magnitude + self.Distance + math.sin(self.Move * self.AnimationOffset)) * direction) 
        local lookVector = (origin - arrowPos).Unit 

        local toCFrame = CFrame.new(arrowPos, arrowPos + lookVector) * CFrame.Angles(math.rad(90),0,-math.rad(90))

        self.Object.CFrame = self.Object.CFrame:lerp(toCFrame, if self.Lerp then 0.5 else 1)
    end 
end 

function Arrow:Destroy()
    self.Maid:GiveTask(self.Object) 
    self.Maid:DoCleaning()
end

return Arrow
