-- Map
-- @ocula
-- July 4, 2021

local Map = {
	Maps = {},

	_mapRandom = {},
}
Map.__index = Map

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Maps

function Map.new(_mapid)
	local self = setmetatable({
		MapId = _mapid,

		Spawns = {},
		Puzzles = {},
		Exits = {},
	}, Map)

	return self
end

-- Get Map spawns
function Map:GetSpawns()
	return self.Spawns
end

-- Get Map puzzles
function Map:GetPuzzles()
	return self.Puzzles
end

-- Get Exits
function Map:GetExits()
	return self.Exits
end

-- Set Spawn
function Map:SetSpawns()
	local _spawns = {}
	local _obj = self.Object

	for _, v in pairs(Knit.GetService("SpawnService").Spawns) do
		local _parent = self.Shared.Utility:FindParent(v.Object, _obj)

		if _parent then
			table.insert(_spawns, v)
		end
	end

	self.Spawns = _spawns
end

function Map:SetPuzzles(_number)
	local _obj = self.Object
	local _puzzles = {}

	local _totalLeft = _number
	local _totalToChooseFrom = {}

	local rng = Random.new(os.time())

	local function shuffle(array)
		local item
		for i = #array, 1, -1 do
			item = table.remove(array, rng:NextInteger(1, i))
			table.insert(array, item)
		end
	end

	-- Make sure the puzzles we're sorting are in our map.

	for _, v in pairs(Knit.GetService("PuzzleService").Puzzles) do
		local _parent = Knit.Modules.Utility:FindParent(v.Object, _obj)

		if _parent then
			table.insert(_totalToChooseFrom, v)
		end
	end

	-- Shuffle!
	shuffle(_totalToChooseFrom)

	-- Aggregate.
	for i = 1, _totalLeft do
		local _backupPuzzleChosen = _totalToChooseFrom[i]
		_backupPuzzleChosen.Active = true
	end

	for i, v in pairs(_totalToChooseFrom) do
		if not v.Active then
			v:Destroy()
		end

		_totalToChooseFrom[i] = nil
	end

	self.Puzzles = _totalToChooseFrom
end

--

function Map:Create()
	warn("Create is being called")
	local _map

	if not self.MapId then
		_map = self._mapRandom[math.random(1, #self._mapRandom)]
	else
		for i, v in pairs(self._mapRandom) do
			if v.Name == self.MapId then
				_map = i
			end
		end
	end

	local _obj = self.Maps[_map]:Clone()
	self.Object = _obj

	_obj.Parent = workspace

	return _obj
end

function Map:Destroy()
	for _, v in pairs(self.Puzzles) do
		v:Destroy()
	end

	for _, v in pairs(self.Spawns) do
		v:Destroy()
	end

	if self.Object then
		self.Object:Destroy()
	end
end

function Map:Start()
	Aero = self
	Puzzle = self.Modules.Puzzle
	Maps = game:GetService("ServerStorage"):WaitForChild("Maps")

	-- Coagulate maps

	for i, v in pairs(Maps:GetChildren()) do
		self.Maps[i] = v
		table.insert(self._mapRandom, i)
	end
end

return Map
