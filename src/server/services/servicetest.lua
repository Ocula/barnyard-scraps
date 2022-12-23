local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local servicetest = Knit.CreateService({
	Name = "servicetest",
	Client = {},
})

function servicetest:KnitStart()
	workspace:WaitForChild("Baseplate").Color = Color3.new(0, 0.317647, 1)
end

function servicetest:KnitInit() end

return servicetest
