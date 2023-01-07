local AssetLibrary = {}
AssetLibrary.__Index = AssetLibrary

AssetLibrary.Assets = {
	Interface = {
		Splash = {
			Building = 11948927290,
			Roof = 11948927468,
			LeftDoor = 11948927017,
			RightDoor = 11948926929,
			Silo = 11967563839,
			Grass = 11948927132,
			BackgroundTexture = 11967350158,
			StripeTexture = 11991918473,
		},
	},

	Audio = { -- Audio is organized by {[id], [timeToStart], [timeToEnd]}
		UI = {},
		Game = {
			Theme = {},
			Effects = {
				BirdFlutter1 = { 2 },
				BirdFlutter2 = { 1 },
				BirdFlutter3 = { 3 },
			},
		},
	},

	Game = {},
}

function AssetLibrary.search(query)
	local result

	local function recursiveSearch(target)
		if result then
			return
		end

		for searchindex, value in pairs(target) do
			if searchindex == "__Index" then
				continue
			end

			if result then
				break
			end

			if searchindex == query then
				result = value
				break
			else
				if type(value) == "table" then
					recursiveSearch(value)
				end
			end
		end
	end

	recursiveSearch(AssetLibrary)

	return result
end

function AssetLibrary.get(index)
	local searchResult = AssetLibrary.search(index)

	if not searchResult then
		warn(
			"Could not find the asset with the identification number that you are looking for. Double check your search query!",
			index
		)
		return
	end

	return searchResult
end

function AssetLibrary:Aggregate()
	-- Get an array of all IDs
	local _array = {}

	local function getAssets(x)
		for i, v in pairs(x) do
			if type(v) == "number" then
				table.insert(_array, "rbxassetid://" .. v) -- Indexing
			elseif type(v) == "table" then
				if v[1] and type(v[1]) == "number" then -- Indexing sound assets
					table.insert(_array, "rbxassetid://" .. v[1])
				else
					getAssets(v)
				end
			end
		end
	end

	getAssets(self.Assets)

	return _array
end

return AssetLibrary
