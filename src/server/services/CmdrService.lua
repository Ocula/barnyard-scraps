local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local CmdrService = Knit.CreateService({
	Name = "CmdrService",
	Client = {},
})

function CmdrService:KnitStart()
	local Cmdr = require(Knit.Library.Cmdr)

	Cmdr:RegisterDefaultCommands()

	warn("CMDR started on Server", Cmdr)
end

function CmdrService:KnitInit() end

return CmdrService
