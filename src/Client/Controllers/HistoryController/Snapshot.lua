local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Snapshot = {}
Snapshot.__index = Snapshot

function Snapshot.new()
    local self = setmetatable({
        Data = {}, 
        Timestamp = os.clock(),
    }, Snapshot)

    self:Take() 

    return self
end

function Snapshot:Take()
    -- get object data -> configs etc 
    local BuildController = Knit.GetController("BuildController") 
    
end

function Snapshot:Revert()

end 

function Snapshot:GetTimestamp()
    return self.Timestamp 
end 

function Snapshot:Destroy()
    
end


return Snapshot
