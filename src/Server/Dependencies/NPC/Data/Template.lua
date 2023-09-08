local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Template = {}
Template.__index = Template

function Template.new()
    local self = setmetatable({}, Template)
    return self
end

function Template:Inject(name: string)
    local Data = require(script.Parent[name])

    for i, v in Data do 
        self[i] = v 
    end 
end 

function Template:Destroy()
    
end


return Template
