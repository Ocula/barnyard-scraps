local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local AssetLibrary = require(Knit.Library.AssetLibrary) 

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Interface = require(Knit.Modules.Interface.get)

local Chicken = {}
Chicken.__index = Chicken

function Chicken.new()
    local self = setmetatable({
        Transparency = Value(1), 
        ScaleOffset = Value(0.25), 
    }, Chicken)

    local Assets = ReplicatedStorage:FindFirstChild("Assets") 
    local ChickenObject = Assets:FindFirstChild("Inactive"):FindFirstChild("Chicken") 

    self.Object = ChickenObject:Clone() 
    self.Object.Parent = workspace.CurrentCamera 

    self:SetInterface() 

    self.Object:SetAttribute("DistanceOffsetX", 0) 
    self.Object:SetAttribute("DistanceOffsetZ", -5) 
    self.Object:SetAttribute("Scale", 0.35) 

    for i, v in pairs(self.Object:GetDescendants()) do 
        if v:IsA("BasePart") then 
            v.CanCollide = false 
            v.CanQuery = false
            v.CanTouch = false 
        end 
    end 

    self.Controller = self.Object:FindFirstChild("AnimationController") 
    self.Animator = Instance.new("Animator") 
    self.Animator.Parent = self.Controller 

    -- get animation ids
    local chickenIds = AssetLibrary.get("ChickenAnimations") 

    -- setup run animation
    local Run = Instance.new("Animation")
    Run.AnimationId = chickenIds.Run 

    self.Run = self.Animator:LoadAnimation(Run)  

    local ScaleSpring = Spring(self.ScaleOffset, 18, .25) 

    -- render 

    self.Render = function(dt) 
        local Camera = workspace.CurrentCamera 
        --[[local ViewportSize = Camera.ViewportSize 
        local FieldOfView = Camera.FieldOfView 
        
        local AspectRatio = ViewportSize.X / ViewportSize.Y 

        -- stole this from roblox developer hub on how they calculate viewportsize lol
        local Height = math.tan(math.rad(FieldOfView/2)) * 2  * 0.02
        local Width = (AspectRatio * Height) 

        local Size = Model:GetExtentsSize()--]]
        local Model = self.Object 

        -- now scale

        Model:ScaleTo(self.Object:GetAttribute("Scale") + Peek(ScaleSpring)) 
        Model:SetPrimaryPartCFrame(CFrame.new((Camera.CFrame * CFrame.new(self.Object:GetAttribute("DistanceOffsetX"),0,self.Object:GetAttribute("DistanceOffsetZ"))).Position, Camera.CFrame.Position)) 
    end 

    return self
end

function Chicken:SetInterface()
    local Player = game.Players.LocalPlayer 
    local PlayerGui = Player:WaitForChild("PlayerGui") 

    self.Interface = Interface:GetComponent("Transitions/Chicken") {
        Adornee = self.Object, 
        PlayerGui = PlayerGui, 
        Face = Enum.NormalId.Front, 

        Transparency = self.Transparency, 
    }
end 

function Chicken:SanityCheck()
    local Player = game.Players.LocalPlayer 
    local PlayerGui = Player:WaitForChild("PlayerGui") 

    if not PlayerGui:FindFirstChild("Chicken") then 
        self:SetInterface() 
    end 
end 

function Chicken:In()
    self:SanityCheck() 
    --end

    self.Run.Looped = true 
    self.Run:Play() 

    self.Transparency:set(0) 
    self.ScaleOffset:set(0) 
end 

function Chicken:Out()
    self:SanityCheck() 
    
    self.Transparency:set(1)
    self.ScaleOffset:set(.25) 

    task.wait(.1) 
    self.Run:Stop()
end 

function Chicken:Destroy()
    
end


return Chicken
