-- Spawn
-- @ocula
-- July 5, 2021

--[[

	Handling the logic and interaction of in-game Spawns

]]
local Spawn = {}
Spawn.__index = Spawn

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Utility = require(Knit.Library.Utility)

function Spawn.new(_obj)
	if not _obj:FindFirstAncestor("Workspace") then
		warn("Not a member of workspace.")
		return { _ShellClass = true, Destroy = function() end }
	end

	local _data = _obj:GetAttributes()
	local _type = _data.Type

	-- Create new table based on data.

	local _newData = {
		_busy = false,
	}

	for index, value in pairs(_data) do
		_newData[index] = value
	end

	_newData.Object = _obj
	_data = nil -- will this get gc'ed?

	local self = setmetatable(_newData, Spawn)
	return self
end

function Spawn:Destroy()
	Knit.GetService("SpawnService").Spawns[self.Object] = nil
	game:GetService("CollectionService"):RemoveTag(self.Object, "Spawn")

	for i, v in pairs(self.Services.GameService.Players) do
		if v._activeSpawn and v._activeSpawn.Object == self.Object then
			v._activeSpawn = nil
		end
	end

	if self.Object then
		self.Object:Destroy()
	end
end

function Spawn:Teleport(_player, _radius)
	--if (self._busy) then warn("Spawn is busy, rerouting") return end

	--self._busy = true

	Utility:TeleportPlayer(_player.Player, self.Object.CFrame, _radius)

	return true
	--self._busy = false
end

return Spawn
