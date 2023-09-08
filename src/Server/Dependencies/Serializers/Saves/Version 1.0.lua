-- Sandbox Serializer Version 1.0.lua 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Bit = require(Knit.Modules.BufferTemplates)

local Version = {}
Version.__index = Version 

function Version.GetTemplate()
    local save_template = Bit.Table({
        -- strings
        Name = Bit.String(), -- save name
        Key = Bit.String(), -- sandbox key
    
        -- nums
        Slot = Bit.Float32(), -- slot # 
        Timestamp = Bit.Float64(), -- maxing out at about 40ish bytes. 
    
        -- locked / empty 
        Locked = Bit.Bool(), -- whether or not the slot is locked (on our end)
        Empty = Bit.Bool(), 
    
        -- settings
        Multiplayer = Bit.Float32(), -- 0 for solo, 1 for multiplayer w/ friends, 2 for multiplayer w/ anyone in server 
        
    })
    
    local saveArray = Bit.Array(save_template) 
    
    return saveArray 
end 

-- @Ocula
-- When we want to format our data to this version. 
function Version.Format(data)
    -- TODO: Format 
    return data 
end 

return Version  