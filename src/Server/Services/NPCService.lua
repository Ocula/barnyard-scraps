local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local NPC = require(Knit.Modules.NPC)
local Signal = require(Knit.Library.Signal)

local NPCService = Knit.CreateService({
	Name = "NPCService",
	Client = {
		Update = Knit.CreateSignal(),
		Load = Knit.CreateSignal(),
	},

	Entities = {},
	Updated = Signal.new(),
})

function NPCService:Add(NPC)
	self.Entities[NPC.GUID] = NPC
end

function NPCService:KnitStart()
	local PlayerService = Knit.GetService("PlayerService")

	PlayerService:GetPlayerAddedSignal():Connect(function(newPlayer)
		local Compressed = {}

		for i, v in self.Entities do
			table.insert(Compressed, v:Package())
		end

		self.Client.Load:Fire(newPlayer, Compressed)
	end)
end

function NPCService:KnitInit() end

return NPCService
