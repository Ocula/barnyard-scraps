local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Binder = require(Knit.Library.Binder)

local ZoneService = Knit.CreateService({
	Name = "ZoneService",
	Client = {
		Update = Knit.CreateSignal(),
	},

	Zones = {},

	Enabled = false,
})

function ZoneService:Update(dt)
	local PlayerService = Knit.GetService("PlayerService")
	local Players = PlayerService:GetAvailablePlayers(true)

	for i, v in Players do
		local Zones = {}
		local ZoneInside

		for _, zone in self.Zones do
			local check = zone:isPlayerInsideZone(v.Player)

			if check then
				table.insert(Zones, zone)
			end
		end

		-- now check priority
		if #Zones > 0 then
			local Priority = math.huge

			for i, zone in pairs(Zones) do
				if zone.Priority < Priority then
					Priority = zone.Priority
					ZoneInside = zone
				end
			end

			if ZoneInside then
				if v.Zone ~= ZoneInside then
					v:SetZone(ZoneInside.Zone)
				end
			end
			-- now see if they're different
		end
	end
end

function ZoneService:KnitStart()
	if self.Enabled then
		local ZoneObject = require(Knit.Modules.Zone)
		local ZoneBinder = Binder.new("Zone", ZoneObject)

		ZoneBinder:GetClassAddedSignal():Connect(function(newZone)
			if newZone.__ShellClass then
				return
			end

			self.Zones[newZone.Object] = newZone

			warn(self)
		end)

		ZoneBinder:GetClassRemovedSignal():Connect(function(oldZone)
			self.Zones[oldZone.Object] = nil
		end)

		ZoneBinder:Start()

		for i, v in pairs(game:GetService("CollectionService"):GetTagged("Teleport")) do
			local newZone = ZoneObject.new(v)

			if newZone.__ShellClass then
				continue
			end

			self.Zones[newZone.Object] = newZone
		end

		--[[ hook us into tunnelservice
        game:GetService("RunService").Heartbeat:Connect(function(dt)
            self:Update(dt) 
        end)--]]
	end
end

function ZoneService:KnitInit() end

return ZoneService
