-- Handles opening / closing game doors. 
-- All doors are animated using an animationcontroller. -> Helps speed things up + makes them smooth and easily customizable for us.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local AssetLibrary = require(Knit.Library.AssetLibrary) 

local Signal = require(Knit.Library.Signal) 

local Door = {}
Door.__index = Door


function Door.new(object)
    assert(object:GetAttribute("AssetId"), "Door object does not have a valid AssetId for retrieving animations.")

    local AnimationIds = AssetLibrary.get(object:GetAttribute("AssetId")) 

    local self = setmetatable({
        Object = object, 
        Ids = AnimationIds, 
        -- TODO: Abstract animation controls to an animate object. 

        Range = object:GetAttribute("Range") or 30, 

        OpenedSignal = Signal.new(), 
        ClosedSignal = Signal.new(), 
    }, Door)

    local AnimationController = Instance.new("AnimationController") 
    AnimationController.Parent = object

    local Animator = Instance.new("Animator")
    Animator.Parent = AnimationController 

    self.Animator = Animator 

    -- Load / Run Animations 
    self:Open()
    self:Close() 

    return self
end

-- check if any players are within range. 
function Door:Check()
    if not self.Object then
        self:Destroy() 
        return 
    end 

    for i, v in pairs(game.Players:GetPlayers()) do 
        local char = v.Character 
        if char then 
            local hrp = char:FindFirstChild("HumanoidRootPart") 

            if hrp then
                local mag = (hrp.Position - self.Object.PrimaryPart.Position).Magnitude 
                local magCheck = mag < self.Range 

                if magCheck then 
                    return true, mag 
                end 
            end 
        end 
    end 

    return false 
end 

function Door:Open(forceOpen: boolean)
    if self.Opened then return end 
    if self.CloseAnimation then 
        self.CloseAnimation:Stop() 
    end 

    self.Opened = true 
    self.OpenedSignal:Fire() 

    local play = function()

        local openConn

        openConn = self.OpenAnimation:GetMarkerReachedSignal("DoorOpen"):Connect(function(paramString)
            self.OpenAnimation:AdjustSpeed(0)
            openConn:Disconnect() 
        end)

        self.OpenAnimation:Play() 

        if forceOpen then 
            self.OpenAnimation.TimePosition = self.OpenAnimation.Length * 0.5  
        end 
       -- end)
    end 

    if self.OpenAnimation then 
        play() 
        return 
    end 

    local anim = Instance.new("Animation")
    anim.AnimationId = self.Ids.Open 

    self.OpenAnimation = self.Animator:LoadAnimation(anim) 

    play() 
end 

function Door:Close()
    if not self.Opened then return end 
    self.OpenAnimation:Stop() 
    self.Opened = false 

    self.ClosedSignal:Fire() 

    if self.CloseAnimation then 
        self.CloseAnimation:Play() 
        return 
    end 

    local anim = Instance.new("Animation")
    anim.AnimationId = self.Ids.Close 

    self.CloseAnimation = self.Animator:LoadAnimation(anim) 

    self.CloseAnimation:Play() 
end 

function Door:Destroy()
    
end


return Door
