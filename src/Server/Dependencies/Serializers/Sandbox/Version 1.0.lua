-- Sandbox Serializer Version 1.0.lua 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Bit = require(Knit.Modules.BufferTemplates)

local Version = {}
Version.__index = Version 

function Version.GetTemplate()
    local config_template = Bit.Table({
        Reference = Bit.Float32(),
        Color = Bit.Color3(),
        Transparency = Bit.Float32(), 
        -- 
        Rotation = Bit.Float32(), 
        Scale = Bit.Float32(),
    }) 
    
    local object_template = Bit.Table({
        ItemId = Bit.String(), 
        CFrame = Bit.CFrame(),
        Config = Bit.Array(config_template),
        
        SpecialId = Bit.String(),
    }) 

    return Bit.Array(object_template) 
end 

function Version.GetCheck()

end 

-- @Ocula
-- When we want to format our data to this version. 
function Version.Format(data)
    local Reconcile = {
        Object = {
            ItemId = "string",
            CFrame = "CFrame",
            Config = "table",

            SpecialId = "string"
        },

        Config = {
            Reference = "number",
            Color = "Color3",
            Transparency = "number",

            Rotation = "number",
            Scale = "number",
        }
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