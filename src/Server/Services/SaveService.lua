-- Versioning Overhead for all Save Data
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local SaveService = Knit.CreateService {
    Name = "SaveService",
    Client = {},

    Versions = {
        Homes = "Version 1.0",
        Inventory = "Version 1.0",
        Saves = "Version 1.0", 
        --
        Sandbox = "Version 1.0", 
    }
}

function SaveService:GetVersion(dataType: string)
    assert(self.Versions[dataType], "Invalid data type provided!")
    return self.Versions[dataType] 
end 

function SaveService:KnitStart()
end

function SaveService:KnitInit()
end


return SaveService