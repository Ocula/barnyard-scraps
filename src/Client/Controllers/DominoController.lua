local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Interface = require(Knit.Modules.Interface.get)

local Signal = require(Knit.Library.Signal) 
local Maid = require(Knit.Library.Maid) 

local DominoController = Knit.CreateController { 
    _debug = false, 

    StartingDomino  = nil, 

    Dominos         = {},
    DominoObjects   = {}, 
    Storage         = {}, 
    Name            = "DominoController", 

    OverlapParams   = OverlapParams.new(),
    RaycastParams   = RaycastParams.new(),

    Started         = false, 
    LastFastest     = nil, 

    Set             = Signal.new(), 
    StateChanged    = Signal.new(), 
    RoundOver       = Signal.new(), 
    CancelRound     = Signal.new(), 
    Finished        = Signal.new(), 
    OnTopple        = Signal.new(), 
    Updated         = Signal.new(),    

    Round           = Maid.new(), 
    Maid            = Maid.new(), 
}

local Action = Interface:GetClass("Game/ActionMessage")
local ActionTheme = Interface:GetTheme("Frames/ActionMessage") 

-- Play methods
function DominoController:GetResults()
    local Data = {
        Dominos = {        
            Toppled = 0, 
            Upright = 0, 
            Halfway = 0,

            Total = 0, 
        },

        Sets = {
            Total = 0, 
            Toppled = 0, 
        }, 
    }

    for _, domino in self.Dominos do
        Data.Dominos.Total += 1 

        local Set = domino:GetSet() 

        if not Data.Sets[Set.ObjectId] then
            Data.Sets[Set.ObjectId] = {
                Toppled     = 0,
                Price       = Set.Price, 
                isToppled   = false, 
                Total       = Set.Total, 
            }

            Data.Sets.Total += 1 
        end 
        
        local state = domino:CheckState()
        local DataSet = Data.Sets[Set.ObjectId] 

        if state == "Toppled" then 
            Data.Dominos.Toppled += 1
            DataSet.Toppled += 1

            if DataSet.Toppled == Set.Total then 
                DataSet.isToppled = true 
                Data.Sets.Toppled += 1 
            end 
        elseif state == "Upright" then 
            Data.Dominos.Upright += 1
        elseif state == "Halfway" then
            Data.Dominos.Halfway += 1
        end
    end

    return Data
end

function DominoController:GetVelocityPosition()
    local Map = self:GetDominoObjects() 

    local VelocityPoint = self.StartingDomino.Object.Position  
    local TotalSpeed = 0

    local TotalDominos = 0 
    local FastestDomino = nil --self.LastFastest or self.StartingDomino.Object 

    for _, domino in Map do -- iterating through this twice per frame might be too much. 
        local speed = domino.Velocity.Magnitude --* (domino:GetAttribute("Velocity") or 1)

        local dominoObject = self:GetDomino(domino) 

        if dominoObject then -- ignore flagged dominos on velocity calculations
            if dominoObject.Flagged then 
                continue 
            end
        end  

        if speed > 0.01 then

            --[[if speed > HighestSpeed then 
                HighestSpeed = speed 
                FastestDomino = domino 
                
                self.LastFastest = FastestDomino 
            end--]]

            local Weight = math.floor(speed / 0.01)

            if TotalDominos == 0 then 
                VelocityPoint = domino.Position * Weight
            else 
                VelocityPoint += domino.Position * Weight -- weight it to where it's the fastest?
            end 

            TotalSpeed += speed 

            --table.insert(Flagged, domino)

            TotalDominos += Weight 
        end 
    end 

    if TotalSpeed == 0 then 
        TotalSpeed = 1
    end 

    if TotalDominos == 0 then
        VelocityPoint = Vector3.new()  
        TotalDominos = 1
    end 

    local VelocityPosition = (VelocityPoint / TotalDominos)

    if FastestDomino then 
        VelocityPosition = FastestDomino.Position 
    end 

    local MapVelocity = TotalSpeed / TotalDominos 

    if self._debug and self.VisualizePoint then 
        self.VisualizePoint.Position = VelocityPosition
    end 

    return VelocityPosition, MapVelocity, FastestDomino -- Flagged 
end 

function DominoController:GetMapVelocity()
    local AverageVelocityPosition, MapVelocity = self:GetVelocityPosition() 

    for _, Domino in self.Dominos do 
        local Object = Domino.Object
        local State = Domino:CheckState() 

        local isInBounds = (AverageVelocityPosition - Object.Position).Magnitude < 5

        local StateMemory = self.Storage[Object] 

        if not StateMemory then 
            self.Storage[Object] = State 
        else 
            if StateMemory ~= State then 
                self.StateChanged:Fire(Domino, self.Storage[Object], State) 
                self.Storage[Object] = State 
            end 
        end 

        local Speed = Object.Velocity.Magnitude --* (Object:GetAttribute("Velocity") or 1)

        if Speed < 0.01 then 
            if State ~= "Upright" then 
                if not isInBounds and Speed < 0.013 and Domino.Object.Anchored == false then
                    if Domino.Flagged then 
                        if tick() - Domino.Flagged > 2 then 
                            Domino:Anchor()
                        end
                    else 
                        Domino:Flag() 
                    end 

                    if Domino.wasInBounds and Domino.Flagged == nil then 
                        Domino:Flag()
                    end 
                end 
            elseif isInBounds and State == "Upright" then 
                if not Domino.wasInBounds then 
                    Domino.wasInBounds = true 
                end 

                if Domino.Traveled then 
                    if Domino.Traveled < 0.02 then 
                        Domino:Deflag() -- if it's within bounds and still upright, deflag it 
                    end 
                end 
                Domino:Pulse() -- keep it awake
                --end
            end
        else 
            -- if we haven't moved, but our velocity is high, flag the domino.
            if Speed > 0.1 and (Domino.Traveled or 1) <= 0.02 then 
                Domino:Flag()
            end

            --if Speed <= 0.1 then 
              --  Domino:Deflag() 
            --end 
        end 

        Domino:UpdateCurrentPosition() 
    end

	return MapVelocity, AverageVelocityPosition -- average map velocity 
end 

-- @Ocula 
-- Before the game can begin toppling, we have to double check that a starting 
-- domino is set. If so, then we start to topple. 
function DominoController:Precheck()
    if self:GetDominoCount() == 0 then 
        local action 

        action = Action.new({
            Choose = function(result)
                action._wait:Fire() 
                action._result:Fire(result) 

                return result
            end, 
            Color = ActionTheme.Green, 
            Body = "Make sure to place some dominos down in your sandbox first!", 
            Header = "empty sandbox!", 
        })

        action:Show()
        action:Wait()

        action:Destroy()

        return false, "No dominos on base!"
    end 

    if self.StartingDomino == nil then 
        local InterfaceController = Knit.GetController("Interface") 
        local action 

        action = Action.new({
            Freeze = "Inventory",
            Choose = function(result)
                action._wait:Fire() 
                action._result:Fire(result) 

                if result then 
                    InterfaceController.Game.HUD:SelectPanel("SetStart", true) 
                end 

                return result
            end, 
            Color = ActionTheme.Delete, 
            Body = "It looks like you haven't set a starting domino! Would you like to select one?", 
            Header = "oh no!", 
        })

        action:Show()
        action:Wait()

        local result = action:GetResult()
        local reason = "No Starting Domino set!"

        if not result then 
            reason = "Cancelled result." 
        end 

        action:Destroy()

        return false, reason 
    else 
        return true 
    end 
end 

function DominoController:SetTally() -- this is only going to show on the owner client. 
    if not self.Started then return end 

    -- Tally up Experience
    self.Round:GiveTask(self.StateChanged:Connect(function(Domino: table, LastState: string, CurrentState: string)
        local Position              = Domino.Object.Position 
        local Y                     = 1.5 
        local ExperiencePosition    = (Domino.Object.CFrame * CFrame.new(0,Y,0)).Position 

        local amountToAdd           = 0

        -- handle set update
        if CurrentState == "Toppled" then 
            local Set = Domino:GetSet() 
            local StorageSet = self.Storage[Domino.Object.Parent] 

            if not StorageSet then
                self.Storage[Domino.Object.Parent] = {
                    Toppled = 1,
                    Total = Set.Total, 
                }
            else 
                if StorageSet.Toppled < StorageSet.Total * 0.7 then 
                    StorageSet.Toppled += 1 

                    if StorageSet.Toppled >= StorageSet.Total * 0.7 then 
                        self.OnTopple:Fire(Set) 
                    end 
                end 
            end 
        end 

        if LastState == "Upright" and CurrentState == "Toppled" then 
            amountToAdd = 1 
        elseif (LastState == "Upright" and CurrentState == "Halfway") or (LastState == "Halfway" and CurrentState == "Toppled") then 
            amountToAdd = 0.5 
        end 

        if amountToAdd > 0 then 
            self.Numbers.Experience:Add(Position, ExperiencePosition, amountToAdd)
        end 
    end))

    -- Tally up Corn 
    self.Round:GiveTask(self.OnTopple:Connect(function(Set)
        local Position = Set.Object.PrimaryPart.Position 
        local Size = Set.Object:GetExtentsSize()
        local CornPosition = (Set.Object.PrimaryPart.CFrame * CFrame.new(0,Size.Y + 2,0)).Position 

        self.Numbers.Corn:Add(Position, CornPosition, Set.Price * 0.2) 
    end))
end 

function DominoController:StartRound() 
    if not self.Started then return end 

    --task.wait(1) 

    local BuildController = Knit.GetController("BuildController") 

    local startTime = tick() -- record start time
    local checkTime = nil 
    local checkThreshold = 1.5 -- how long it takes for us to consider the map resting

    local roundOver = false 
    local mapVelocity, mapVelocityPosition = self:GetMapVelocity() 

    local roundCancelled = false 

    local positionClock = nil 
    local doneClock = tick() 
    local magnitudeAverage = 0 
    local lastPosition = nil 
    local totalMag = 1 
    local doneChecks = 0 
    local lastDoneChecks = 0 

    self.Round:GiveTask(self.CancelRound:Connect(function()
        roundCancelled = true 
        self.RoundOver:Fire() 
    end))

    self.Round:GiveTask(game:GetService("RunService").RenderStepped:Connect(function(dt)
        if self.Paused then 
            return 
        end 

        if roundOver then 
            self.RoundOver:Fire()
            return 
        end

        local currentTime = tick() 

        lastPosition = mapVelocityPosition 

        mapVelocity, mapVelocityPosition = self:GetMapVelocity() -- we should throttle this if dt > a certain #. idk what the calibration is for that though.
        
        -- if the last 2 seconds of mapVelocityPosition is relatively similar, we could... call a stop. 
        -- nevermind. i've tested that and that didn't work.
        local mag = (lastPosition - mapVelocityPosition).Magnitude 
    
        if mag < 1 then 
            -- start clock 
            if positionClock == nil then 
                positionClock = currentTime 
                magnitudeAverage = mag 
            else 
                --if currentTime - positionClock > 0.2 then 
                    --warn("DoneChecks:", doneChecks) 
                doneChecks += 1 
                --end 
            end 
            -- we've barely moved

            --warn(mag, magnitudeAverage)

        else 
            positionClock = nil 
            magnitudeAverage = 0
        end--]]

        if mapVelocity <= 0.01002 or mapVelocityPosition == Vector3.new() then  -- average map velocity for a dead map is around 0.01 
            if not checkTime then 
                checkTime = tick() 
            end 

            if tick() - checkTime > checkThreshold then 
                roundOver = true 
            end 
        else 
            checkTime = nil 
        end 

        if roundCancelled then 
            roundOver = true 
        end 
    end))

    -- Now that we're counting, push the start domino! 
    self.StartingDomino:Push() 

    self.RoundOver:Wait()

    if BuildController.isOwner and not roundCancelled then 
        self:SendResults({
            Start = startTime, 
            End = tick(),
        })  
    end

    self:CleanupRound() 
end 

function DominoController:SendResults(Time: table)
    warn("Map time:", Time.End - Time.Start, "seconds.")

    -- Get our results and send the data to the server. 
    local Results = self:GetResults()
    local DominoService = Knit.GetService("DominoService")

    warn("Sending Results:", Results)

    DominoService:Receive(Results) 
end 

function DominoController:CleanupRound()
    if self._cleaning then return end 
    self._cleaning = true 
    self.Round:DoCleaning()

    self.Numbers.Experience:Clean()
    self.Numbers.Corn:Clean() 

    self.Storage = {}

    self.Paused = false 
    self.Started = false 

    -- reset dominos

    self:ResetAll() 
    self._cleaning = false 
end 


-- TODO: add in load in line for starting domino in sandbox update!
-- so we switch to localizing start dominos, which will help us support
-- MP topple. 

-- @Ocula
-- DominoController:Play() --> begins toppling the visible dominos on the current client.
function DominoController:Play()
    if self.Started then return end 
    self.Started = true 

    local count = self:GetDominoCount()
    self.TotalCount = count 
    self.CurrentCount = 0 

    warn("Look at me:", self)
    -- ? do we need to check that the set domino is in the correct sandbox?
    -- > to respond to my own question, i think this would technically be a server problem.
    if not self.StartingDomino then 
        warn("No Starting Domino is set! We can't play.")
        return 
    end

    -- Show the player that we're loading. 
    -- Unanchor function will throttle our unanchoring to prevent any front-end lag
    local Loading  
    Loading = Action.new({
        Color = ActionTheme.Delete, 
        Body = "⚠️ Loading ⚠️", 
        Header = "play", 
    })
    
    local hasLoaded = false 
    local hadToLock = false 

    task.delay(0.5, function()
        if not hasLoaded then 
            hadToLock = true 
            self:Lock(true)

            Loading:Show()
        end
    end)

    -- Unanchor All dominos.
    self:UnanchorAll() 

    hasLoaded = true 

    if hadToLock then 
        self:Unlock(true) 
    end 

    -- Destroy Loading Message, some loading messages won't even have the time to show up.
    Loading:Destroy() 

    -- if we own this sandbox then we set tallies.
    local BuildController = Knit.GetController("BuildController")

    if BuildController.isOwner then 
        self:SetTally() 
    end 

    self:StartRound() 
end 

function DominoController:Pause()
    self:AnchorAll() 
    self.Paused = true 
end

function DominoController:Unpause()
    self.Paused = false 
    self:UnanchorAll() 
end 

function DominoController:SetStartingDomino(objectId, reference)
    --warn("Updating Starting Domino:", objectId, reference) 

    local Domino 
    
    if objectId and reference then 
        Domino = self:GetDominoFromObjectId(objectId, reference) 
    end

    if Domino and Domino ~= self.StartingDomino and self.StartingDomino ~= nil then 
        self.StartingDomino:SetPhysics() -- reset physics on the starting domino. 
    end 

    self.StartingDomino = Domino 

    if self.StartingDomino then 
        self.StartingDomino:GetDirection() 
    end 

    if Domino then 
        Domino.Object.CustomPhysicalProperties = PhysicalProperties.new(3,3,0,3,0)
    end 

    self.Set:Fire(Domino) 
end 

-- Get methods 
function DominoController:GetDominoCount()
    local _count = 0 

    for i, v in self.Dominos do 
        _count += 1
    end 

    return _count
end 

function DominoController:GetDomino(object: instance)
    return self.Dominos[object] or false 
end 

function DominoController:GetDominos(): array 
    return self.Dominos 
end

function DominoController:GetDominoObjects(): array 
    return self.DominoObjects 
end 

function DominoController:GetDominoFromObjectId(objectId: string, referenceId: number) 
    local BuildController = Knit.GetController("BuildController")

    local Object = BuildController:GetObject(objectId)
    local Domino = nil 

    if Object then 
        for i, v in Object:GetChildren() do 
            if v.Name == "Domino" and v:GetAttribute("_config") == referenceId then
                Domino = v 
                break 
            end
        end 

        return self:GetDomino(Domino) 
    end 
end

-- Update
function DominoController:UpdateDomino(domino: instance) 
    local IndexedDomino = self:GetDomino(domino) 

    if IndexedDomino then 
        IndexedDomino:Update() 
    end 
end 

function DominoController:UnanchorAll()
    local _count = 0 
    for i, v in self.Dominos do 
        v:Unanchor() 
        
        _count += 1 

        if _count % 10 == 0 then 
            _count = 0 
            task.wait()
        end 
    end 
end 

function DominoController:AnchorAll()
    for i, v in self.Dominos do 
        if v.Object.Anchored == false then 
            v:Anchor()
        end 
    end 
end 

function DominoController:ResetAll()
    self:Lock()

    --self:AnchorAll() 

    local throttle = 0 
    for i, v in self.Dominos do 

        local isReset = v:Reset() 

        if isReset then 
            throttle += 1 
        end 

        if throttle % 10 == 0 then 
            task.wait() 
            throttle = 0 
        end 
    end 

    self:Unlock() 
end

function DominoController:Lock(_master)
    local InterfaceController = Knit.GetController("Interface")
    local HUD = InterfaceController.Game.HUD 

    if not _master then 
        HUD:Lock("Play", true) 
        HUD:Lock("Pause", true) 
        HUD:Lock("SetStart", true) 
    else 
        HUD:Lock("Master", true)
    end 
end 

function DominoController:Unlock(_master)
    local InterfaceController = Knit.GetController("Interface")
    local HUD = InterfaceController.Game.HUD 

    if not _master then 
        HUD:Lock("Play", false)
        HUD:Lock("SetStart", false)
    else 
        HUD:Lock("Master", false)
    end 
end 

function DominoController:KnitStart()
    --local RaycastParam = RaycastParams.new() 

    local Binder = require(Knit.Library.Binder) 
    local Domino = require(Knit.Modules.Classes.Domino) 

    local DominoBinder = Binder.new("Domino", Domino) 

    DominoBinder:GetClassAddedSignal():Connect(function(newDomino) -- we can double check whether or not this domino is in OUR sandbox. if it 
        if newDomino._ShellClass then 
            return
        end
        
        self.Dominos[newDomino.Object] = newDomino 
        self.DominoObjects[newDomino.Object] = newDomino.Object 

        self.OverlapParams:AddToFilter(newDomino.Object)
        self.RaycastParams:AddToFilter(newDomino.Object) 
    end)

    DominoBinder:GetClassRemovedSignal():Connect(function(oldDominoClass, oldDomino) 
        self.Dominos[oldDomino] = nil 
    end) 

    DominoBinder:Start() 

    --

    local NumberController = Knit.GetController("NumberController") 

    self.Numbers = {
        Corn = NumberController:GetClass("Corn"),
        Experience = NumberController:GetClass("Experience", 5) 
    }

    if self._debug then 
        self.VisualizePoint = Instance.new("Part", workspace)
        self.VisualizePoint.Anchored = true 
        self.VisualizePoint.Size = Vector3.new(2,2,2)
        self.VisualizePoint.Color = Color3.new(0,1,0)
        self.VisualizePoint.CanCollide = false--]]
    end 
end

function DominoController:KnitInit()
    local DebugService = Knit.GetService("DebugService") 

    DebugService.Domino:Connect(function(toggle: boolean)
        self._debug = toggle 

        if self._debug then 
            self.VisualizePoint = Instance.new("Part", workspace)
            self.VisualizePoint.Anchored = true 
            self.VisualizePoint.Size = Vector3.new(2,2,2)
            self.VisualizePoint.Color = Color3.new(0,1,0)
            self.VisualizePoint.CanCollide = false--]]
        else 
            self.VisualizePoint:Destroy()
        end 
    end)
    
    self.OverlapParams.CollisionGroup = "Dominos"
    self.OverlapParams.MaxParts = 5
    self.OverlapParams.FilterType = Enum.RaycastFilterType.Include 

    self.RaycastParams.CollisionGroup = "Dominos"
    self.RaycastParams.FilterType = Enum.RaycastFilterType.Include 

    -- Events

    local DominoService = Knit.GetService("DominoService") 
    local BuildController = Knit.GetController("BuildController") 

    DominoService.SetStartingDomino:Connect(function(sandboxId, objectId, reference)
        if BuildController:CheckInSandbox(sandboxId) then
            self:SetStartingDomino(objectId, reference) 
        end 
    end)

    DominoService.Update:Connect(function(playerSentId, sandboxId, state)
        local PlayerId = game.Players.LocalPlayer.userId 
        if playerSentId == PlayerId then return end 

        warn("Receiving State Update", state)
        if BuildController:CheckInSandbox(sandboxId) then
            if state == "Play" then 
                self:Play()
            elseif state == "Pause" then 
                self:Pause() 
            elseif state == "Unpause" then
                self:Unpause() 
            elseif state == "Stop" then 
                self.CancelRound:Fire() 
            end 
        end
    end)
end


return DominoController
