local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Utility = require(Knit.Library.Utility) 

local Teleport = {}
Teleport.__index = Teleport


function Teleport.new(Object)
    local self = setmetatable({
        Active = true, 
        Object = Object, 
    }, Teleport)

    for i, v in Object:GetAttributes() do 
        self[i] = v 
    end

    self.Position = self:Cast() 

    return self
end

function Teleport:Cast(): Vector3 
    local rayparams = RaycastParams.new()
    rayparams.FilterType = Enum.RaycastFilterType.Exclude 

    local rayDirection = Vector3.new(0,-1,0)

    local cast = workspace:Raycast(self.Object.Position, rayDirection * 25, rayparams)

    if cast then 
        return cast.Position 
    else 
        return self.Object.Position 
    end 
end 

function Teleport:Process(Player)
    if self.Active == false then return "Not active." end 

    local HumRoot = Utility:GetHumanoidRootPart(Player.Player) 
    local Character = Player.Player.Character 

    if self.__ProcessCall then 
        local _check, reason = self.__ProcessCall(Player) 

        if not _check then 
            return _check, reason 
        end 
    end 

    if HumRoot and Character then 
        local Position          = self.Position 
        local rotx, roty, rotz  = self.Object.CFrame:ToOrientation()

        local Size = Character:GetExtentsSize() 

        HumRoot.CFrame = CFrame.new(Position + Vector3.new(0,Size.Y/2,0)) * CFrame.Angles(rotx, roty, rotz) -- could raycast to get a perfect position to teleport to... yeah
    end 
end

function Teleport:Destroy()
    
end


return Teleport
