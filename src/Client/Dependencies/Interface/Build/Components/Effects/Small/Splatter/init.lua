-- Paint Splatter Effect
--[=[
    API
        .new(Size, Position) -- Should be noted that Positions refer to the Center of the Splatter object

        :Play() -- Plays Splatter effect.
        :Hide(time) -- Hides the splatter. Can fade if given a time greater than 0. 
        :SetImages(array) -- Give the splatter a list of images to choose from. Otherwise, it will pick randomly from AssetLibrary.Interface.Game.Splatter.Striking
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Handler = require(Knit.Modules.Interface.get)
local InterfaceUtils = require(Knit.Library.InterfaceUtils)
local Utility = require(Knit.Library.Utility)
local AssetLibrary = require(Knit.Library.AssetLibrary)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Splatter = {}
Splatter.__index = Splatter

function Splatter.new(Size, Position, Image)
	local _chosenImage = Image

	if Image then
		local get = AssetLibrary.get(Image, AssetLibrary.Interface)
		if get then
			_chosenImage = get
		end
	else
		local _array = AssetLibrary.Assets.Interface.Game.Splatters.Striking
		local tableValue = Utility:GetRandomTableValue(_array)

		_chosenImage = tableValue
	end

	local self = setmetatable({}, Splatter)

	local _imageSize = InterfaceUtils.ResolveResolution(_chosenImage.Size, 1024)

	self.props = {
		Size = Value(Size + UDim2.new(0.5, 0, 0.5, 0)),
		Position = Value(Position),
		ImageId = _chosenImage.ID,
		Transparency = Value(1),
		ImageSize = Value(UDim2.new(_imageSize.X, 0, _imageSize.Y, 0)),
		ImagePosition = Value(UDim2.new(0.5, 0, 0.5, 0)),

		Memory = {
			_Size = Size,
			_Position = Position,
		},
	}

	self._object = Handler:GetComponent("Effects/Small/Splatter/SplatterObject")(self.props)

	return self
end

function Splatter:Play()
	-- Start size big
	-- self.props.Size:set(self.props.Memory._Size + UDim2.new(0.5,0,0.5,0))
	self.props.Transparency:set(0)
	self.props.Size:set(self.props.Memory._Size)

	task.delay(0, function()
		-- Create drip effect
		repeat
			local _currentSize = Peek(self.props.ImageSize)
			local _currentPosition = Peek(self.props.ImagePosition)

			self.props.ImageSize:set(UDim2.new(_currentSize.X.Scale + 0.025, 0, _currentSize.Y.Scale + 0.25, 0))
			self.props.ImagePosition:set(UDim2.new(_currentPosition.X.Scale, 0, _currentPosition.Y.Scale + 0.125, 0))

			task.wait(1.5)
		until self._hidden
	end)
end

function Splatter:Hide()
	self._hidden = true
	self.props.Transparency:set(1)
end

function Splatter:SetImages(_array)
	self.Images = _array
end

return Splatter
