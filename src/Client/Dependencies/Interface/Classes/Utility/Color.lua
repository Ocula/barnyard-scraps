
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

local ColorWheel = Interface:GetComponent("Game/Inventory/Tools/ColorWheel")

local Color = {}
Color.__index = Color

function Color.lerpPosition(min, max, point) 
    return min * (1 - point) + (max * point)
end 

function Color.new()
    local RGB = {
        R = Value(255), 
        G = Value(255), 
        B = Value(255)
    }

    local self = setmetatable({

        Data = {
            Visible = Value(false), 
            FramePosition = Value(UDim2.fromScale(0.5,0.5)),

            FrameAbsSize = nil,
            FrameAbsPos = nil, 

            Sliders = {}, 
            SliderObjects = {}, 
        },

        Signals = {

            NewSlider = Signal.new(), 

            WheelUpdate = Signal.new(), 
            SliderUpdate = Signal.new(), 
            UpdatePicked = Signal.new(), 

            MouseButton1Down = Signal.new(), 
            MouseButton1Up = Signal.new(),
            MouseLeave = Signal.new(), 

            SliderSignals = {
                MouseButton1Down = Signal.new(), 
                MouseButton1Up = Signal.new(), 
                MouseLeave = Signal.new(), 

                NewSlider = Signal.new(), 
                Update = Signal.new(), 
                TextBoxRequest = Signal.new(), 
            },
        },

        Updated = Signal.new(), 

        Maid = Maid.new(), 

    }, Color)

    -- we've got a sh*t load of events to connect here

    -- pre-color wheel creation things (set RGB, Picked event, RGB sliders) 
    self.RGB = RGB 

    for name in RGB do 
        self.Data.Sliders[name] = name 
    end 

    self.Data.Picked = Computed(function(Use)
        local r, g, b = Use(RGB.R), Use(RGB.G), Use(RGB.B)
        local color = Color3.fromRGB(r, g, b) 

        self.Updated:Fire(color) 

        return color
    end)

    -- new sliders:
    self.Signals.SliderSignals.NewSlider:Connect(function(name, instance, slider, text)
        self.Data.SliderObjects[name] = {
            Name            = name, 
            Instance        = instance, 
            SliderPosition  = slider, 
            TextBox         = text 
        }
    end) 

    -- create color wheel and picker. 
    self.Object, self.Picker = ColorWheel(self.Data, self.Signals) 

    -- set circle properties
    self:UpdateCircleProps()

    return self
end

function Color:Connect() -- Connect PRE and POST signals.
    -- now... begin our signals... lol
    self.Maid:GiveTask(self.Signals.MouseButton1Down:Connect(function(Data)
        self:Start(Data) 
    end)) 

    self.Maid:GiveTask(self.Signals.MouseButton1Up:Connect(function()
        self:Stop() 
    end)) 

    -- slider details 
    local min, max = 0, 0.9
    local UserInput = Knit.GetController("UserInput")
    local Mouse = UserInput:Get("Mouse") 

    self.Maid:GiveTask(self.Signals.SliderSignals.MouseButton1Down:Connect(function(instance, sliderPosition, currRGB, Text)
        local RGBFind = self.RGB[currRGB] 
        local drag = instance:FindFirstChild("Drag") 
        local frame = drag:FindFirstChild("DragFrame") 

        self:UpdateCircleProps() 

        self.Maid:GiveTask(Mouse.LeftUp:Connect(function()
            self.Signals.SliderSignals.MouseButton1Up:Fire() 
        end)) 

        RunService:BindToRenderStep("Slider", Enum.RenderPriority.Last.Value - 1, function(dt)
            self.Signals.SliderSignals.Update:Fire(frame, sliderPosition, RGBFind, Text) 
        end)
    end)) 

    self.Maid:GiveTask(self.Signals.SliderSignals.TextBoxRequest:Connect(function(name, request) 
        if tonumber(request) ~= nil then 
            local clamped = math.clamp(tonumber(request), 0, 255) 
            local currSlider = self.Data.SliderObjects[name] 
            local currRGB = self.RGB[name] 

            if currSlider then 
                local lerpPosition = self.lerpPosition(min, max, clamped/255)
                currSlider.SliderPosition:set(lerpPosition) 
                currSlider.TextBox:set(tostring(math.floor(clamped)))
            end 

            if currRGB then 
                currRGB:set(math.floor(clamped)) 
            end 

            self.Signals.SliderUpdate:Fire() 
        end 
    end))

    self.Maid:GiveTask(self.Signals.SliderSignals.Update:Connect(function(frame, sliderPosition, currRGB, Text)
        local mouseLocation = Mouse:GetPosition()
        local absPos, absSize = frame.AbsolutePosition, frame.AbsoluteSize 
        
        local total = absSize.X - (absSize.X * min) 

        local clampedMouse = math.clamp(mouseLocation.X - absPos.X, 0, total) 
        local point = (clampedMouse) / total

        local rgbSet = math.floor(point * 255)

        local lerppoint = self.lerpPosition(min, max, point) 

        if currRGB then 
            currRGB:set(rgbSet) 
        end 

        Text:set(tostring(rgbSet)) 
        sliderPosition:set(lerppoint) 

        self.Signals.UpdatePicked:Fire() 
        self.Signals.SliderUpdate:Fire() 
    end))

    -- everytime the wheel updates, also update sliders. 
    self.Maid:GiveTask(self.Signals.WheelUpdate:Connect(function()
        local function calcRGB255(x)
            return x / 255 
        end 

        for name, value in self.RGB do 
            local currentSlider = self.Data.SliderObjects[name] 
            local lerpPosition = self.lerpPosition(min, max, calcRGB255(Peek(value)))
            currentSlider.SliderPosition:set(lerpPosition) 
            currentSlider.TextBox:set(tostring(math.floor(Peek(value))))
        end 
    end))

    self.Maid:GiveTask(self.Signals.SliderUpdate:Connect(function()
        local rgb = {} 

        for name, value in self.RGB do 
            rgb[name] = Peek(value) 
        end 

        local hue, saturation, value = Color3.fromRGB(rgb.R, rgb.G, rgb.B):ToHSV() 

        local newPosition = self:GetHSPosition(hue, saturation) 
        self.Data.FramePosition:set(newPosition) 
    end))

    self.Maid:GiveTask(self.Signals.SliderSignals.MouseButton1Up:Connect(function()
        RunService:UnbindFromRenderStep("Slider") 
    end))

    -- connect
    self.Signals.WheelUpdate:Fire() 
end 

function Color:UpdateCircleProps()
    local Circle = self.Picker.Parent 

    self.Data.Circle = Circle 
    self.Data.FrameAbsSize = Circle.AbsoluteSize -- V2 
    self.Data.FrameAbsPos = Circle.AbsolutePosition -- V2
    self.Data.CircleRadius = Circle.AbsoluteSize.X / 2 -- Num 
    self.Data.CircleCenter = Circle.AbsolutePosition + (Circle.AbsoluteSize / 2) -- V2 
end 

function Color:Start(Data)
    self:UpdateCircleProps() 

    local UserInput = Knit.GetController("UserInput")
    local Mouse = UserInput:Get("Mouse") 

    self.Maid:GiveTask(Mouse.LeftUp:Connect(function()
        self:Stop() 
    end)) 

    game:GetService("RunService"):BindToRenderStep("Color", Enum.RenderPriority.Last.Value - 1, function(dt)
        self:Update(Mouse) 
    end) 
end

function Color:Stop()
    game:GetService("RunService"):UnbindFromRenderStep("Color") 
end

function Color:GetClampPosition(mousePosition: Vector2 ): UDim2
    local radius = self.Data.CircleRadius 
    local center = self.Data.CircleCenter 
    local absSize = self.Data.FrameAbsSize 
    local topLeft = self.Data.FrameAbsPos 

    local direction = mousePosition - center 
    local magnitude = direction.magnitude 

    local transformMousePosition = mousePosition - topLeft 

    if magnitude > radius then 
        local dir = direction.unit * radius 
        transformMousePosition = (center + dir) - topLeft 
    end 

    -- now convert to scale pos

    return UDim2.fromScale(transformMousePosition.X / absSize.X, transformMousePosition.Y / absSize.Y), transformMousePosition
end

function Color:GetHSPosition(hue, saturation) 
    local center = self.Data.CircleCenter 
    local radius = self.Data.CircleRadius 

    local absSize = self.Data.FrameAbsSize 
    local absPos = self.Data.FrameAbsPos 

    -- Calculate the angle based on the hue (normalized distance along the circumference)
    local angleOffset = math.pi / 2 -- this is to work with the current image. 
    local angle = (hue * 2 * math.pi) + angleOffset
    
    -- Calculate the point on the circumference
    local x = center.X + radius * math.cos(angle)
    local y = center.Y + radius * math.sin(angle)

    -- Calculate the distance from the circumference to the center based on the saturation
    local direction = Vector2.new(x - center.X, y - center.Y)
    local distanceFromCircumference = saturation * radius
    
    -- Calculate the final position in Vector2 coordinates
    local position = center + direction.Unit * distanceFromCircumference

    -- Convert to Scale 
    local transformPosition = position - absPos 
    local scalePosition = UDim2.fromScale(transformPosition.X / absSize.X, transformPosition.Y / absSize.Y) 

    return scalePosition 
end 

function Color:GetHue(mousePosition)
    local radius = self.Data.CircleRadius 
    local center = self.Data.CircleCenter 

    local top = center + Vector2.new(0, radius)

    local direction = mousePosition - center
    local angle = math.atan2(top.Y - center.Y, top.X - center.X)
    local pointAngle = math.atan2(direction.Y, direction.X)

    local fullAngle = 2 * math.pi

    local normalizedDistance = (pointAngle - angle) / fullAngle
    if normalizedDistance < 0 then
        normalizedDistance = normalizedDistance + 1
    end

    return normalizedDistance
end

function Color:GetSaturation(mousePosition)
    local radius = self.Data.CircleRadius 
    local center = self.Data.CircleCenter
    local absSize = self.Data.FrameAbsSize 
    local topLeft = self.Data.FrameAbsPos  

    local transformCenter = center - topLeft
    local mag = (transformCenter - mousePosition).Magnitude 

    return math.clamp(mag / radius, 0, 1)
end 

function Color:GetRGB() 
    return Peek(self.Data.Picked)
end 

--TODO: add value slider 

function Color:Update(Mouse) 
    local mouseLocation = Mouse:GetPosition()
    local clampFramePosition, mousePosition = self:GetClampPosition(mouseLocation)

    local hue, saturation = self:GetHue(mouseLocation), self:GetSaturation(mousePosition) 

    self.Data.FramePosition:set(clampFramePosition)

    local hsvColor = Color3.fromHSV(hue, saturation, 1)
    local r, g, b = hsvColor.R * 255, hsvColor.G * 255, hsvColor.B * 255 

    self.RGB.R:set(r) 
    self.RGB.G:set(g) 
    self.RGB.B:set(b)
    -- 

    self.Signals.WheelUpdate:Fire() 
end 

function Color:Toggle(bool: boolean)
    self.Data.Visible:set(bool) 

    if bool == false then 
        self.Maid:DoCleaning() 
    elseif bool == true then 
        self:UpdateCircleProps() 
        self:Connect() 
    end 
end 


function Color:Destroy()
    
end


return Color
