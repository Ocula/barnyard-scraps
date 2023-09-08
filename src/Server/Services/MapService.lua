local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Binder = require(ReplicatedStorage.Shared.Binder) 

local MapService = Knit.CreateService({
	Name = "MapService",
	Maps = {},
	Client = {},
})

function MapService:add(Map)
	self.Maps[Map.MapId] = Map
end

function MapService:remove(MapId)
	self.Maps[MapId] = nil
end


function MapService:KnitStart() 

end

function MapService:KnitInit()

end

return MapService
