local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
--
local Interface = require(Knit.Modules.Interface.get)
--
local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

return function (props)
    local Size = Computed(function(Use)
        if Use(props.Visible) then 
            return 1 
        else 
            return 0 
        end 
    end) 

    local SizeSpring = Spring(Size, 30, .8) 

    props.Cleaner:GiveTask(Observer(props.Pop):onChange(function()
        if Peek(props.Pop) then 
            SizeSpring:addVelocity(.2) 
            props.Pop:set(false) 
        end 
    end)) 

    local Visible = Computed(function(Use)
        local num = Use(SizeSpring) 

        if num < 0.1 then 
            props.Hidden:Fire() 
            return false 
        else 
            return true 
        end 
    end)

    local PositionSpring = Spring(props.Position, 15, .7) 

    local Anchor = New "Part" {
        Name = "Number",
        Anchored = true,
        BottomSurface = Enum.SurfaceType.Smooth,
        Position = PositionSpring, 
        CanCollide = false,
        CanQuery = true,
        --CanTouch = false,
        Size = Vector3.new(1, 1, 1),
        TopSurface = Enum.SurfaceType.Smooth,
        Transparency = 1,
        Parent = workspace.game.client.bin, 
    }

    props.Cleaner:GiveTask(Anchor) 

    return New "BillboardGui" {
        Name = "Numbers",
        Active = true,
        AlwaysOnTop = true,
        ClipsDescendants = false,
        Adornee = Anchor, 
        LightInfluence = 1,
        Parent = props.Parent, 
        Size = UDim2.fromScale(3, 2),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    
        [Children] = {
            New "TextLabel" {
                Name = "Amount",
                FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                Text = props.Amount,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextScaled = true,
                TextSize = 16,
                AnchorPoint = Vector2.new(0.5,0.5),
                Position = UDim2.fromScale(0.5,0.5), 
                Visible = Visible, 
                TextWrapped = true,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = Computed(function(Use)
                    local scale = Use(SizeSpring)
                    return UDim2.fromScale(scale, scale)
                end),
        
                [Children] = {
                    New "UIStroke" {
                        Name = "UIStroke",
                        Color = Color3.fromRGB(76, 76, 76),
                        Thickness = 3,
                    },
        
                    New "UIGradient" {
                        Name = "UIGradient",
                        Color = props.Theme.UIGradient,
                        Rotation = -90,
                    },
                }
            },
        }
    }, Anchor 
end 