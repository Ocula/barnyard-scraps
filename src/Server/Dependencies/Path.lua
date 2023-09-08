local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService") 

local Knit = require(ReplicatedStorage.Packages.Knit)
local Maid = require(Knit.Library.Maid) 
local Signal = require(Knit.Library.Signal) 

local Path = {}
Path.__index = Path

-- @Ocula
-- Creates a new Path object. 
function Path.new(From, Destination, Customize) 
    local self = setmetatable({
        From = From, 
        Destination = Destination,
 
        Path = PathfindingService:CreatePath(Customize), 

        Blocked = Signal.new(), 
        Finished = Signal.new(), 

        Clean = Maid.new(), 
    }, Path) 

    self.Clean:GiveTask(self.Path) 

    return self
end

-- @Ocula
-- Gets our Path ready. 
function Path:Get(subject)
    local success, fail = pcall(function()
        self.Path:ComputeAsync(self.From, self.Destination)
    end)

    if success and self.Path.Status == Enum.PathStatus.Success then 
        self.Waypoints = self.Path:GetWaypoints()
        return true 
    else
        --warn("Path failed to compute.", fail, self.Path.Status, self.Path) 

        subject:MoveTo(self.Destination)
        self.Finished:Fire()  
        self:DoCleaning() 

        return false 
    end 
end 

function Path:DoCleaning()
    --self.Finished:Fire() 
    self.Clean:DoCleaning() 
end 

-- @Ocula
-- Moves subject along the path. 
function Path:Grab(subject, timeout: number?) 
    if not self.Waypoints then
        local pathCheck = self:Get(subject) 

        if not pathCheck then 
            return 
        end 
    end

    self:DoCleaning() 

    self.Index = 2 

    -- recalculate initial path if path is blocked. 
    self.Clean:GiveTask(self.Path.Blocked:Connect(function(blockedIndex)
        if blockedIndex > self.Index + 1 then 
            self.BlockedConnection:Disconnect()

            local pathCheck = self:Get(subject) 

            if pathCheck then 
                self:Grab(subject) 
            end 
        end 
    end)) 

    --[[self.ReachedConnection = subject.MoveToFinished:Connect(function(reached)
        if reached and (self.Index + 1) < #self.Waypoints then 
            self.Index += 1
        else 
            self.Heartbeat:Disconnect() 
            self.BlockedConnection:Disconnect() 
            self.ReachedConnection:Disconnect() 
        end 
    end)--]]

    local subjectHRP = subject.Parent:FindFirstChild("HumanoidRootPart") 
    local timePassed = 0 
    
    self.Clean:GiveTask(game:GetService("RunService").Heartbeat:Connect(function(dt)
        if not self.Index or not self.Waypoints then 
            self.Finished:Fire() 
            self:DoCleaning()
        end 

        timePassed += dt 

        if timeout then 
            if timePassed > timeout then
                self.Finished:Fire() 
                self:DoCleaning() 
            end 
        end 

        local currentWaypoint = self.Waypoints[self.Index].Position 

        subject:MoveTo(currentWaypoint) 
        
        if subject.Health <= 0 then 
            self.Finished:Fire()
            self:DoCleaning() 
        end 

        if subjectHRP then 
            local Pos = subjectHRP.Position 
            local Distance = (Pos - currentWaypoint).Magnitude

            if Distance < 7 and (self.Index + 1) < #self.Waypoints then 
                self.Index += 1
            elseif Distance < 7 and (self.Index + 1) >= #self.Waypoints then 
                self.Finished:Fire() 
                self:DoCleaning() 
            end 
        end 
    end))

    --subject:MoveTo(self.Waypoints[self.Index].Position) 
end 

function Path:Cancel()
    self:DoCleaning() 
end 

function Path:Destroy()
    self:DoCleaning() 
end


return Path
