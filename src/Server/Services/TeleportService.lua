local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Binder = require(Knit.Library.Binder) 

local TeleportService = Knit.CreateService {
    Name = "TeleportService",
    Client = {},

    Teleports = {}, 
}

function TeleportService:GetPort(LocationId)
    return self.Teleports[LocationId] 
end 

function TeleportService:Teleport(Player: table, LocationId: string)
    local Port = self:GetPort(LocationId) 

    return Port:Process(Player) 
end

function TeleportService:KnitStart()

end

function TeleportService:KnitInit()
    local TeleportObject = require(Knit.Modules.Teleport)
    local TeleportBinder = Binder.new("Teleport", TeleportObject) 

    TeleportBinder:GetClassAddedSignal():Connect(function(newTeleport)
        if newTeleport.__ShellClass then return end 

        self.Teleports[newTeleport.LocationId] = newTeleport 

        warn(self) 
    end)

    TeleportBinder:GetClassRemovedSignal():Connect(function(oldTeleport)
        self.Teleports[oldTeleport.LocationId] = nil 
    end)

    TeleportBinder:Start() 


    for i, v in pairs(game:GetService("CollectionService"):GetTagged("Teleport")) do 
        local newTeleport = TeleportObject.new(v)

        if newTeleport.__ShellClass then 
            continue 
        end 

        self.Teleports[newTeleport.LocationId] = newTeleport 
    end 

end


return TeleportService
