local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local servicetest = Knit.CreateService({
	Name = "servicetest",
	Client = {},
})

function servicetest:KnitStart()
	workspace:WaitForChild("Baseplate").Color = Color3.new(1, 0.258823, 0.258823)
end

function servicetest:KnitInit() end

return servicetest
