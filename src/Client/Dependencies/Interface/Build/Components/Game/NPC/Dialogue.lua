local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Interface = require(Knit.Modules.Interface.get)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Size = Interface:GetUtilityBuild("Size") 

local function round(n)
    return math.floor(n + 0.5)
end 

--TODO animate last grapheme character with <font size="X"> .. </font>

return function (props)
    local Text = props.Text

    local TotalGraphemes = props.GraphemeTotal 
    local GraphemeSpring = props.GraphemeSpring 

    local Grapheme = Computed(function(Use)
        local Spr = Use(GraphemeSpring)
        local Total = Use(TotalGraphemes) 

        return round(Spr * Total) 
    end)

    return New "Frame" {
        Name = "Talk",
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = Color3.fromRGB(207, 207, 207),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Parent = props.Parent, 
        Visible = props.Visible, 
        Position = UDim2.fromScale(0.5, 0.955),
        Size = Size(Value(UDim2.fromOffset(600, 300))),
      
        [Children] = {
          New "UICorner" {
            Name = "UICorner",
            CornerRadius = UDim.new(0.1, 0),
          },
      
          New "Frame" {
            Name = "Header",
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = Color3.fromRGB(95, 204, 28),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.025, 0.083),
            Rotation = -3,
            Size = UDim2.fromScale(0.317, 0.167),
      
            [Children] = {
              New "UICorner" {
                Name = "UICorner",
                CornerRadius = UDim.new(0.1, 0),
              },
      
              New "UIStroke" {
                Name = "UIStroke",
                Color = Color3.fromRGB(76, 76, 76),
                Thickness = 8,
              },
      
              New "TextLabel" {
                Name = "TextLabel",
                FontFace = Font.new("rbxassetid://12187375716"),
                Text = props.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextScaled = true,
                TextSize = 14,
                TextWrapped = true,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 3,
      
                [Children] = {
                  New "UIStroke" {
                    Name = "UIStroke",
                    Color = Color3.fromRGB(76, 76, 76),
                    Thickness = 3,
                  },
                }
              },
      
              New "ImageLabel" {
                Name = "Bubble",
                Image = "rbxassetid://14629577704",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
              },
      
              New "ImageLabel" {
                Name = "Texture",
                Image = "rbxassetid://14005215526",
                ImageColor3 = Color3.fromRGB(48, 101, 0),
                ImageTransparency = 0.9,
                ResampleMode = Enum.ResamplerMode.Pixelated,
                ScaleType = Enum.ScaleType.Tile,
                TileSize = UDim2.fromOffset(512, 512),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 3,
      
                [Children] = {
                  New "UICorner" {
                    Name = "UICorner",
                    CornerRadius = UDim.new(1, 0),
                  },
                }
              },
            }
          },
      
          New "UIStroke" {
            Name = "UIStroke",
            Color = Color3.fromRGB(76, 76, 76),
            Thickness = 8,
          },
      
          New "Frame" {
            Name = "Body",
            BackgroundColor3 = Color3.fromRGB(152, 153, 154),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.025, 0.15),
            Size = UDim2.fromScale(0.95, 0.8),
            ZIndex = 2,
      
            [Children] = {
              New "UICorner" {
                Name = "UICorner",
                CornerRadius = UDim.new(0.1, 0),
              },
      
              New "TextLabel" {
                Name = "Text",
                FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                RichText = true,
                Text = Text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextScaled = true,
                TextSize = 24,
                MaxVisibleGraphemes = Grapheme, 
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.0265, 0.0579),
                Size = UDim2.fromScale(0.961, 0.872),
                ZIndex = 3,
      
                [Children] = {
                  New "UITextSizeConstraint" {
                    Name = "UITextSizeConstraint",
                    MaxTextSize = 36,
                  },
                }
              },
      
              New "UIStroke" {
                Name = "UIStroke",
                Color = Color3.fromRGB(76, 76, 76),
                Thickness = 8,
              },
      
              New "ImageButton" {
                Name = "Next",
                Image = "rbxassetid://14629656807",
                AnchorPoint = Vector2.new(1, 1),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(1, 1),
                Size = UDim2.fromScale(0.1, 0.1),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                ZIndex = 3,

                [OnEvent "MouseButton1Down"] = function()
                    props.Next:Fire() 
                end, 
      
                [Children] = {
                  New "UICorner" {
                    Name = "UICorner",
                    CornerRadius = UDim.new(1, 0),
                  },
                }
              },
            }
          },
      
          New "ImageLabel" {
            Name = "Texture",
            Image = "rbxassetid://14005215526",
            ImageColor3 = Color3.fromRGB(159, 154, 161),
            ImageTransparency = 0.9,
            ResampleMode = Enum.ResamplerMode.Pixelated,
            ScaleType = Enum.ScaleType.Tile,
            TileSize = UDim2.fromOffset(512, 512),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
      
            [Children] = {
              New "UICorner" {
                Name = "UICorner",
                CornerRadius = UDim.new(0.1, 0),
              },
            }
          },
        }
      }
end 
