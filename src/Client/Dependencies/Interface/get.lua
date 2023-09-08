--!strict

-- @Ocula 2023 6/4/2023
-- Handles the relationship between Interface, Components, Classes, and Themes. 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Utility = require(Knit.Library.Utility)

local GetManager = {}
GetManager.__index = GetManager

function GetManager.getTo(tree: table, scope: any?) -- parentString for debugging
	local _object = scope or script.Parent

	local function checkTree(thisTree)
		for index, nextName in pairs(thisTree) do
			_object = _object:FindFirstChild(nextName)

			if not _object and nextName then
				break
			end
		end
	end

	checkTree(tree)

	if not _object then
		return false --error("GetManager failed to find the desired instance in the tree:", parentString)
	end

	return _object
end

function GetManager:GetTheme(treeQuery: string) 
	local tree = Utility.splitString(treeQuery, "/") 
	local theme = self.getTo(tree, script.Parent.Build.Themes)

	assert(theme, "GetManager failed to find the desired Theme instance in the tree: " .. treeQuery)

	return require(theme) 
end

function GetManager:GetComponent(treeQuery: string)
	local tree = Utility.splitString(treeQuery, "/")
	local component = self.getTo(tree, script.Parent.Build.Components) 

	assert(component, "GetManager failed to find the desired instance in the tree: " .. treeQuery)

	return require(component)
end

-- @Ocula
-- Utility properties for building ui. Use for all resolution-based needs. 
function GetManager:GetUtilityBuild(treeQuery: string)
	local tree = Utility.splitString(treeQuery, "/")
	local component = self.getTo(tree, script.Parent.Build.Utility)

	assert(component, "GetManager failed to find the desired instance in the tree: " .. treeQuery)

	return require(component)
end

function GetManager:GetClass(treeQuery: string)
	local tree = Utility.splitString(treeQuery, "/")
	local class = self.getTo(tree, script.Parent.Classes) 

	assert(class, "GetManager failed to find the desired Class instance in the tree: " .. treeQuery)

	return require(class)
end

function GetManager:Get(treeQuery: string)
	local tree = Utility.splitString(treeQuery, "/")
	local object = self.getTo(tree) 

	assert(object, "GetManager failed to find the desired Component instance in the tree: " .. treeQuery)

	return require(object)
end

return GetManager
