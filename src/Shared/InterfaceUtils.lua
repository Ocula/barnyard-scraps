-- Interface Utility Library
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local InterfaceUtils = {}
InterfaceUtils.__Index = InterfaceUtils

-- Utility Functions
function InterfaceUtils.getVector2FromUDim(udim)
	if not RunService:isClient() then
		return
	end

	local screenSize = workspace.CurrentCamera.ViewportSize

	local offsetX, offsetY = udim.X.Offset / screenSize.X, udim.Y.Offset / screenSize.Y
	local scaleX, scaleY = udim.X.Scale, udim.Y.Scale

	local makeVectorX, makeVectorY = scaleX + offsetX, scaleY + offsetY

	local convert = Vector2.new(makeVectorX, makeVectorY)

	return convert
end

function InterfaceUtils.getUDimFromVector2(vector, conversion)
	if conversion == "Scale" then
		return UDim2.new(vector.X, 0, vector.Y, 0)
	elseif conversion == "Offset" then
		return UDim2.new(0, vector.X, 0, vector.Y)
	end
end

function InterfaceUtils.ResolveResolution(vector, resolution)
	return Vector2.new(vector.X / resolution, vector.Y / resolution)
end

function InterfaceUtils.capitalizeWords(inputString)
    -- Split the input string into words
    local words = {}
    for word in inputString:gmatch("%S+") do
        table.insert(words, word)
    end

    -- Capitalize the first letter of each word
    for i, word in ipairs(words) do
        local firstChar = word:sub(1, 1):upper()
        local restOfString = word:sub(2):lower()
        words[i] = firstChar .. restOfString
    end

    -- Join the words back together into a single string
    local result = table.concat(words, " ")

    return result
end


-- Indexing Functions

function InterfaceUtils.getImage(id)
	local Library = require(Knit.Library.AssetLibrary)
	local target = Library.Assets.Interface

	local retrieve = Library.get(id, target)

	return retrieve
end

function InterfaceUtils.getImageId(id)
	local asset = InterfaceUtils.getImage(id)

	return asset.ID
end

function InterfaceUtils.getImageListFromArray(array)
	local images = {}

	for i, v in pairs(array) do
		if v.ID then
			table.insert(images, v.ID)
		end
	end

	return images
end

return InterfaceUtils
