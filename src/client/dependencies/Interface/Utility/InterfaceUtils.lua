-- Interface Utility Library
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Roact = require(ReplicatedStorage:FindFirstChild("Roact", true))

local InterfaceUtils = {}
InterfaceUtils.__Index = InterfaceUtils

-- Indexing Functions

function InterfaceUtils.getImageId(id)
	local Library = require(Knit.Library.AssetLibrary)
	local target = Library.Assets.Interface
	local retrieve

	local function search(x)
		for i, v in pairs(x) do
			if i == id then
				retrieve = v
				break
			end

			if type(v) == "table" then
				return search(v)
			end
		end
	end

	search(target)

	return "rbxassetid://" .. retrieve
end

-- Element Functions

function InterfaceUtils.getFrame(props)
	local _frameElement = {
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		Size = props.Size or UDim2.new(0.5, 0, 0.5, 0),
		Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = props.BackgroundColor3 or Color3.new(1, 1, 1),
		BackgroundTransparency = props.BackgroundTransparency or 1,
	}

	if props then
		for i, v in pairs(props) do
			_frameElement[i] = v
		end
	end

	return Roact.createElement("Frame", _frameElement)
end

function InterfaceUtils.getImageLabel(props)
	local _imageElement = {
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		Size = props.Size or UDim2.new(0.5, 0, 0.5, 0),
		Position = props.Position or UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = props.BackgroundColor3 or Color3.new(1, 1, 1),
		Image = props.Image,
		BackgroundTransparency = props.BackgroundTransparency or 1,
		ResampleMode = props.ResampleMode or Enum.ResamplerMode.Pixelated,
	}

	if props then
		for i, v in pairs(props) do
			_imageElement[i] = v
		end
	end

	return Roact.createElement("ImageLabel", _imageElement)
end

function InterfaceUtils.getLoadingBar(props)
	warn("Loadingbar props:", props)
	local _loadingBar = {
		Size = UDim2.new(props.Size.X.Scale or 0.285, 0, 0.1, 0),
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(0.5 - ((props.Size.X.Scale or 0.285) / 2), 0, 0.75, 0),
		BackgroundTransparency = 0,
		ZIndex = 5,
	}

	if props then
		for i, v in pairs(props) do
			_loadingBar[i] = v
		end
	end

	return Roact.createElement("Frame", _loadingBar, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
	})
end

function InterfaceUtils.getGradient(props)
	local _gradient = {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.new()),
		}),
	}

	if props then
		for i, v in pairs(props) do
			_gradient[i] = v
		end
	end

	return Roact.createElement("UIGradient", _gradient)
end

function InterfaceUtils.getCorner(props)
	local _corner = {
		CornerRadius = UDim.new(1, 0),
	}

	if props then
		for i, v in pairs(props) do
			_corner[i] = v
		end
	end

	return Roact.createElement("UICorner", _corner)
end

return InterfaceUtils
