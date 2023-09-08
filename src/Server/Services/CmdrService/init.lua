local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local CmdrService = Knit.CreateService({
	Name = "CmdrService",
	Client = {},
})

function CmdrService:KnitStart()

end

function CmdrService:KnitInit() 
	local Cmdr = require(Knit.Library.Cmdr)

	Cmdr:RegisterDefaultCommands()
	Cmdr:RegisterHooksIn(script.Hooks)

	Cmdr:RegisterCommandsIn(Knit.Modules.Cmdr)
end

return CmdrService
