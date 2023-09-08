local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(_, players, bool)
    local DebugService = Knit.GetService("DebugService") 

    for i, v in pairs(players) do 
        DebugService.Client.Domino:Fire(v, bool)
    end 

    return ("Set domino debug to "..tostring(bool)) 

    -- FINISH THIS
end
