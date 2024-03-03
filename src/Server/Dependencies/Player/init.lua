-- Player
-- @ocula
-- July 4, 2021

--[[ 

How saving should work.

-->
		Ingredients = { -- individually serialize these
			[Ingredient Name] = [-1 > infinite], [0-999 amount in inventory],

			--> IngredientsService will manage overhead permissions for ingredients. 
			--> In order to allow for disabling of ingredients from an upper-level manager. 
		}, 

		Building = { -- and then we'll serialize this into it's own compacted bin. 
			[Set Piece Name] = [-1 > infinite], [0-999 amount in inventory]

			--> BuildService will have access over deactivating certain build pieces and whatnot.
			--> If for example we needed to deactivate a piece because of an error published in an update
			--> we can disable it using the set piece's name in BuildService.
		},
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Promise = require(Knit.Library.Promise)
local Signal = require(Knit.Library.Signal)
local Utility = require(Knit.Library.Utility)
local Maid = require(Knit.Library.Maid)

local Player = {}
Player.__index = Player

function Player.new(_player, _profile)
	assert(_profile, "No player profile provided. Exiting.")

	local BuildService = Knit.GetService("BuildService")
	-- deconstruct profile saves first

	local self = setmetatable({ -- TODO: reorganize this so its easier to read
		-- Profile Data
		Player = _player,
		Lobby = false,

		Cash = _profile.Data.Cash,
		Diamonds = _profile.Data.Diamonds,

		TrackedData = _profile.Data.Data_Tracking,

		Image = Players:GetUserThumbnailAsync(
			_player.UserId,
			Enum.ThumbnailType.AvatarBust,
			Enum.ThumbnailSize.Size180x180
		),

		Inventory = nil,
		Ingredients = nil,
		Pizzerias = nil,

		Permissions = _profile.Data.Permissions,
		Bin = _profile.Data.Bin,
		Zone = nil,

		PaymentHistory = {},

		Humanoid = {
			WalkSpeed = 24,
		},

		PropertyChangedSignal = Signal.new(),
		Leaving = Signal.new(),
		Died = Signal.new(),
		BinUpdated = Signal.new(),

		RankChanged = Signal.new(),
		ExperienceChanged = Signal.new(),
		CornChanged = Signal.new(),

		Debounce = false,

		-- Private Properties / Events
		_disableEvents = false,
		_sessionId = "",
		_maid = Maid.new(),
		_characterAdded = Signal.new(),
		_profile = _profile.Data, -- avoid cyclic data
	}, Player)

	-- Iterate through saves
	self:Load()

	self._maid:GiveTask(_player.CharacterAdded:Connect(function(char)
		self._characterAdded:Fire(char)
	end))

	local testinginventory = self:GetTestingInventory()
	--self.Inventory = {}--testinginventory

	-- Update Inventory
	BuildService.Client.UpdateInventory:Fire(_player, self.Inventory)

	self._maid:GiveTask(self.Leaving:Connect(function()
		for i, v in pairs(BuildService.Sandboxes) do
			if v:isOwner(self.Player) then
				v:RemoveOwner(self)
				--TODO: check if any other owners are left and release the sandbox profile.
			end
		end

		self:Save()

		if _profile then
			_profile:Release()
		end

		self._maid:DoCleaning()
	end))

	self._maid:GiveTask(self.Died:Connect(function()
		self:SetDebounce(false)
	end))

	-- Data tracking
	self.TrackedData.Dev.Last_Played = os.date()

	return self
end

function Player:GetSaveIndex()
	return self.Game.SaveIndex
end

function Player:AddBin(input, amount)
	if not self.Bin[input] then
		self.Bin[input] = amount

		self.BinUpdated:Fire()
		return
	end

	self.Bin[input] += amount
	self.BinUpdated:Fire()
end

function Player:CollectBin()
	for input, amount in self.Bin do
		if self[input] then
			if input == "Corn" then
				self:Give("Corn", amount)

				self.Bin[input] = 0
				self.BinUpdated:Fire()
			end
		end
	end
end

function Player:Load()
	local Versions = self._profile.Versions
	local Serializers = Knit.Modules.Serializers

	print("Loading:", self._profile.Inventory)

	local Inventory = require(Serializers.Inventory).deserialize(Versions.Inventory, self._profile.Inventory)

	-- now load <3

	self.Inventory = Inventory

	print("Inventory:", self.Inventory)
end

function Player:Save()
	local Serializers = Knit.Modules.Serializers

	local Version, Inventory = require(Serializers.Inventory).serialize(self.Inventory)

	self._profile.Inventory = Inventory
	self._profile.Versions.Inventory = Version

	print("Player saved!")
end

function Player:GetTestingInventory()
	--[[
	local Inventory = {}
	local strings = {}

	local Assets = ReplicatedStorage.Storage.Assets.Build

	for i, v in Assets:GetChildren() do
		local newStringHeader = v.Name:lower()
		for _, object in v:GetChildren() do
			for _, childobjects in object:GetChildren() do
				table.insert(strings, newStringHeader .. ":" .. object.Name .. ":" .. childobjects.Name:lower())
			end
		end
	end

	for i, v in strings do
		table.insert(Inventory, {
			ItemId = v,
			Type = "build", 
			Amount = 10,
		})
	end
--]]
	return {}
end

function Player:findInInventory(itemId)
	for inventoryIndex, inventoryData in pairs(self.Inventory) do
		if inventoryData.ItemId:lower() == itemId:lower() then
			return inventoryData, inventoryIndex
		end
	end
end

function Player:isInDebounce()
	return self.Debounce
end

function Player:SetDebounce(bool: boolvalue)
	self.Debounce = bool
end

function Player:AddItem(itemId: string, amount: number)
	local InventoryData, Index = self:findInInventory(itemId)
	local BuildService = Knit.GetService("BuildService")

	if InventoryData then
		InventoryData.Amount += amount or 1
	else
		table.insert(self.Inventory, {
			ItemId = itemId,
			Amount = amount or 1,
		})
	end

	BuildService.Client.UpdateInventory:Fire(self.Player, self.Inventory)
end

function Player:BuyInGameItem(ItemId: string, Amount: number)
	local ItemIndexService = Knit.GetService("ItemIndexService")
	local Item = ItemIndexService:Search(ItemId) -- these are the only things for sale... so

	if Item then
		local Price = Item.Price

		if self.Corn >= Price then
			local CornLeft = self.Corn - Price

			self:AddItem(ItemId, Amount or 1)
			self.CornChanged:Fire(CornLeft)

			return true
		else
			return false, "Insufficient funds."
		end
		--local
	end
end

function Player:Give(itemType: string, amount: number?) -- TODO: Security check
	if itemType == "Corn" then
		local current = self.Corn
		local add = current + amount

		self.CornChanged:Fire(add)
	elseif itemType == "Experience" then
		local current = self.Experience
		local add = current + amount

		self.ExperienceChanged:Fire(add)
	end
end

function Player:RemoveItem(itemId: string, amount: number)
	local inventoryData, inventoryIndex = self:findInInventory(itemId)
	local BuildService = Knit.GetService("BuildService")

	if inventoryData then
		inventoryData.Amount -= amount

		if inventoryData.Amount <= 0 then
			table.remove(self.Inventory, inventoryIndex)
		end
	end

	BuildService.Client.UpdateInventory:Fire(self.Player, self.Inventory)
end

function Player:SetControls(enabled: boolean)
	local PlayerService = Knit.GetService("PlayerService")
	PlayerService.Client.SetControls:Fire(self.Player, enabled)

	--self.Player.DevEnableMouseLock = enabled
end

function Player:HasItem(itemId)
	-- only checks if the item exists in the inventory
	local check = self:findInInventory(itemId)
	return check ~= nil, if check then check.Amount else nil
end

function Player:CheckPermission(permissionIndex)
	return self.Permissions[permissionIndex]
end

function Player:GetInventory()
	return self.Inventory
end

function Player:GetDataTracked()
	return self.TrackedData
end

function Player:SetZone(Zone)
	if self.Zone == Zone then
		return
	end

	self.Zone = Zone

	local ZoneService = Knit.GetService("ZoneService")
	ZoneService.Client.Update:Fire(self.Player, Zone)

	warn("Player is now in: ", Zone)
end

function Player:Move(positionTo: Vector3, isYield: bool?, positionFrom: Vector3?) -- use pathfinding
	local character = self.Player.Character

	if character then
		local Humanoid = character:FindFirstChild("Humanoid")
		local HumRoot = Utility:GetHumanoidRootPart(self.Player)

		if Humanoid.Health > 0 and HumRoot then
			local Path = require(Knit.Modules.Path).new(positionFrom or HumRoot.Position, positionTo, {
				AgentHeight = 1,
				AgentCanJump = true,
				AgentRadius = HumRoot.Size.Z / 2,
				AgentCanClimb = true,
			})

			local _finished = false

			local ConnectFinish = Path.Finished:Connect(function()
				_finished = true
			end)

			Path:Grab(Humanoid, 1)

			if isYield then
				repeat
					task.wait()
				until _finished

				ConnectFinish:Disconnect()
				Path:Destroy()
			end
		end
	end
end

function Player:GetSaveData(slotId)
	warn("Searching save data:", self.Game.Saves)
	for _, v in self.Game.Saves do
		if v.Slot == slotId then
			return table.clone(v) -- we want to keep from editing this data
		end
	end
end

function Player:ReplaceSave(slotId, newData)
	for i, v in self.Game.Saves do
		if v.Slot == slotId then
			for newIndex, newValue in newData do
				v[newIndex] = newValue
			end
		end
	end
end

function Player:SendFloorData(floorData)
	local BuildService = Knit.GetService("BuildService")
	BuildService.Client.UpdateFloors:Fire(self.Player, floorData)
end

function Player:SetSandbox(newSandbox)
	local BuildService = Knit.GetService("BuildService")

	local Sandbox = if BuildService.Sandboxes[newSandbox] then BuildService.Sandboxes[newSandbox]:Package() else nil

	self.Sandbox = newSandbox

	BuildService.Client.UpdateSandbox:Fire(self.Player, self.Sandbox, Sandbox)
end

function Player:GetOwnedSandbox()
	local _owned = self._ownedSandbox
	local BuildService = Knit.GetService("BuildService")

	return BuildService:GetSandbox(_owned)
end

function Player:GetSandbox()
	return self.Sandbox
end

-- Disables all Player Events on the Player. Important for when we have no player character on purpose.
function Player:Disable()
	self._disableEvents = true
end

function Player:Enable()
	self._disableEvents = false
end

function Player:SetJumpHeight(num)
	self.Humanoid.JumpHeight = num -- Set this on the server so any time our player Humanoid regenerates, we have the value saved.

	local char = self.Player.Character

	if char then
		local hum = char:FindFirstChild("Humanoid")
		if hum then
			hum.JumpHeight = num
			warn("Setting JumpHeight of", self.Player, "to", hum.JumpHeight)
		end
	end
end

function Player:SetCameraState(...)
	local GameService = Knit.GetService("GameService")
	GameService.Client.SetCameraState:Fire(self.Player, ...)
end

function Player:connectCharacterEvents(player)
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")

		for property, value in pairs(self.Humanoid) do
			humanoid[property] = value
		end

		humanoid.Died:Connect(function()
			self.Died:Fire()

			if self._disableEvents then
				return
			end

			self.Player.Character = nil

			task.spawn(function()
				self:Spawn()
			end)
		end)
	end
end

function Player:SetSpawn(spawn)
	if type(spawn) == "userdata" then
		local SpawnService = Knit.GetService("SpawnService")
		spawn = SpawnService:GetSpawn(spawn)
	end

	self._activeSpawn = spawn
end

function Player:Spawn()
	if not self.Player.Character then
		self.Player:LoadCharacter()
		self:connectCharacterEvents(self.Player)
	end

	local SpawnService = Knit.GetService("SpawnService")

	if not self._activeSpawn then
		SpawnService:LobbySpawn(self.Player)

		if not self.Lobby then
			self.Lobby = true
			self.PropertyChangedSignal:Fire("Lobby", true)
		end
	else
		self._activeSpawn:Teleport(self)
	end
end

function Player:Kick()
	self.Player:Kick()
end

function Player:Reset() end

return Player
