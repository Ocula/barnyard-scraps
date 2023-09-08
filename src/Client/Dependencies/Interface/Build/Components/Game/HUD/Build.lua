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
local InterfaceController = Knit.GetController("Interface") 

local Corn = Interface:GetComponent("Game/HUD/Corn")
local Rank = Interface:GetComponent("Game/HUD/Rank")
local Play = Interface:GetComponent("Game/HUD/Play") 
local HUDButton = Interface:GetComponent("Buttons/HUDButton")

return function(props)

    -- Signals
    local ToggleMenu = props.ToggleMenu 

    local Visibility = props.Visibility --[[

        -> HUDVisible: top priority

        -> VisibilityTable: {
            Edit = Value(false), 
            Backpack = Value(true), 
            Settings = Value(true), 
            Shop = Value(true),
            Teleport = Value(true), 

            Corn = Value(true)
            Rank = Value(true), 
        } -> second priority 

    ]]

    local ToggleWatch = Observer(props.Toggles.Edit):onChange(function()
        local Toggled = Peek(props.Toggles.Edit)

        if not Toggled then 
            --InterfaceController.Game.HUD.Visibility.PlayPanel.Panel:set(false)

            warn("setting inventory false") 
            
            local Inventory = InterfaceController.Game.Menus.Inventory
            Inventory:Toggle(false)
        end
    end)

    local VisibleWatch = Observer(Visibility.Edit):onChange(function()
        local isVisible = Peek(Visibility.Edit)

        if not isVisible then 
            props.Toggles.Edit:set(false) 
        end
    end)

    return New "Frame" {
        Name = "HUD",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),

        Parent = props.Parent, 
    
        [Children] = {
            Play {
                Visible = props.Visibility, 
                Toggled = props.Toggles, 
                Selected = props.PanelSelect, 
                Locks = props.Locks, 
            },

            New "Frame" {
                Name = "Menus",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.013, 0.5),
                Size = UDim2.fromScale(0.055, 0.25),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
    
                [Children] = {
                    New "UIListLayout" {
                        Name = "UIListLayout",
                        Padding = UDim.new(0.05, 0),
                        SortOrder = Enum.SortOrder.LayoutOrder,

                        VerticalAlignment = Enum.VerticalAlignment.Center, 
                        HorizontalAlignment = Enum.HorizontalAlignment.Center, 
                    },

                    HUDButton {
                        Name = "Settings", 
                        LayoutOrder = 3, 
                        Offset = Value(0),
                        SizeConstraint = Enum.SizeConstraint.RelativeXX,  
                        Visible = Visibility, 
                    },

                    HUDButton {
                        Name = "Shop", 
                        LayoutOrder = 1, 
                        Offset = Value(0), 
                        SizeConstraint = Enum.SizeConstraint.RelativeXX,  
                        Visible = Visibility, 
                    },

                    HUDButton {
                        Name = "Teleport", 
                        LayoutOrder = 2, 
                        Offset = Value(0), 
                        SizeConstraint = Enum.SizeConstraint.RelativeXX,  
                        Visible = Visibility, 
                    },
                }
            },
    
            New "Frame" {
                Name = "Stats",
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.987, 0.5),
                Size = UDim2.fromScale(0.135, 0.25),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
    
                [Children] = {
                    New "UIListLayout" {
                        Name = "UIListLayout",
                        Padding = UDim.new(0.1, 0),
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Center, 
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    },

                    Corn {
                        Corn = props.Corn, 
                        Visible = Visibility, 
                        ToggleMenu = ToggleMenu, 
                    },

                    Rank {
                        Experience = props.Experience, -- 0-1 value passed from server. 
                        Rank = props.Rank,
                        Visible = Visibility, 
                        ToggleMenu = ToggleMenu, 
                        Max = props.Max, 
                    },
                }
            },
    
            New "Frame" {
                Name = "Game",
                AnchorPoint = Vector2.new(0.5, 1),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.975),
                Size = UDim2.fromScale(0.5, 0.095),
    
                [Children] = {
                    New "UIListLayout" {
                        Name = "UIListLayout",
                        Padding = UDim.new(0.03, 0),
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalAlignment = Enum.VerticalAlignment.Center, 
                        HorizontalAlignment = Enum.HorizontalAlignment.Center, 
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    },

                    HUDButton {
                        Name = "Backpack",
                        LayoutOrder = 2, 

                        Visible = Visibility, 
                        Offset = Value(0), 

                        MouseButton1Up = function()
                            --ToggleMenu:Fire("Backpack")
                        end, 
                    },

                    HUDButton {
                        Name = "Edit", 
                        LayoutOrder = 1, 
                        Offset = Value(0), 

                        Toggled = props.Toggles.Edit, 
                        Visible = Visibility,

                        MouseButton1Up = function(toggled)
                            toggled:set(not Peek(toggled))
                        end, 
                    },
                }
            },
        }
    }
end 