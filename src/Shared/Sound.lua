local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local AssetLibrary = require(Knit.Library.AssetLibrary)

local Sound = {
	_bin = {},
}

Sound.__Index = Sound

function Sound.getSoundId(id)
	return AssetLibrary.get(id)
end

function Sound.play() end

return Sound
