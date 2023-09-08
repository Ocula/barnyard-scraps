local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(_, players, typeofgive, amount)
    local PlayerService = Knit.GetService("PlayerService") 

	for _, player in pairs(players) do
        local Player = PlayerService:GetPlayer(player) 
        Player:Give(typeofgive, amount) 
	end
    
	return ("Set %d players"):format(#players)
end
