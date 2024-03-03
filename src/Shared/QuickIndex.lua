-- Function for quickly indexing game assets on the client.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Utility = require(Knit.Library.Utility)

local QuickIndex = {
	Index = {},
}

-- @Ocula
function QuickIndex:GetBuild(itemId)
	if type(itemId) == "string" and #itemId == 0 then
		return
	end

	local build = Utility:Retrieve(self.Build, itemId)

	return build
end

function QuickIndex:GetVendor(itemId)
	if type(itemId) == "string" and #itemId == 0 then
		return
	end

	local vendor = Utility:Retrieve(self.Vendors, itemId)

	return vendor
end

function QuickIndex:GetSound(soundId)
	if type(soundId) == "string" and #soundId == 0 then
		return
	end

	local sound = Utility:Retrieve(self.Sounds, soundId)

	return sound
end

function QuickIndex:GetFolder(name)
	local folder = Utility:GetFolderInAssets(name:lower())

	return folder
end

function QuickIndex:Load() -- client assets !
	local Assets = game:GetService("ReplicatedStorage"):WaitForChild("Assets")
	local Items = Assets:WaitForChild("Items")
	local Sounds = Assets:WaitForChild("Sounds")
	local Build = Assets:WaitForChild("Build")
	local Vendors = Assets:WaitForChild("Vendors")

	--Find all objects
	self.Index = Utility:FindObjects(Items)
	self.Sounds = Utility:FindObjects(Sounds)
	self.Build = Utility:FindObjects(Build)
	self.Vendors = Utility:FindObjects(Vendors)
end

return QuickIndex
