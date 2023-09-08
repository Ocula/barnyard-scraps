local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Interface = require(Knit.Modules.Interface.get)

local Maid = require(Knit.Library.Maid) 
local Signal = require(Knit.Library.Signal) 

local RunService = game:GetService("RunService") 

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local RotateFrame = Interface:GetComponent("Game/Inventory/Tools/RotateFrame")

local Rotate = {}
Rotate.__index = Rotate

function lerpSet(min, max, point) 
    return min * (1 - point) + (max * point)
end 

function Rotate.new(rotate)
    local self = setmetatable({
        Visible = Value(false), 

        Signals = {
            MouseButton1Down = Signal.new(), 
            MouseButton1Up = Signal.new(), 

            RequestRotate = Signal.new(),

            --  

            PreviewUpdate = Signal.new(), 
        },

        Maid = Maid.new(), 

        RotateValue = rotate, 
        Updated = Signal.new(), 

        _rendering = false, 
    }, Rotate)

    self.Object = RotateFrame { 
        Visible = self.Visible, 
        Rotate = rotate, 
        Signals = self.Signals, 
        SliderPosition = Computed(function(Use)
            return lerpSet(0.05, 0.95, Use(self.RotateValue) / 360)
        end), 
    }

    local Container = self.Object:FindFirstChild("Container") 
    local Slider = Container:FindFirstChild("Slider")
    local DragContainer = Slider:FindFirstChild("Drag")
    local TotalFrame = DragContainer:FindFirstChild("TotalFrame")
    local DragFrame = TotalFrame:FindFirstChild("DragFrame") 

    self.Frames = {
        Total = TotalFrame, 
        Drag = DragFrame 
    }

    return self
end

function Rotate:Select(object)
    self.Signals.PreviewUpdate:Fire(object) 
end 

function Rotate:StartDrag()
    if self._rendering then return end 

    self._rendering = true 

    local UserInput = Knit.GetController("UserInput")
    local Mouse = UserInput:Get("Mouse") 

    game:GetService("RunService"):BindToRenderStep("Rotate", Enum.RenderPriority.Last.Value - 1, function()
        local MousePosition = Mouse:GetPosition() 
        self:Update(MousePosition) 
    end)
end 

function Rotate:StopDrag()
    if self._rendering == false then return end 

    game:GetService("RunService"):UnbindFromRenderStep("Rotate") 

    self._rendering = false 
end 

function Rotate:Update(pos: Vector2)
    local totFrame = self.Frames.Total 

    local totLeft = 0
    local totRight = totFrame.AbsoluteSize.X 

    local clampToContainer = math.clamp(pos.X - totFrame.AbsolutePosition.X, totLeft, totRight) 
    local point = clampToContainer / totRight

    --
    self.RotateValue:set(math.floor(point * 360)) 
    self.Updated:Fire(Peek(self.RotateValue)) 
end 

function Rotate:Connect()
    local UserInput = Knit.GetController("UserInput")
    local Mouse = UserInput:Get("Mouse") 

    self.Maid:GiveTask(self.Signals.MouseButton1Down:Connect(function()
        self:StartDrag() 
    end))

    self.Maid:GiveTask(Mouse.LeftUp:Connect(function()
        self:StopDrag() 
    end))

    self.Maid:GiveTask(self.Signals.RequestRotate:Connect(function(text)
        local _num = tonumber(text) 
        if _num ~= nil then 
            local clamp = math.clamp(_num, 0, 360) 
            self.RotateValue:set(clamp)
            self.Updated:Fire(Peek(self.RotateValue)) 
        end 
    end))
end 

function Rotate:Clean()
    self.Maid:DoCleaning() 
end 

function Rotate:Toggle(bool: boolean) 
    self.Visible:set(bool)

    if bool then 
        self:Connect() 
    else 
        self:Clean() 
    end 
end 

function Rotate:Destroy()
    self.Maid:DoCleaning() 
end


return Rotate
