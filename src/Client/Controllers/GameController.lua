local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(Knit.Library.Signal)

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local GameController = Knit.CreateController({
	Name = "GameController",

	Bin 		= {}, 
	Sets		= {}, 

	__loaded 	= false,
	__began 	= os.time(),

	isLoading 	= Value(true), -- used to freeze any game mechanics while we load. 

	Loaded = Signal.new(),
	QueueTutorial = Signal.new(), 

	Tutorial = true, 
})

function GameController:getClientBegan()
	return self.__began
end

-- testing
function GameController:Tutorial()
	game.Players.LocalPlayer.CharacterAdded:Wait() 
	local Character = game.Players.LocalPlayer.Character
	local HRP = Character:WaitForChild("HumanoidRootPart") 

	local newArrow = require(Knit.Library.Arrow).new() 
	newArrow:Anchor(HRP)
end

function GameController:GetSetFromObjectId(ObjectId)
	for set, metaobject in pairs(self.Sets) do 
		if set:GetAttribute("ID") == ObjectId then 
			return metaobject 
		end 
	end 
end 

function GameController:KnitStart() 
	local Binder = require(Knit.Library.Binder)

	local SetBinder = Binder.new("Set", require(Knit.Modules.Classes.Set)) 

	SetBinder:GetClassAddedSignal():Connect(function(newSet)
		if newSet._ShellClass then return end 

		self.Sets[newSet.Object] = newSet 
	end)

	SetBinder:GetClassRemovedSignal():Connect(function(oldSet)
		if oldSet.Object then 
			self.Sets[oldSet.Object] = nil 
		end 
	end)

	SetBinder:Start() 
end

function GameController:SetControls(bool: boolean)
	local Player = game.Players.LocalPlayer 
	local PlayerModule = require(Player.PlayerScripts.PlayerModule):GetControls()

	if bool then 
		PlayerModule:Enable()
	else 
		PlayerModule:Disable()
	end 
end

function GameController:SetBin(input, amount)
	if not self.Bin[input] then 
		self.Bin[input] = Value(amount) 
	end 

	self.Bin[input]:set(amount) 
end 

function GameController:GetBin(input)
	return self.Bin[input]
end 

function GameController:KnitInit()
	-- Connect Events
	local PlayerService = Knit.GetService("PlayerService")

	PlayerService.PlayerLoaded:Connect(function(bool)
		self.__loaded = bool
		self.isLoading:set(false)
		self.Loaded:Fire(bool)
	end)

	PlayerService.QueueTutorial:Connect(function(bool)
		self._tutorial = bool 
		self.QueueTutorial:Fire(bool) 
	end)

	PlayerService.SetControls:Connect(function(bool)
		self:SetControls(bool) 
	end)

	PlayerService.UpdateBin:Connect(function(bin: table) -- gotta be strict on these types man
		for input, amount in bin do 
			self:SetBin(input, amount)
		end
	end)	
	-- Quick Index
	local QuickIndex = require(Knit.Library.QuickIndex)
	QuickIndex:Load() 

	-- Player 
	local Player = game.Players.LocalPlayer 
end

return GameController
