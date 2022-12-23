local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages:WaitForChild("Knit"))

-- Load all services
local Services = script.Parent:WaitForChild("services")

Knit.AddServices(Services)

-- Load all dependency modules
Knit.Dependencies = script.Parent:WaitForChild("dependencies")

-- Load all nevermore modules.
Knit.Nevermore = {}

for _, module in pairs(ReplicatedStorage.Packages.Nevermore:GetChildren()) do
	if module:FindFirstChild("Shared") then
		-- Get all the children of the Shared folder and index them into the Nevermore table.
		local QueryResults = Knit.Nevermore
		local CurrentQuery = module.Shared

		local function search(me, query)
			for i, v in pairs((me or CurrentQuery):GetChildren()) do
				if v:IsA("ModuleScript") then
					query[v.Name] = v
				elseif v:IsA("Folder") then
					Knit.Nevermore[v.Name] = {}
					search(v, Knit.Nevermore[v.Name])
				end
			end
		end

		search(CurrentQuery, QueryResults)
	end
end

warn("Nevermore modules loaded into Knit...", Knit.Nevermore)

Knit.Start()
	:andThen(function()
		print("Knit started")
	end)
	:catch(warn)
