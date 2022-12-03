local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)

local ui = Knit.CreateController({ Name = "ui" })

function ui:KnitStart()
	print("user interface boot")
end

function ui:KnitInit() end

return ui
