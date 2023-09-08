local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Hydrate, Attribute = Fusion.Hydrate, Fusion.Attribute

local Interface = require(Knit.Modules.Interface.get)

local HUDButtonTheme = Interface:GetTheme("Buttons/HUDButton") 
local StrokeSize = Interface:GetUtilityBuild("1DSize")

return function(props)
    local Selected = props.Selected 

    if not Selected then 
        Selected = Value(props.Name) 
    end 

    -- Button
    if not props.Toggled then 
        props.Toggled = Value(false) 
    end

    local Toggled = Computed(function(Use)
        if Use(Selected) ~= props.Name then -- if the player selects another menu / selection with this one open, we switch toggle
            props.Toggled:set(false) 
            return false 
        else 
            return Use(props.Toggled)  
        end
    end)

    local Scale = props.Scale or Value(1) 

    local Theme = HUDButtonTheme[props.Name or "Settings"]
    local Offset = props.Offset or Value(0) -- Size Offset
    local OffsetSpring = Spring(Offset, 25, .6)

    local VisibilityOffset = Value(0)
    local Visibility = props.Visible 

    local VisibilitySpring = Spring(VisibilityOffset, 25, .6) 

    local Visible = Value(true) 

    if props.Visible then 
        Visible = Computed(function(Use)
            local hudVisible = Use(Visibility.Parent) -- not getting 
            local selfVisible = Use(Visibility[props.Name])

            local visOffset = 0 

            if hudVisible == false or selfVisible == false then 
                visOffset = (-1 - Use(OffsetSpring))
            end 

            VisibilityOffset:set(visOffset) 

            if Use(VisibilitySpring) <= -0.85 then 
                return false 
            else 
                return true 
            end 
        end)
    end 

    -- Locked 
    local Locked = props.Locked 
    local Master = props.Master 

    if not Master then 
        Master = Value(false) 
    end 

    if not Locked then 
        Locked = Value(false) 
    end 

    -- Cooldown 

    local Cooldown = props.Cooldown 
    local isInCooldown = false 

    if Cooldown then 
        Observer(props.Toggled):onChange(function()
            local isToggled = Peek(props.Toggled) 

            if isToggled then 
                Locked:set(true)

                isInCooldown = true 

                task.delay(Peek(Cooldown), function()
                    if isInCooldown then 
                        Locked:set(false) 
                        isInCooldown = false 
                    end
                end)
            else 
                if isInCooldown then 
                    isInCooldown = false 
                    Locked:set(false) 
                end 
            end 
        end) -- needs to be cleaned up
    end 

    return New "Frame" {
        Name = props.Name,
        BackgroundColor3 = Computed(function(Use)
            if props.Locked then 
                local isLocked = Use(props.Locked) or Use(Master) 
                if isLocked then 
                    return Color3.fromRGB(180,180,180)
                end 
            end 

            if Use(Toggled) then 
                return Theme.SelectedColor or Theme.Color 
            else 
                return Theme.Color
            end
        end), 

        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        LayoutOrder = props.LayoutOrder or 1,

        Position = props.Position or UDim2.fromOffset(0,0), 
        AnchorPoint = props.AnchorPoint or Vector2.new(0,0), 

        Visible = Visible, 

        Size = Computed(function(Use)
            local springValue = Use(OffsetSpring) 
            local visibilityOffset = Use(VisibilitySpring) 
            local scaleSet = Peek(Scale) or 1  

            return UDim2.fromScale(scaleSet + springValue + visibilityOffset, scaleSet + springValue + visibilityOffset) 
        end),

        SizeConstraint = props.SizeConstraint or Enum.SizeConstraint.RelativeYY,

        [Attribute "MouseHover"] = props.HoverName or props.Name,
    
        [Children] = {
            New "UICorner" {
                Name = "UICorner",
                CornerRadius = UDim.new(1, 0),
            },

            New "ImageButton" {
                Name = "ImageButton",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 10,

                [OnEvent "MouseEnter"] = function()
                    local isLocked = Peek(Locked) or Peek(Master) 
                    if isLocked then return end 

                    Offset:set(props.EnterPop or 0.1)
                end, 

                [OnEvent "MouseLeave"] = function()
                    local isLocked = Peek(Locked) or Peek(Master) 
                    if isLocked then return end 

                    Offset:set(0)
                end,

                [OnEvent "MouseButton1Down"] = function()
                    local isLocked = Peek(Locked) or Peek(Master) 
                    if isLocked then return end 

                    Offset:set(-.1) 

                    if props.ToggleMenu then 
                        props.ToggleMenu:Fire(props.Name, props.Toggled) 
                    end 
                end, 

                [OnEvent "MouseButton1Up"] = function()
                    local isLocked = Peek(Locked) or Peek(Master) 
                    if isLocked then return end 

                    OffsetSpring:addVelocity(props.VelocityPop or 0.5)
                    Offset:set(0) 

                    if props.MouseButton1Up then 
                        props.MouseButton1Up(props.Toggled, Selected) 
                    end 
                end, 
            },
    
            New "ImageLabel" {
                Name = "BubbleOverlay",
                Image = "rbxassetid://14465129538",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
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
                        Thickness = StrokeSize(8),
                    },
                }
            },
    
            New "ImageLabel" {
                Name = "IconStroke",
                Image = Computed(function(Use)
                    if Use(Toggled) then 
                        return Theme.SelectedIconStroke or Theme.IconStroke 
                    else 
                        return Theme.IconStroke
                    end
                end),
                ImageColor3 = Color3.fromRGB(76, 76, 76),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = Theme.Sizes.IconStroke,
                ZIndex = 5,
            },
    
            New "ImageLabel" {
                Name = "Icon",
                Image = Computed(function(Use)
                    if Use(Toggled) then 
                        return Theme.SelectedIcon or Theme.Icon 
                    else 
                        return Theme.Icon
                    end
                end),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = Theme.Sizes.Icon,
                ZIndex = 5,
            },
        }
    }
end 