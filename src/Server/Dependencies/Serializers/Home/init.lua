-- Homes Serialization 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Serialization = {}
Serialization.__index = Serialization

local SaveService = Knit.GetService("SaveService") 
local CurrentVersion = SaveService:GetVersion("Homes") 

local blank_template = {
    {
        Interior = {
            ID = "testing",
            Config = {
                UpgradeId = ""
            },

			Save = 1, 
        },

        Exterior = {
            ID = "testing",
            Config = {
                UpgradeId = ""
            }
        }
    }
} 

function Serialization.serialize(data)
	local Serializer = require(script[CurrentVersion]).GetTemplate() 
	local Data = Serializer:CompressIntoBase91(data) 
	
	-- returns version, data 
    return CurrentVersion, Data 
end

function Serialization.deserialize(version, data)
	if data then 
		if #data > 0 then 
			local Template = require(script[version]).GetTemplate() 
			local Data = Template:DecompressFromBase91(data) 
		
			if version ~= CurrentVersion then 
				-- format 
				warn("Conflicting Home Versions!") 
				Data = require(script[CurrentVersion]).Format(Data) 
			end 
		
			return Data
		end 
	end

	warn("No data provided to Homes Serializer.")
	return table.clone(blank_template) 
end 


return Serialization