local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService") 
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Interface = require(Knit.Modules.Interface.get)

local Size = Interface:GetUtilityBuild("Size")
local Size1D = Interface:GetUtilityBuild("1DSize") 

local GamepadButtonImage = {
	[Enum.KeyCode.ButtonX] = "rbxasset://textures/ui/Controls/xboxX.png",
	[Enum.KeyCode.ButtonY] = "rbxasset://textures/ui/Controls/xboxY.png",
	[Enum.KeyCode.ButtonA] = "rbxasset://textures/ui/Controls/xboxA.png",
	[Enum.KeyCode.ButtonB] = "rbxasset://textures/ui/Controls/xboxB.png",
	[Enum.KeyCode.DPadLeft] = "rbxasset://textures/ui/Controls/dpadLeft.png",
	[Enum.KeyCode.DPadRight] = "rbxasset://textures/ui/Controls/dpadRight.png",
	[Enum.KeyCode.DPadUp] = "rbxasset://textures/ui/Controls/dpadUp.png",
	[Enum.KeyCode.DPadDown] = "rbxasset://textures/ui/Controls/dpadDown.png",
	[Enum.KeyCode.ButtonSelect] = "rbxasset://textures/ui/Controls/xboxView.png",
	[Enum.KeyCode.ButtonStart] = "rbxasset://textures/ui/Controls/xboxmenu.png",
	[Enum.KeyCode.ButtonL1] = "rbxasset://textures/ui/Controls/xboxLB.png",
	[Enum.KeyCode.ButtonR1] = "rbxasset://textures/ui/Controls/xboxRB.png",
	[Enum.KeyCode.ButtonL2] = "rbxasset://textures/ui/Controls/xboxLT.png",
	[Enum.KeyCode.ButtonR2] = "rbxasset://textures/ui/Controls/xboxRT.png",
	[Enum.KeyCode.ButtonL3] = "rbxasset://textures/ui/Controls/xboxLS.png",
	[Enum.KeyCode.ButtonR3] = "rbxasset://textures/ui/Controls/xboxRS.png",
	[Enum.KeyCode.Thumbstick1] = "rbxasset://textures/ui/Controls/xboxLSDirectional.png",
	[Enum.KeyCode.Thumbstick2] = "rbxasset://textures/ui/Controls/xboxRSDirectional.png",
}

local KeyboardButtonImage = {
	[Enum.KeyCode.Backspace] = "rbxasset://textures/ui/Controls/backspace.png",
	[Enum.KeyCode.Return] = "rbxasset://textures/ui/Controls/return.png",
	[Enum.KeyCode.LeftShift] = "rbxasset://textures/ui/Controls/shift.png",
	[Enum.KeyCode.RightShift] = "rbxasset://textures/ui/Controls/shift.png",
	[Enum.KeyCode.Tab] = "rbxasset://textures/ui/Controls/tab.png",
}

local KeyboardButtonIconMapping = {
	["'"] = "rbxasset://textures/ui/Controls/apostrophe.png",
	[","] = "rbxasset://textures/ui/Controls/comma.png",
	["`"] = "rbxasset://textures/ui/Controls/graveaccent.png",
	["."] = "rbxasset://textures/ui/Controls/period.png",
	[" "] = "rbxasset://textures/ui/Controls/spacebar.png",
}

local KeyCodeToTextMapping = {
	[Enum.KeyCode.LeftControl] = "Ctrl",
	[Enum.KeyCode.RightControl] = "Ctrl",
	[Enum.KeyCode.LeftAlt] = "Alt",
	[Enum.KeyCode.RightAlt] = "Alt",
	[Enum.KeyCode.F1] = "F1",
	[Enum.KeyCode.F2] = "F2",
	[Enum.KeyCode.F3] = "F3",
	[Enum.KeyCode.F4] = "F4",
	[Enum.KeyCode.F5] = "F5",
	[Enum.KeyCode.F6] = "F6",
	[Enum.KeyCode.F7] = "F7",
	[Enum.KeyCode.F8] = "F8",
	[Enum.KeyCode.F9] = "F9",
	[Enum.KeyCode.F10] = "F10",
	[Enum.KeyCode.F11] = "F11",
	[Enum.KeyCode.F12] = "F12",
}

return function(props)

    -- Prompt things
    local Prompt = props.Prompt 
    local ObjectText = Value(Prompt.ObjectText) 

    props.Cleaner:GiveTask(Prompt:GetPropertyChangedSignal("ObjectText"):Connect(function()
        warn("Object text changed") 
        ObjectText:set(Prompt.ObjectText) 
    end))

    -- Keycode Pop
    local KeycodePop = Value(0) 
    local KeycodePopSpring = Spring(KeycodePop, 25, .6)

    props.Cleaner:GiveTask(Prompt.Triggered:Connect(function()
        KeycodePop:set(-.1) 
    end))
    
    props.Cleaner:GiveTask(Prompt.TriggerEnded:Connect(function()
        KeycodePopSpring:addVelocity(.3)
        KeycodePop:set(0)
    end))

    -- Sizing
    local SizeMultiplier = props.SizeMultiplier 
    local SizeSpring = Spring(SizeMultiplier, 25, .6)  

    local SizeComputed = Size(Computed(function(Use)
        local SizeSpringSet = Use(SizeSpring)
        return UDim2.fromOffset(250 * SizeSpringSet, 125 * SizeSpringSet)
    end))

    local SizeOffset = props.SizeOffset 
    local SizeOffsetCalculation = Computed(function(Use)
        local Offset = Use(SizeOffset) 
        local SizeComp = Use(SizeComputed) 

        return Vector2.new(Offset.X / SizeComp.X.Offset, Offset.Y / SizeComp.Y.Offset)
    end)
    
    --> Input 
    local InputType = props.InputType 

    -- @ROBLOX -> Taken from Documentation page: https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt
    local KeyboardText = UserInputService:GetStringForKeyCode(Prompt.KeyboardKeyCode)
    local ButtonTextImage = KeyboardButtonImage[Prompt.KeyboardKeyCode] 
    local GamepadButtonImageIcon = GamepadButtonImage[Prompt.GamepadKeyCode]
    local TouchImage = "rbxasset://textures/ui/Controls/TouchTapIcon.png"
    
    if ButtonTextImage == nil then 
        ButtonTextImage = KeyboardButtonIconMapping[KeyboardText] 
    end 

    if ButtonTextImage == nil then 
        local KeycodeMappedText = KeyCodeToTextMapping[Prompt.KeyboardKeyCode]

        if KeycodeMappedText then 
            KeyboardText = KeycodeMappedText
        end 
    end 

    -- Background
    local HideBackground = Prompt:GetAttribute("HideBackground")

    -- Local Colors 
    local Background = Prompt:GetAttribute("Background")
    local KeycodeBackground = Prompt:GetAttribute("KeycodeBackground")
    local KeystrokeColor = Prompt:GetAttribute("KeystrokeColor") 
    local Trim = Prompt:GetAttribute("Trim") 

    return New "BillboardGui" {
        Name = "BillboardGui",
        Active = true,
        AlwaysOnTop = true,
        Enabled = props.Enabled, 
        Parent = props.Parent, 
        Adornee = props.Adornee, 
        Size = SizeComputed,
        SizeOffset = SizeOffsetCalculation, 
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    
        [Children] = {
            New "Frame" {
                Name = "Proximity",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Background,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                BackgroundTransparency = Computed(function(Use)
                    if HideBackground then 
                        return 1
                    else 
                        return 0
                    end 
                end),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(1, 1),
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.25, 0),
                    },
    
                    New "UIStroke" {
                        Name = "UIStroke",
                        Color = Color3.fromRGB(76, 76, 76),
                        Thickness = Size1D(8),

                        Enabled = Computed(function(Use)
                            if HideBackground then 
                                return false
                            else 
                                return true 
                            end 
                        end), 
                    },
    
                    New "ImageLabel" {
                        Name = "Light",
                        Image = "rbxassetid://14479002642",
                        TileSize = UDim2.fromOffset(512, 512),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Visible = Computed(function(Use)
                            if HideBackground then 
                                return false
                            else 
                                return true 
                            end 
                        end), 
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(0.975, 0.975),
                        ZIndex = 4,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.25, 0),
                            },
                        }
                    },
    
                    New "Frame" {
                        Name = "Keycode",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = KeycodeBackground,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        LayoutOrder = 2,
                        Position = UDim2.fromScale(0.25, 0.5),
                        Size = Computed(function(Use)
                            local KeycodePopSpringSet = Use(KeycodePopSpring)
                            return UDim2.fromScale(0.75 + KeycodePopSpringSet, 0.75 + KeycodePopSpringSet)
                        end),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        ZIndex = 5,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(1, 0),
                            },
    
                            New "Frame" {
                                Name = "WhiteStroke",
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Size = UDim2.fromScale(1, 1),
    
                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(1, 0),
                                    },
    
                                    New "UIStroke" {
                                        Name = "UIStroke",
                                        Color = Color3.fromRGB(76, 76, 76),
                                        Thickness = Size1D(8),
                                    },
                                }
                            },
    
                            New "ImageButton" {
                                Name = "Button",
                                Image = "rbxassetid://14465236652",
                                ImageTransparency = 1,
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(1, 1),
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                ZIndex = 3,


                                [OnEvent "MouseEnter"] = function()
                                    KeycodePop:set(.1)
                                end, 

                                [OnEvent "MouseLeave"] = function()
                                    KeycodePop:set(0)
                                end,

                                [OnEvent "MouseButton1Down"] = function()
                                    KeycodePop:set(-.1) 
                                end, 

                                [OnEvent "MouseButton1Up"] = function()
                                    KeycodePopSpring:addVelocity(.3)
                                    KeycodePop:set(0) 

                                    if props.MouseButton1Up then 
                                        props.MouseButton1Up() 
                                    end 
                                end, 

                                [OnEvent "InputBegan"] = function(input)
                                    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and input.UserInputState ~= Enum.UserInputState.Change then
                                        Prompt:InputHoldBegin()
                                    end
                                end, 

                                [OnEvent "InputEnded"] = function(input)
                                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                                        Prompt:InputHoldEnd()
                                    end
                                end, 
                            },
    
                            New "Frame" {
                                Name = "Keystroke",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = KeystrokeColor or KeycodeBackground,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(0.7, 0.7),
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                ZIndex = 4,
    
                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(1, 0),
                                    },
                                }
                            },
    
                            New "ImageLabel" {
                                Name = "ImageLabel",
                                Image = "rbxassetid://14465129538",
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Size = UDim2.fromScale(1, 1),
                            },
    
                            New "Frame" {
                                Name = "Inputs",
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Size = UDim2.fromScale(1, 1),
                                ZIndex = 4,
    
                                [Children] = {
                                    New "ImageLabel" {
                                        Name = "Key",
                                        Image = "rbxasset://textures/ui/Controls/key_single.png",
                                        AnchorPoint = Vector2.new(0.5, 0.5),
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = UDim2.fromScale(0.5, 0.5),
                                        Size = UDim2.fromScale(0.45, 0.45),
                                        Visible = if InputType == Enum.ProximityPromptInputType.Keyboard then true else false,
                                        ZIndex = 8,
    
                                        [Children] = {
                                            New "TextLabel" {
                                                Name = "TextLabel",
                                                FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                                                Text = if KeyboardText then KeyboardText else "",
                                                TextColor3 = Color3.fromRGB(255, 255, 255),
                                                TextScaled = true,
                                                TextSize = 14,
                                                TextWrapped = true,
                                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                                BackgroundTransparency = 1,
                                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                                BorderSizePixel = 0,
                                                Size = UDim2.fromScale(1, 0.9),
                                            },

                                            New "ImageLabel" {
                                                Name = "ButtonImage",
                                                Image = ButtonTextImage,
                                                AnchorPoint = Vector2.new(0.5, 0.5),
                                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                                BackgroundTransparency = 1,
                                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                                BorderSizePixel = 0,
                                                Position = UDim2.fromScale(0.5, 0.5),
                                                Size = UDim2.fromScale(1, 1),
                                                Visible = if ButtonTextImage then true else false,
                                                ZIndex = 5,
                                            },
                                        },
                                    },
    
                                    New "ImageLabel" {
                                        Name = "Touch",
                                        Image = TouchImage,
                                        AnchorPoint = Vector2.new(0.5, 0.5),
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = UDim2.fromScale(0.5, 0.5),
                                        Size = UDim2.fromScale(0.35, 0.45),
                                        Visible = if InputType == Enum.ProximityPromptInputType.Touch then true else false,
                                        ZIndex = 8,
                                    },
    
                                    New "ImageLabel" {
                                        Name = "Controller",
                                        Image = GamepadButtonImageIcon,
                                        AnchorPoint = Vector2.new(0.5, 0.5),
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = UDim2.fromScale(0.5, 0.5),
                                        Size = UDim2.fromScale(0.45, 0.45),
                                        Visible = if InputType == Enum.ProximityPromptInputType.Gamepad then true else false,
                                        ZIndex = 8,
                                    },
                                }
                            },
                        }
                    },
    
                    New "Frame" {
                        Name = "Context",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0),
                        Size = UDim2.fromScale(0.45, 1),
                        ZIndex = 6,
    
                        [Children] = {
                            New "UIListLayout" {
                                Name = "UIListLayout",
                                Padding = UDim.new(0, 5),
                                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                            },
    
                            New "TextLabel" {
                                Name = "Action",
                                FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                                Text = Prompt.ActionText,
                                TextColor3 = Color3.fromRGB(255, 255, 255),
                                TextScaled = true,
                                TextSize = 14,
                                TextWrapped = true,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                LayoutOrder = 1,
                                Size = UDim2.fromScale(0.85, 0.35),
    
                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(1, 0),
                                    },
    
                                    New "UIStroke" {
                                        Name = "UIStroke",
                                        Color = Color3.fromRGB(76, 76, 76),
                                        Thickness = Size1D(4),
                                    },
                                }
                            },
    
                            New "Frame" {
                                Visible = Computed(function(Use)
                                    if Use(ObjectText) == "" then 
                                        return false 
                                    else 
                                        return true 
                                    end 
                                end), 
                                Name = "ContextFrame",
                                BackgroundColor3 = Trim,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Size = UDim2.fromScale(1, 0.35),
    
                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(1, 0),
                                    },
    
                                    New "TextLabel" {
                                        Name = "ContextText",
                                        FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                                        Text = ObjectText,
                                        TextColor3 = Color3.fromRGB(255, 255, 255),
                                        TextScaled = true,
                                        TextSize = 14,
                                        TextWrapped = true,
                                        AnchorPoint = Vector2.new(0.5, 0.5),
                                        BackgroundColor3 = Color3.fromRGB(154, 154, 154),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = UDim2.fromScale(0.5, 0.5),
                                        Size = UDim2.fromScale(0.8, 0.8),
                                        ZIndex = 7,
    
                                        [Children] = {
                                            New "UICorner" {
                                                Name = "UICorner",
                                                CornerRadius = UDim.new(1, 0),
                                            },
    
                                            New "UIStroke" {
                                                Name = "UIStroke",
                                                Enabled = Computed(function(Use)
                                                    if HideBackground then 
                                                        return false 
                                                    else 
                                                        return true 
                                                    end 
                                                end), 
                                                Color = Computed(function(Use)
                                                    local h,s,v = Trim:ToHSV()
                                                    local newhue = if h == 0 then 0.02 else h 

                                                    local shadow = Color3.fromHSV(newhue-0.02,s,v-0.05) 

                                                    return shadow
                                                end),
                                                Thickness = Size1D(3),
                                            },
                                        }
                                    },
                                }
                            },
                        }
                    },
                }
            },
        }
    }
end 