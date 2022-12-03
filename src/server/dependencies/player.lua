local player = {}
player.__index = player

function player.new()
	local self = setmetatable({}, player)
	return self
end

function player:Destroy() end

return player
