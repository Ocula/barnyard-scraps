local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local DialogueFormat = {}
DialogueFormat.__index = DialogueFormat

-- could update to proper string patterns 
local Replacements = {
    ["<player>"] = function()
        return '<font color="rgb(100,255,255)">'..game.Players.LocalPlayer.DisplayName.."</font>"
    end, 

    ["<topple>"] = function()
        return [[<i><font color="rgb(255,210,0)">topple</font></i>]]
    end,

    ["<corn>"] = function()
        return "🌽"
    end,

    ["<rank>"] = function()
        return "⭐️"
    end,

    ["<npc: alfred>"] = function()
        return [[<b><font family="rbxassetid://12187375716"><font color="rgb(100,255,100)">alfred the alpaca</font></font></b>]]
    end,
}

--[[
Replacements["<npc:%s*([%w%s]+)>"] = function(matchedText, npcName)
    print("replacing matchedText:", matchedText, npcName)

    npcName = npcName:lower() 

    return Replacements[npcName]()
end--]]

local function removeTags(str)
	-- replace line break tags (otherwise grapheme loop will miss those linebreak characters)
	str = str:gsub("<br%s*/>", "\n")
	return str --(str:gsub("<[^<>]->", ""))
end

local function format(str)
    for pattern, repl in Replacements do 
        str = string.gsub(str, pattern, repl) 
    end 

    str = removeTags(str) 

    return str 
end

function DialogueFormat:Format(str)
    return format(str) 
end


return DialogueFormat