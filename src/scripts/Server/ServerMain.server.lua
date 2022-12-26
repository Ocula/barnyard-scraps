--[[
	@class ServerMain
]]
local ServerScriptService = game:GetService("ServerScriptService")

local loader = ServerScriptService.BarnyardScraps:FindFirstChild("LoaderUtils", true).Parent
local packages = require(loader).bootstrapGame(ServerScriptService.BarnyardScraps)

local serviceBag = require(packages.ServiceBag).new()

serviceBag:GetService(packages.BarnyardScrapsService)

serviceBag:Init()
serviceBag:Start()
