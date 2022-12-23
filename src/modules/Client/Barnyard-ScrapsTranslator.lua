--[[
	@class Barnyard-ScrapsTranslator
]]

local require = require(script.Parent.loader).load(script)

return require("JSONTranslator").new("Barnyard-ScrapsTranslator", "en", {
	gameName = "Barnyard-Scraps";
})