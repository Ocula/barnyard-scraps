local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(Knit.Library.Maid) 
local Signal = require(Knit.Library.Signal) 
local Spring = require(Knit.Library.Spring) 
local Utility = require(Knit.Library.Utility) 
local TableUtil = require(Knit.Library.TableUtil) 
local Door = require(Knit.Modules.Door) 

local PlayerService = Knit.GetService("PlayerService") 
local TweenService = game:GetService("TweenService") 

local Tunnel = {}
Tunnel.__index = Tunnel

function lerp(startValue, endValue, t)
    return startValue + (endValue - startValue) * t
end

function Tunnel.new(object, push) 
    if push == nil then 
        if not object:isDescendantOf(workspace) then 
            return {_ShellClass = true}
        end
    end 

    local self = setmetatable({
        ID = object:GetAttribute("TunnelId"), 
        Object = object, 

        Front = object:FindFirstChild("Front", true), 
        Base = object.PrimaryPart, 

        Range = object:GetAttribute("Range") or 6.5,
        Radius = 20, 

        PlayerInside = Signal.new(), 

        Maid = Maid.new(), 
    }, Tunnel)

    for i, v in pairs(object:GetAttributes()) do 
        self[i] = v 
    end 

    local DoorObject = object:FindFirstChild("Door", true) 
    
    if DoorObject then 
        self.Door = Door.new(DoorObject) 
        self.Maid:GiveTask(self.Door) 
    end 

    self.Maid:GiveTask(self.Front.Touched:Connect(function(hit)
        if hit.Parent:FindFirstChild("Humanoid") then 
            local player = game.Players:GetPlayerFromCharacter(hit.Parent) 

            self.PlayerInside:Fire(player) 
        end
    end))

    -- Tunnel.Link -> refers to the tunnel that this tunnel travels to. 
    -- Link is set by TunnelService -> when new tunnels come in with same ids and different objects, it links them together.

    return self
end

function Tunnel:isInRange()
    local isInRange = false 
    local distance = math.huge

    local Players = game.Players:GetPlayers() 

    for i, v in Players do 
        local HRP = Utility:GetHumanoidRootPart(v) 

        if HRP then 
            local Mag = (HRP.Position - self.Front.Position).Magnitude 

            if self.Radius * 1.5 >= Mag then 
                isInRange = true 
            end

            if Mag < distance then 
                distance = Mag 
            end 
        end 
    end 

    return isInRange, distance 
end 

function Tunnel:Link(linkTo: table, avoidProcess: boolean) 
    if self.Linked then return end -- use NewLink to set a new Link at runtime. 
    assert(type(linkTo) == "table" and linkTo.ID == self.ID, "The link tunnel object fed to Tunnel:Link() must have a matching identification string!") 

    self.Linked = linkTo 

    if not avoidProcess then 
        linkTo:Link(self) 
    end 
end 

function Tunnel:GetLinkPosition()
    if not self.Linked then return false end 

    return self.Linked:GetTeleportCFrame() 
end 

function Tunnel:GetTeleportCFrame()
    local object = self.Object 
    local front = self.Front 

    if object:isDescendantOf(workspace) and front:isDescendantOf(workspace) then 
        return object.PrimaryPart.CFrame, front.CFrame
    else 
        return false 
    end 
end 

function Tunnel:WaitForPlayer(player, reverse, timeOut) 
    local waitForPlayer 
    local currentWait = Signal.new() 
    local _waitComplete = false 

    waitForPlayer = self.PlayerInside:Connect(function(hitPlayer)
        if hitPlayer == player.Player then
            _waitComplete = true 
            currentWait:Fire()
            waitForPlayer:Disconnect() 
        end 
    end) 

    local startTick = tick() 

    task.spawn(function()
        repeat 
            task.wait(.1) 
            local playerObj = player.Player 
            local character = playerObj.Character 

            if character then 
                local HRP = character:FindFirstChild("HumanoidRootPart")

                if HRP then 
                    local magCheck = (HRP.Position - self.Base.Position).Magnitude 

                    _waitComplete = if reverse then magCheck > 5 else magCheck < 5 
                end 
            end 

            if _waitComplete == false then 
                _waitComplete = (tick() - startTick) >= timeOut 
            end 
        until _waitComplete == true 

        currentWait:Fire() 
    end)

    if not _waitComplete then 
        currentWait:Wait() -- timeout functionality should be implemented! we don't want to wait for the player forever. 
    end 
end 

function Tunnel:GetLookDirection(Character)
    if not Character then return end 

    local Direction = -(self.Front.CFrame.ZVector).Unit
    local HumRoot = Character:FindFirstChild("HumanoidRootPart") 

    -- check humroot dot to direction vector 

    if HumRoot then -- if not ... then we can debounce the player til they respawn maybe lol
        -- check dot 
        local DotCheck = HumRoot.CFrame.LookVector.Unit:Dot(Direction)

        return DotCheck, HumRoot.CFrame.Position 
    end 

    return false 
end 

-- switch from cast checking to just checking players for a nearby player
-- if we have any nearby players, then we check if they're inside door bounds and facing in.
function Tunnel:Check()
    if self._throttle then return end 
    self._throttle = true 

    local overlapParam = OverlapParams.new()
    overlapParam.FilterType = Enum.RaycastFilterType.Include 

    local players = PlayerService:GetAvailablePlayers()
    overlapParam:AddToFilter(players)

    local rangeSize = Vector3.new(0, 0, self.Range * 2)
    local query = workspace:GetPartBoundsInBox(self.Front.CFrame, self.Front.Size + rangeSize, overlapParam)

    for i, v in query do 
        -- check humroot dot to direction vector 
        if v.Parent:FindFirstChild("Humanoid") then 
            local Character = v.Parent 
            local Player = game.Players:GetPlayerFromCharacter(v.Parent)
            local PlayerObject = PlayerService:GetPlayer(Player)
            local HumRoot = v.Parent:FindFirstChild("HumanoidRootPart")

            if HumRoot then 
                local DotCheck = self:GetLookDirection(Character) 

                if DotCheck and DotCheck < -0.25 then -- if not ... then we can debounce the player til they respawn maybe lo
                    local isInside = self:CheckInside(Player, self.Range)

                    if isInside then 
                        self:Grab(PlayerObject)
                    end 
                    --self:Grab(PlayerObject)
                else 
                    local isInside = self:CheckInside(Player) 

                    if isInside then
                        self:Grab(PlayerObject) 
                    end 
                end 

            end 
        end 
    end 

    task.delay(.01, function()
        self._throttle = false 
    end)
end 

function Tunnel:Grab(player)
    if not player then return end 
    if player:isInDebounce() then return end

    local TunnelService = Knit.GetService("TunnelService") 

    TunnelService.Client.Transition:Fire(player.Player, true, {
        Front = self.Front,
        ToggleInventory = self.ToggleInventory, 
    }) 

    player:SetDebounce(true) -- travel debounce to true

    -- set controls false
    player:SetControls(false) 

    -- move player
    player:Move(self.Base.CFrame.Position + Vector3.new(0,3.5,0), true) 

    task.delay(1, function()
        self:Teleport(player) 
    end)
end

-- @Ocula
-- Check if a player is inside the tunnel.
-- > Used to combat the slim chances that players run back in mid-debounce (rare)
function Tunnel:CheckInside(player: Instance, margin: number?)

    -- Check that player is behind the Front part 
    local Front = self.Front.CFrame 
    local HumRoot = Utility:GetHumanoidRootPart(player) -- wrong position on humroot

    if HumRoot then 
        local Check = Front:Inverse() * HumRoot.CFrame 

        if (Check.Z + (margin or 0)) > self.Front.Size.Z/2 then
            return true 
        end 
    end 

    --[[
    local HumRoot = Utility:GetHumanoidRootPart(player) 
    local Humanoid = player.Character:FindFirstChild("Humanoid") 

    if HumRoot and Humanoid.Health > 0 then 
        local SpatialParams = OverlapParams.new()
        SpatialParams.FilterType = Enum.RaycastFilterType.Include 
        SpatialParams:AddToFilter({HumRoot}) 

        local boxCFrame = self.Object:GetBoundingBox() 

        local SpatialQuery = workspace:GetPartBoundsInBox(boxCFrame, self.Object:GetExtentsSize(), SpatialParams) 

        if #SpatialQuery > 0 then 
            warn("Player is inside!")
            return true  
        end
    end--]]

    return false 
end

-- @Ocula
-- Take in a player that's just run through. 
function Tunnel:Process(player: userdata, teleportPosition: CFrame)
    local RunTo = self.Front.CFrame * CFrame.new(0,0,-self.Range - 5) 

    local TunnelService = Knit.GetService("TunnelService") 
    TunnelService.Client.Transition:Fire(player.Player, false, {
        Front = self.Front,
        ToggleInventory = self.ToggleInventory, 
    }) 

    -- move player 
    player:Move(RunTo.Position, true, teleportPosition.Position) 

    -- enable controls

    local Character = player.Player.Character 

    if Character then 
        local DotCheck, Position = self:GetLookDirection(Character) 
        local Humanoid = Character:FindFirstChild("Humanoid")

        if DotCheck and DotCheck < -0.25 and Humanoid.Health > 0 then -- we're facing the wrong way and should hold our debounce just until the player moves.
            local currentDirection, currentPosition 
            local magnitude 

            player:SetControls(true) 

            local startMag = math.floor((RunTo.Position - Position).Magnitude)

            Position = RunTo.Position

            repeat 
                currentDirection, currentPosition = self:GetLookDirection(player.Player.Character) 
                magnitude = math.floor((currentPosition - Position).Magnitude) 

                task.wait() 
            until magnitude > (startMag) or currentDirection and currentDirection >= -0.25

            task.delay(0.25, function()
                player:SetDebounce(false)

                local playerInside = self:CheckInside(player.Player)

                if playerInside then 
                    self:Grab(player) 
                end
            end) 
            -- 
        else 
            player:SetControls(true) 
            player:SetDebounce(false)
        end
    end
end 

-- @Ocula
-- Calling Teleport on a Tunnel teleports the player to the Link tunnel.
function Tunnel:Teleport(player)
    local To, Direction = self:GetLinkPosition() 

    -- if we want to load sandboxes based on tunnel entrances / exits, we can do so here.
    -- for now we will let buildservice handle all of that updating. 

    local Character = player.Player.Character 

    if Character then 
        local Humanoid = Character:FindFirstChild("Humanoid")

        if Humanoid then 
            if Humanoid.Health > 0 then 
                local HRP = Character:FindFirstChild("HumanoidRootPart")

                if HRP then 
                    local CharacterSize = Character:GetExtentsSize() 

                    if Direction and To then -- player might have left mid-transport
                        local CFrameDirection = CFrame.new(To.Position + Vector3.new(0,CharacterSize.Y/2,0), Direction.Position) 

                        HRP.CFrame = CFrameDirection

                        self.Linked:Process(player, CFrameDirection)
                    end 
                end 
            end 
        end 
    end 
end

function Tunnel:Destroy()
    local TunnelService = Knit.GetService("TunnelService")
    
    if TunnelService.Tunnels[self.Object] then
        TunnelService.Tunnels[self.Object] = nil 
    end

    self.Maid:DoCleaning() 
end


return Tunnel
