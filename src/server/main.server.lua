-- Initiation script

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Knit = require(ReplicatedStorage.Packages:WaitForChild("Knit"))

-- Load all services
local Services = script.Parent:WaitForChild("services")

Knit.AddServices(Services)

-- Load all dependency modules
Knit.Dependencies = script.Parent:WaitForChild("dependencies")

-- Load all nevermore modules.
local loader = ServerScriptService.Nevermore:FindFirstChild("LoaderUtils", true).Parent

Knit.Nevermore = require(loader).bootstrapGame(ServerScriptService.Nevermore)

Knit.Start()
	:andThen(function()
		print("Knit started")
	end)
	:catch(warn)
