local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Signal = require(Knit.Library.Signal)

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

local Scroll = Interface:GetComponent("Frames/Scroll")
local Content = Interface:GetComponent("Frames/Content") 
local Slot = Interface:GetComponent("Save-screen/SaveSlot")

local CircleButtonTheme = Interface:GetTheme("Buttons/CircleButton")
local SaveSlotTheme = Interface:GetTheme("Frames/Save")

local ActionMessageTheme = Interface:GetTheme("Frames/ActionMessage")
local ActionMessage = Interface:GetClass("Game/ActionMessage")

local Size = Interface:GetUtilityBuild("Size") 
local Size1D = Interface:GetUtilityBuild("1DSize")

type SaveSlotProps = {
    Saves: Fusion.StateObject<Array> 
}

return function (props)
    -- get contentsize 
    local contentSize = Size(Value(UDim2.new(1,0,0,135))) 

    -- check resolution and change contentsize.Y accordingl

    return New "Frame" {
        Name = "Menu",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Visible = props.Visible, 
        
        Position = UDim2.fromScale(0.5, 0.5),
        Size = Size(Value(Vector2.new(1200,690))),
        SizeConstraint = Enum.SizeConstraint.RelativeXY,
    
        [Children] = {
            New "Frame" {
                Name = "Holder",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeXY,
        
                [Children] = {
                    New "Frame" {
                        Name = "Holder",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
            
                        [Children] = {
                            New "Frame" {
                                Name = "Border",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = Color3.fromRGB(74, 219, 81),
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(0.95, 1.08),
                
                                [Children] = {
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(0.1, 0),
                                    },

                                    New "UIStroke" {
                                        Name = "UIStroke",
                                        Color = Color3.fromRGB(76, 76, 76),
                                        Thickness = Size1D(8),
                                    },
                
                                    New "ImageLabel" {
                                        Name = "Texture",
                                        Image = "rbxassetid://14005215526",
                                        ImageColor3 = Color3.fromRGB(145, 251, 124),
                                        ImageTransparency = 0.2,
                                        ResampleMode = Enum.ResamplerMode.Pixelated,
                                        ScaleType = Enum.ScaleType.Tile,
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Size = UDim2.fromScale(1, 1),
                    
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
                            Name = "Content",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.fromScale(0.5, 0.575),
                            Size = UDim2.fromScale(0.9, 0.85),
            
                            [Children] = {
                                New "UICorner" {
                                    Name = "UICorner",
                                    CornerRadius = UDim.new(0.1, 0),
                                },

                                Scroll {
                                    Size = UDim2.fromScale(1, 0.925), 
                                    Position = UDim2.fromScale(0, 0.05), 
                                    ZIndex = 2, 

                                    AutomaticCanvasSize = Enum.AutomaticSize.Y,

                                    Children = {
                                        Content {
                                            ContentSize = contentSize, 

                                            Children = {
                                                ForPairs(props.Saves, function(Use, id, saveData)
                                                    local Color = Value(SaveSlotTheme.Blue)
                                                    local LayoutOrder = 0
                                                    local Name = Value(saveData.Name)
                                                    local ButtonLock = Value(false) 
                                                    local Time 

                                                    --TODO: FIX LOCALIZATION
                                                    if saveData.Timestamp > 0 then
                                                        Time = DateTime.fromUnixTimestampMillis(saveData.Timestamp):FormatLocalTime("LLL", "en-us")
                                                    end

                                                    local actions 
                                                    
                                                    actions = {
                                                        Delete = {
                                                            Color = Value(CircleButtonTheme.Red), 
                                                            Icon = AssetLibrary.get("Trashcan").ID, 
                                                            Locked = false, 
                                                            ButtonLock = Computed(function(Use)
                                                                local Frozen = if props.Frozen then Use(props.Frozen) else false 
                                                                
                                                                if not Frozen then 
                                                                    Frozen = Use(ButtonLock) 
                                                                end 

                                                                return Frozen 
                                                            end), 
                                                            IconSize = 0.7, 
                                                            LayoutOrder = 3, 

                                                            MouseButton1Down = function(size, rotate)
                                                                size:set(-0.1) 
                                                            end, 

                                                            MouseButton1Up = function(size, rotate)
                                                                size:set(0) 
                                                                ButtonLock:set(true)

                                                                local _new 
                                                                _new = ActionMessage.new({
                                                                    Freeze = "Save", -- freezes the save menu so the player can't interact. 

                                                                    Choose = function(_result)
                                                                        if _result then 
                                                                            local BuildService = Knit.GetService("BuildService")
                                                                            BuildService:RequestDelete(saveData.Slot) 
                                                                            
                                                                            if InterfaceController.Game.Menus.Save:isVisible() then 
                                                                                InterfaceController.Game.Menus.Save:Load() --updates saves
                                                                            end 
                                                                        else 
                                                                            ButtonLock:set(false)
                                                                            --warn("FAILED") 
                                                                        end

                                                                        _new:Destroy() -- switch to destroy 
                                                                    end, 

                                                                    Color = ActionMessageTheme.Delete, 
                                                    
                                                                    Header = "delete save",
                                                                    Body = "Are you sure you want to delete '"..Peek(Name).."'? You can't undo this action!"
                                                                })

                                                                -- exits out of the menu if they click away / tap away
                                                                local userInput = Knit.GetController("UserInput")
                                                                local pref = userInput:GetPreferred() 
                                                                local conn

                                                                if pref == "Keyboard" then 
                                                                    conn = userInput:Get("Mouse").LeftDown:Connect(function(processed)
                                                                        if processed then return end 
                                                                        _new:Cancel() 
                                                                        conn:Disconnect()
                                                                    end) 
                                                                elseif pref == "Touch" then 
                                                                    conn = userInput:Get("Touch").TouchStarted:Connect(function(input, processed)
                                                                        if processed then return end 
                                                                        _new:Cancel()
                                                                        conn:Disconnect() 
                                                                    end)
                                                                end 

                                                                _new:Show()
                                                            end 
                                                        },
                                                        Load = {
                                                            Color = Value(CircleButtonTheme.Green), 
                                                            Icon = AssetLibrary.get("Play").ID,
                                                            IconSize = 0.85, 
                                                            Locked = false, 
                                                            ButtonLock = Computed(function(Use)
                                                                local Frozen = if props.Frozen then Use(props.Frozen) else false 
                                                                
                                                                if not Frozen then 
                                                                    Frozen = Use(ButtonLock) 
                                                                end 

                                                                return Frozen 
                                                            end), 
                                                            LayoutOrder = 1, 

                                                            MouseButton1Down = function(size, rotate)
                                                                size:set(-0.1) 
                                                            end, 

                                                            MouseButton1Up = function(size, rotate)
                                                                size:set(0) 
                                                                ButtonLock:set(true) 

                                                                if saveData.Empty then 
                                                                    local message, result = actions.Rename.MouseButton1Up(size, rotate)
                                                                    
                                                                    result:Connect(function(_result) 
                                                                        if _result then 
                                                                            --warn("SUCCESS!")
                                                                            local BuildService = Knit.GetService("BuildService")

                                                                            if InterfaceController.Game.Menus.Save:isVisible() then 
                                                                                InterfaceController.Game.Menus.Save:Load()
                                                                                InterfaceController.Game:Toggle("Save", false)
                                                                                BuildService:SpawnPlayer()

                                                                                task.delay(1, function()
                                                                                    InterfaceController.Game:Toggle("Inventory", true)
                                                                                end) 
                                                                            end 
                                                                            
                                                                            BuildService:RequestSaveLoad(saveData.Slot)
                                                                        else 
                                                                            ButtonLock:set(false)
                                                                            --warn("FAILED") 
                                                                        end
                                                                    end)
                                                                else 
                                                                    local _new, _debounce 
                                                                    _new = ActionMessage.new({
                                                                        Freeze = "Save", -- freezes the save menu so the player can't interact. 

                                                                        Choose = function(_result)
                                                                            if _debounce then return end 
                                                                            _debounce = true 

                                                                            if _result then 
                                                                                --warn("SUCCESS!")
                                                                                local BuildService = Knit.GetService("BuildService")
                                                                                
                                                                                BuildService:RequestSaveLoad(saveData.Slot):andThen(function(success, message)
                                                                                    if success then     
                                                                                        _new:Destroy() 

                                                                                        if InterfaceController.Game.Menus.Save:isVisible() then 
                                                                                            InterfaceController.Game:Toggle("Save", false)
                                                                                            BuildService:SpawnPlayer()

                                                                                            task.delay(1, function()
                                                                                                InterfaceController.Game:Toggle("Inventory", true) -- gamehud instead
                                                                                            end) 
                                                                                        end 
                                                                                    else 
                                                                                        _new.Body:set(message) -- it's a state object after it's been passed in.
                                                                                        _debounce = false 
                                                                                        _new.Choose = function()
                                                                                            _new:Destroy() 
                                                                                        end
                                                                                    end 
                                                                                end):catch(function(err)
                                                                                    _new.Body:set("An error has occurred trying to load your save data. Please file a bug report. [Error: 1-313]")
                                                                                    _debounce = false 
                                                                                    _new.Choose = function()
                                                                                        _new:Destroy() 
                                                                                    end

                                                                                    warn(err) 
                                                                                end)
                                                                            else 
                                                                                ButtonLock:set(false)
                                                                                _new:Destroy() 
                                                                            end

                                                                        end, 
                                                        
                                                                        Header = "load save",
                                                                        Body = "Are you sure you would like to load '"..Peek(Name).."' onto your sandbox?",
                                                                        Color = ActionMessageTheme.Blue,
                                                                    })

                                                                    _new:Show()
                                                                end
                                                            end 
                                                        },

                                                         Rename = {
                                                            Color = Value(CircleButtonTheme.Yellow), 
                                                            Icon = AssetLibrary.get("Pencil").ID,
                                                            Locked = false, 
                                                            ButtonLock = Computed(function(Use)
                                                                local Frozen = if props.Frozen then Use(props.Frozen) else false 
                                                                
                                                                if not Frozen then 
                                                                    Frozen = Use(ButtonLock
                                                                ) 
                                                                end 

                                                                return Frozen 
                                                            end), 
                                                            LayoutOrder = 2, 

                                                            MouseButton1Down = function(size, rotate)
                                                                size:set(-0.1) 
                                                            end, 

                                                            MouseButton1Up = function(size, rotate)
                                                                size:set(0) 

                                                                local _new
                                                                local resultSignal = Signal.new()

                                                                _new = ActionMessage.new({
                                                                    Freeze = "Save", -- freezes the save menu so the player can't interact. 

                                                                    Capture = true, -- create capture action. 

                                                                    Choose = function(_result, size, rotate, vis, capture) -- focuslost. 
                                                                        resultSignal:Fire(_result) 

                                                                        if _result then 
                                                                            --warn("SUCCESS!")
                                                                            local BuildService = Knit.GetService("BuildService")

                                                                            warn("Requesting rename to: "..Peek(capture).Text)

                                       
                                                                            BuildService:RequestRename(saveData.Slot, Peek(capture).Text):andThen(function(newText)
                                                                                -- what. is wrong. 
                                                                                if Peek(capture) then 
                                                                                    Peek(capture).Text = newText
                                                                                end 
                                                                                
                                                                                Name:set(newText)
                                                                            end):catch(error)--]]
                                                                        else 
                                                                            ButtonLock:set(false)
                                                                            --warn("FAILED") 
                                                                        end

                                                                        _new:Destroy() -- switch to destroy 
                                                                    end, 
                                                    
                                                                    Header = "name save",
                                                                    Body = "What would you like to name '"..Peek(Name).."'?"
                                                                })

                                                                _new:Show()
                                                                return _new, resultSignal 
                                                            end 
                                                        }
                                                    }

                                                    if saveData.Empty and not saveData.Locked then 
                                                        Color = Value(SaveSlotTheme.Green)
                                                        LayoutOrder = 1
                                                        Name = Value("Empty slot")

                                                        actions.Delete.Locked = true
                                                        actions.Delete.Color:set(SaveSlotTheme.Green)

                                                        actions.Rename.Locked = true 
                                                        actions.Rename.Color:set(SaveSlotTheme.Green)
                                                    end 

                                                    if saveData.Locked then 
                                                        Color:set(SaveSlotTheme.Gray) 
                                                        LayoutOrder = 2

                                                        Name = Value("Locked")

                                                        for _,v in pairs(actions) do 
                                                            v.Color:set(SaveSlotTheme.Gray)
                                                            v.Locked = true
                                                        end 
                                                    end

                                                    return id, Slot {
                                                        NameText = Name,
                                                        Timestamp = Time, 
                                                        Actions = actions, 
                                                        Color = Color, 
                                                        LayoutOrder = LayoutOrder, 
                                                    }
                                                end, Fusion.cleanup)
                                            },
                                        }
                                    },
                                },
                
                                New "ImageLabel" { 
                                    Name = "Texture",
                                    Image = "rbxassetid://14005223523",
                                    ImageColor3 = Color3.fromRGB(136, 210, 128),
                                    ImageTransparency = 0.8,
                                    ResampleMode = Enum.ResamplerMode.Pixelated,
                                    ScaleType = Enum.ScaleType.Tile,
                                    TileSize = UDim2.fromScale(1, 1.5),
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Size = UDim2.fromScale(1, 1),
                
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
                            Name = "Header",
                            AnchorPoint = Vector2.new(0.5, 0),
                            BackgroundColor3 = Color3.fromRGB(13, 188, 5),
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.fromScale(0.5, 0),
                            Size = UDim2.fromScale(0.9, 0.125),
            
                            [Children] = {
                                New "UICorner" {
                                    Name = "UICorner",
                                    CornerRadius = UDim.new(0.5, 0),
                                },
                
                                New "TextLabel" {
                                    Name = "Title",
                                    FontFace = Font.new(
                                        "rbxassetid://12187375716",
                                        Enum.FontWeight.Bold,
                                        Enum.FontStyle.Normal
                                    ),
                                    Text = "build saves",
                                    TextColor3 = Color3.fromRGB(255, 255, 255),
                                    TextScaled = true,
                                    TextSize = 14,
                                    TextWrapped = true,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    AnchorPoint = Vector2.new(0, 0.5),
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.fromScale(0.025, 0.5),
                                    Size = UDim2.fromScale(0.5, 0.85),
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