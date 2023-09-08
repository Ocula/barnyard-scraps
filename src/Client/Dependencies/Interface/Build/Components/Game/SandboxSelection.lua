--[[

    2023
    UI component for selecting your Domino base. @Ocula

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local AssetLibrary = require(Knit.Library.AssetLibrary) 

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Interface = require(Knit.Modules.Interface.get)
local InterfaceController = Knit.GetController("Interface")  

local CircleButton = Interface:GetComponent("Buttons/CircleButton")
local Theme = Interface:GetTheme("Buttons/CircleButton")

type PlayerListProps = {
    PlayerList: Fusion.StateObject<Set<Player>>
}

return function(props: PlayerListProps)
    -- overhead size property
    local primarySizeOffset = props.PrimarySizeOffset
    local primarySize = props.PrimarySize 

    return New "Frame" {
        Name = "Frame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = props.Position,
        Visible = props.Visible, 
        Size = props.Size or UDim2.fromScale(0.6, 0.15),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        
        [Children] = {
            New "UIGridLayout" {
                Name = "UIGridLayout",
                CellPadding = props.CellPadding or UDim2.new(0, 10, 0, 0),
                CellSize = props.CellSize or UDim2.fromScale(0.15, 1),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
            },  

            ForPairs(props.PlayerList, function(use, id, player)

                local button = CircleButton {
                    Image = player.Image or "",
                    Name = player.Name, 
                    Color = Value(Theme.Orange), 
                    PrimarySizeOffset = primarySizeOffset, 
                    PrimarySize = primarySize,
                    ButtonLock = props.ButtonLock, 
                }

                return id, button 
            end, Fusion.cleanup),

            -- Add one more button for 
            CircleButton {
                LayoutOrder = 10, -- always put last 
                Image = AssetLibrary.get("PlusSign").ID,
                ImageTransparency = 0, 
                PrimarySizeOffset = primarySizeOffset, 
                PrimarySize = primarySize, 

                ButtonLock = props.ButtonLock, 

                IconSize = 0.8, 
                IconColor = Computed(function(Use)
                    if Use(props.Locked) then 
                        return Color3.new(0.5,0.5,0.5)  -- Gray + button or maybe Green for unlocked, Gray for locked?
                    else 
                        local h, s, v = Theme.Green:ToHSV()

                        return Color3.fromHSV(h,s,v+.1)
                    end
                end),

                Color = Computed(function(Use)
                    if Use(props.Locked) then 
                        return Color3.new(0.4,0.4,0.4)  -- Gray + button or maybe Green for unlocked, Gray for locked?
                    else 
                        return Theme.Green 
                    end
                end),

                Hover = true, 
                PlusSign = true,

                ["MouseButton1Down"] = function(size, rotate)
                    if Peek(props.ButtonLock) then return end 
                    if Peek(props.OverheadLock) then return end 

                    if Peek(props.Locked) == false then 
                        size:set(-0.1)
                        rotate:set(180)
                    else
                        size:set(0.05)
                    end 
                end, 

                ["MouseButton1Up"] = function(size, rotate)
                    if Peek(props.ButtonLock) then return end

                    if Peek(props.Locked) == false and Peek(props.OverheadLock) == false then 
                        if props.Request then 
                            InterfaceController.Game:ToggleSelectionBoxUpdate(false) 
                            props.Request() 
                        end 
                    end
                    
                    size:set(0)
                end, 
            }
        }
    }
end 