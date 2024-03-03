-- @Ocula
-- December 30, 2022

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Signal = require(Knit.Library.Signal)

print("[SCRAPS] - Setup PlayerService data keys.")

local PlayerService = Knit.CreateService({
	Name = "PlayerService",
	Players = {},
	Client = {
		PlayerLoaded = Knit.CreateSignal(),
		QueueTutorial = Knit.CreateSignal(),
		SetControls = Knit.CreateSignal(),

		Update = Knit.CreateSignal(),
		UpdateBin = Knit.CreateSignal(),
	},

	Profile = {
		Profiles = {},
		Game_Key = "SCRAPS_0.00001",
		Service = require(Knit.Modules.Profile),
		Blank = require(Knit.Modules.Profile.Blank), -- TODO: make sure the blank profile is correct.
	},

	Signals = {
		PlayerAdded = Signal.new(),
	},
})

local TableUtil = require(Knit.Library.TableUtil)

-- Dependencies
local Utility = require(Knit.Library.Utility)
local Player = require(Knit.Modules.Player)

-- PlayerService.Client:GetSaves()

function PlayerService.Client:GetPlayerSaves(player)
	local PlayerObject = self.Server:GetPlayer(player)

	if not PlayerObject then
		repeat
			PlayerObject = self.Server:GetPlayer(player)
			task.wait(0.1)
		until PlayerObject
	end

	return PlayerObject.Game.Saves
end

function PlayerService.Client:GetPlayerInventory(player)
	local PlayerObject = self.Server:GetPlayer(player)

	if PlayerObject then
		return PlayerObject:GetInventory()
	end
end

function PlayerService.Client:RequestBinCollect(player)
	local PlayerObject = self.Server:GetPlayer(player)

	if PlayerObject then
		PlayerObject:CollectBin()
	end
end

function PlayerService:GetPlayerAddedSignal()
	return self.Signals.PlayerAdded
end

function PlayerService:GetAvailablePlayers(_ignoreTransform: boolean?)
	local AvailablePlayers = TableUtil.Filter(self.Players, function(player)
		return player:isInDebounce() == false
	end)

	if not _ignoreTransform then
		local Transform = {}

		for i, v in pairs(AvailablePlayers) do
			table.insert(Transform, v.Player.Character)
		end

		return Transform
	else
		return AvailablePlayers
	end
end

function PlayerService:Save(player)
	local PlayerObject = self:GetPlayer(player)
	PlayerObject:Save()
end

function PlayerService:GetPlayersInLobby()
	local playersToReturn = Utility:FilterTable(self.Players, function(player)
		return player.Lobby
	end)

	return playersToReturn
end

function PlayerService.getProfile(user)
	return PlayerService.Profile.Profiles[user]
end

function PlayerService:new(newPlayer)
	local userId = newPlayer.UserId

	-- Handle profiling
	local loadedProfile = self.Profile.Store:LoadProfileAsync(self.Profile.Game_Key .. "/" .. userId, "ForceLoad")

	if loadedProfile then
		loadedProfile:AddUserId(userId)
		loadedProfile:Reconcile()

		loadedProfile:ListenToRelease(function()
			self.Profile.Profiles[newPlayer] = nil
			newPlayer:Kick(
				"Your account did not load into the game properly. To save your data, you have been kicked. Please rejoin at your earliest convenience!"
			)
		end)

		self.Profile.Profiles[newPlayer] = loadedProfile

		-- Handle player only if profile is loaded.
		local playerObject = Player.new(newPlayer, loadedProfile)

		playerObject._characterAdded:Connect(function(char)
			if char then
				task.wait()

				for i, v in pairs(char:GetDescendants()) do
					if v.ClassName == "MeshPart" or v:IsA("BasePart") then
						v.CollisionGroup = "Players"
					end
				end
			end
		end)

		--warn("Loaded profile", loadedProfile)
		self.Players[newPlayer] = playerObject

		-- Load the client
		self.Client.PlayerLoaded:Fire(newPlayer, true) -- client will communicate the rest of the load in sequence to the server.

		-- Load any other listeners
		self:GetPlayerAddedSignal():Fire(newPlayer)

		-- spawn
		playerObject:Spawn()
	else
		newPlayer:Kick("Your player data could not be loaded correctly. Try rejoining the game!")
	end
end

function PlayerService:GetPlayer(player)
	return self.Players[player]
end

function PlayerService:KnitStart()
	local Players = game:GetService("Players")

	for _, player in pairs(Players:GetPlayers()) do
		self:new(player)
	end

	Players.PlayerAdded:Connect(function(p)
		self:new(p)
	end)

	Players.PlayerRemoving:Connect(function(player)
		local playerObject = self.Players[player]

		if playerObject then
			playerObject.Leaving:Fire()
		else
			self.Profile.Profiles[player] = nil
		end

		self.Players[player] = nil
	end)
end

function PlayerService:KnitInit()
	self.Profile.Store = self.Profile.Service.GetProfileStore(self.Profile.Game_Key, self.Profile.Blank)
end

return PlayerService
