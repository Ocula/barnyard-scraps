local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages:WaitForChild("Knit"))

local controllers, dependencies = script.Parent:WaitForChild("controllers"), script.Parent:WaitForChild("dependencies")

Knit.AddControllers(controllers)
Knit.Dependencies = dependencies

-- Start Knit
local success, err = Knit.Start():await()

if not success then
	error(tostring(err))
end
