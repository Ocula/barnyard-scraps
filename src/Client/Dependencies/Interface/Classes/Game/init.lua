-- Game UI
-- Domino Simulator 2023

--[[

    Game UI is fed through a main class system. Top-down control starts here for all Game UI. 

    We should be able to feed UIs directly into this system.

    @Build:MoveTo(#) --> Index number. Will clamp to max/min. 
    @Build:GetSelected()
    @Build:SetSelected() 
    @Build:Describe() --> Turns the wheel into a table designed for UI feedback.
    
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(Knit.Library.Maid)
local Signal = require(Knit.Library.Signal)
local Handler = require(Knit.Modules.Interface.get)

local InterfaceController = Knit.GetController("Interface")

local SandboxSelect = require(script.SandboxSelect)
local Edit = require(script.Edit)
local Save = require(script.Save)
local Inventory = require(Knit.Modules.Classes.Inventory)

local Resolution = Vector2.new(1980, 1020)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs =
	Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup =
	Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Game = {}
Game.__index = Game

export type GameUIObject<table> = { [_gameUIObject]: true }

type MenuObject<table> = { [_isMenu]: true }
type UIObject<table> = { [_isUI]: true }

function Game.new(): GameUIObject -- create the game ui
	local self = setmetatable({
		-- $ Menu / XP Menu
		-- Settings
		-- Shop
		Menus = {},

		Sandboxes = {},

		Object = New("ScreenGui")({
			Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"),
			Name = "Game",
			IgnoreGuiInset = true,
		}),

		OverheadLock = Value(false),

		-- Two maids for cleanup
		ConnectionsMaid = Maid.new(),
		InstancesMaid = Maid.new(),

		Scale = 1,

		ConnectQueue = {}, -- queue for callbacks we need to connect to renderstepped, if the loop is running, any added callbacks will be applied on the next frame.

		-- internal
		_activeMenu = false,
		_gameUIObject = true,
		_allowSelectionBoxUpdates = true,
		_isBusy = false,
		_loadedBases = false,
		_loadedBasesSignal = Signal.new(),
	}, Game)

	-- Load HUD
	print("[SCRAPS] - Setup a new HUD ui here!")
	self.HUD = {} --require(script.HUD).new(self.Object)

	-- Load menus
	--[[self.Menus.Inventory = Inventory.new()
    self.Menus.Edit = Edit.new(self.Object) 
    self.Menus.Save = Save.new(self.Object) -- TODO: create back button for getting back to base select. --]]

	InterfaceController._menusLoaded:Fire()

	return self
end

function Game:GetBin()
	return self.Object
end

-- @Ocula
-- Freezes all menu buttons so they don't interfere with any prioritized prompts
function Game:Freeze()
	for i, v in self.Menus do
		if v.Freeze then
			v:Freeze()
		end
	end
end

function Game:Thaw()
	for i, v in self.Menus do
		if v.Thaw then
			v:Thaw()
		end
	end
end

function Game:adjustScale()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local viewportArea, resolutionArea = viewportSize.X * viewportSize.Y, Resolution.X * Resolution.Y

	self.Scale = viewportArea / resolutionArea -- accurate scale marking for screen. -> this really only has a few use cases, but it's useful regardless.
end

function Game:Render() -- starts all render connections.
	local uiRender = RunService.RenderStepped:Connect(function(dt)
		local _hit = false

		-- self callback support
		for _, callback in self do
			if type(callback) == "table" or type(callback) == "array" then
				if callback.Render then
					callback:Render(dt)
					_hit = true
				end
			end
		end

		for _, callback in self.Sandboxes do
			if type(callback) == "table" or type(callback) == "array" then
				if callback.Render then
					callback:Render(dt)
					_hit = true
				end
			end
		end

		-- custom callback support
		for _, callback in self.ConnectQueue do
			callback(dt)
			_hit = true
		end

		--[[if _hit == false then 
            warn("We're currently rendering for no reason! Unbinding.")
            self:Halt() 
        end--]]
	end)

	self.ConnectionsMaid:GiveTask(uiRender)
end

function Game:Halt() -- stops all render connections.
	self.ConnectionsMaid:DoCleaning()
end

function Game:Toggle(setObject: UIObject, force) -- toggle menu object
	if force then
		self.Menus[setObject]:Toggle(force)
		return
	end

	if not self._activeMenu then
		self.Menus[setObject]:Toggle(true)

		self._currentMenu = setObject
		self._activeMenu = true
	else
		self.Menus[self._currentMenu]:Toggle(false)
		self._activeMenu = false
	end
end

function Game:Destroy()
	self.ConnectionsMaid:DoCleaning()
	self.InstancesMaid:DoCleaning()
end

return Game
