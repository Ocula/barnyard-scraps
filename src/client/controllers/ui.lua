local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ui = Knit.CreateController({ Name = "ui" })

function ui:KnitStart()
	print("user interface start")
end

function ui:KnitInit() end

return ui
