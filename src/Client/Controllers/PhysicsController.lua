-- Wakes certain parts up every second. Throttled to handle client lag. 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PhysicsController = Knit.CreateController { 
    Name = "PhysicsController", 

    Check = tick(), 

    Wake = {}, 
}

function PhysicsController:Update(dt) 
    if tick() - self.Check > (1 + dt) then -- throttle
        self.Check = tick() 
    else 
        return
    end

    -- to keep a part awake we feed it into Wake 
    for object, reference in self.Wake do
        if object and reference and object:isDescendantOf(workspace) then 
            object.Velocity = Vector3.new(0,-0.00008,0) -- this seems to be the lower limit i've hit
        else 
            self.Wake[object] = nil 
            continue 
        end 

        if type(reference) == "table" then 
            if reference.CheckAsleep then 
                local _check = reference:CheckAsleep() 

                if _check then 
                    self:Starve(object) 
                end 
            end 
        end 
    end 
end 

function PhysicsController:Feed(object: Instance?)
    if type(object) == "userdata" then 
        self.Wake[object] = object 
    elseif type(object) == "table" then 
        self.Wake[object.Object] = object
    end
end 

function PhysicsController:Starve(instance: Instance) 
    self.Wake[instance] = nil 
end 

function PhysicsController:KnitStart()
    --[[game:GetService("RunService"):BindToRenderStep("Wake", Enum.RenderPriority.Camera.Value - 1, function(dt)
        self:Update(dt) 
    end)--]] 
end


function PhysicsController:KnitInit()
    
end


return PhysicsController
