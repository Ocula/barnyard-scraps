local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(Knit.Library.Roact)

local ui = Knit.CreateController({
	Name = "ui",
	serverLoaded = false,

	goalWait = 7, -- We dont want the player waiting to load in any longer than 3 seconds.
})

local clientBegan

--[[ Structurally:
        Mount all roact trees here via their respective modules in Interface
--]]

function ui:Load()
	-- Splash Screen / Loading Bar
	local splashScreen = require(Knit.Modules.Interface.Controllers.SplashScreen)
	splashScreen:mount()

	-- Aggregate all Assets
	local assets = require(Knit.Library.AssetLibrary):Aggregate()

	local function getCurrentLoadBarPosition()
		local bin = splashScreen.bin
		local perc = bin.currentPercentage or 0.1

		local amountToGo = 1 - perc

		return (perc + amountToGo / ((math.random((self.goalWait / 2) * 10, (self.goalWait * 10))) / 10))
	end

	ContentProvider:PreloadAsync(assets)

	-- If we haven't loaded on the server yet, give some content to keep it interesting.
	if not self.serverLoaded then
		repeat
			local _id = "Shake" .. math.random(1, 3)
			splashScreen:shake(math.random(10, 30) / 10, _id)
			splashScreen:load(getCurrentLoadBarPosition())

			for _ = 0, 1.5, 0.01 do -- special wait so we dont miss the server loading.
				if self.serverLoaded then
					break
				end

				task.wait(0.01)
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
			splashScreen:shake(math.random(10, 30) / 10, _id)

			if i > (_timeLeftToWait - inc) then
				splashScreen:load(1)
			else
				splashScreen:load(getCurrentLoadBarPosition())
			end
		end
	end

	task.wait(0.1)

	-- Open doors!
	splashScreen:load(1)
	splashScreen:shake(1.5)
	splashScreen:toggleDoors(true)

	task.wait(1)

	splashScreen:unmount()
end

function ui:KnitStart()
	self:Load()
end

function ui:KnitInit()
	-- Interface init
	local GC = Knit.GetController("GameController")

	GC.Loaded:Connect(function(bool)
		self.serverLoaded = bool
	end)

	clientBegan = GC:getClientBegan()
end

return ui
