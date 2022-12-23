--[[
	@class ClientMain
]]
local packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")

local serviceBag = require(packages:WaitForChild("ServiceBag")).new()

serviceBag:GetService(packages:WaitForChild("Barnyard-ScrapsServiceClient"))

serviceBag:Init()
serviceBag:Start()