-- Game Service
-- @ocula
-- July 4, 2021

--[[

We gonna have our round modules inside this guy

1. Load in players through PlayerService, when they've completely loaded in, the game will throw them into GameService.Players
2. Round will continue looping until it has enough players.  *1st check 
3. Once enough players, round will pass. 

]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Signal = require(Knit.Library.Signal)
local Utility = require(Knit.Library.Utility)

local GameService = Knit.CreateService({
	Name = "GameService",
	Client = {},
	Players = {},
	Rounds = {},

	_roundInProgress = false,
	_amountNeededPerRound = 1,
})

-- Create events
GameService.SetControls = Signal.new()
GameService.Countdown = Signal.new()

-- Methods
function GameService:_getQueued()
	local _queued = {}

	for i, v in pairs(self.Players) do
		if v.Enabled then
			table.insert(_queued, v)
		end
	end

	return _queued
end

function GameService:_getPlaying()
	local _playing = {}

	for i, v in pairs(self.Players) do
		if v.Enabled then
			table.insert(_playing, v)
		end
	end

	return _playing
end

-- "Shuffle" round type will give us a random round type.
--
function GameService:_getRound(_roundtype)
	-- Right now we're only going to have a Normal round.
	local _module = self.Rounds.Normal

	if _roundtype then
		if _roundtype:lower() ~= "shuffle" then
			_module = self.Rounds[_roundtype]
		elseif _roundtype:lower() == "shuffle" then
			local _randoms = {}

			for index, _ in pairs(self.Rounds) do
				table.insert(_randoms, index)
			end

			local _randomChoice = _randoms[math.random(1, #_randoms)]
			_module = self.Rounds[_randomChoice]
		end
	end

	print("Round chosen:", _module)

	------------------------------------------

	local _map = self:_getMap()

	local _roundid = game:GetService("HttpService"):GenerateGUID()
	local _round = _module.new(self, {

		GameId = _roundid,
		Players = self:_getPlaying(),

		Map = _map,
	})

	return _round
end

function GameService:_getMap()
	if not self.Map then
		warn("No map has been loaded")
		return false
	end
	return self.Map
end

function GameService:_canPlay()
	local _playing = Utility:CountTable(self.Players, { Enabled = true })

	print("Amount playing:", _playing)

	return (_playing >= self._amountNeededPerRound) -- Add to this conditional as needed.
end

---------------------------
-- --------------------- --
-- // CLIENT  METHODS \\ --
-- --------------------- --
---------------------------

function GameService.Client:CheckInProgress()
	return self.Server._roundInProgress
end

function GameService.Client:CountdownComplete(Player)
	self.Server._currentRound._countdownSignal:Fire(Player)
end

-- -------------------- --
-- // PUBLIC METHODS \\ --
-- -------------------- --

-- Ease of use player search function. Can search with the player object, player name, player userid.
function GameService:GetPlayer(_search)
	local _player

	-- USERDATA SEARCH
	if type(_search) == "userdata" then
		_player = self.Players[_search.userId]
	end

	-- NAME SEARCH
	if type(_search) == "string" then
		-- This one's heavy so it probably won't be used unless for specific things  (Terminal)
		for _, playerobject in pairs(self.Players) do
			if playerobject.Player.Name:lower() == _search:lower() then
				_player = playerobject
			end
		end
	end

	-- USERID SEARCH
	if type(_search) == "number" then
		_player = self.Players[_search]
	end

	return _player
end

function GameService:Round(_loopBypass)
	-- Player check. If not, pass through.
	self._break = not self:_canPlay() -- not self:_canPlay()

	warn("Round check:", self._break)

	local _passCheck = false

	if not self._break and not _loopBypass then
		if not self._inSession then
			self._inSession = true
		end
		_passCheck = true

		-- LOAD MAP
		local _map = self.Modules.Map.new(false, self:_getPlaying(), math.random(1, 3)) -- map id, players, difficulty
		self.Map = _map

		print("Map loaded:", _map)
		-- LOAD ROUND
		local _round = self:_getRound()
		self._currentRound = _round

		print("Round loaded:", _round)
		-- PLAY ROUND

		_round:Play()
	end

	if not _passCheck then
		wait(2)
		GameService:Round()
	end
end

function GameService:KnitStart()
	-- Aggregate round types
	for _, round in pairs(script:GetChildren()) do
		GameService.Rounds[round.Name] = require(round)
	end

	self._roundOver = Signal.new()
	self._roundOver:Connect(function()
		task.wait(3)
		self:Round()
	end)

	self:Round()
end

function GameService:KnitInit() end

return GameService
