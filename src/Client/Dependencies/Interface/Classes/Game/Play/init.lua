local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(Knit.Library.Maid) 
local Signal = require(Knit.Library.Signal)

local Play = {}
Play.__index = Play

-- Skeleton play class that essentially handles communication between the UI and DominoController.
function Play.new()
    local self = setmetatable({
        Maid = Maid.new(), 
        Neutral = Maid.new(), 

        Update = Signal.new(), 
    }, Play)
    return self
end

local function sendState(state)
    local DominoService = Knit.GetService("DominoService")
    DominoService:ProcessState(state) 
end 

function Play:Check()
    if self.SetStart then 
        self.SetStart:Load() 
    end 

    local DominoController = Knit.GetController("DominoController")
    return DominoController:Precheck() 
end 

function Play:Play() 
    local DominoController = Knit.GetController("DominoController")
    local BuildController = Knit.GetController("BuildController") 

    if not DominoController.Paused and not DominoController.Started then 
        local Interface = Knit.GetController("Interface") 
        
        sendState("Play") 

        if BuildController.isOwner then 
            self.Update:Fire(0) 

            self.Neutral:GiveTask(DominoController.Updated:Connect(function(percentageToppled)
                self.Update:Fire(percentageToppled)
            end))
        end 
        
        DominoController:Play() 

        Interface.Game.HUD:SelectPanel("Play", false) 
    else 
        DominoController:Unpause() 
    end 
end

function Play:Stop() 
    local DominoController = Knit.GetController("DominoController")

    if not DominoController.Paused then
        DominoController.CancelRound:Fire() 
        self.Update:Fire(0) 

        sendState("Stop") 

        self.Neutral:DoCleaning() 
    end
end 

function Play:Pause(Toggled)
    local DominoController = Knit.GetController("DominoController")

    if Toggled then 
        DominoController:Pause() 

        sendState("Pause") 

    else
        if DominoController.Paused then 
            DominoController:Unpause() 

            sendState("Unpause") 
        end 
    end 
end

function Play:Destroy()
    self.Maid:DoCleaning() 
end


return Play
