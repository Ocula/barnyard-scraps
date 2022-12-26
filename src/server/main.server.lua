local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Knit = require(ReplicatedStorage.Packages:WaitForChild("Knit"))

-- Load all dependency modules into our utility library:
-- 		Get all nevermore modules
local loader = ServerScriptService:FindFirstChild("LoaderUtils", true).Parent
local nevermore = require(loader).bootstrapGame(ServerScriptService.Nevermore)

local shared = ReplicatedStorage:WaitForChild("Shared")

Knit.Library = {}

function _indexModules(folder, to)
	for i, v in pairs(folder:GetChildren()) do
		if v:IsA("ModuleScript") then
			-- Reconcile any clones.
			if to[v.Name] then
				warn("Module of the same name already exists!", v)
				continue
			end

			local success, module = pcall(function()
				return require(v)
			end)
			if success then
				warn("Successfully loaded", v.Name)
				to[v.Name] = v
			else
				warn("Module load failed on:", v.Name, module)
			end
		end
	end
end

-- _indexModules(nevermore, Knit.Library)
_indexModules(shared, Knit.Library)

-- Load server modules
Knit.Modules = {}
local dependencies = script.Parent:WaitForChild("dependencies")

_indexModules(dependencies, Knit.Modules)
-- Load Services
local Services = script.Parent:WaitForChild("services")
Knit.AddServices(Services)

Knit.Start()
	:andThen(function()
		print("Knit started", Knit)
	end)
	:catch(warn)
