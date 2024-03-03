-- Item Index Service
-- ocula
-- September 1, 2020

--[[
	
	For setting up the ItemIndex. 

	Overall concept (split to server/client later):
		- Item IDs should be namespaced names, i.e. toy:robot, ingredient:magic, or similar.
			- We can use these namespaced names as keys in a single hashtable as key/value pairs. In the case of non-unique (stackable) items,
			  we can simply store a number as the value. In the case of unique, non-stackable items, we can store an array of objects as the value
			  instead, which can contain item metadata. 
		- Differentiate between Unique items and Non-unique items. 
			- Bool on the item type definition that determines whether it's unique or not.
			- Being unique and being stackable is mutually exclusive.
			- However, what we're doing is handling both differently. The only major difference is that they are completely separate.
			- This can be done by attributing a unique-id to any non-unique objects
			- Non-unique objects will most likely be objects that are storing more metadata than just "Number" 
			- We should attempt to correct for "incorrectly" stored information. If for some reason an item becomes stackable or vice versa, we should
			  change the data 
			- So what we can do is have items reconcilable on the profile end of things. 
			- Should we actually have a Bool that determines whether an object is unique or not? It'd simplify our case handling. <- YES. Absolutely. 
			  Should we store this on the item type in the game, or in the stored inventory data?
			- Well, okay, it's something that I guess should be stored in the game. And then stored onto the player's data.
				- So that we can change this value in-game and it would then replicate to clients when they join and their profile is interpreted. 

			- And would also solve future reconciliation. Ok sweet.
			- 

		- HERES WHAT WE SHOULD DO:

			- When a player joins, once the data here is compiled properly and their profile is loaded safely:
				- Check their backpack and update any data points that don't match up with the base data on each object.
				- I see what ur saying, sort of. It might actually be unused completely moving forward. The data itself can be sent from server/retrieved by the client through this service entirely.
				- I think the goal here in ItemIndexService is to 1) fully automate the indexing process, 2) switch it over to namespace 
				- That's really it. How the data is handled will then need to be worked on.

			- How should we then setup the index table?
				
				- Index = {

					--* i think this one makes the most sense to me, however the id on the item would be it's reference name:
					
					["toys"] = {
						["stuffed"] = {
							["anna"] = {
								Unique = true; -- but is she really unique -- *wow* fuck you -- <3 xoxo
							};
						}
					}

				}
								
	Server:
	

--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Utility = require(Knit.Library.Utility)

local Signal = require(Knit.Library.Signal)

local ItemIndexService = Knit.CreateService({
	Name = "ItemIndexService",
	Client = {},
	Index = {}, -- The entire game content index.
	Sounds = {}, --

	Loaded = false,
	_loadedEvent = Signal.new(),
})

-- Utility Functions
function splitString(inputStr, delimiter)
	local out = {}
	for str in string.gmatch(inputStr, "([^" .. delimiter .. "]+)") do
		table.insert(out, str)
	end

	return out
end

-- Utility Methods
function ItemIndexService:FolderCheck(CheckMe)
	for i, v in pairs(CheckMe:GetChildren()) do
		if v:IsA("Folder") then
			return true
		end
	end

	return false
end

function ItemIndexService:ValueCheck(Object)
	for k, v in pairs(Object:GetDescendants()) do
		if v.ClassName:sub(#v.ClassName - 4, #v.ClassName):lower() == "value" then
			return true
		end
	end

	return false
end

function ItemIndexService:CompileValues(Object)
	return Utility:CompileValues(Object)
end

-- Method for collecting Index information
-- Parameters: None
function ItemIndexService:Load()
	local Assets = game:GetService("ReplicatedStorage"):WaitForChild("Assets")
	local Items = Assets:WaitForChild("Items")
	local Sounds = Assets:WaitForChild("Sounds")
	local Build = Assets:WaitForChild("Build")
	local Homes = Assets:WaitForChild("Homes")
	local Vendors = Assets:WaitForChild("Vendors")

	local Game = game:GetService("ServerStorage"):WaitForChild("Game")

	--Find all objects
	-- Server
	self.Game = Utility:FindObjects(Game)

	-- Shared
	self.Index = Utility:FindObjects(Items)
	self.Sounds = Utility:FindObjects(Sounds)
	self.Build = Utility:FindObjects(Build)
	self.Homes = Utility:FindObjects(Homes)
	self.Vendors = Utility:FindObjects(Vendors)

	warn("ItemIndexService:", self)
	----
end

-- Function for retrieving namespaced *things*
function retrieveNamespacedInternal(index, itemIndex)
	if itemIndex == nil or type(itemIndex) == "number" then
		warn("NamespacedInternal: ", index, itemIndex)
		error("ItemIndex parameter is nil or a number, please provide a string id.")
	end

	local arrayList = splitString(itemIndex:upper(), ":")

	-- Check to make sure the index exists!
	local object = index
	for _, v in ipairs(arrayList) do
		--Go down a level if we can
		object = object[v]

		--Exit if we ever hit a nil pointer
		if object == nil then
			--warn("Item type " .. itemIndex .. " is invalid!")
			return nil
		end
	end

	--Return the object we found
	return object
end

function ItemIndexService:Search(query)
	local splitQuery = splitString(query:upper(), ":")
	local queryIndex = nil

	for i, v in pairs(self) do
		if type(v) == "table" then
			local Search = splitQuery[1]

			if v[Search] then
				queryIndex = v
			end
		end
	end

	local object = retrieveNamespacedInternal(queryIndex, query)

	--Make sure we have an object
	if object and (object.__ItemIndexType ~= "Object") then
		warn("Item type " .. query .. " is not an object!")
		return nil
	end

	return object
end

-- Method for retrieving namespaced folder from an ItemIndex
function ItemIndexService:GetCategory(itemIndex)
	--warn("Attempting to get Category:", itemIndex)

	local folder = splitString(itemIndex:upper(), ":")[1]
	local object = retrieveNamespacedInternal(self.Index, folder)

	--Make sure we have an object
	if object and (object.__ItemIndexType ~= "Folder") then
		--warn("Item type " .. itemIndex .. " is not a category!")
		return nil
	end

	return folder, object -- Return Index, Value
end

-- Method for retrieving namespaced asset
function ItemIndexService:GetItem(itemIndex)
	local object = retrieveNamespacedInternal(self.Index, itemIndex)

	--Make sure we have an object
	if object and (object.__ItemIndexType ~= "Object") then
		warn("Item type " .. itemIndex .. " is not an object!")
		return nil
	end

	return object
end

function ItemIndexService:GetSound(itemIndex)
	local object = retrieveNamespacedInternal(self.Sounds, itemIndex)

	--Make sure we have an object
	if object and (object.__ItemIndexType ~= "Object") then
		warn("Item type " .. itemIndex .. " is not an object!")
		return nil
	end

	return object
end

function ItemIndexService:GetVendor(itemIndex)
	local object = retrieveNamespacedInternal(self.Vendors, itemIndex)

	--Make sure we have an object
	if object and (object.__ItemIndexType ~= "Object") then
		warn("Item type " .. itemIndex .. " is not an object!")
		return nil
	end

	return object
end

-- Method for retrieving Map assets
function ItemIndexService:Get(itemIndex)
	local object = retrieveNamespacedInternal(self.Game, itemIndex)

	if object and object.__ItemIndexType ~= "Object" then
		return nil
	end

	return object
end

function ItemIndexService:GetBuild(itemIndex)
	local object = retrieveNamespacedInternal(self.Build, itemIndex)

	if object and object.__ItemIndexType ~= "Object" then
		return nil
	end

	return object
end

function ItemIndexService:GetHomes(itemIndex)
	local object = retrieveNamespacedInternal(self.Homes, itemIndex)

	if object and object.__ItemIndexType ~= "Object" then
		return nil
	end

	return object
end

-- Method for retrieving assets via their names.
function ItemIndexService:GetItemFromName(item, path) -- Can narrow down where to begin its recursive search.
	local Result

	local _searchPath = (path or ""):upper()

	local function _recursiveSearch(table)
		if not table then
			return
		end

		for k, v in pairs(table) do
			if k:upper() == item:upper() then
				_searchPath ..= ":" .. k
				Result = v
				return
			else
				if (type(v) == "table") and not Result then
					_recursiveSearch(v)
				end
			end
		end
	end

	-- Search in the index table.
	local Scope = self.Index
	if path then
		Scope = self.Index[path:upper()]
	end

	_recursiveSearch(Scope)
	return Result
end

-- Legacy compatibility function.
function ItemIndexService:GetFurnitureFromName(item)
	return self:GetItemFromName(item, "furniture")
end

function ItemIndexService.Client:GetCategory(Player, ItemIndex)
	return self.Server:GetCategory(ItemIndex)
end

function ItemIndexService.Client:GetBuild(Player, ItemIndex)
	return self.Server:GetBuild(ItemIndex)
end

function ItemIndexService.Client:GetSound(Player, ItemIndex)
	return self.Server:GetSound(ItemIndex)
end

function ItemIndexService.Client:GetItem(Player, ItemIndex)
	warn("Getting Item:", ItemIndex, self.Index)
	return self.Server:GetItem(ItemIndex)
end

function ItemIndexService.Client:GetTable(Player, Index)
	return self.Server.Index[Index:upper()]
end

function ItemIndexService:KnitStart()
	--whrr putt putt pop pop popop pop po-VROOOOOMMMMM
	--vROOMmm vROOMmmm
	--LOL
end

-- Method to initialize the ItemIndexService
function ItemIndexService:KnitInit()
	self:Load()
	self.Loaded = true
	self._loadedEvent:Fire(self)

	--print("ItemIndex:", self.Index)
	--print("Game:", self.Game)
end

return ItemIndexService
