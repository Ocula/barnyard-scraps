-- Handles tunnel travel :)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local TunnelService = Knit.CreateService({
	Name = "TunnelService",
	Tunnels = {},
	Client = {
		Transition = Knit.CreateSignal(),
	},

	Enabled = false,
})

function TunnelService:GetTunnelFromId(tunnelId: string)
	for i, v in self.Tunnels do
		if v.ID == tunnelId then
			return v
		end
	end

	return false
end

function TunnelService:AddTunnelsManual(a, b)
	local Tunnel = require(Knit.Modules.Tunnel)
	local newTunnelA, newTunnelB = Tunnel.new(a, true), Tunnel.new(b, true)

	newTunnelA:Link(newTunnelB)

	--

	self.Tunnels[a] = newTunnelA
	self.Tunnels[b] = newTunnelB

	return newTunnelA, newTunnelB
end

function TunnelService:Update(dt)
	for i, v in self.Tunnels do
		local isInRange, distance = v:isInRange()

		if isInRange then
			v:Check()

			if v.Door then
				v.Door:Open(distance < v.Door.Range / 2)
			end
		else
			if v.Door then
				v.Door:Close()
			end
		end
	end
end

function TunnelService:KnitStart()
	if self.Enabled then
		local Binder = require(Knit.Library.Binder)
		local Tunnel = Binder.new("Tunnel", require(Knit.Modules.Tunnel))

		Tunnel:GetClassAddedSignal():Connect(function(newTunnel)
			if newTunnel._ShellClass then
				return
			end

			local _getTunnel = self:GetTunnelFromId(newTunnel.ID)

			if _getTunnel then
				if _getTunnel.Object ~= newTunnel.Object then
					newTunnel:Link(_getTunnel)
				end
			end

			self.Tunnels[newTunnel.Object] = newTunnel
		end)

		Tunnel:GetClassRemovingSignal():Connect(function(oldTunnel)
			self.Tunnels[oldTunnel.Object] = nil
		end)

		Tunnel:Start()

		--[[game:GetService("RunService").Heartbeat:Connect(function(dt)
            self:Update(dt) 
        end)--]]
	end
end

function TunnelService:KnitInit() end

return TunnelService
