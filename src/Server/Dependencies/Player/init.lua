-- Player
-- @ocula
-- July 4, 2021

--[[ 

How saving should work.

--> Player:save() --> Apply Save Data in Player.Game to the Player's Profile. 

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
	local PlayerService = Knit.GetService("PlayerService") 
	local ExperienceService = Knit.GetService("ExperienceService") 

	-- deconstruct profile saves first

	local self = setmetatable({-- TODO: reorganize this so its easier to read

		-- Profile Data

		Player 					= _player,
		Lobby 					= false,

		Corn 					= _profile.Data.Corn, 
		Experience				= _profile.Data.Experience, 
		Rank					= ExperienceService:GetRankName(_profile.Data.Experience), 

		Image 					= Players:GetUserThumbnailAsync(
									_player.UserId,
									Enum.ThumbnailType.AvatarBust,
									Enum.ThumbnailSize.Size180x180
								),
		Inventory 				= {},

		Permissions				= _profile.Data.Permissions, 
		Bin						= _profile.Data.Bin, 
		Zone 					= nil, 

		PaymentHistory			= {
			-- store all payment stuff here? just so we know how much each player is buying
			-- we can also push this to 3rd party cloud software for game analytics
		},

		Humanoid 				= {
			WalkSpeed = 32, 
		},

		Game 					= {
			Saves 				= {}, 
			SaveIndex			= _profile.Data.SaveIndex, 
		},

		Homes					= {
			Index				= _profile.Data.Homes.Index, 
			Data				= {

			}
		}, 

		PropertyChangedSignal 	= Signal.new(),
		Leaving 				= Signal.new(),
		Died					= Signal.new(),
		BinUpdated				= Signal.new(), 
		
		RankChanged				= Signal.new(),
		ExperienceChanged		= Signal.new(),
		CornChanged				= Signal.new(), 


		Debounce 				= false, 

		-- Private Properties / Events 
		_disableEvents 			= false,
		_sessionId 				= "",
		_maid 					= Maid.new(),
		_characterAdded 		= Signal.new(), 
        _profile                = _profile.Data, -- avoid cyclic data 

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

	-- if players die in a tunnel, we wanna make sure this gets reconciled.
	-- we can have different use cases later.
	self._maid:GiveTask(self.Died:Connect(function()
		self:SetDebounce(false) 
	end)) 

	self._maid:GiveTask(self.RankChanged:Connect(function()
		local newRank = ExperienceService:GetRankName(self.Experience) 

		PlayerService.Client.Update:Fire(_player, "Data", {
			Rank = newRank
		}) 

		self.Rank = newRank
	end))

	self._maid:GiveTask(self.ExperienceChanged:Connect(function(newExperience)
		local current 			= self.Experience

		local rank, upperLimit 	= ExperienceService:GetRank(current) 
		local expNext 			= ExperienceService:GetExperience(rank + 1) 
		local expLast 			= ExperienceService:GetExperience(rank) 

		if upperLimit then 
			--warn("Upper Limit hit", newExperience)
			self.Experience = expLast
			self._profile.Experience = expLast 

			PlayerService.Client.Update:Fire(_player, "Data", {
				Experience = 1, 
				Max = upperLimit,
			}) 

			self.RankChanged:Fire()
			return 
		end 

		if newExperience >= expNext then
			rank, upperLimit = ExperienceService:GetRank(newExperience)

			--warn("Rank up!", rank, newExperience, expNext, expLast) 

			if not upperLimit then
				expLast = expNext 
				expNext = ExperienceService:GetExperience(rank + 1) 
			end 
		end 

		local expTotal = expNext - expLast
		local expNormalized = newExperience - expLast 

		local expNeeded = expTotal - expNormalized
		local expDifference = expTotal - expNeeded 

		local clampedToOne = expDifference / expTotal

		if upperLimit then 
			clampedToOne = 1 
		end 

		PlayerService.Client.Update:Fire(_player, "Data", {
			Experience = clampedToOne, 
			Max = upperLimit,
		}) 

		self.Experience = newExperience 
		self._profile.Experience = newExperience 

		self.RankChanged:Fire()
	end))

	self._maid:GiveTask(self.CornChanged:Connect(function(newCorn)
		PlayerService.Client.Update:Fire(_player, "Data", {
			Corn = newCorn, 
		}) 

		self.Corn = newCorn
		self._profile.Corn = newCorn  
	end))

	self._maid:GiveTask(self.BinUpdated:Connect(function()
		PlayerService.Client.UpdateBin:Fire(self.Player, self.Bin) 
	end))

	--[[self._maid:GiveTask(self.InventoryUpdated:Connect(function()
		local Inventory = self.Inventory 
		PlayerService.Client.Update:Fire(_player, "Inventory", Inventory)
	end))--]]

	self.ExperienceChanged:Fire(self.Experience)
	self.CornChanged:Fire(self.Corn) 
	self.BinUpdated:Fire() 

	--[[
	PlayerService.Client.Update:Fire(_player, "Data", {
		Corn = self.Corn, 
		Experience = self.Experience, 
		Rank = self.Rank, 
	})--]]

    --warn("New player:", self)

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

function Player:Load() -- update to a versioning system of all save data so that when we deserialize, 
	-- we deserialize correctly and then convert data over to our new format! 
	local versions = self._profile.Versions 

	local saves = require(Knit.Modules.Serializers.Saves).deserialize(versions.Saves, self._profile.Saves) 
	local inventory = require(Knit.Modules.Serializers.Inventory).deserialize(versions.Inventory, self._profile.Inventory) 
	local homes = require(Knit.Modules.Serializers.Home).deserialize(versions.Homes, self._profile.Homes.Data) 

	if saves then 
		--warn("Saves loaded:", saves) 
		self.Game.Saves = saves 
	end

	if inventory then 
		--warn("Inventory loaded:", inventory) 
		self.Inventory = inventory 
	end 

	if homes then 
		--warn("Homes loaded:", homes) 
		self.Homes.Data = homes 
		self.Homes.Index = self._profile.Homes.Index 

		--
		warn("Loading previously loaded save:", homes)
	end 
end

function Player:Save() -- get current owned sandboxes (that are active) and save them. 
    local _ownedSandbox = self:GetOwnedSandbox() 
	if _ownedSandbox then 
		_ownedSandbox:Save()
	end 

	-- gamepasses / permissions
	for i, v in pairs(self.Permissions) do 
		self._profile.Permissions[i] = v 
	end

	-- saves
	local SavesSerializer = require(Knit.Modules.Serializers.Saves) 
	local SavesVersion, SaveData = SavesSerializer.serialize(self.Game.Saves)

	self._profile.Saves = SaveData

	-- that should save the player's sandbox data
	-- now save inventory
	local InventorySerializer = require(Knit.Modules.Serializers.Inventory)
	local InventoryVersion, InventoryData  = InventorySerializer.serialize(self.Inventory) 

	self._profile.Inventory = InventoryData

	-- save home data
	local HomesSerializer = require(Knit.Modules.Serializers.Home) 
	local HomeVersion, HomeData = HomesSerializer.serialize(self.Homes.Data) 

	self._profile.Homes.Data = HomeData 
	self._profile.Homes.Index = self.Homes.Index 

	-- versioning 
	self._profile.Versions.Saves = SavesVersion 
	self._profile.Versions.Inventory = InventoryVersion 
	self._profile.Versions.Homes = HomeVersion 

	-- all data is now saved! 
	warn("Player Data saved:", self._profile) 
end 

function Player:GetTestingInventory()
	local Inventory = {}
	local strings = {}

	local Assets = ReplicatedStorage.Assets.Build

	for i, v in Assets:GetChildren() do 
		local newStringHeader = v.Name:lower()
		for _, object in v:GetChildren() do 
			for _, childobjects in object:GetChildren() do 
				table.insert(strings, newStringHeader..":"..object.Name..":"..childobjects.Name:lower())
			end 
		end 
	end 

	for i, v in strings do 
		table.insert(Inventory, {
			ItemId = v, 
			Amount = 10
		})
	end 

	return Inventory 
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

function Player:SetZone(Zone)
	if self.Zone == Zone then return end 

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
				AgentRadius = HumRoot.Size.Z/2, 
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
