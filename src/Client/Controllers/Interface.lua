local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")

local Knit = require(ReplicatedStorage.Packages.Knit)

local InterfaceUtils = require(Knit.Library.InterfaceUtils)

local Utility = require(Knit.Library.Utility)
local Handler = require(Knit.Modules.Interface.get)
--
local Fusion = require(Knit.Library.Fusion)

local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Signal = require(Knit.Library.Signal)

local Interface = Knit.CreateController({
	Resolution = Vector2.new(1980,1020), -- UI resolution. Everything has been set using 1980 x 1020. The UI system will scale accordingly.
	Scale = 1, -- This can be changed at runtime.
	Name = "Interface",
	serverLoaded = false,
	Loaded = false, 
	Buttons = {},

	Notifications = {
		Upper = nil, -- only one upper notification at a time. 
		Middle = {}, 
		Lower = {}, 
	},

	Mouse = {
		Hover = Value(""), 
		Position = Value(Vector2.new()),
	},

	ViewportSize = Value(workspace.CurrentCamera.ViewportSize),

	BuildComplete = Signal.new(), 

	Input = Value("Keyboard"), 
	Tween = Value(0), 

	CurrentZone = "", 
	
	RelativeCamera = CFrame.new(), 
	CameraFinished = Signal.new(), 

	goalWait = 1.5, -- We dont want the player waiting to load in any longer than 3 seconds.

	_epilepsy = Value(true),
	-- For players with epilepsy. They will be prompted during Load-in on their first visit. Can be changed in settings.
	-- This will wrap any UI calls with a Safety net.
	-- Any running UI can check here
	-- This will mute any flashes. Will not affect gameplay.

	_viewport = Signal.new(), 
	_cameraTween = Signal.new(), 
	_menusLoaded = Signal.new(), 
	_interfaceLoaded = Signal.new(), 

	ZoneChanged = Signal.new(), 

	_menusAreLoaded = false, 
})

local clientBegan

function Interface:Build()
	self.Bin = New "ScreenGui" {
		Name = "Bin",
		Enabled = true, 
		DisplayOrder = 10, 
		IgnoreGuiInset = false, 
		ResetOnSpawn = false, 
		Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") 
	}

	task.spawn(function()
		self.Game = Handler:GetClass("Game").new() -- create new game ui
		self.BuildComplete:Fire() 
	end)
end

function Interface:GetBin()
	if not self.Bin then 
		self.BuildComplete:Wait() 
	end

	return self.Bin 
end 

function Interface:SetMouse()
	local UserInputServ = game:GetService("UserInputService") 
	local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

	local MouseComponent = Handler:GetComponent("Frames/MouseHover")
	local Obj = MouseComponent {
		Text = self.Mouse.Hover,
		Position = self.Mouse.Position
	}

	Obj.Parent = self:GetBin() 

	UserInputServ.InputChanged:Connect(function(input, gameprocessed)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local Position = input.Position 
			local Guis = PlayerGui:GetGuiObjectsAtPosition(Position.X, Position.Y) 

			local Broke = false 

			for i, v in Guis do 
				local Attribute = v:GetAttribute("MouseHover")
				if Attribute then 
					self.Mouse.Hover:set(Attribute)

					Broke = true 

					break
				end 
			end

			if not Broke then 
				self.Mouse.Hover:set("")
			end 

			self.Mouse.Position:set(Position) 
		end
	end)
end 

function Interface:GetViewportRenderSignal()
	return self._viewport 
end 

-- takes in a callback function that will run before the game ui finishes loading
function Interface:Load(callback)
	-- Splash Screen / Loading Bar
	local Load = Handler:GetComponent("Load-screen")
	local LoadObject = Load.new() -- Create new Loading Screen

	-- Aggregate all Assets
	local assets = require(Knit.Library.AssetLibrary):Aggregate()

	local function getCurrentLoadBarPosition()
		local perc = LoadObject:GetLoadingPercentage()
		local amountToGo = 1 - perc

		return (perc + amountToGo / ((math.random((self.goalWait / 2) * 10, (self.goalWait * 10))) / 10))
	end

	ContentProvider:PreloadAsync(assets)

	-- If we haven't loaded on the server yet, give some content to keep it interesting.

	if not self.serverLoaded then
		local _overTime = false
		local _currentTime = os.time()

		repeat
			local _id = "Shake" .. math.random(1, 3)
			LoadObject:Shake(math.random(10, 30) / 10, _id)
			LoadObject:SetLoadingPercentage(getCurrentLoadBarPosition())

			for _ = 0, 1.5, 0.01 do -- special wait so we dont miss the server loading.
				if self.serverLoaded then
					break
				end

				task.wait(0.01)
			end

			if _currentTime - clientBegan > self.goalWait * 2 then
				self.serverLoaded = true
			end

		until self.serverLoaded
	end

	local _currentTime = os.time()
	local _timeLeft = _currentTime - clientBegan

	if _timeLeft < self.goalWait then
		local _timeLeftToWait = self.goalWait - _timeLeft
		local inc = 1.5

		for i = 0, _timeLeftToWait, inc do
			task.wait(1)

			local _id = "Shake" .. math.random(1, 3)
			LoadObject:Shake(math.random(10, 30) / 10, _id)

			if i > (_timeLeftToWait - inc) then
				LoadObject:SetLoadingPercentage(1)
			else
				LoadObject:SetLoadingPercentage(getCurrentLoadBarPosition())
			end
		end
	end

	task.wait(0.1)

	-- Open doors!
	LoadObject:SetLoadingPercentage(1)
	LoadObject:Shake(3)
	LoadObject:SetDoor(0.6)

	if self.Game then 
		self.Game:Render()
	end

	if callback then 
		callback(self) 
	end 

	task.wait(1)

	LoadObject:Hide()

	task.wait(1)

	LoadObject:Destroy()
end

function Interface:CameraSet()
	local Lerp = self.Tween 
	local CamSpring = Spring(Lerp, 5, .7) 

	self.CameraSpring = CamSpring 
	
	local SpringValue = Instance.new("NumberValue") 
	SpringValue.Parent = workspace.CurrentCamera 

	local Component = Hydrate(SpringValue, {
		Value = CamSpring, 
	})

	SpringValue.Changed:Connect(function()
		self._cameraTween:Fire(SpringValue.Value) 
	end) 
end

function Interface:SetTransitions()
	local chicken = Handler:GetClass("Game/Transition").new("Chicken") 

	self.Transitions = {
		Chicken = chicken, 
	} 
end 

function Interface:TweenCamera(From, To)
	if self.CamTween then 
		self.CamTween:Disconnect() 
		self.CamTween = nil 
	end 

	-- reset
	self.Tween:set(0)
	self.CameraSpring:setPosition(0) 

	local Camera = workspace.CurrentCamera 

	self.CamTween = game:GetService("RunService").RenderStepped:Connect(function(dt) 
		Camera.CFrame = From:Lerp(To, Peek(self.CameraSpring)) 

		if Peek(self.CameraSpring) >= 0.999 then 
			self.CameraFinished:Fire() 
			self.CamTween:Disconnect() 
		end 
	end)

	self.Tween:set(1)
end 

function Interface:SetZoneChanged()
	local LoadedZone = nil -- refers to locked/loaded lol. not the actual loaded zone.

	self.ZoneChanged:Connect(function(Zone)
		LoadedZone = Zone 

		warn("Loaded Zone:", LoadedZone)

		if self.CurrentZone ~= Zone and LoadedZone ~= self.CurrentZone then 
			task.delay(.5, function()
				if Zone == LoadedZone and self.CurrentZone ~= Zone then 
					self.CurrentZone = Zone 

					if not self.Loaded then 
						warn("Waiting for load-in:", Zone)
						self._interfaceLoaded:Wait() 
					end 
			
					warn("Updating new zone now:", Zone)
					-- upper notification
					local Notification = Handler:GetClass("Game/Notifications/Zone").new({
						Name = Zone, 
					})
			
					if self.Notifications.Upper then 
						self.Notifications.Upper:Destroy() 
					end 
			
					self.Notifications.Upper = Notification
			
					if self.Notifications.Upper == Notification then 
						Notification:Show() 
					end 
				end 
			end) 
		end 
	end)
end 

function Interface:KnitStart()
	-- Remove health bar stuff
	pcall(function()
		game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health, false) 
	end) 
	
	-- Prep Proximities 
	local ProximityController = Knit.GetController("ProximityController")
	--local SaveObject = 
	--ProximityController:RegisterHook()

	local camera = workspace.CurrentCamera

	camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		local newSize = camera.ViewportSize
		self.ViewportSize:set(newSize) 
	end) 

	self:Build()
	self:Load(function()
		self.Loaded = true 
		self._interfaceLoaded:Fire() 
	end) 

	self.Game.HUD:Toggle(true) 

	-- check for inits 
	for i, v in self.Game.Menus do 
		if v.Init then 
			v:Init() 
		end 
	end

	self:SetMouse()
	-- self.Game:SaveCamera() -- only happens on load in for save screen--]]

	--self.Game:Toggle("Save", true)--]]
	-- select
end

function Interface:KnitInit()
	local userInput = Knit.GetController("UserInput")

	userInput.PreferredChanged:Connect(function()
		local pref = userInput:GetPreferred() -- gets the string version 
		self.Input:set(pref) 
	end)

	-- local events
	self._menusLoaded:Connect(function()
		self._menusAreLoaded = true 
	end)

	local GameController = Knit.GetController("GameController")
	local PlayerController = Knit.GetController("PlayerController") 

	local TunnelService = Knit.GetService("TunnelService") 
	local PlayerService = Knit.GetService("PlayerService") 
	local ZoneService = Knit.GetService("ZoneService") 

	--[[
	RunService:BindToRenderStep("ButtonRender", Enum.RenderPriority.Last.Value, function()
		for i, v in pairs(self.Buttons) do
			v:Render()
		end
	end)--]]

	self:SetTransitions() 
	self:CameraSet() 
	self:SetZoneChanged() 

	GameController.Loaded:Connect(function(bool)
		self.serverLoaded = bool
	end)

	PlayerService.Update:Connect(function(dataType, data)
		if not self.Game then 
			repeat 
				task.wait(.1)
			until self.Game 
		end 

		if dataType == "Data" then 
			for i, v in data do 
				local object = self.Game.HUD.Data[i]
				object:set(v)
			end
		elseif dataType == "Inventory" then 
			self.Game.Menus.Inventory:Process(data) 	
		end
	end)

	ZoneService.Update:Connect(function(zone)
		self.ZoneChanged:Fire(zone) 
	end)

	TunnelService.Transition:Connect(function(inOut, data)
		local StarterGui = game:GetService("StarterGui")

		local chicken = self.Transitions.Chicken  
		local CameraModule = PlayerController:GetCamera()

		if inOut then 
			--[[if data.ToggleInventory then
				self.Game.Menus.Inventory:Toggle(false)
			end--]]
			repeat task.wait() until pcall(StarterGui.SetCore, StarterGui, "ResetButtonCallback", false)
			-- 
			self.Game.HUD:Toggle(false) 

			--CameraModule:SetFirstPerson(false) 

			local Camera = workspace.CurrentCamera 
			Camera.CameraType = "Scriptable" 

			local From = Camera.CFrame -- store this relative player's head 
			local Head = Utility:GetHumanoidRootPart(game.Players.LocalPlayer).Parent:FindFirstChild("Head") 

			if Head then 
				self.RelativeCamera = From:ToObjectSpace(Head.CFrame) 
			end 
			
			local To = CFrame.new((data.Front.CFrame * CFrame.new(0, 5, - 15 - (data.Front.Size.Magnitude/2))).Position, data.Front.Position) 

			self:TweenCamera(From, To) 

			self.CameraFinished:Wait()
			-- 
			chicken:In() 
		else 
			--UserInputService.MouseBehavior = Enum.MouseBehavior.Default 

			local From = CFrame.new((data.Front.CFrame * CFrame.new(0, 5, - 15 - (data.Front.Size.Magnitude/2))).Position, data.Front.Position) 
			local Camera = workspace.CurrentCamera 

			Camera.CFrame = From 

			chicken:Out()

			local To = From * CFrame.new(0,0,data.Front.Size.Magnitude/6) 

			self:TweenCamera(From, To) 

			self.CameraFinished:Wait() 

			self.Game.HUD:Toggle(true) 

			local HumRoot = Utility:GetHumanoidRootPart(game.Players.LocalPlayer)
			
			if HumRoot then 
				local Head = HumRoot.Parent:FindFirstChild("Head") 

				if Head then 
					local lookVector = Head.CFrame.LookVector
					local yRotation = math.atan2(lookVector.Z, lookVector.X) 

					--print(zDot * (math.pi/2)) 

					CameraModule:Reset(Vector2.new(yRotation, math.rad(90))) 
				end 
			end 

			-- we can technically do a camera that "follows" the player until they're out of range and then it snaps to them.
			-- > this is sick kainoa but you don't need it right now. control urself. 
			-- > but it'd be SO COOL. 

			Camera.CameraType = "Custom"

			repeat task.wait() until pcall(StarterGui.SetCore, StarterGui, "ResetButtonCallback", true) 

			--CameraModule:SetFirstPerson(true) 


			--[[if data.ToggleInventory then
				self.Game.Menus.Inventory:Toggle(true)
			end--]]
		end
	end)

	clientBegan = GameController:getClientBegan() -- Time that the game started.
end

return Interface
