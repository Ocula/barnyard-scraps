-- Inventory Serialization
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Bit = require(Knit.Modules.BufferTemplates)

local Serialization = {}
Serialization.__index = Serialization

local SaveService = Knit.GetService("SaveService")
local CurrentVersion = SaveService:GetVersion("Inventory")

local blank_template = {
	{ ItemId = "dominos:basic:basic", Amount = 5 },
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

	warn("No data provided to Inventory Serializer.")
	return {}
end

return Serialization
