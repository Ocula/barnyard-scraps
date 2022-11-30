local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local client = Knit.CreateController({ Name = "client" })

function client:KnitStart() end

function client:KnitInit() end

return client
