--[[
	@class ServerMain
]]
local ServerScriptService = game:GetService("ServerScriptService")

local loader = ServerScriptService.Barnyard-Scraps:FindFirstChild("LoaderUtils", true).Parent
local packages = require(loader).bootstrapGame(ServerScriptService.Barnyard-Scraps)

local serviceBag = require(packages.ServiceBag).new()

serviceBag:GetService(packages.Barnyard-ScrapsService)

serviceBag:Init()
serviceBag:Start()