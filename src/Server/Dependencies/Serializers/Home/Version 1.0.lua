-- Sandbox Serializer Version 1.0.lua 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Bit = require(Knit.Modules.BufferTemplates)

local Version = {}
Version.__index = Version 

function Version.GetTemplate()
    local home_data_template = Bit.Table({
        Interior = Bit.Table({
            ID = Bit.String(), 

            Config = Bit.Table({
                UpgradeId = Bit.String(),
            }),

            Save = Bit.Float32(), 
        }),
    
        Exterior = Bit.Table({
            ID = Bit.String(), 
            Config = Bit.Table({
                UpgradeId = Bit.String(), 
            })
        }),
    })
    
    local homeArray = Bit.Array(home_data_template)

    return homeArray 
end 

-- @Ocula
-- When we want to format our data to this version. 
function Version.Format(data)
    local Reconcile = {}
    -- Format 
    return data 
end 

return Version  