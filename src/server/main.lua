local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local main = Knit.CreateService({
	Name = "main",
	Client = {},
})

function main:KnitStart()
	workspace:WaitForChild("Baseplate").Color = Color3.new(0, 0.501960, 1)
end

function main:KnitInit() end

return main
