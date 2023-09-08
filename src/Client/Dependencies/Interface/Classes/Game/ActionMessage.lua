local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Signal = require(Knit.Library.Signal) 
local Maid = require(Knit.Library.Maid) 
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

local ActionMessage = {}
ActionMessage.__index = ActionMessage

function ActionMessage.new(data)
    local InterfaceController = Knit.GetController("Interface")

    local self = setmetatable({
        Choose = data.Choose,
        Capture = data.Capture, 
        Color = data.Color, 
        Visible = Value(false), 
        Body = Value(data.Body), 
        Header = Value(data.Header),
        Cancel = Value(false), 
        Freeze = data.Freeze, 

        Result = nil, 

        _wait = Signal.new(), 
        _result = Signal.new(), 

        Maid = Maid.new(), 
    }, ActionMessage)

    local Message = Interface:GetComponent("Frames/ActionMessage") 

    self.Object = Message { 

        Choose = self.Choose, 
        Capture = self.Capture,
        Visible = self.Visible, 
        Body = self.Body, 
        Color = self.Color, 
        Header = self.Header, 

        Result = self._result, 
    }

    self.Maid:GiveTask(self._result:Connect(function(result)
        self.Result = result 
    end))
    

    self.Object.Parent = InterfaceController:GetBin() 

    return self
end

function ActionMessage:GetResultListener()
    return self._result 
end 

function ActionMessage:GetResult()
    return self.Result 
end 

-- waits for the message to disappear
function ActionMessage:Wait()
    self._wait:Wait() 
end 

-- terminates any current 
function ActionMessage:Cancel()
    self.Cancel:set(true) 
    self:Destroy() 
end 

function ActionMessage:Show()
    local InterfaceController = Knit.GetController("Interface")

    if self.Freeze then
        InterfaceController.Game:Freeze() 
    end 

    self.Visible:set(true) 
end

function ActionMessage:Hide()
    local InterfaceController = Knit.GetController("Interface")

    self._wait:Fire() 

    if self.Freeze then
        InterfaceController.Game:Thaw() 
    end 

    self.Visible:set(false) 

    -- we should destroy if no activity.

    task.delay(3, function()
        if Peek(self.Visible) ~= true then 
            self:Destroy() 
        end 
    end)
end 

function ActionMessage:Destroy()
    self:Hide() 
    task.delay(.2, function()
        self.Object:Destroy() 
    end) 
end


return ActionMessage
