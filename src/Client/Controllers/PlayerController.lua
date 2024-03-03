local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Signal = require(Knit.Library.Signal)

local PlayerController = Knit.CreateController({
	Name = "PlayerController",
	Loaded = Signal.new(),

	_isLoaded = false,
	_forceControlsDisabled = false,
})

function PlayerController:GetCamera()
	if not self._isLoaded then
		self.Loaded:Wait()
	end

	return self.Camera
end

function PlayerController:Load()
	self.Loaded:Fire()
	self._isLoaded = true
end

function PlayerController:KnitStart()
	local Player = game.Players.LocalPlayer
	local PlayerModule = require(Player.PlayerScripts:WaitForChild("PlayerModule"))

	self.Control = PlayerModule:GetControls()
	self.Camera = PlayerModule:GetCameras()

	Player.CharacterAdded:Connect(function() -- reset camera & controls
		-- this is for custom camera only.
		-- self.Camera:Reset()
		workspace.CurrentCamera.CameraType = "Custom"

		if self._forceControlsDisabled then
			self.Control:Disable()
		else
			self.Control:Enable()
		end
	end)

	self:Load()
end

function PlayerController:KnitInit() end

return PlayerController
