return {
	Cash = 0,
	Diamonds = 100,
	Saves = "",
	SaveIndex = 1,
	Versions = {
		Ingredients = "Version 1.0", -- this will house ingredient data.
		Inventory = "Version 1.0", -- this will house all build set pieces and set data.
		Pizzeria = "Version 1.0", -- this will house all pizzeria placement data
	},

	Inventory = "",
	Pizzeria = "",

	Homes = {
		Index = 1,
		Data = "",
	},
	Bin = {
		Corn = 0,
	},
	Permissions = { -- whether or not players are allowed to buy/have access to things
	},

	Data_Tracking = {
		Player = {
			Pizzas_Made = 0,
			Customers_Served = 0,
			Customers = {
				Openers = 0,
				Common = 0,
				Uncommon = 0,
				Rare = 0,
				Legendary = 0,
				Federation = 0,
			},
			Playtime = 0,
		},
		Dev = {
			Last_Played = 0,
			Times_Played = 0,
		},
	},
}
