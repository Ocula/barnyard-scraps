-- DEPRECATED, SHOULD NOT BE USED.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Handler = require(Knit.Modules.Interface.get)

local Fusion = require(Knit.Library.Fusion)
local AssetLibrary = require(Knit.Library.AssetLibrary)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

--[[


]]

return function(props)
    if not props.Color then 
        props.Color = Value(Color3.new(1,1,1)) -- white as default or maybe a theme color as default tbh
    end

    if not props.PrimarySizeOffset or not props.PrimarySize then 
      props.PrimarySizeOffset = Value(0)
      props.PrimarySize = Value(props.Size or UDim2.fromScale(1,1)) 
    end 

    local circleSize = Computed(function(Use)
        local udimSize = Peek(props.PrimarySize) 
        local offsetSize = Peek(props.PrimarySizeOffset) 
        return UDim2.new(udimSize.X.Scale + offsetSize, 0, udimSize.Y.Scale + offsetSize, 0)
    end)

    local sizeSpring = Spring(circleSize, 30, .4) 

    local rotate = Value(0)
    local rotateSpring = Spring(rotate, 25, .4) 

	  return New "Frame" {
        Name = "CircleButton",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = props.Size or UDim2.fromScale(0.3, 0.5),
        LayoutOrder = props.LayoutOrder or 0,
        ZIndex = props.ZIndex, 
      
        [Children] = {
          New "Frame" {
            Name = "Holder",
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = sizeSpring,
            SizeConstraint = Enum.SizeConstraint.RelativeXX,
      
            [Children] = {
              New "Frame" {
                Name = "Button",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(1, 1),
                ZIndex = 3,
      
                [Children] = {
                  New "UICorner" {
                    Name = "UICorner",
                    CornerRadius = UDim.new(1, 0),
                  },
      
                  New "Frame" {
                    Name = "Background",
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = props.Color, 
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromScale(1, 1),
      
                    [Children] = {
                      New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(1, 0),
                      },
                    }
                  },
      
                  New "ImageLabel" {
                    Name = "Icon",
                    ImageTransparency = props.ImageTransparency or 0, 
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(0.5,0.5), 
                    Position = UDim2.new(0.5,0,0.5,0),
                    Rotation = rotateSpring, 
                    Size = Computed(function(Use)
                      local sizeSet = props.IconSize or 1 
                      return UDim2.fromScale(sizeSet, sizeSet) 
                    end), 
                    Image = props.Image or "", 
                    ImageColor3 = props.IconColor or Color3.new(1,1,1), 
                    ZIndex = 5,
      
                    [Children] = {
                      New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(1, 0),
                      },
                    }
                  },
      
                  New "TextButton" {
                    Name = "Button",
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                    Text = "",
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    TextSize = 14,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromScale(1.06, 1.06),

                    -- ADD EVENTS 
                    [OnEvent "MouseEnter"] = function()
                      if props.ButtonLock and Peek(props.ButtonLock) then return end
                      if props.OverheadLock and Peek(props.OverheadLock) then return end 

                      if props.Hover == false then 
                        return 
                      end 
                      
                      if props.PrimarySizeOffset then 
                        props.PrimarySizeOffset:set(.05)
                      end 

                      if props.PlusSign then 
                        rotate:set(90)
                      end 
                    end, 

                    [OnEvent "MouseLeave"] = function()
                      if props.ButtonLock and Peek(props.ButtonLock) then return end 
                      if props.OverheadLock and Peek(props.OverheadLock) then return end 

                      if props.Hover == false then 
                        return 
                      end 

                      if props.PrimarySizeOffset then 
                        props.PrimarySizeOffset:set(0) 
                      end 

                      if props.PlusSign then 
                        rotate:set(0) 
                      end 
                    end,

                    [OnEvent "MouseButton1Down"] = function()
                      if props.ButtonLock and Peek(props.ButtonLock) then return end 
                      if props.OverheadLock and Peek(props.OverheadLock) then return end 

                      if props.MouseButton1Down then
                        props.MouseButton1Down(props.PrimarySizeOffset, rotate, props.buttonDebounce) 
                      end
                    end, 

                    [OnEvent "MouseButton1Up"] = function() 
                      if props.ButtonLock and Peek(props.ButtonLock) then return end
                      if props.OverheadLock and Peek(props.OverheadLock) then return end 

                      if props.MouseButton1Up then 
                        props.MouseButton1Up(props.PrimarySizeOffset, rotate, props.buttonDebounce)
                      end 
                    end, 
                  },
                }
              },
      
              New "Frame" {
                Name = "Shadow",
                BackgroundColor3 = Computed(function(Use)
                    local color = Use(props.Color) 
                    local h, s, v = color:ToHSV() 
                    local newhue = if h == 0 then 0.02 else h 
                
                    return Color3.fromHSV(newhue - 0.02, s, v-0.15) -- always get a shadow of the main color of the button. 
                end),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1.03, 1.03),
                Visible = true,
      
                [Children] = {
                  New "UICorner" {
                    Name = "UICorner",
                    CornerRadius = UDim.new(1, 0),
                  },
                }
              },
      
              New "Frame" {
                Name = "Highlight",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(-0.02, -0.02),
                Size = UDim2.fromScale(1.02, 1.02),
                ZIndex = 2,
      
                [Children] = {
                  New "UICorner" {
                    Name = "UICorner",
                    CornerRadius = UDim.new(1, 0),
                  },
                }
              },
            }
          },
        }
      }
end
