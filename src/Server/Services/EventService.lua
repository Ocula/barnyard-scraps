local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local EventService = Knit.CreateService {
    Name = "EventService",

    Client = {},
    Active = {}, 

    Event = nil, 
}

function EventService:GetActive()
    return self.Active 
end 

function EventService:Register(event)
    self.Active[event.GUID] = event 
end 

function EventService:KnitStart()
    -- find any active events and register them 
end


function EventService:KnitInit()
    
end


return EventService
