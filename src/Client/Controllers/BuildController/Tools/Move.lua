local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService") 
local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(Knit.Library.Maid) 

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Interface = require(Knit.Modules.Interface.get)
local Highlight = require(Knit.Library.Highlight) 
local QuickIndex = require(Knit.Library.QuickIndex) 

local Move = {}
Move.__index = Move

function Move.new()
    local self = setmetatable({
        Highlight = Highlight.new(), 
        InactiveMaid = Maid.new(),
        Selected = nil, 
        Hover = nil, 

        Dragging = false, 

        Maid = Maid.new(), 
    }, Move)

    self._rayParams = RaycastParams.new()
    self._rayParams.FilterType = Enum.RaycastFilterType.Include

    self.Highlight:SetTheme("Place") 

    return self
end

function Move:Request(Object, CFrame, LastCFrame) 
    if self.Selected then 
        local ObjectID = Object:GetAttribute("ID") 
        local BuildService = Knit.GetService("BuildService") 

        BuildService:RequestUpdate("Move", ObjectID, CFrame):andThen(function(success, reason)
            if success == false then 
                self.Highlight:Flash(Color3.new(1,0,0), 1, 0.25) 
                Object:SetPrimaryPartCFrame(LastCFrame) 
            end 
        end)
    end 
end

function Move:GetSelected()
    if self._started then return end 

    local UserInput = Knit.GetController("UserInput")
    local BuildController = Knit.GetController("BuildController") 
    local Mouse = UserInput:Get("Mouse") 
    -- check under mouse
    local mouseHit = Mouse:Raycast(self._rayParams, 256, .2) 

    if mouseHit then 
        if BuildController:isPartParentASet(mouseHit.Instance) then 
            self.Highlight:Select(mouseHit.Instance.Parent)
            self.Hover = mouseHit.Instance.Parent
        else
            self.Highlight:Select(nil)
            self.Hover = nil 
        end 
    else 
        self.Highlight:Select(nil) 
        self.Hover = nil 
    end 
end 

function Move:Start()
    self._started = true 

    if self.Selected then 
        self._lastCFrame = self.Selected.PrimaryPart.CFrame 

        game:GetService("RunService"):BindToRenderStep("Move", Enum.RenderPriority.Last.Value - 1, function()
            self.Place:Update(self.Selected, true)
        end)
    end 
end 

function Move:Stop()
    self._started = false 

    game:GetService("RunService"):UnbindFromRenderStep("Move") 

    if self.Selected then 
        self.Selected:SetPrimaryPartCFrame(self.Place._loadedPlace) 
        self:Request(self.Selected, self.Place._loadedPlace, self._lastCFrame) 
    end 
end 

function guiCheck(ancestor, guis) 
    for i, v in pairs(guis) do 
        if v:isDescendantOf(ancestor) then 
            return true 
        end 
    end 
end 

function Move:Enable()
    local UserInput = Knit.GetController("UserInput")
    local BuildController = Knit.GetController("BuildController") 
    local InterfaceController = Knit.GetController("Interface") 

    local Inventory = InterfaceController.Game.Menus.Inventory 
    
    self.Place = BuildController.Tools.Place 

    -- Mouse
    local Mouse = UserInput:Get("Mouse") 
    local Keyboard = UserInput:Get("Keyboard") 

    self._rayParams:AddToFilter(workspace.game.client.bin:GetChildren()) 
    
    RunService:BindToRenderStep("Select", Enum.RenderPriority.Last.Value - 1, function(dt)
        self:GetSelected()
    end)

    self.InactiveMaid:GiveTask(Mouse.LeftDown:Connect(function(processed, guis)
        if processed then return end 
        if #guis > 0 then 
            if guiCheck(Inventory.Object, guis) then 
                return
            end 
        end 
        
        if not Inventory:isVisible() then self:Disable() return end 

        if self.Hover then 
            self.Selected = self.Hover 
        end 

        self:Start() 
    end))
    
    self.InactiveMaid:GiveTask(Mouse.LeftUp:Connect(function()
        self:Stop() 
        self.Selected = nil 
    end))

    self.InactiveMaid:GiveTask(Keyboard.KeyDown:Connect(function(key, processed)
        if not Inventory:isVisible() then return end 

        if processed then return end 

        if key == Enum.KeyCode.R then 
            self.Place.Rotate += math.pi/2
        elseif key == Enum.KeyCode.T then 
            self.Place.Rotate -= math.pi/2
        end 
    end))  

    -- Touch
    local Touch = UserInput:Get("Mobile")

    --[[self.InactiveMaid:GiveTask(Touch.TouchTap:Connect(function()
        self:GetSelected() 
    end))--]]
end 

function Move:Disable()
    RunService:UnbindFromRenderStep("Select")

    self.Highlight:Select()
    self.InactiveMaid:DoCleaning() 
end

function Move:SetInput()

end 

function Move.Init(_tools) 
    local self = Move.new()
    return self 
end 


function Move:Destroy()
    
end


return Move
