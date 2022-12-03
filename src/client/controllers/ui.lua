local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ui = Knit.CreateController({ Name = "ui" })

function ui:KnitStart() end

function ui:KnitInit() end

return ui
