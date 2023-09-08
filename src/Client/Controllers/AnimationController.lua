-- preloads all animations on client
-- handles playing animations

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimationsFolder = ReplicatedStorage.Assets:WaitForChild("Animations")
local ClientFolder = AnimationsFolder:WaitForChild("Client") 

local Knit = require(ReplicatedStorage.Packages.Knit)

local AssetLibrary = require(Knit.Library.AssetLibrary) 

local AnimationController = Knit.CreateController { 
    Name = "AnimationController",
    Animations = {}, 
}

function AnimationController:Load(animationId)
    local Anim = Instance.new("Animation") 
end 

function AnimationController:KnitStart()
    -- Get Animations
    local Animations = AssetLibrary:Aggregate(AssetLibrary.Assets.Animations) 

    -- Preload Animations on a Dummy Rig

end


function AnimationController:KnitInit()
    
end


return AnimationController
