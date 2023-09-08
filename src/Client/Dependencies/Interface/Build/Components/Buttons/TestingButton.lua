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

local AssetLibrary = require(Knit.Library.AssetLibrary)

local LockedTheme = {
    Container = Color3.fromRGB(140,140,140),
    Icon = Color3.fromRGB(180,180,180), 
}

return function(props)

    local SelectedColor = props.SelectedColor or Color3.fromRGB(0, 227, 199) 
    local SelectedIcon, Icon 

    if props.SelectedIcon then 
        SelectedIcon = AssetLibrary.get(props.SelectedIcon).ID 
    end 

    Icon = AssetLibrary.get(props.Name).ID 

    local isLocked = Computed(function(Use)
        local LockedButtons = Use(props.PlayLocked) 
        return LockedButtons[props.Name] or LockedButtons[props.SelectedIcon or ""]
    end)

    return New "Frame" {
        Name = props.Name,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(100, 100),
        ZIndex = 5,

        [Children] = {
            New "Frame" {
                Name = "Container",
                BackgroundColor3 = Computed(function(Use)
                    if Use(isLocked) then 
                        return LockedTheme.Container 
                    end 

                    if Use(props.Selected) == props.Name then 
                        return SelectedColor
                    else
                        return Color3.fromRGB(24, 223, 0)
                    end 
                end),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                ZIndex = 5,

                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(1, 0),
                    },

                    New "ImageLabel" {
                        Name = "Icon",
                        Image = Computed(function(Use)
                            if Use(props.Selected) == props.Name and SelectedIcon then 
                                return SelectedIcon 
                            end 

                            return Icon 
                        end), --.."Test"
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        ImageColor3 = Computed(function(Use)
                            if Use(isLocked) then 
                                return LockedTheme.Icon 
                            else 
                                return Color3.fromRGB(255,255,255) 
                            end 
                        end),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(0.8 * (props.IconResize or 1), 0.8 * (props.IconResize or 1)),
                        ZIndex = 5,
                    },

                    New "UIStroke" {
                        Name = "UIStroke",
                        Color = Color3.fromRGB(255, 255, 255),
                        Thickness = Computed(function(Use)
                            if Use(props.Selected) == props.Name then 
                                return 2.5
                            else 
                                return 0 
                            end 
                        end)
                    },
                }
            },

            New "TextButton" {
                Name = "TextButton",
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                Text = "",
                TextColor3 = Color3.fromRGB(0, 0, 0),
                TextSize = 14,
                AutoButtonColor = false,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 6,

                [OnEvent "MouseButton1Down"] = function()
                    
                end, 

                [OnEvent "MouseButton1Up"] = function()
                    --
                    if Peek(props.Selected) ~= props.Name and props.PreSelect then 
                        local continue = props.PreSelect() 

                        if not continue then 
                            return
                        end 
                    end 

                    if Peek(props.Selected) == props.Name and props.PreDeselect then 
                        local continue = props.PreDeselect()

                        if not continue then 
                            return 
                        end 
                    end 

                    local Inventory = InterfaceController.Game.Menus.Inventory 
                    Inventory._setPlay:Fire(props.Name) 
                    --
                end, 

                [OnEvent "MouseEnter"] = function()
                    -- TODO: cool bubble rush pop effect! 
                    -- i want the play button to be the most enticing thing on the inventory ui
                end, 
            },
        }
    }
end 