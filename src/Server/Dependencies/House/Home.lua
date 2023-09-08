local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Signal = require(Knit.Library.Signal)
local Maid = require(Knit.Library.Maid) 

local Home = {}
Home.__index = Home


function Home.new()
    local self = setmetatable({
        __identifier = "Home", 
        Maid = Maid.new(), 
    }, Home)
    return self
end

 
function Home:Destroy()
    Maid:DoCleaning() 
end


return Home
