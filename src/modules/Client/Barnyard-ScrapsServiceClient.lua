--[=[
	@class Barnyard-ScrapsServiceClient
]=]

local require = require(script.Parent.loader).load(script)

local Barnyard-ScrapsServiceClient = {}
Barnyard-ScrapsServiceClient.ServiceName = "Barnyard-ScrapsServiceClient"

function Barnyard-ScrapsServiceClient:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("CmdrServiceClient"))

	-- Internal
	self._serviceBag:GetService(require("Barnyard-ScrapsBindersClient"))
	self._serviceBag:GetService(require("Barnyard-ScrapsTranslator"))
end

return Barnyard-ScrapsServiceClient