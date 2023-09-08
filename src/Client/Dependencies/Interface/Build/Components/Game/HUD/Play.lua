local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Interface = require(Knit.Modules.Interface.get)

local HUDButton = Interface:GetComponent("Buttons/HUDButton") 
local Size = Interface:GetUtilityBuild("Size")
local Size1D = Interface:GetUtilityBuild("1DSize") 

local Maid = require(Knit.Library.Maid)

local function round(n)
    return math.floor(n + 0.5)
end 

return function (props)

    local MaidObject = Maid.new()

    local Selected = props.Selected

    local Position = Computed(function(Use)
        return UDim2.fromScale(0.5, 
            if Use(props.Visible.Edit) then 
                0 
            else 
                -1.25
            ) 
    end) 

    local PositionSpring = Spring(Position, 25, .95) 

    local Visible = Computed(function(Use)
        return Use(PositionSpring).Y.Scale > -1
    end)

    local Locks = props.Locks 

    local Play = Interface:GetClass("Game/Play").new() 
    local SetStart = Interface:GetClass("Game/Play/SetStart").new() 

    local Debounces = {
        Play = false, 
        SetStart = false, 
        Pause = false, 
    }

    Play.SetStart = SetStart 

    -- progress bar
    local Progress = Value(0) 
    local ProgressSpring = Spring(Progress, 25, .6)

    Play.Update:Connect(function(_toGo)
        Progress:set(_toGo) 
    end)

    local function checkInventoryToggle()
        local isInventoryToggled = not (
            Peek(props.Toggled.SetStart) or 
            Peek(props.Toggled.Play) or 
            Peek(props.Toggled.Pause)
        )

        local InterfaceController = Knit.GetController("Interface")
        local Inventory = InterfaceController.Game.Menus.Inventory 
        local HUD = InterfaceController.Game.HUD 

        if Peek(HUD.Toggles.Edit) == false then 
            warn("is false bro")
            return 
        end 

        Inventory:Toggle(isInventoryToggled, {
            --Settings = true, 
            --Shop = true,
            --Teleport = true, 
        }) 
    end 

    local function untoggleOthers(target)
        for i, v in props.Toggled do 
            if v ~= target and i ~= "Edit" then 
                v:set(false) 
            end 
        end
    end 

    MaidObject:GiveTask(Observer(props.Toggled.SetStart):onChange(function()
        local Toggled = Peek(props.Toggled.SetStart) 

        if Toggled then 
            SetStart:Enable() 
            Selected:set("SetStart") 
        else
            -- check if others are toggled
            local okayToSetSelect = not (Peek(props.Toggled.Play) or Peek(props.Toggled.Pause)) 

            SetStart:Disable() 

            if okayToSetSelect then 
                Selected:set("") 
            end 
        end 

        checkInventoryToggle() 
    end))

    MaidObject:GiveTask(Observer(props.Toggled.Play):onChange(function()
        local Toggled = props.Toggled.Play

        -- first check
        if Peek(Toggled) == true then 
            local DominoController = Knit.GetController("DominoController")

            if DominoController.Paused then 
                props.Toggled.Pause:set(false) 
                
                Selected:set("Play") 

                Play:Pause(false) 

                return 
            end 

            untoggleOthers(props.Toggled.Play)

            -- check 
            local isOkay, failMessage = Play:Check() 

            if not isOkay then 
                Toggled:set(false) 
                return 
            end 

            Selected:set("Play") 

            Locks.SetStart:set(true)
            Locks.Pause:set(false) 

            -- 
            task.spawn(function()
                Play:Play() 
            end) 

            Debounces.Play = false 
        elseif Peek(Toggled) == false then 
            local DominoController = Knit.GetController("DominoController")

            if DominoController.Paused then 
                return 
            end 

            Selected:set("") 

            Locks.SetStart:set(false) 
            Locks.Pause:set(true)

            Play:Stop() 

            Debounces.Play = false 
        end

        checkInventoryToggle() 
    end))

    MaidObject:GiveTask(Observer(props.Toggled.Pause):onChange(function()
        local Toggled = props.Toggled.Pause

        Play:Pause(Peek(Toggled))

        if Peek(Toggled) then 
            untoggleOthers(props.Toggled.Pause)

            Selected:set("Pause")
        else 
            if Peek(props.Toggled.Play) == false then 
                props.Toggled.Play:set(true) 
            end 

            Selected:set("Play")
        end
    end))

    MaidObject:GiveTask(Observer(props.Visible.Edit):onChange(function()
        local isVisible = Peek(props.Visible.PlayPanel.Parent)

        if not isVisible then 
            props.Toggled.Edit:set(false)
            props.Toggled.Play:set(false) 
        end 
    end)) 

    return New "Frame" {
        Name = "Play",
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = PositionSpring,
        Visible = Visible, 
        Size = Size(Value(UDim2.fromOffset(400, 200))),

        [Children] = {
            New "Frame" {
                Name = "Content",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 2,

                [Children] = {
                    New "Frame" {
                        Name = "Buttons",
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0, 0.335),
                        Size = UDim2.fromScale(1, 0.55),
                        ZIndex = 2,

                        [Children] = {
                            New "UIListLayout" {
                                Name = "UIListLayout",
                                Padding = UDim.new(0.075, 0),
                                FillDirection = Enum.FillDirection.Horizontal,
                                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                VerticalAlignment = Enum.VerticalAlignment.Center, 
                                SortOrder = Enum.SortOrder.LayoutOrder,
                            },

                            HUDButton {
                                Name = "Play",
                                LayoutOrder = 1, 
                                Offset = Value(0), 
                                Scale = Value(0.9), 
                                Selected = Selected, 
                                Toggled = props.Toggled.Play, 

                                VelocityPop = 0.1,
                                EnterPop = 0.05, 

                                Cooldown = Value(1), 

                                Master = Locks.Master, 

                                Locked = Locks.Play,

                                Visible = props.Visible.PlayPanel, 

                                MouseButton1Up = function(Toggled, selected) 
                                    --if Debounces.Play then warn("debounced") return end 
                                    --Debounces.Play = true 

                                    local tog = Peek(Toggled) 

                                    local DominoController = Knit.GetController("DominoController") 

                                    if DominoController.Paused then 
                                        tog = false 
                                    end 

                                    Toggled:set(not tog) 
                                end, 
                            },

                            HUDButton {
                                Name = "Pause",
                                LayoutOrder = 2, 
                                Offset = Value(0), 
                                Scale = Value(0.9), 
                                Selected = Selected,
                                Toggled = props.Toggled.Pause, 

                                Master = Locks.Master, 
                                
                                Locked = Locks.Pause, 

                                Cooldown = Value(1), 

                                VelocityPop = 0.1,
                                EnterPop = 0.05, 

                                Visible = props.Visible.PlayPanel, 

                                MouseButton1Up = function(Toggled, selected)
                                    Toggled:set(not Peek(Toggled))
                                end, 
                            },

                            HUDButton {
                                Name = "SetStart",
                                HoverName = "Select Starting Domino",
                                LayoutOrder = 3, 
                                Offset = Value(0), 
                                Scale = Value(0.9), 
                                Selected = Selected, 
                                Toggled = props.Toggled.SetStart,

                                Master = Locks.Master, 

                                Locked = Locks.SetStart, 

                                VelocityPop = 0.1,
                                EnterPop = 0.05,

                                Visible = props.Visible.PlayPanel,  

                                MouseButton1Up = function(Toggled, selected) 
                                    Toggled:set(not Peek(Toggled))
                                end, 
                            },


                            --[[New "Frame" {
                                Name = "Play",
                                BackgroundColor3 = Color3.fromRGB(106, 243, 125),
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                LayoutOrder = 2,
                                Size = UDim2.fromScale(1, 1),
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                ZIndex = 2,

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
                                        ZIndex = 3,

                                        [Children] = {
                                            New "UICorner" {
                                                Name = "UICorner",
                                                CornerRadius = UDim.new(1, 0),
                                            },

                                            New "UIStroke" {
                                                Name = "UIStroke",
                                                Color = Color3.fromRGB(76, 76, 76),
                                                Thickness = 8,
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
                                    },

                                    New "ImageLabel" {
                                        Name = "IconStroke",
                                        Image = "rbxassetid://14556922986",
                                        ImageColor3 = Color3.fromRGB(76, 76, 76),
                                        AnchorPoint = Vector2.new(0.5, 0.5),
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = UDim2.fromScale(0.5, 0.5),
                                        Size = UDim2.fromScale(0.8, 0.8),
                                        ZIndex = 5,
                                    },

                                    New "ImageLabel" {
                                        Name = "ImageLabel",
                                        Image = "rbxassetid://14465129538",
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Size = UDim2.fromScale(1, 1),
                                        ZIndex = 3,
                                    },

                                    New "ImageLabel" {
                                        Name = "Icon",
                                        Image = "rbxassetid://14023735276",
                                        AnchorPoint = Vector2.new(0.5, 0.5),
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = UDim2.fromScale(0.5, 0.5),
                                        Size = UDim2.fromScale(0.7, 0.7),
                                        ZIndex = 5,
                                    },
                                }
                            },

                            New "Frame" {
                                Name = "Pause",
                                BackgroundColor3 = Color3.fromRGB(255, 170, 116),
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                LayoutOrder = 2,
                                Size = UDim2.fromScale(1, 1),
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                ZIndex = 2,

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
                                        ZIndex = 3,

                                        [Children] = {
                                            New "UICorner" {
                                                Name = "UICorner",
                                                CornerRadius = UDim.new(1, 0),
                                            },

                                            New "UIStroke" {
                                                Name = "UIStroke",
                                                Color = Color3.fromRGB(76, 76, 76),
                                                Thickness = 8,
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
                                    },

                                    New "ImageLabel" {
                                        Name = "IconStroke",
                                        Image = "rbxassetid://14556958111",
                                        ImageColor3 = Color3.fromRGB(76, 76, 76),
                                        AnchorPoint = Vector2.new(0.5, 0.5),
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = UDim2.fromScale(0.5, 0.5),
                                        Size = UDim2.fromScale(0.7, 0.7),
                                        ZIndex = 5,
                                    },

                                    New "ImageLabel" {
                                        Name = "ImageLabel",
                                        Image = "rbxassetid://14465129538",
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Size = UDim2.fromScale(1, 1),
                                        ZIndex = 3,
                                    },

                                    New "ImageLabel" {
                                        Name = "Icon",
                                        Image = "rbxassetid://14197857438",
                                        AnchorPoint = Vector2.new(0.5, 0.5),
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = UDim2.fromScale(0.5, 0.5),
                                        Size = UDim2.fromScale(0.7, 0.7),
                                        ZIndex = 5,
                                    },
                                }
                            },

                            New "Frame" {
                                Name = "Backpack",
                                BackgroundColor3 = Color3.fromRGB(186, 157, 243),
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                LayoutOrder = 2,
                                Size = UDim2.fromScale(1, 1),
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                ZIndex = 2,

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
                                        ZIndex = 3,

                                        [Children] = {
                                            New "UICorner" {
                                                Name = "UICorner",
                                                CornerRadius = UDim.new(1, 0),
                                            },

                                            New "UIStroke" {
                                                Name = "UIStroke",
                                                Color = Color3.fromRGB(76, 76, 76),
                                                Thickness = 8,
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
                                    },

                                    New "ImageLabel" {
                                        Name = "IconStroke",
                                        Image = "rbxassetid://14556988217",
                                        ImageColor3 = Color3.fromRGB(76, 76, 76),
                                        AnchorPoint = Vector2.new(0.5, 0.5),
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = UDim2.fromScale(0.5, 0.5),
                                        Size = UDim2.fromScale(0.7, 0.7),
                                        ZIndex = 5,
                                    },

                                    New "ImageLabel" {
                                        Name = "ImageLabel",
                                        Image = "rbxassetid://14465129538",
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Size = UDim2.fromScale(1, 1),
                                        ZIndex = 3,
                                    },

                                    New "ImageLabel" {
                                        Name = "Icon",
                                        Image = "rbxassetid://14556986561",
                                        AnchorPoint = Vector2.new(0.5, 0.5),
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = UDim2.fromScale(0.5, 0.5),
                                        Size = UDim2.fromScale(0.7, 0.7),
                                        ZIndex = 5,
                                    },
                                }
                            },--]]


                        }
                    },

                    New "Frame" {
                        Name = "Progress",
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.675),
                        Size = UDim2.fromScale(0.8, 0.2),

                        [Children] = {
                            New "Frame" {
                                Name = "Experience",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = Color3.fromRGB(106, 106, 102),
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                ClipsDescendants = true,
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(1, 1),
                                ZIndex = 6,

                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(1, 0),
                                    },

                                    New "Frame" {
                                        Name = "Bar",
                                        AnchorPoint = Vector2.new(0, 0.5),
                                        BackgroundColor3 = Color3.fromRGB(251, 223, 48),
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = Computed(function(Use) 
                                            return UDim2.fromScale(-1 + math.clamp(Use(ProgressSpring), 0, 1), 0.5)
                                        end),
                                        Size = UDim2.fromScale(1, 1),
                                        ZIndex = 6,

                                        [Children] = {
                                            New "UICorner" {
                                                Name = "UICorner",
                                                CornerRadius = UDim.new(1, 0),
                                            },

                                            New "TextLabel" {
                                                Name = "Percentage",
                                                FontFace = Font.new(
                                                    "rbxasset://fonts/families/FredokaOne.json",
                                                    Enum.FontWeight.Bold,
                                                    Enum.FontStyle.Normal
                                                ),
                                                Text = Computed(function(Use)
                                                    local percent = math.clamp(Use(Progress), 0, 1)
                                                    local roundedNumber = round(percent * 100)

                                                    return tostring(roundedNumber).."%"
                                                end),
                                                TextColor3 = Color3.fromRGB(255, 255, 255),
                                                TextScaled = true,
                                                TextSize = 14,
                                                TextWrapped = true,
                                                TextXAlignment = Enum.TextXAlignment.Right,
                                                AnchorPoint = Vector2.new(1, 0.5),
                                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                                BackgroundTransparency = 1,
                                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                                BorderSizePixel = 0,
                                                Position = UDim2.fromScale(1, 0.5),
                                                Size = UDim2.fromScale(1.75, 0.8),
                                                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                                ZIndex = 6,

                                                [Children] = {
                                                    New "UIStroke" {
                                                        Name = "UIStroke",
                                                        Color = Color3.fromRGB(241, 190, 0),
                                                        Thickness = Size1D(3.5), 
                                                    },
                                                }
                                            },
                                        }
                                    },
                                }
                            },

                            New "ImageLabel" {
                                Name = "ExperienceCover",
                                Image = "rbxassetid://14464506622",
                                ImageColor3 = Color3.fromRGB(144, 143, 147),
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(1.1, 1.15),
                                ZIndex = 6,

                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(1, 0),
                                    },
                                }
                            },

                            New "Frame" {
                                Name = "BarStroke",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = Color3.fromRGB(180, 163, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                ClipsDescendants = true,
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(1, 1),
                                ZIndex = 8,

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
                        }
                    },
                }
            },

            New "Frame" {
                Name = "BackgroundStroke",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 0,

                [Children] = {
                    New "Frame" {
                        Name = "Background",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(76, 76, 76),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = 0,

                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.1, 0),
                            },
                        }
                    },

                    New "Frame" {
                        Name = "LeftSide",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(76, 76, 76),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.445, 0.225),
                        Rotation = -10,
                        Size = UDim2.fromScale(1, 1.2),
                        ZIndex = 0,

                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.1, 0),
                            },
                        }
                    },

                    New "Frame" {
                        Name = "RightSide",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(76, 76, 76),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.556, 0.232),
                        Rotation = 10,
                        Size = UDim2.fromScale(0.997, 1.2),
                        ZIndex = 0,

                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.1, 0),
                            },
                        }
                    },
                }
            },

            New "Frame" {
                Name = "Background",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.96, 0.92),

                [Children] = {
                    New "Frame" {
                        Name = "Background",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(144, 143, 147),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1, 1),

                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.1, 0),
                            },
                        }
                    },

                    New "Frame" {
                        Name = "LeftSide",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(144, 143, 147),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.45, 0.22),
                        Rotation = -10,
                        Size = UDim2.fromScale(1, 1.25),

                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.1, 0),
                            },
                        }
                    },

                    New "Frame" {
                        Name = "RightSide",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(144, 143, 147),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.553, 0.22),
                        Rotation = 10,
                        Size = UDim2.fromScale(0.997, 1.2),

                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.1, 0),
                            },
                        }
                    },
                }
            },

            New "ImageLabel" {
                Name = "Highlight",
                Image = "rbxassetid://14557062393",
                ImageTransparency = 0.8,
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, 2, 0.175, 0),
                Size = UDim2.fromScale(1.1125, 0.55),

                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.3, 0),
                    },
                }
            },
        }
    }
end 