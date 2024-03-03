--[[



]]

local DisableTools = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Binder = require(ReplicatedStorage.Shared.Binder)
local Maid = require(ReplicatedStorage.Shared.Maid)
local Signal = require(ReplicatedStorage.Shared.Signal)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs =
	Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup =
	Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Utility = require(Knit.Library.Utility)

local BuildController = Knit.CreateController({
	Name = "BuildController",
	Inventory = {},
	Active = true,
	Objects = {},
	Tools = {},
	Selected = "",
	SelectedTool = "",

	SelectionChanged = Signal.new(),

	Selection = 1,

	currentMousePosition = Vector3.new(),

	isOwner = false,

	_floorObjects = {},
	_inventoryCount = {},
	_inputConnections = {},

	_setPreview = Signal.new(),

	_input = false,
	_currentFloor = nil,

	_currentSandbox = "",

	_maid = Maid.new(),
	_uiMaid = Maid.new(),
})

function BuildController:CheckToppleData()
	if self.ToppleData then
	end
end

function BuildController:GetObject(objectId: string)
	local sandbox = self.Objects[self._currentSandbox]

	if sandbox then
		return sandbox[objectId]
	else
		return false
	end
end

function BuildController:Place(itemId, cf, objectId, config, _mute)
	if self._currentSandbox == nil then
		return
	end

	local sandbox = self.Objects[self._currentSandbox]

	if not sandbox then
		self.Objects[self._currentSandbox] = {}
		sandbox = self.Objects[self._currentSandbox]
	end

	local object = self.Tools.Place:Place(itemId, cf, objectId, config)
	sandbox[objectId] = object

	if not _mute then
		local Sound = Knit.GetController("Sound")
		Sound:Play("Place")
	end
end

function BuildController:DeleteObject(objectId)
	if self._currentSandbox == nil then
		return
	end
	local sandbox = self.Objects[self._currentSandbox]

	if not sandbox then
		return
	end -- this should never happen for deletion.

	local object = sandbox[objectId]

	object:Destroy()
	sandbox[objectId] = nil

	local Sound = Knit.GetController("Sound")
	Sound:Play("Delete")
end

function BuildController:GetStaticCFrame(ItemId, Reference)
	local QuickIndex = require(Knit.Library.QuickIndex)
	local Build = QuickIndex:GetBuild(ItemId)

	local PrimaryPart = Build.Object.PrimaryPart

	for i, v in Build.Object:GetChildren() do
		local _conf = v:GetAttribute("_config")

		if _conf and _conf == Reference then
			return v.CFrame:ToObjectSpace(PrimaryPart.CFrame)
		end
	end
end

function BuildController:UpdateConfig(objectId, config)
	if self._currentSandbox == nil then
		return
	end
	local sandbox = self.Objects[self._currentSandbox]

	if not sandbox then
		return
	end

	local object = sandbox[objectId]
	local ItemId = object:GetAttribute("ItemId")
	local DominoController = Knit.GetController("DominoController")
	local base = object.PrimaryPart

	for i, v in pairs(object:GetChildren()) do
		local configCheck = v:GetAttribute("_config")

		if configCheck then
			if configCheck == config.Reference then
				local Domino = DominoController:GetDomino(v)

				Domino:Paint(config.Color or Color3.new(1, 1, 1))
				Domino:SetTransparency(config.Transparency or 0)

				--v.Transparency = config.Transparency or v.Transparency
				--v.Color = config.Color or v.Color

				local staticCF = self:GetStaticCFrame(ItemId, configCheck)
				local worldCF = base.CFrame * staticCF:Inverse()

				v.CFrame = worldCF * CFrame.Angles(0, math.rad(config.Rotation or 0), 0)
				v:SetAttribute("Rotate", config.Rotation or 0)

				DominoController:UpdateDomino(v)
				--TODO: add scaling support on this end
			end
		end
	end
end

function BuildController:UpdateObject(objectId, newCF)
	if self._currentSandbox == nil then
		return
	end
	local sandbox = self.Objects[self._currentSandbox]

	if not sandbox then
		return
	end

	local object = sandbox[objectId]
	local DominoController = Knit.GetController("DominoController")

	object:SetPrimaryPartCFrame(newCF)

	for i, v in pairs(object:GetDescendants()) do
		if game:GetService("CollectionService"):HasTag(v, "Domino") then
			DominoController:UpdateDomino(v)
		end
	end
end

function BuildController:isPartParentASet(part)
	local CollectionService = game:GetService("CollectionService")

	if part.Parent:IsA("Model") and CollectionService:HasTag(part.Parent.PrimaryPart, "Base") then -- exclude the actual baseparts i think
		if part.Parent.PrimaryPart == part then
			-- check if its under the base
			-- if so, return false.
			local ypos = self._currentBase.Position.Y + (self._currentBase.Size.Y / 2)
			if part.Position.Y < ypos then
				return false
			end
		end

		return true
	end

	return false
end

function BuildController:FormatInventory(inventoryTable)
	if not inventoryTable then
		inventoryTable = self.Inventory
	end

	local newInventory = {
		Sections = {},
	}

	local QuickIndex = require(Knit.Library.QuickIndex)

	for i, v in inventoryTable do
		local splitString = Utility:SplitString(v.ItemId:lower(), ":")
		local reference = newInventory.Sections[splitString[1]]

		-- section will always be the first one
		if not reference then
			newInventory.Sections[splitString[1]] = {}
			reference = newInventory.Sections[splitString[1]]
		end

		local pageReference = reference[splitString[2]]

		if not pageReference then
			reference[splitString[2]] = {
				Objects = {},
			}

			pageReference = reference[splitString[2]]
		end

		local itemObject = QuickIndex:GetBuild(v.ItemId)

		if itemObject then
			local _newInventoryObject = {
				Object = itemObject.Object:Clone(),
				ItemId = v.ItemId,
				Amount = Value(v.Amount),
			}

			pageReference.Objects[_newInventoryObject.Object.Name] = _newInventoryObject
		end
	end

	return newInventory
end

function BuildController:UpdateSelected(itemId)
	self.Tools.Place.ItemSelected = itemId
	self.Tools.Place._setPreview:Fire(itemId)
end

function BuildController:CountInventory() -- used for testing. just a quick little switch selection
	local _index = 1

	for i, v in pairs(self.Inventory) do
		_index += 1
	end

	self._inventoryCount = _index

	return _index
end

function BuildController:Switch(num: number)
	-- Switch to the next or last object in Inventory
	local InterfaceController = Knit.GetController("Interface")
	local Inventory = InterfaceController.Game.Menus.Inventory

	Inventory:Switch(num)
end

-- Utility Function
function BuildController.Reconcile(from, to)
	for i, v in pairs(from) do
		to[i] = v
	end

	return to
end

function BuildController:ClearObjects(sandboxId)
	local currentObjects = self.Objects[sandboxId]

	local DominoController = Knit.GetController("DominoController")

	if DominoController.Started then
		DominoController.CancelRound:Fire()
		task.wait()
	end

	if currentObjects then
		for i, v in pairs(currentObjects) do
			v:Destroy()
		end

		self.Objects[sandboxId] = {}
	end
end

function BuildController:Clean() -- cleanup any things going on with edit ui
end

function BuildController:SwitchTool(toolName)
	if toolName == self.SelectedTool then
		return
	end

	local _currentTool = self.Tools[self.SelectedTool]

	if _currentTool then
		_currentTool:Disable()
	end

	self.SelectedTool = toolName

	if toolName == nil or toolName == "" then
		return
	end

	local _newTool = self.Tools[toolName]

	_newTool:Enable()
end

function BuildController:CheckInSandbox(sandboxId)
	if not self._currentSandbox then
		return
	end --
	if self._currentSandbox ~= sandboxId then
		return
	end -- these are both just precautions. we shouldn't ever end up triggering them.

	local currentSandbox = self.Objects[self._currentSandbox]

	if not currentSandbox then
		return false
	end

	return true
end

function BuildController:KnitStart()
	--[[
	for i, v in script.Tools:GetChildren() do
		local moduleRequire = require(v)

		if moduleRequire.Init then
			local newTool = moduleRequire.Init()
			self.Tools[v.Name] = newTool
		end
	end

	-- Setup HouseService events / connections
	local HouseService = Knit.GetService("HouseService")

	HouseService.UpdateHomebase:Connect(function(base)
		self.Homebase = base
	end)

	-- Setup BuildService events / connections
	local BuildService = Knit.GetService("BuildService")
	local Grid = require(Knit.Modules.Classes.Grid)

	BuildService.UpdateFloors:Connect(function(floorData)
		local floorId = floorData.Object
		local floorCheck = self.Tools.Place.Floors[floorId]

		if floorCheck then
			self.Reconcile(floorData, floorCheck)
		else
			self.Tools.Place.Floors[floorId] = floorData
			self.Tools.Place.Grids[floorData.GUID] = Grid.new(floorData.Object, floorData.GridUnit)

			-- keep this array unordered, we just need it for a raycast check
			self.Tools.Place._rayParams:AddToFilter({ floorData.Object })
		end
	end)

	BuildService.UpdateInventory:Connect(function(inventoryData)
		self.Inventory = inventoryData

		local Interface = Knit.GetController("Interface")

		if Interface.Game then
			Interface.Game.Menus.Inventory:Process(inventoryData)
		end
	end)

	BuildService.UpdateSandbox:Connect(function(sandboxId, sandbox)
		-- check that the player's loaded
		local GameController = Knit.GetController("GameController")

		if Peek(GameController.isLoading) then
			GameController.Loaded:Wait()
		end

		--warn("Updating sandbox:", sandboxId, sandbox)
		local Interface = Knit.GetController("Interface")

		if Interface.Game == nil then
			return
		end

		if sandbox then
			local userId = tostring(game.Players.LocalPlayer.userId)

			if sandbox.Owners[userId] ~= nil then
				self.isOwner = true
				Interface.Game.HUD.Visibility.Edit:set(true)
			else
				self.isOwner = false
				Interface.Game.HUD.Visibility.Edit:set(false)
			end

			warn("IsOwner:", self.isOwner)
		else
			self.isOwner = false
			Interface.Game.HUD.Visibility.Edit:set(false)
		end

		if self._currentSandbox ~= sandboxId then
			-- Need to throttle this somehow.
			self:ClearObjects(self._currentSandbox)

			self._currentSandbox = sandboxId

			if sandbox then
				self._currentBase = sandbox.Object
				self.ToppleData = sandbox.ToppleData

				local _throttle = 0

				if sandboxId and sandbox then
					if sandbox.Objects then
						for i, v in pairs(sandbox.Objects) do
							_throttle += 1
							local worldCF = sandbox.Object.CFrame * v.CFrame:Inverse()

							self:Place(v.ItemId, worldCF, v.SpecialId, v.Config, true)

							if _throttle % 5 == 0 then
								_throttle = 0
								task.wait()
							end
						end
					end
				end

				local DominoController = Knit.GetController("DominoController")
				DominoController:SetStartingDomino(sandbox.ToppleData.ObjectId, sandbox.ToppleData.Reference)
			else
				self._currentBase = nil
				self.ToppleData = nil
			end
		end
	end)

	--TODO: I know these are all quite redundant events. I need to reorganize them all to be in one streamlined process.
	-- But as of right now, deal with it <3

	BuildService.DeleteObject:Connect(function(sandboxId, objectId)
		if self:CheckInSandbox(sandboxId) then
			self:DeleteObject(objectId)
		end
	end)

	BuildService.UpdateConfig:Connect(function(sandboxId, objectId, config)
		if self:CheckInSandbox(sandboxId) then
			self:UpdateConfig(objectId, config)
		end
	end)

	BuildService.UpdateObject:Connect(function(sandboxId, objectId, newCF)
		if self:CheckInSandbox(sandboxId) then
			self:UpdateObject(objectId, newCF)
		end
	end)

	BuildService.LoadPlacedItem:Connect(function(sandboxId, itemId, cf, objectId, config, mute)
		if not self._currentSandbox then
			return
		end
		if self._currentSandbox ~= sandboxId then
			return
		end

		local currentSandbox = self.Objects[self._currentSandbox]

		if not currentSandbox then
			self.Objects[self._currentSandbox] = {}
		end

		self:Place(itemId, cf, objectId, config, mute)
	end)

	BuildService.LoadStart:Connect(function(sandbox)
		local DominoController = Knit.GetController("DominoController")

		self:ClearObjects(self._currentSandbox)

		self.ToppleData = sandbox.ToppleData
		DominoController:SetStartingDomino(sandbox.ToppleData.ObjectId, sandbox.ToppleData.Reference)

		for i, v in pairs(sandbox.Objects) do
			self:Place(v.ItemId, v.CFrame, v.SpecialId, v.Config, true)
		end
	end)

	BuildService.ManualUpdateSandbox:Connect(
		function(sandboxId, sandbox) -- hard update, should really never ever ever be used unless for debugging purposes.
			if self._currentSandbox == sandboxId then
				self:ClearObjects(self._currentSandbox)
				self._currentBase = sandbox.Object

				self.ToppleData = sandbox.ToppleData

				if sandbox.Objects then
					for i, v in pairs(sandbox.Objects) do
						local worldCF = sandbox.Object.CFrame * v.CFrame:Inverse()

						self:Place(v.ItemId, worldCF, v.SpecialId, v.Config, true)
					end
				end
			end
		end
	)--]]
end

function BuildController:KnitInit() end

return BuildController
