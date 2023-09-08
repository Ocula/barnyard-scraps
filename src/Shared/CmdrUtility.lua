local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local CmdrUtility = {}
CmdrUtility.__index = CmdrUtility

function CmdrUtility:GetUserHasPermission(context)
	local user = context.Executor
	local rankInGroup = user:GetRankInGroup(11323634)

	if rankInGroup >= 180 or user.userId < 1 then 
		return true 
	end 
end

return CmdrUtility
