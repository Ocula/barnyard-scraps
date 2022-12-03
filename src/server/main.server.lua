local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages:WaitForChild("Knit"))

-- Load all services
local Services = script.Parent:WaitForChild("services")

Knit.AddServices(Services)

-- Load all dependency modules
Knit.Dependencies = script.Parent:WaitForChild("dependencies")

Knit.Start()
	:andThen(function()
		print("Knit started")
	end)
	:catch(warn)
