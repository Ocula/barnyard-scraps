local RankTemplate = {
    [1] = {
        Name = "Chickadee",
        Interface = {
            Theme = {
                Stroke = {
                    Inner = Color3.new(1,1,1),
                    Outer = Color3.new(), 
                },


            }, -- color theme 
            Icon = {
                Image = "",
                OuterStroke = "",
                InnerStroke = "", 
            },
        }, -- color theme
    },

    [2] = {
        Name = "Piglet",

        Reward = {
            Corn = 50,
            Items = {
                ["dominos:turns:turn"] = 5, 
            }, 
        },

        Interface = {
            Theme = {
                Stroke = {
                    Inner = Color3.new(1,1,1),
                    Outer = Color3.new(), 
                },
            }
        }, 

        Icon = {
            Image = "",
            OuterStroke = "",
            InnerStroke = "", 
        },
    },

    [3] = {
        Name = "Puppy",

        Reward = {
            Corn = 50,
            Items = {
                ["dominos:turns:turn"] = 5, 
            }, 
        },

        Interface = {
            Theme = {
                Stroke = {
                    Inner = Color3.new(1,1,1),
                    Outer = Color3.new(), 
                },
            }
        }, 
        
        Icon = {
            Image = "",
            OuterStroke = "",
            InnerStroke = "", 
        },
    },

    [4] = {
        Name = "Kitten",
    },

    [5] = {
        Name = "Duck",
    },

    [6] = {
        Name = "Horse",
    },

    [7] = {
        Name = "Sheep",
    },

    [8] = {
        Name = "Hen",
    },

    [9] = {
        Name = "Donkey",
    },

    [10] = {
        Name = "Alpaca",
    },

    [11] = {
        Name = "Farmhand",
    },
}

local Ranks = {} 
Ranks.__Index = Ranks 

function Ranks.get()
    return setmetatable(table.clone(RankTemplate), Ranks) 
end 

function Ranks:GetRankShift(from, to, player)
    -- if there's a module labeled "1 -> 2" then we have a module that 
    local upgradeModule = script:FindFirstChild(tostring(from).." -> "..tostring(to))

    if upgradeModule then 
        warn("We have an upgrade!")
        local upgrade = require(upgradeModule) 
        local securityCheck = upgrade.Check(player)

        -- check if player's definitely eligible

        if securityCheck then 
            upgrade.Get()(player) 
        end 
    end 
end 

return Ranks 