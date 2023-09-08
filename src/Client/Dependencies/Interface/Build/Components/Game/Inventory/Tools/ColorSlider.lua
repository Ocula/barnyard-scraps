local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService") 

local Knit = require(ReplicatedStorage.Packages.Knit)

local Interface = require(Knit.Modules.Interface.get)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

return function (props, signals) 
    local _lastString = Value("255")

    local textBoxReference = Value() 
    local dragFrameReference = Value() 
    local sliderPosition = Value(0) 

    local _instanceReference 

    local _textBoxFocused = Value(false) 

    local position = Computed(function(Use)
        return UDim2.fromScale(Use(sliderPosition),0.5) 
    end) 

    local positionSpring = Spring(position, 30, .85) 

    _instanceReference = New "Frame" {
        Name = props.Title,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        LayoutOrder = props.LayoutOrder or 0,
        Size = UDim2.fromScale(0.5, 0.33),
        ZIndex = 5,
    
        [Children] = {
            New "Frame" {
                Name = "Drag",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.8,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.125, 0.5),
                Size = UDim2.fromScale(0.6, 0.8),
                ZIndex = 5,
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.25, 0),
                    },
    
                    New "Frame" {
                        Name = "DragFrame",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(225, 130, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(0.9, 0.25),
                        ZIndex = 5,

                        [Ref] = dragFrameReference, 
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(1, 0),
                            },

                            New "TextButton" {
                                Name = "TextButton",
                                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                                Text = "",
                                TextColor3 = Color3.fromRGB(0, 0, 0),
                                TextSize = 14,
                                AnchorPoint = Vector2.new(0.5,0.5), 
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5,0.5),
                                Size = UDim2.fromScale(1.5, 1.5),
                                ZIndex = 6,

                                [OnEvent "MouseButton1Down"] = function()
                                    signals.MouseButton1Down:Fire(_instanceReference, sliderPosition, props.Name, props.TextBox) 
                                end, 

                                [OnEvent "MouseButton1Up"] = function()
                                    signals.MouseButton1Up:Fire()
                                end, 

                                [OnEvent "MouseLeave"] = function()
                                    signals.MouseLeave:Fire() 
                                end
                            },
    
                            New "Frame" {
                                Name = "Frame",
                                AnchorPoint = Vector2.new(0, 0.5),
                                BackgroundColor3 = Color3.fromRGB(247, 242, 200),
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = positionSpring,
                                Size = UDim2.fromScale(0.125, 0.125),
                                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                                ZIndex = 5,
    
                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(1, 0),
                                    },
    
                                    New "TextButton" {
                                        Name = "TextButton",
                                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                                        Text = "",
                                        TextColor3 = Color3.fromRGB(0, 0, 0),
                                        TextSize = 14,
                                        AnchorPoint = Vector2.new(0.5,0.5), 
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = UDim2.fromScale(0.5,0.5),
                                        Size = UDim2.fromScale(1.5, 1.5),
                                        ZIndex = 6,

                                        [OnEvent "MouseButton1Down"] = function()
                                            signals.MouseButton1Down:Fire(_instanceReference, sliderPosition, props.RGBValue, props.TextBox) 
                                        end, 

                                        [OnEvent "MouseButton1Up"] = function()
                                            signals.MouseButton1Up:Fire()
                                        end, 

                                        [OnEvent "MouseLeave"] = function()
                                            signals.MouseLeave:Fire() 
                                        end
                                    },
                                }
                            },
                        }
                    },
                }
            },
    
            New "Frame" {
                Name = "Number",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.8,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.75, 0.5),
                Size = UDim2.fromScale(0.225, 0.8),
                ZIndex = 5,
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.25, 0),
                    },
    
                    New "TextBox" {
                        Name = "TextBox",
                        CursorPosition = -1,
                        FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                        PlaceholderText = "255",
                        Text = Computed(function(Use)
                            if Use(_textBoxFocused) == false then 
                                return Peek(props.TextBox)
                            else 
                                return ""
                            end 
                        end),
                        ClearTextOnFocus = true,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextScaled = true,
                        TextSize = 14,
                        TextWrapped = true,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = 5,
    
                        [Children] = {
                            New "UITextSizeConstraint" {
                                Name = "UITextSizeConstraint",
                                MaxTextSize = 24,
                            },
                        },

                        [Ref] = textBoxReference,

                        [OnEvent "Focused"] = function()
                            _textBoxFocused:set(true) 
                        end, 

                        [OnEvent "FocusLost"] = function()
                            local textBox = Peek(textBoxReference)
                            local textCache = textBox.Text 
                            
                            _textBoxFocused:set(false) 

                            signals.TextBoxRequest:Fire(props.Name, textCache) 
                        end, 
                    },
                }
            },
    
            New "TextLabel" {
                Name = "TextLabel",
                FontFace = Font.new(
                    "rbxasset://fonts/families/Bangers.json",
                    Enum.FontWeight.Bold,
                    Enum.FontStyle.Normal
                ),
                Text = props.Title,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextScaled = true,
                TextSize = 18,
                TextStrokeColor3 = Color3.fromRGB(198, 123, 0),
                TextStrokeTransparency = 0,
                TextWrapped = true,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(0.125, 1),
                ZIndex = 5,
    
                [Children] = {
                    New "UITextSizeConstraint" {
                        Name = "UITextSizeConstraint",
                        MaxTextSize = 24,
                    },
                }
            },
        }
    }

    signals.NewSlider:Fire(props.Name, _instanceReference, sliderPosition, props.TextBox) 

    return _instanceReference
end 