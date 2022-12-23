--[=[
	@class Barnyard-ScrapsService
]=]

local require = require(script.Parent.loader).load(script)

local Barnyard-ScrapsService = {}
Barnyard-ScrapsService.ServiceName = "Barnyard-ScrapsService"

function Barnyard-ScrapsService:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("CmdrService"))

	-- Internal
	self._serviceBag:GetService(require("Barnyard-ScrapsBindersServer"))
end

return Barnyard-ScrapsService