-- Build and provide functions for game's boot Splash Screen
-- hi / hey
local Splash = {}
Splash.__Index = Splash

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(Knit.Library.Roact)
local Otter = require(Knit.Modules.Interface.Utility.Otter)
local Sound = require(Knit.Library.Sound)

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

Splash.motors = {}
Splash.bin = {}

function Splash:createComponent()
	self.splashScreen = require(Knit.Modules.Interface.Build.Components.Splash)
end

function Splash:toggleDoors(bool) -- Open / Closed (True / False)
	if bool then
		self.splashScreen:setDoorGoals(0.4, 0.6, {
			dampingRatio = 0.35,
			frequency = 4,
		})
		--Roact.createElement(self.splashScreen, {self.setLeftDoorBind:SetGoal({ X = 0.65, Y = 0 }),})
		--Roact.update(self.splashMount, Roact.createElement(self.splashScreen, {}))
	else
		self.splashScreen:setDoorGoals(0.5, 0.5, {
			dampingRatio = 0.35,
			frequency = 4,
		})
	end
end

function Splash:shake(vel, sound) -- Parameters: vel - Velocity
	if sound then
		local id = Sound.getSoundId(sound)
	end

	self.splashScreen:shake(vel)
end

function Splash:load(percent, options) -- Set Loading bar and shake effect to Loading percentage.
	-- Get motor
	local _motor = self.motors.loadBar

	if not _motor then
		_motor = Otter.createSingleMotor(0.05)
		self.motors.loadBar = _motor

		_motor:onStep(function(value)
			self.splashScreen:setLoadPercentage(value)
			self.bin.currentPercentage = value
		end)
	end

	_motor:setGoal(Otter.spring(percent, options or {}))
end

function Splash:updateText() end

function Splash:mount()
	if not self.splashScreen then
		self:createComponent()
	end

	self.splashMount = Roact.createElement(self.splashScreen)

	Roact.mount(self.splashMount, PlayerGui)
end

return Splash
