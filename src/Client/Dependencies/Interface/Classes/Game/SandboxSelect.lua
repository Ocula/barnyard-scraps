--[[

local a = game.Selection:Get()[1]
local buttonBackg = a.Button.Background
local shadow = a.ShadowTest 

local h,s,v = buttonBackg.BackgroundColor3:ToHSV()
local newhue = if h == 0 then 0.02 else h 
local test = Color3.fromHSV(h-0.02,s,v-0.15) 

shadow.BackgroundColor3 = test

]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Signal = require(Knit.Library.Signal) 

local Interface = require(Knit.Modules.Interface.get)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local SandboxSelection = Interface:GetComponent("Game/SandboxSelection")

local SandboxSelect = {}
SandboxSelect.__index = SandboxSelect 

function SandboxSelect.new(Data: Data): metatable  
    local self          = setmetatable({
        GUID            = Data.GUID, 
        OverheadLock    = Data.OverheadLock, 
        ButtonLock      = Value(false), 
        Locked          = Value(Data.Locked), 
        PlayerList      = Value(Data.PlayerList),
        Position        = Data.Position, -- this should never change at runtime. we'd be stupid to do that. don't do that kainoa. just don't. *don't* 
        Size            = UDim2.fromScale(0.8,0.15),

        -- ui frontend stuff
        PrimarySize         = Value(UDim2.fromScale(1,1)),
        PrimarySizeOffset   = Value(-1), 

        _hidden = Signal.new(), 
    }, SandboxSelect)

    local screenPoint, visible = workspace.CurrentCamera:WorldToScreenPoint(Data.Position)

    self.ScreenPoint    = Value(screenPoint)
    self.Visible        = Value(visible) 

    self.Object = SandboxSelection {
        PrimarySize         = self.PrimarySize, 
        PrimarySizeOffset   = self.PrimarySizeOffset, 
        Locked              = self.Locked, 
        ButtonLock          = self.ButtonLock, 
        OverheadLock        = self.OverheadLock, 
        PlayerList          = self.PlayerList, 
        Position            = Computed(function(Use)
                                local point = Use(self.ScreenPoint)
                                return UDim2.new(0, point.X, 0, point.Y)
                            end),
        Visible             = self.Visible, 

        Request             = function()
            self.OverheadLock:set(true) 
            self:Request()
        end, 
    }
 
    return self 
end

function SandboxSelect:Show()
    self.PrimarySizeOffset:set(0)
end 

function SandboxSelect:Hide()
    self.ButtonLock:set(true) 
    self.PrimarySizeOffset:set(-1)
end 

function SandboxSelect:Request()
    local HouseService = Knit.GetService("HouseService")
    local InterfaceController = Knit.GetController("Interface") 

    InterfaceController.Transitions.Chicken:In()

    HouseService:RequestOwnership(self.GUID):andThen(function(success, reason) 
        if success then 
            InterfaceController.Game:DisableSandboxes()
            InterfaceController.Transitions.Chicken:Out()
        else 
            InterfaceController.Game:ToggleSelectionBoxUpdate(false) 
            warn("Base ownership request failed:", reason) 
            
            self.OverheadLock:set(false) 

            InterfaceController.Transitions.Chicken:Out() 
        end
    end):catch(warn)
end 

function SandboxSelect:Render()
    local screenPoint, visible = workspace.CurrentCamera:WorldToScreenPoint(self.Position)

    if visible and Peek(self.ScreenPoint) ~= screenPoint then 
        self.ScreenPoint:set(screenPoint)
    end
    
    if visible ~= Peek(self.Visible) then 
        self.Visible:set(visible)
    end 
end 

function SandboxSelect:UpdatePlayerList(newList: array)
    self.PlayerList:set(newList) 
end 

function SandboxSelect:ToggleLock(_set: boolvalue?)
    self.Locked:set(
        if _set == nil then 
            not Peek(self.Locked) 
        else 
            _set
    ) 
end 

function SandboxSelect:Destroy()
    self:Hide()
    task.delay(1, function()
        self.Object:Destroy()
    end) 
end

return SandboxSelect