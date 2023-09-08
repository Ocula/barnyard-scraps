local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Animate = {}
Animate.__index = Animate


function Animate.new()
    local self = setmetatable({
        Object = Instance.new("AnimationController"), 
    }, Animate)

    return self
end


function Animate:Destroy()
    
end


return Animate
