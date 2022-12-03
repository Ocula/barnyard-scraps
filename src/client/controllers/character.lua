-- Robust character controller that we can use for multiple games and case uses.
--
-- ocula @ dec 3, 2022
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Player = game.Players.LocalPlayer

local character = Knit.CreateController({
	Name = "character",
	Style = "Classic",
	Objects = {},
})

function character:CreateObjects()
	local _partAnchor = Instance.new("Part")
	_partAnchor.Parent = Player.Character
	_partAnchor.Size = Vector3.new(2, 2, 2)
	_partAnchor.CanCollide = false
	_partAnchor.Transparency = 0.4
	_partAnchor.Color = Color3.new(0.074509, 0.501960, 0)

	-- Body Objects

	-- Index

	self.Objects.Anchor = _partAnchor
end

function character:SetMode(_mode)
	self.Style = _mode
end

function character:KnitStart() end

function character:KnitInit() end

return character
