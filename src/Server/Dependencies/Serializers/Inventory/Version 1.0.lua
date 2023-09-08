-- Sandbox Serializer Version 1.0.lua 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Bit = require(Knit.Modules.BufferTemplates)

local Version = {}
Version.__index = Version 

function Version.GetTemplate()
    local inventory_item_template = Bit.Table({
        ItemId = Bit.String(), -- itemid
        Amount = Bit.Float32(), -- amount # 
        --> we can have special inventory types
    })

    return Bit.Array(inventory_item_template) 
end 

-- @Ocula
-- When we want to format our data to this version. 
function Version.Format(data)
    local Reconcile = {
        ItemId = "string",
        Amount = "number", 
    }
    
    for i, v in pairs(data) do 
        for ind, prop in Reconcile.Object do 
            if not v[ind] then 
                table.remove(data, i) 
            else 
                -- type check 
                if typeof(v[ind]) ~= prop then 
                    warn("Conflicting type check:", v[ind], prop)
                end 
            end 
        end 
    end 

    -- TODO: format 
    return data 
end 

return Version  