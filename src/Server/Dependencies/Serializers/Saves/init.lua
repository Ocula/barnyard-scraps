-- Inventory Serialization 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Serialization = {}
Serialization.__index = Serialization

local SaveService = Knit.GetService("SaveService") 
local CurrentVersion = SaveService:GetVersion("Saves") 

local blank_template = {
    {
        Slot = 1, 
        Locked = false, -- unlock for players that want more slots
        Name = "Untitled", 
        Empty = true, 
        Key = "", -- if no key, game will create one.
        Timestamp = 0, -- this will be set as well, 
        Multiplayer = 0, 
    },
    {
        Slot = 2, 
        Locked = false, -- unlock for players that want more slots
        Empty = true, 
        Name = "Untitled", 
        Key = "", -- if no key, game will create one.
        Timestamp = 0, -- this will be set as well, 
        Multiplayer = 0, 
    },
    {
        Slot = 3, 
        Locked = true, -- unlock for players that want more slots
        Name = "Untitled",
        Empty = true, 
        Key = "", -- if no key, game will create one.
        Timestamp = 0, -- this will be set as well, 
        Multiplayer = 0, 
    },
    {
        Slot = 4, 
        Locked = true, -- unlock for players that want more slots
        Name = "Untitled", 
        Empty = true, 
        Key = "", -- if no key, game will create one.
        Timestamp = 0, -- this will be set as well, 
        Multiplayer = 0, 
    },
    {
        Slot = 5, 
        Locked = true, -- unlock for players that want more slots
        Name = "Untitled", 
        Empty = true, 
        Key = "", -- if no key, game will create one.
        Timestamp = 0, -- this will be set as well, 
        Multiplayer = 0, -- 1 / 2 / 3 
    }
}

function Serialization.serialize(data)
	local Serializer = require(script[CurrentVersion]) 
	local Data = Serializer.GetTemplate():CompressIntoBase91(data) 
	
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
				warn("Conflicting Inventory Versions!") 
				Data = require(script[CurrentVersion]).Format(Data) 
			end 
		
			return Data
		end 
	end

	warn("No data provided to Saves Serializer.")
	return table.clone({
        {
            Slot = 1, 
            Locked = false, -- unlock for players that want more slots
            Name = "Untitled", 
            Empty = true, 
            Key = "", -- if no key, game will create one.
            Timestamp = 0, -- this will be set as well, 
            Multiplayer = 0, 
        },
        {
            Slot = 2, 
            Locked = false, -- unlock for players that want more slots
            Empty = true, 
            Name = "Untitled", 
            Key = "", -- if no key, game will create one.
            Timestamp = 0, -- this will be set as well, 
            Multiplayer = 0, 
        },
        {
            Slot = 3, 
            Locked = true, -- unlock for players that want more slots
            Name = "Untitled",
            Empty = true, 
            Key = "", -- if no key, game will create one.
            Timestamp = 0, -- this will be set as well, 
            Multiplayer = 0, 
        },
        {
            Slot = 4, 
            Locked = true, -- unlock for players that want more slots
            Name = "Untitled", 
            Empty = true, 
            Key = "", -- if no key, game will create one.
            Timestamp = 0, -- this will be set as well, 
            Multiplayer = 0, 
        },
        {
            Slot = 5, 
            Locked = true, -- unlock for players that want more slots
            Name = "Untitled", 
            Empty = true, 
            Key = "", -- if no key, game will create one.
            Timestamp = 0, -- this will be set as well, 
            Multiplayer = 0, -- 1 / 2 / 3 
        }
    }) 
end 


return Serialization
