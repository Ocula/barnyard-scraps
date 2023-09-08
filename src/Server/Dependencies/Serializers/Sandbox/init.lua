local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Serialization = {}
Serialization.__index = Serialization

local SaveService = Knit.GetService("SaveService") 
local CurrentVersion = SaveService:GetVersion("Sandbox") 

-- There's an issue with Sandboxes.
-- Objectively we won't have a player root... so we won't know what version we're technically at unless we save it on the
-- sandbox profile of the last save. 

-- @Ocula
-- Update the serialize function to getTypes() and check against. 
function Serialization.serialize(data)
    local template = require(script[CurrentVersion])
    local objectsArray = template.GetTemplate() 
    local compressedData = objectsArray:CompressIntoBase91(data) 

    return CurrentVersion, compressedData
end

-- @Ocula
-- Deserialize and version check. 
function Serialization.deserialize(version, data)
    if data then 
		if #data > 0 then 
			local Template = require(script[version]).GetTemplate() 
			local Data = Template:DecompressFromBase91(data) 
		
			if version ~= CurrentVersion then 
				-- format 
				warn("Conflicting Sandbox Versions!") 
				Data = require(script[CurrentVersion]).Format(Data) 
			end 
		
			return Data
		end 
	end

	warn("No data provided to Sandbox Serializer.")
	return {}
end

return Serialization
