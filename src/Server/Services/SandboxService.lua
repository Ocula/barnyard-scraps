-- Right now this empty service exists as a reminder that I need to export all the sandbox shit from 
-- BuildService, into this. 

-- Which will be a massive fucking undertaking. 
-- Can't be done until houseservice is working.
--[[
    
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local SandboxService = Knit.CreateService {
    Name = "SandboxService",
    Client = {},
}


function SandboxService:KnitStart()
    
end


function SandboxService:KnitInit()
    
end


return SandboxService
