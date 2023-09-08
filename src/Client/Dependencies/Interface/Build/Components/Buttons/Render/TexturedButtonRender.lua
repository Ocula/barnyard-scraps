local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

return function(self)
	local props = self.props
	local textureSize = props.PatternID.Size / 2
	local textureSpeed = props.TextureSpeed or Vector2.new(0, 2)

	local currentOffset = Peek(props.ImageRectOffset)
	local newOffset = currentOffset + textureSpeed

	if newOffset.X >= textureSize.X or newOffset.Y >= textureSize.Y then
		newOffset = Vector2.new(0, 0)
	end

	props.ImageRectOffset:set(newOffset)
end
