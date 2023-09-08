local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local InterfaceUtils = require(Knit.Library.InterfaceUtils)

return function(props)
	return New("ImageLabel")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = InterfaceUtils.getImageId("BackgroundTexture"),
		ScaleType = "Tile",
		TileSize = UDim2.new(0, Peek(props.Resolution) / 2, 0, Peek(props.Resolution) / 2),
		Size = UDim2.new(4, 0, 4, 0),

		Position = props.BackgroundTexture.Position,
		ImageTransparency = props.BackgroundTexture.Transparency,
		Rotation = 0,
	})
end
