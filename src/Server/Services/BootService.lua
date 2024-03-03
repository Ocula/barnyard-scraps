local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local BootService = Knit.CreateService({
	Name = "BootService",
	Order = {},
	Client = {},
})

function BootService:Boot(Callback: func, ForceOrder: int?, Throttle: int?)
	if ForceOrder then
		assert(not self.Order[ForceOrder], "Cannot force into this order slot, it's full!")
	end

	self.Order[(ForceOrder or (#self.Order + 1))] = {
		__call = Callback,
		Throttle = Throttle,
		Last = Throttle,
	}
end

function BootService:KnitStart()
	local ZoneService = Knit.GetService("ZoneService")

	--[[
        BOOT ORDER:
            [ ] ZoneService
            [ ] 
    ]]

	self:Boot(function(dt)
		ZoneService:Update(dt)
	end)

	local RunService = game:GetService("RunService")

	RunService.Stepped:Connect(function(dt)
		for index = 1, #self.Order do
			local Data = self.Order[index]
			local Callback = Data.__call

			if tick() - (Data.Last or 0) >= (Data.Throttle or 0) then
				Callback(dt)

				Data.Last = tick()
			end
		end
	end)
end

function BootService:KnitInit() end

return BootService
