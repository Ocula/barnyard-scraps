local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local QuickIndex = require(Knit.Library.QuickIndex) 

local Signal = require(Knit.Library.Signal)
local Maid = require(Knit.Library.Maid) 

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate
local Interface = require(Knit.Modules.Interface.get)

local StrokeSize = Interface:GetUtilityBuild("1DSize")

local Viewport = Interface:GetComponent("Frames/ViewportFrame")

return function(props)
    assert(props.Selected, "No selected State provided.")
    local InterfaceController = Knit.GetController("Interface")

    local Selected = props.Selected 
    local Clean = Maid.new() 

    local Object = {
        Object = nil, 

        Name = Value(""),

        Price = Value(0), 
        Rank = Value(1), 
    }

    local function updateObjectSelected(selectedId)
        if #selectedId > 0 then 
            local ObjectData = QuickIndex:GetBuild(selectedId)

            Object.Object = ObjectData.Object:Clone()

            Object.Name:set(Object.Object.Name) 
            Object.Price:set(Object.Object:GetAttribute("Price"))
            Object.Rank:set(Object.Object:GetAttribute("Rank") or 1)

            local Update = props.Update 
            Update:Fire(Object) 
        else 
            local Update = props.Update 
            Update:Fire(nil) 
        end 
    end

    -- connect to event and change inner workings here as needed
    --TODO: Convert to viewport object

    Clean:GiveTask(Observer(Selected):onChange(function()
        local selectedObject = Peek(Selected)
        updateObjectSelected(selectedObject) 
    end))

    updateObjectSelected(Peek(Selected)) 

    return New "Frame" {
        Name = "ObjectPanel",
        BackgroundColor3 = Color3.fromRGB(193, 153, 110),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.605, 0.09),
        Size = UDim2.fromScale(0.37, 0.55),
        ZIndex = 2,
    
        [Children] = {
            New "UICorner" {
                Name = "UICorner",
                CornerRadius = UDim.new(0.1, 0),
            },
    
            New "UIStroke" {
                Name = "UIStroke",
                Color = Color3.fromRGB(76, 76, 76),
                Thickness = StrokeSize(8),
            },
    
            New "Frame" {
                Name = "Item",
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0),
                Size = UDim2.fromScale(0.875, 0.65),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                ZIndex = 4,
    
                [Children] = {
                    New "Frame" {
                        Name = "Data",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(215, 175, 127),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1, 0.85),
                        ZIndex = 4,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.1, 0),
                            },
    
                            New "ImageLabel" {
                                Name = "Icon",
                                Image = "rbxassetid://14631514963",
                                ImageColor3 = Color3.fromRGB(0, 193, 249),
                                ImageTransparency = 0.6,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Size = UDim2.fromScale(1, 1),
                                Visible = false,
                                ZIndex = 4,
                            },
    
                            New "Frame" {
                                Name = "ObjectName",
                                AnchorPoint = Vector2.new(0.5, 0),
                                BackgroundColor3 = Color3.fromRGB(0, 191, 255),
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5, 0.75),
                                Size = UDim2.fromScale(0.95, 0.225),
                                ZIndex = 8,
    
                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(1, 0),
                                    },
    
                                    New "TextLabel" {
                                        Name = "TextLabel",
                                        FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                                        Text = Object.Name,
                                        TextColor3 = Color3.fromRGB(255, 255, 255),
                                        TextScaled = true,
                                        TextSize = 14,
                                        TextWrapped = true,
                                        AnchorPoint = Vector2.new(0.5, 0.5),
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = UDim2.fromScale(0.5, 0.5),
                                        Size = UDim2.fromScale(0.975, 0.75),
                                        ZIndex = 9,
                                    },
                                }
                            },
                        }
                    },

                    Viewport {
                        Maid = Clean, 
                        Name = "Object",
                        ZIndex = 7,
                        Size = UDim2.fromScale(1,0.85), 
                        Update = props.Update,  
                        Visible = Computed(function(Use)
                            if #Use(Selected) > 0 then 
                                return true 
                            else 
                                return false
                            end 
                        end),
                    },
                    --[[
                    New "ViewportFrame" {
                        Name = "Object",
                        Ambient = Color3.fromRGB(255, 255, 255),
                        LightDirection = Vector3.new(0, -1, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 0.8),
                        ZIndex = 7,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.125, 0),
                            },
    
                            New "WorldModel" {
                                Name = "WorldModel",
                                WorldPivot = CFrame.new(0, 101.907501, 16.0000038, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    
                                [Children] = {
                                    New "Model" {
                                        Name = "Basic",
                                        WorldPivot = CFrame.new(20.5, 2.19499969, -17.5, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    
                                        [Children] = {
                                            New "MeshPart" {
                                                Name = "Domino",
                                                Anchored = true,
                                                BrickColor = BrickColor.new("Lily white"),
                                                CFrame = CFrame.new(1, 102.419998, 16.0000038, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                                                CollisionGroup = "Dominos",
                                                Color = Color3.fromRGB(237, 234, 234),
                                                CustomPhysicalProperties = PhysicalProperties.new(Enum.Material.Brick),
                                                EnableFluidForces = false,
                                                Material = Enum.Material.SmoothPlastic,
                                                Size = Vector3.new(0.331, 3.79, 1.67),
                                            },
    
                                            New "Part" {
                                                Name = "Base",
                                                Anchored = true,
                                                BottomSurface = Enum.SurfaceType.Smooth,
                                                BrickColor = BrickColor.new("Smoky grey"),
                                                CFrame = CFrame.new(0, 100, 16.0000038, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                                                CollisionGroup = "Dominos",
                                                Color = Color3.fromRGB(91, 93, 105),
                                                CustomPhysicalProperties = PhysicalProperties.new(1, 1, 0, 1, 1),
                                                EnableFluidForces = false,
                                                Size = Vector3.new(5, 1, 5),
                                                TopSurface = Enum.SurfaceType.Smooth,
                                            },
    
                                            New "MeshPart" {
                                                Name = "Domino",
                                                Anchored = true,
                                                BrickColor = BrickColor.new("Lily white"),
                                                CFrame = CFrame.new(-1, 102.419998, 16.0000038, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                                                CollisionGroup = "Dominos",
                                                Color = Color3.fromRGB(237, 234, 234),
                                                CustomPhysicalProperties = PhysicalProperties.new(Enum.Material.Brick),
                                                EnableFluidForces = false,
                                                Material = Enum.Material.SmoothPlastic,
                                                Size = Vector3.new(0.331, 3.79, 1.67),
                                            },
    
                                            New "MeshPart" {
                                                Name = "Domino",
                                                Anchored = true,
                                                BrickColor = BrickColor.new("Lily white"),
                                                CFrame = CFrame.new(-2, 102.419998, 16.0000038, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                                                CollisionGroup = "Dominos",
                                                Color = Color3.fromRGB(237, 234, 234),
                                                CustomPhysicalProperties = PhysicalProperties.new(Enum.Material.Brick),
                                                EnableFluidForces = false,
                                                Material = Enum.Material.SmoothPlastic,
                                                Size = Vector3.new(0.331, 3.79, 1.67),
                                            },
    
                                            New "MeshPart" {
                                                Name = "Domino",
                                                Anchored = true,
                                                BrickColor = BrickColor.new("Lily white"),
                                                CFrame = CFrame.new(0, 102.419998, 16.0000038, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                                                CollisionGroup = "Dominos",
                                                Color = Color3.fromRGB(237, 234, 234),
                                                CustomPhysicalProperties = PhysicalProperties.new(Enum.Material.Brick),
                                                EnableFluidForces = false,
                                                Material = Enum.Material.SmoothPlastic,
                                                Size = Vector3.new(0.331, 3.79, 1.67),
                                            },
    
                                            New "MeshPart" {
                                                Name = "Domino",
                                                Anchored = true,
                                                BrickColor = BrickColor.new("Lily white"),
                                                CFrame = CFrame.new(2, 102.419998, 16.0000038, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                                                CollisionGroup = "Dominos",
                                                Color = Color3.fromRGB(237, 234, 234),
                                                CustomPhysicalProperties = PhysicalProperties.new(Enum.Material.Brick),
                                                EnableFluidForces = false,
                                                Material = Enum.Material.SmoothPlastic,
                                                Size = Vector3.new(0.331, 3.79, 1.67),
                                            },
                                        }
                                    },
                                }
                            },
                        }
                    },--]]
                }
            },
    
            New "Frame" {
                Name = "Stats",
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundColor3 = Color3.fromRGB(215, 175, 127),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.65),
                Size = UDim2.fromScale(0.875, 0.3),
                ZIndex = 6,
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.135, 0),
                    },
    
                    New "Frame" {
                        Name = "Price",
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 212, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        LayoutOrder = 1,
                        Position = UDim2.fromScale(0.5, 0.65),
                        Size = UDim2.fromScale(0.95, 0.4),
                        ZIndex = 8,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.5, 0),
                            },
    
                            New "TextLabel" {
                                Name = "TextLabel",
                                FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                                Text = Computed(function(Use)
                                    return Use(Object.Price).." 🌽"
                                end),
                                TextColor3 = Color3.fromRGB(255, 255, 255),
                                TextScaled = true,
                                TextSize = 14,
                                TextWrapped = true,
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(0.975, 0.75),
                                ZIndex = 9,
    
                                [Children] = {
                                    New "UIStroke" {
                                        Name = "UIStroke",
                                        Color = Color3.fromRGB(255, 177, 0),
                                        Thickness = StrokeSize(3),
                                    },
                                }
                            },
                        }
                    },
    
                    New "UIListLayout" {
                        Name = "UIListLayout",
                        Padding = UDim.new(0.05, 0),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    },
    
                    New "Frame" {
                        Name = "Rank",
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(101, 201, 100),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        LayoutOrder = 1,
                        Position = UDim2.fromScale(0.5, 0.65),
                        Size = UDim2.fromScale(0.95, 0.4),
                        ZIndex = 8,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.5, 0),
                            },
    
                            New "TextLabel" {
                                Name = "TextLabel",
                                FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
                                Text = Computed(function(Use)
                                    local Item = InterfaceController.Game.Menus.Inventory:Get(Use(Selected))

                                    if Item then 
                                        local ownedAmount = Use(Item.Data.Amount) 

                                        return "Owned: " .. ownedAmount -- connect
                                    else 
                                        return "N/A"
                                    end 
                                end),
                                TextColor3 = Color3.fromRGB(255, 255, 255),
                                TextScaled = true,
                                TextSize = 14,
                                TextWrapped = true,
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(0.975, 0.75),
                                ZIndex = 9,
    
                                [Children] = {
                                    New "UIStroke" {
                                        Name = "UIStroke",
                                        Color = Color3.fromRGB(2, 157, 43),
                                        Thickness = StrokeSize(3),
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