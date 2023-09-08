local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Utility = require(Knit.Library.Utility)

local RunService = game:GetService("RunService")
local AssetLibrary = {}
AssetLibrary.__Index = AssetLibrary

AssetLibrary.Assets = {
	Interface = {
		Textures = {
			Giraffe = {
				ID = "rbxassetid://12179976153",
				Size = Vector2.new(1024, 1024),
			},
			SquareSquiggles = {
				ID = "rbxassetid://12181829304",
				Size = Vector2.new(1024, 1024),
			},

			PolkaDot = {
				ID = "rbxassetid://14080052911",
				Size = Vector2.new(1024,1024)
			}
		},
		
		Buttons = {
			PaintDrip1 = {
				ID = "rbxassetid://12181502342",
				Size = Vector2.new(500, 100),
			},
			PaintDrip2 = {
				ID = "rbxassetid://12181515975",
				Size = Vector2.new(500, 100),
			},
			FadeUp = {
				ID = "rbxassetid://12180711062",
				Size = Vector2.new(1024, 1024),
			},
		},

		Chicken = {
			Backtail = {
				ID  = "rbxassetid://14283855092",
				Size = Vector2.new(282, 302),

				Scale = Vector2.new(0.7255859375, 0.6865234375)
			},

			Headtail = {
				ID = "rbxassetid://14283853323",
				Size = Vector2.new(255, 241),

				Scale = Vector2.new(0.37158203125, 0.16552734375), 
			},

			Arm = {
				ID = "rbxassetid://14283853241",
				Size = Vector2.new(262, 236),

				Scale = Vector2.new(0.5458984375, 0.55078125),
			},

			Body = {
				ID = "rbxassetid://14283877155",
				Size = Vector2.new(524, 723), 

				Scale = Vector2.new(0.4013671875, 0.58154296875), 
			},

			RLeg = {
				ID = "rbxassetid://14283852930",
				Size = Vector2.new(87, 87), 

				Scale = Vector2.new(0.58837890625, 0.87646484375), 
			},

			LLeg = {
				ID = "rbxassetid://14283853071", 
				Size = Vector2.new(87, 87), 

				Scale = Vector2.new(0.34619140625, 0.90966796875), 
			},
		},

		Splash = { -- Legacy ID System for UI assets
			Building = {
				ID = "rbxassetid://11948927290",
				Size = Vector2.new(771, 318),
			},
			Roof = {
				ID = "rbxassetid://11948927468",
				Size = Vector2.new(872, 451),
			},
			LeftDoor = {
				ID = "rbxassetid://11948927017",
				Size = Vector2.new(188, 318),
			},
			RightDoor = {
				ID = "rbxassetid://11948926929",
				Size = Vector2.new(188, 318),
			},
			Silo = {
				ID = "rbxassetid://11967563839",
				Size = Vector2.new(256, 871),
			},
			Grass = {
				ID = "rbxassetid://11948927132",
				Size = Vector2.new(984, 119),
			},
			BackgroundTexture = {
				ID = "rbxassetid://11967350158",
				Size = Vector2.new(1024, 1024),
			},
			StripeTexture = {
				ID = "rbxassetid://11991918473",
				Size = Vector2.new(1024, 1024),
			},
		},

		Game = {
			Icons = {
				PlusSign = {
					ID = "rbxassetid://13958562686",
					Size = Vector2.new(1000,1000),
				},

				Checkmark = {
					ID = "rbxassetid://14015899211",
					Size = Vector2.new(1024,1024)
				},

				Play = {
					ID = "rbxassetid://14023735276",
					Size = Vector2.new(1024,1024)
				},

				Pencil = {
					ID = "rbxassetid://14015855151",
					Size = Vector2.new(1024,1024)
				},

				Trashcan = {
					ID = "rbxassetid://14015878622",
					Size = Vector2.new(512,512)
				},

				X = {
					ID = "rbxassetid://14016261220",
					Size = Vector2.new(1024,1024),
				},

				-- case sensitive icons for inventory ui
				curves = {
					ID = "rbxassetid://14079928734",
					Size = Vector2.new(1024,1024), 
				},

				basic = {
					ID = "rbxassetid://14079928372",
					Size = Vector2.new(1024,1024), 
				},

				turns = {
					ID = "rbxassetid://14079928500",
					Size = Vector2.new(1024,1024), 
				},

				rise = {
					ID = "rbxassetid://14079928217",
					Size = Vector2.new(1024,1024), 
				},
				
				Stop = {
					ID = "rbxassetid://14198111978",
					Size = Vector2.new(512, 512),
				},

				Pause = {
					ID = "rbxassetid://14197857438",
					Size = Vector2.new(512, 512), 
				},

				Reset = {
					ID = "rbxassetid://14197857295",
					Size = Vector2.new(512, 512),
				},
				
				SetStart = {
					ID = "rbxassetid://14220649167",
					Size = Vector2.new(512, 512), 
				},

				Back = {
					ID = "rbxassetid://14197857645",
					Size = Vector2.new(512, 512)
				},

				PlaceTool = {
					ID = "rbxassetid://14101725029",
					Size = Vector2.new(512, 512)
				},

				RotateTool = {
					ID = "rbxassetid://14101724804",
					Size = Vector2.new(512, 512)
				},

				MoveTool = {
					ID = "rbxassetid://14101725328",
					Size = Vector2.new(512, 512)
				},

				PaintTool = {
					ID = "rbxassetid://14102476151",
					Size = Vector2.new(512, 512) 
				},

				DeleteTool = {
					ID = "rbxassetid://14015878622",
					Size = Vector2.new(512,512)
				},
			},

			Splatters = {
				Cartoon = { -- 12 to use
					-- Cartoony splatters, use for more UI base interactions
					CartoonSplatter1 = {
						ID = "rbxassetid://12157341441",
						Size = Vector2.new(1334, 1305),
					},
					CartoonSplatter2 = {
						ID = "rbxassetid://12157341138",
						Size = Vector2.new(1288, 1094),
					},
					CartoonSplatter3 = {
						ID = "rbxassetid://12157340890",
						Size = Vector2.new(1184, 1127),
					},
					CartoonSplatter4 = {
						ID = "rbxassetid://12157340588",
						Size = Vector2.new(1046, 932),
					},
					CartoonSplatter5 = {
						ID = "rbxassetid://12157340282",
						Size = Vector2.new(1158, 1051),
					},
					CartoonSplatter6 = {
						ID = "rbxassetid://12157339975",
						Size = Vector2.new(916, 753),
					},
					CartoonSplatter7 = {
						ID = "rbxassetid://12157339752",
						Size = Vector2.new(824, 903),
					},
					CartoonSplatter8 = {
						ID = "rbxassetid://12157339394",
						Size = Vector2.new(794, 874),
					},
					CartoonSplatter9 = {
						ID = "rbxassetid://12157339015",
						Size = Vector2.new(995, 788),
					},
					CartoonSplatter10 = {
						ID = "rbxassetid://12157338846",
						Size = Vector2.new(846, 854),
					},
					CartoonSplatter11 = {
						ID = "rbxassetid://12157338675",
						Size = Vector2.new(772, 737),
					},
					CartoonSplatter12 = {
						ID = "rbxassetid://12157338498",
						Size = Vector2.new(825, 704),
					},
				},
				Striking = { -- 19 splatters to use.
					-- Striking splatters. Good for kills / quick flash UI.
					StrikingSplatter1 = {
						ID = "rbxassetid://12157073938",
						Size = Vector2.new(1085, 1203),
					},
					StrikingSplatter2 = {
						ID = "rbxassetid://12157073682",
						Size = Vector2.new(979, 991),
					},
					StrikingSplatter3 = {
						ID = "rbxassetid://12157073472",
						Size = Vector2.new(791, 809),
					},
					StrikingSplatter4 = {
						ID = "rbxassetid://12157073305",
						Size = Vector2.new(1085, 897),
					},
					StrikingSplatter5 = {
						ID = "rbxassetid://12157073000",
						Size = Vector2.new(1070, 1037),
					},
					StrikingSplatter6 = {
						ID = "rbxassetid://12157072590",
						Size = Vector2.new(875, 899),
					},
					StrikingSplatter7 = {
						ID = "rbxassetid://12157072418",
						Size = Vector2.new(896, 949),
					},
					StrikingSplatter8 = {
						ID = "rbxassetid://12157072242",
						Size = Vector2.new(1085, 1093),
					},
					StrikingSplatter9 = {
						ID = "rbxassetid://12157072067",
						Size = Vector2.new(926, 902),
					},
					StrikingSplatter10 = {
						ID = "rbxassetid://12157071859",
						Size = Vector2.new(1085, 981),
					},
					StrikingSplatter11 = {
						ID = "rbxassetid://12157071599",
						Size = Vector2.new(1085, 1055),
					},
					StrikingSplatter12 = {
						ID = "rbxassetid://12157071370",
						Size = Vector2.new(1085, 1059),
					},
					StrikingSplatter13 = {
						ID = "rbxassetid://12157070978",
						Size = Vector2.new(966, 905),
					},
					StrikingSplatter14 = {
						ID = "rbxassetid://12157070790",
						Size = Vector2.new(892, 906),
					},
					StrikingSplatter15 = {
						ID = "rbxassetid://12157070565",
						Size = Vector2.new(1159, 1121),
					},
					StrikingSplatter16 = {
						ID = "rbxassetid://12157070343",
						Size = Vector2.new(1061, 986),
					},
					StrikingSplatter17 = {
						ID = "rbxassetid://12157070111",
						Size = Vector2.new(775, 934),
					},
					StrikingSplatter18 = {
						ID = "rbxassetid://12157069926",
						Size = Vector2.new(1301, 880),
					},
					StrikingSplatter19 = {
						ID = "rbxassetid://12157069710",
						Size = Vector2.new(906, 823),
					},
				}, -- More noise to these splatters... use for in-match purposes.
				Wall = {
					WallSplatter1 = {
						ID = "rbxassetid://12156990479",
						Size = Vector2.new(1737, 565),
					},
					WallSplatter2 = {
						ID = "rbxassetid://12156990236",
						Size = Vector2.new(1648, 491),
					},
					WallSplatter3 = {
						ID = "rbxassetid://12156989989",
						Size = Vector2.new(1543, 703),
					},
					WallSplatter4 = {
						ID = "rbxassetid://12156989773",
						Size = Vector2.new(1460, 384),
					},
					WallSplatter5 = {
						ID = "rbxassetid://12156989632",
						Size = Vector2.new(1389, 604),
					},
					WallSplatter6 = {
						ID = "rbxassetid://12156989435",
						Size = Vector2.new(1336, 1334),
					},
					WallSplatter7 = {
						ID = "rbxassetid://12156989047",
						Size = Vector2.new(1653, 2198),
					},
					WallSplatter8 = {
						ID = "rbxassetid://12156988416",
						Size = Vector2.new(1868, 1840),
					},
					WallSplatter9 = {
						ID = "rbxassetid://12156987937",
						Size = Vector2.new(2289, 1499),
					},
				}, -- Dripping down the wall
			},
			Match = {},
		},
	},

	Animations = {
		Doors = {
			Barnhouse1 = {
				Open = "rbxassetid://14278758806",
				Close = "rbxassetid://14271130280",
			}
		},

		Transitions = {
			ChickenAnimations = {
				Run = "rbxassetid://14414470404",
			},
		},

		Sandbox = {
			Wheelbarrow = {
				Up = "rbxassetid://14478507082",
				Down = "rbxassetid://14478534426",
				Collect = "rbxassetid://14478541864",
			}
		}
	},

	Audio = { -- Audio is organized by {[id], [timeToStart], [timeToEnd]}
		UI = {},
		Game = {
			Theme = {
				
			},
			Effects = {
				DominoClick = {
					SoundId = "rbxassetid://156286438", 
				},

				Pop = {
					SoundId = "rbxassetid://4607031412",
					Start = 0.815,
				},
				
				Delete = {
					SoundId = "rbxassetid://14105375350", 
				},

				Place = {
					SoundId = "rbxassetid://14105342383",
				},

				Paint = {
					SoundId = "rbxassetid://9120584671", 
				},

				Shake1 = {
					SoundId = "rbxassetid://12087471292",
					Start = 3,
					--End = 0.76,
					PlaybackSpeed = 0.8,
				},
				Shake2 = {
					SoundId = "rbxassetid://12087471292",
					Start = 3,
					--End = 1.4,
					PlaybackSpeed = 0.9,
				},
				Shake3 = {
					SoundId = "rbxassetid://12087471292",
					Start = 3,
					PlaybackSpeed = 0.7,
				},
			},
		},
	},
}

function AssetLibrary.search(query, scope)
	local result, parent

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
					parent = target
					recursiveSearch(value)
				end
			end
		end
	end

	recursiveSearch(scope or AssetLibrary)

	return result, parent
end

function AssetLibrary.getRandom(scope)
	local currentScope = scope

	if not currentScope then
		currentScope = AssetLibrary.Assetsx
	end

	local randomObject = Utility:GetRandomTableValue(scope)

	return randomObject
end

function AssetLibrary.get(index, scope)
	local searchResult = AssetLibrary.search(index, scope)

	if not searchResult then
		warn(
			"Could not find the asset with the identification string that you are looking for. Double check your search query!",
			index
		)
		return
	end

	return searchResult
end

function AssetLibrary.getMap(search)
	return AssetLibrary.get(search, AssetLibrary.Game)
end

function AssetLibrary:BuildServer()
	local GameBin = game:GetService("ServerStorage"):WaitForChild("Game")
	local bin = {}

	local function build(parent, tbl)
		for i, v in pairs(tbl) do --
			if type(v) == "userdata" then
				if not v:IsA("Folder") then
					parent[v.Name] = v
				else
					if v:GetAttribute("Ignore") then
						continue
					end

					parent[v.Name] = {}
					build(parent[v.Name], v:GetChildren())
				end
			end
		end
	end

	build(bin, GameBin:GetChildren())

	self.Assets.Game = bin
end

function AssetLibrary:Aggregate(scope) 
	if not RunService:IsClient() then
		return
	end

	-- Get an array of all IDs

	local _array = {}

	local function getAssets(x)
		if not x then return end 

		for i, v in pairs(x) do
			if type(v) == "string" and v:sub(1, 13):lower() == "rbxassetid://" then
				table.insert(_array, v)
			elseif type(v) == "table" then
				getAssets(v) 
			end
		end
	end

	getAssets(scope) 

	return _array
end

return AssetLibrary
