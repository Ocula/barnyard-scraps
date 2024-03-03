local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(Knit.Library.Maid)
local Signal = require(Knit.Library.Signal)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs =
	Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup =
	Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Interface = require(Knit.Modules.Interface.get)
local Highlight = require(Knit.Library.Highlight)
local QuickIndex = require(Knit.Library.QuickIndex)

local Place = {}
Place.__index = Place

function Place.new()
	local self = setmetatable({
		Object = nil, -- object that will always be used for updating.
		ItemSelected = "", -- itemid
		Rotate = 0, -- rotation of the current object

		Floors = {},
		Grids = {},

		Highlight = Highlight.new(),

		Twist = Value(0),

		_loadedPlace = CFrame.new(),
		_offset = CFrame.new(0, -0.5, 0),

		_placeSize = Vector3.new(5, 5, 5),
		_yOffset = Value(2),

		_input = "Mouse",

		_setPreview = Signal.new(),
		_currentFloor = nil,
		_currentSandbox = "",
		_active = false,
		_InactiveMaid = Maid.new(), -- cleans up front end things
		_Maid = Maid.new(),
	}, Place)

	self.YSpring = Spring(self._yOffset, 20, 0.6)
	self.TwistSpring = Spring(self.Twist, 20, 0.5)

	local UserInput = Knit.GetController("UserInput")
	local InterfaceController = Knit.GetController("Interface")

	local Preferred = InterfaceController.Input

	self._input = Computed(function(Use)
		return {
			Preferred = Use(Preferred),
			Mouse = UserInput:hasMouse(),
			Keybaord = UserInput:hasKeyboard(),
			Touch = UserInput:isTouch(),
		}
	end)

	self._rayParams = RaycastParams.new()
	self._rayParams.FilterType = Enum.RaycastFilterType.Include

	self.Highlight:SetTheme("Place")

	self._setPreview:Connect(function(itemId)
		self:Show(itemId)
	end)

	return self
end

function Place:SetGrid(floorId)
	self.Grid = self.Grids[floorId]
end

function Place:UpdateGrid(mousePosition)
	if self.Grid then
		self.Grid:Show(mousePosition, self._placeSize)
	end
end

function Place:GetMousePosition(): Vector3
	local userinput = Knit.GetController("UserInput")
	local mouse = userinput:Get("Mouse")
	--local playerMouse = game.Players.LocalPlayer:GetMouse()

	local hit = mouse:Raycast(self._rayParams, 256)

	--if hit or playerMouse.Hit then
	if hit and hit.Instance then
		self._currentFloor = self.Floors[hit.Instance]
		self.currentMousePosition = hit.Position

		self:SetGrid(self._currentFloor.GUID)

		--checkforinset.CFrame = CFrame.new(self.currentMousePosition or Vector3.new())

		return self.currentMousePosition, hit.Instance
	end
	--end

	return self.currentMousePosition
end

function Place:Snap(object, pos): CFrame
	if not self._currentFloor then
		return
	end
	-- use other method to get info about the surface
	local cf, size = self._currentFloor.Canvas.CFrame, self._currentFloor.Canvas.Size

	local model = object

	-- rotate the size so that we can properly constrain to the surface
	local transformSize = Vector3.new(model.PrimaryPart.Size.X, 0, model.PrimaryPart.Size.Z)
	local modelSize = CFrame.fromEulerAnglesYXZ(0, self.Rotate, 0) * transformSize
	modelSize = Vector3.new(math.abs(modelSize.X), 0, math.abs(modelSize.Z))

	-- get the position relative to the surface's CFrame
	local lpos = cf:pointToObjectSpace(pos)
	-- the max bounds the model can be from the surface's center
	local size2 = (size - Vector2.new(modelSize.x, modelSize.z)) / 2

	-- constrain the position using size2
	local x = math.clamp(lpos.X, -size2.X, size2.X)
	local y = math.clamp(lpos.Y, -size2.Y, size2.Y)

	local g = self._currentFloor.GridUnit

	if g > 0 then
		x = math.sign(x) * ((math.abs(x) - math.abs(x) % g) + (size2.x % g))
		y = math.sign(y) * ((math.abs(y) - math.abs(y) % g) + (size2.y % g))
	end

	-- create and return the CFrame
	return cf * CFrame.new(x, y, -modelSize.y / 2) * CFrame.Angles(-math.pi / 2, self.Rotate, 0) -- -modelSize.y will always subtract the primarypart (base)
end

function Place:LooseSnap(object, pos): CFrame
	if not self._currentFloor then
		return
	end
	-- use other method to get info about the surface
	local cf, size = self._currentFloor.Canvas.CFrame, self._currentFloor.Canvas.Size

	local model = object

	-- rotate the size so that we can properly constrain to the surface
	local transformSize = Vector3.new(model.PrimaryPart.Size.X, 0, model.PrimaryPart.Size.Z)
	local modelSize = CFrame.fromEulerAnglesYXZ(0, self.Rotate, 0) * transformSize
	modelSize = Vector3.new(math.abs(modelSize.X), 0, math.abs(modelSize.Z))

	-- get the position relative to the surface's CFrame
	local lpos = cf:pointToObjectSpace(pos)
	-- the max bounds the model can be from the surface's center
	local size2 = (size - Vector2.new(modelSize.x, modelSize.z)) / 2

	-- constrain the position using size2
	local x = math.clamp(lpos.X, -size2.X, size2.X)
	local y = math.clamp(lpos.Y, -size2.Y, size2.Y)

	local g = self._currentFloor.GridUnit / 24

	if g > 0 then
		x = math.sign(x) * ((math.abs(x) - math.abs(x) % g) + (size2.x % g))
		y = math.sign(y) * ((math.abs(y) - math.abs(y) % g) + (size2.y % g))
	end

	-- create and return the CFrame
	return cf * CFrame.new(x, y, -modelSize.y / 2) * CFrame.Angles(-math.pi / 2, self.Rotate, 0) -- -modelSize.y will always subtract the primarypart (base)
end

function Place:Clean(object)
	if object.PrimaryPart then
		object.PrimaryPart.Transparency = 1
	end

	for i, v in object:GetChildren() do
		if CollectionService:HasTag(v, "CollisionPart") or v.Name == "CollisionPart" then
			v:Destroy()
		end
	end
end

function Place:Show(itemId: string)
	warn("ItemId:", itemId)

	if self.Object then
		self.Object:Destroy()
	end

	local objectCheck = QuickIndex:GetBuild(itemId)

	if objectCheck then
		local newObject = objectCheck.Object:Clone()

		warn("Showing @ 203:", itemId)

		self:Clean(newObject)

		if newObject.PrimaryPart == nil then
			newObject:SetAttribute("Preview", true)
			newObject.Parent = workspace.game.client.fix

			warn("PrimaryPart missing on model.")

			return
		end

		newObject:SetPrimaryPartCFrame(self._loadedPlace)
		newObject.Parent = workspace.game.client.bin

		self._placeSize = newObject:GetExtentsSize()

		self.Highlight:Select(newObject)
		self.Object = newObject

		self._InactiveMaid:GiveTask(self.Object)

		return newObject
	else
		warn("No object found...", objectCheck)
	end
end

function Place:Request()
	if self._currentFloor and self.Object then
		local selectionId = self.ItemSelected

		if selectionId and #selectionId > 0 then
			local BuildService = Knit.GetService("BuildService")
			BuildService:RequestUpdate("Place", selectionId, self._loadedPlace):andThen(function(success, reason)
				if not success then
					if reason == "Collision" then
						self.Highlight:Flash(Color3.new(1, 0, 0), 3, 1)
					end
					--TODO: play sound effect
				else
					self._yOffset:set(0)
					self.YSpring:addVelocity(-1)

					task.delay(0.25, function()
						self._yOffset:set(2)
						self.YSpring:addVelocity(2)
					end)
				end
			end)
		end
	end
end

function Place:Place(itemId, cf, objectId, config)
	local GetItem = QuickIndex:GetBuild(itemId)

	if GetItem then
		local Object = GetItem.Object:Clone()

		self:Clean(Object)

		if Object.PrimaryPart == nil then
			warn("[1] We couldn't find a primary part for:", Object:GetFullName())
			Object.Parent = workspace.game.client.fix
			return
		end

		Object:SetPrimaryPartCFrame(cf)

		Object:SetAttribute("ID", objectId)
		Object:SetAttribute("ItemId", itemId)

		self.Highlight:Flash(Color3.new(0, 1, 1), 1, 0.25, 0.1)

		for i, v in pairs(config) do
			for index, object in Object:GetChildren() do
				if object:GetAttribute("_config") == v.Reference then
					object.Transparency = v.Transparency
					object.Color = v.Color
					object.CFrame *= CFrame.Angles(0, math.rad(v.Rotation), 0)

					object:SetAttribute("Rotate", v.Rotation)
				end
			end
		end

		Object.Parent = workspace.game.client.bin -- so we don't index it into collectionservice too late

		return Object
	end
end

function guiCheck(ancestor, guis)
	for i, v in pairs(guis) do
		if v:isDescendantOf(ancestor) then
			return true
		end
	end
end

function Place:SetInput()
	local UserInput = Knit.GetController("UserInput")
	local InterfaceController = Knit.GetController("Interface")
	local Inventory = InterfaceController.Game.Menus.Inventory

	-- Mouse
	local Mouse = UserInput:Get("Mouse")

	self._InactiveMaid:GiveTask(Mouse.LeftDown:Connect(function(processed, guis)
		if processed then
			return
		end

		if #guis > 0 then
			if guiCheck(Inventory.Object, guis) then
				return
			end
		end

		if not Inventory:isVisible() then
			return
		end
		if Peek(self._input).Preferred == "Touch" then
			return
		end

		if self.Object then
			self:Request()
		end
	end))

	-- Touch
	local Touch = UserInput:Get("Mobile")

	self._InactiveMaid:GiveTask(Touch.TouchTapInWorld:Connect(function(position, processed)
		if not Inventory:isVisible() then
			return
		end
		if processed then
			return
		end

		local RaycastResult = Touch:Raycast(position, 256, self._rayParams)

		if RaycastResult then
			self.touchCFrame = RaycastResult.Position
		end
		--[[
        if self.Object then 
            self:Request() 
        end--]]
	end)) --]]

	-- Keyboard
	local Keyboard = UserInput:Get("Keyboard")

	self._InactiveMaid:GiveTask(Keyboard.KeyDown:Connect(function(key, processed)
		if not Inventory:isVisible() then
			return
		end

		if processed then
			return
		end
		if not self._active then
			return
		end

		if key == Enum.KeyCode.R then
			self.Rotate += math.pi / 2
		elseif key == Enum.KeyCode.T then
			self.Rotate -= math.pi / 2
		end
	end))
end

function Place:Update(object, forceLoad)
	if not self._active and not forceLoad then
		return
	end

	if object ~= nil and object:isDescendantOf(workspace) then
		local input = Peek(self._input)

		if input.Preferred ~= "Touch" and input.Mouse == true then
			local mousePos = self:GetMousePosition()

			if mousePos then
				local snap = self:Snap(object, mousePos)
				local twistCF = CFrame.Angles(math.rad(45), 0, math.rad(45))
					:lerp(CFrame.Angles(0, 0, 0), Peek(self.TwistSpring))

				if not self.LastSnap then
					self.LastSnap = snap
					self.Twist:set(0)

					if Peek(self.TwistSpring) > 0.3 then
						self.TwistSpring:setPosition(0)
					end

					self.Twist:set(1)
				else
					if self.LastSnap ~= snap then
						self.LastSnap = snap
						self.Twist:set(0)

						if Peek(self.TwistSpring) > 0.3 then
							self.TwistSpring:setPosition(0)
						end

						self.Twist:set(1)
					end
				end
				--local lerp = object.PrimaryPart.CFrame

				if snap then
					local toCF = snap * self._offset
					local lerp =
						object.PrimaryPart.CFrame:lerp(snap * self._offset * CFrame.new(0, Peek(self.YSpring), 0), 0.2)

					self._loadedPlace = toCF
					object:SetPrimaryPartCFrame(lerp:Lerp(toCF * twistCF, 0.2))

					self:UpdateGrid(toCF)
				end
			end
		else
			local player = game.Players.LocalPlayer

			if player.Character then
				local HRP = player.Character:FindFirstChild("HRP")

				if HRP then
					local cf = (self.touchCFrame or HRP.CFrame) * CFrame.new(0, 0, 5)
					local snap = self:Snap(object, cf.p)
					local lerp = object.PrimaryPart.CFrame

					if snap then
						local toCF = snap * self._offset

						self._loadedPlace = toCF
						object:SetPrimaryPartCFrame(lerp:Lerp(toCF, 0.2))
					end
				end
			end
		end
	end
end

function Place:Enable()
	if self._active == false then
		self._active = true
		warn("Enabled")
		-- bring loaded place closer
		local player = game.Players.LocalPlayer

		if player then
			local char = player.Character

			if char then
				local hrp = char:FindFirstChild("HumanoidRootPart")

				if hrp then
					self._loadedPlace = hrp.CFrame * CFrame.new(5, 0, 0)
				end
			end
		end

		self:SetInput()

		game:GetService("RunService"):BindToRenderStep("Place Update", Enum.RenderPriority.Last.Value - 1, function(dt)
			self:Update(self.Object)
		end)

		if self.ItemSelected then
			self:Show(self.ItemSelected)
		end
	end
end

function Place:Disable()
	if self._active == true then
		self._active = false

		game:GetService("RunService"):UnbindFromRenderStep("Place Update")

		if self.Grid then
			self.Grid:Hide()
		end

		self._InactiveMaid:DoCleaning()
	end
end

function Place:Destroy()
	self._Maid:DoCleaning()
end

function Place.Reconcile(from, to)
	for i, v in pairs(from) do
		to[i] = v
	end

	return to
end

function Place.Init()
	local self = Place.new()

	-- self.
	local InterfaceController = Knit.GetController("Interface")

	InterfaceController.BuildComplete:Wait()
	--[[
    InterfaceController.Game.Menus.Inventory.Request:Connect(function(ItemId)
        self.ItemSelected = ItemId 
    end) --]]

	-- collisioncheck remover for serverside collisionparts

	local collisionCheck = CollectionService:GetInstanceAddedSignal("CollisionPart")

	collisionCheck:Connect(function(_collision)
		task.wait()
		if _collision:isDescendantOf(workspace) then
			_collision:Destroy()
		end
	end)

	for i, v in pairs(CollectionService:GetTagged("CollisionPart")) do
		if v:isDescendantOf(workspace) then
			v:Destroy()
		end
	end

	return self
end

return Place
