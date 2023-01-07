-- Player
-- @ocula
-- July 4, 2021
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Library.Promise)

local Player = {}
Player.__index = Player

function Player.new(_player, _profile)
	if not _profile then
		warn("No profile provided for player:", _player, "... exiting.")
		return
	end

	local self = setmetatable({
		Player = _player,
	}, Player)

	-- Reconcile player profile:
	for _saveIndex, _saveValue in pairs(_profile.Data) do
		self[_saveIndex] = _saveValue
	end

	return self
end

function Player:Spawn()
	if not self._activeSpawn then
		self.Services.SpawnService:LobbySpawn(self.Player)
	else
		self._activeSpawn:Teleport(self.Player)
	end
end

function Player:Kick() end

function Player:Reset() end

function Player:Exit() end

function Player:Save() end

function Player:Interface() end

return Player
