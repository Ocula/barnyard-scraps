-- Spawn Service
-- @ocula
-- July 15, 2021

local SpawnService = {
	Client = {},
	Spawns = {},
}

function SpawnService:LobbySpawn(_player)
	local _spawns = game:GetService("CollectionService"):GetTagged("Lobby")
	local _spawn = _spawns[math.random(1, #_spawns)]
	self.Shared.Utility:TeleportPlayer(_player, _spawn.CFrame, 0)
end

function SpawnService:GetRandomSpawn(_villain)
	local _filteredTable = self.Shared.Utility:FilterTable(self.Spawns, function(_value)
		return _value.Villain == _villain
	end)

	local _count = self.Shared.Utility:CountTable(_filteredTable)
	local _rand = math.random(1, _count)

	local _num = 0
	for _, spawn in pairs(_filteredTable) do
		_num += 1

		if _num == _rand then
			return spawn
		end
	end
end

function SpawnService:Start()
	local _binder = self.Shared.Binder.Binder
	local _spawnBinder = _binder.new("Spawn", self.Modules.Spawn)

	_spawnBinder:GetClassAddedSignal():Connect(function(Spawn)
		if Spawn and not Spawn._ShellClass then
			if self.Spawns[Spawn.Object] then
				warn("Spawn class already created for that Spawn.", Spawn.Object:GetFullName())
				return
			end

			self.Spawns[Spawn.Object] = Spawn
		end
	end)

	_spawnBinder:Initialize()
end

function SpawnService:Init() end

return SpawnService
