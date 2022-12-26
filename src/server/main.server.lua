local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Knit = require(ReplicatedStorage.Packages:WaitForChild("Knit"))

-- Load all services
local Services = script.Parent:WaitForChild("services")

Knit.AddServices(Services)

-- Load all nevermore modules.
local loader = ServerScriptService:FindFirstChild("LoaderUtils", true).Parent

-- Load all dependency modules
local dependencies = script.Parent:WaitForChild("dependencies")
local nevermore = require(loader).bootstrapGame(ServerScriptService.Nevermore)

Knit.Library = {}

function _indexModules(folder)
	for i, v in pairs(folder:GetChildren()) do
		if v:IsA("ModuleScript") then
			local success, module = pcall(function()
				return require(v)
			end)
			if success then
				--warn("Successfully loaded", v.Name)
				Knit.Library[v] = v
			else
				warn("Module load failed on:", v.Name, module)
			end
		end
	end
end

_indexModules(dependencies)
_indexModules(nevermore)

Knit.Start()
	:andThen(function()
		print("Knit started", Knit)
	end)
	:catch(warn)
