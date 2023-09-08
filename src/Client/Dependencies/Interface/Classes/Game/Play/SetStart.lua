local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Signal = require(Knit.Library.Signal) 
local Maid = require(Knit.Library.Maid) 

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Interface = require(Knit.Modules.Interface.get)

local Arrow = require(Knit.Library.Arrow) 
local Highlight = require(Knit.Library.Highlight) 

local SetStart = {}
SetStart.__index = SetStart

function SetStart.new()
    local self = setmetatable({
        Hover = nil, 
        Selected = nil, 

        Highlight = Highlight.new(), 
        SelectHighlight = Highlight.new({
            FillTransparency = 0, 
            FillColor = Color3.new(1, 0.882352, 0),
        }), 

        _selectedChanged = Signal.new(), 
        _hoverChanged = Signal.new(), 

        Maid = Maid.new()
    }, SetStart)

    self.HoverArrow = Arrow.new({
        Lerp = false,
        PointFromLookVector = true, 
    })

    self.SelectedArrow = Arrow.new({
        Lerp = false,
        PointFromLookVector = true, 
    }) 

    self.HoverArrow:SetDistance(0)
    self.SelectedArrow:SetDistance(0) 

    return self 
end 

function SetStart:UpdateHover()
    local UserInput = Knit.GetController("UserInput")
    local Mouse = UserInput:Get("Mouse") 
    -- check under mouse
    local mouseHit = Mouse:Raycast(self._rayParams, 256, .1) 

    if mouseHit then
        if mouseHit.Instance.Parent:IsA("Model") and mouseHit.Instance.Name == "Domino" then 
            self._hoverChanged:Fire(mouseHit.Instance) 
            return
        end
    end 

    self._hoverChanged:Fire(nil) 
end 

function SetStart:Request()
    if self.Selected then 
        local BuildService = Knit.GetService("BuildService")
        local SelectedReference = self.Selected:GetAttribute("_config") 
        local SelectedObjectId = self.Selected.Parent:GetAttribute("ID") 

        --warn("REQ OBJ ID, REF:", SelectedObjectId, SelectedReference)

        BuildService:SetStartDomino(SelectedObjectId, SelectedReference) 
    end 
end 

function SetStart:ClearSelection()
    self.Selected = nil 
    self.SelectedArrow:Anchor(nil) 
    self.SelectHighlight:Select(nil) 
end 

function SetStart:Load()
    local BuildService = Knit.GetService("BuildService")
    local InterfaceController = Knit.GetController("Interface")
    
    local Complete = Signal.new() 
    local Data
    
    BuildService:GetStartDomino():andThen(function(toppleData)
        Data = toppleData
        Complete:Fire(true) 
    end):catch(function(err) 
        Complete:Fire(false) 
        error(err) 
    end)

    Complete:Wait()

    self.Data = Data

    --

    if Data.ObjectId and Data.Reference then 
        if Data.ObjectId ~= "" and Data.Reference > 0 then 
            local DominoController = Knit.GetController("DominoController") 
            local Domino = DominoController:GetDominoFromObjectId(self.Data.ObjectId, self.Data.Reference) 

            if Domino then 
                self.Selected = Domino.Object

                DominoController.Set:Fire(Domino) 
                DominoController:SetStartingDomino(self.Data.ObjectId, self.Data.Reference) 
            else 
                self:ClearSelection() 
            end 
        end 
    else 
        warn("We have no objectid or reference data", Data)
    end 
end 

function guiCheck(ancestor, guis) 
    for i, v in pairs(guis) do 
        if v:isDescendantOf(ancestor) then 
            return true 
        end 
    end 
end 

function SetStart:Enable()
    self:Load() 

    local UserInput = Knit.GetController("UserInput")
    local InterfaceController = Knit.GetController("Interface")
    local DominoController = Knit.GetController("DominoController")
    local Inventory = InterfaceController.Game.Menus.Inventory 
    local Mouse = UserInput:Get("Mouse") 

    self.Maid:GiveTask(self._selectedChanged:Connect(function(selection)
        local Domino = DominoController:GetDomino(selection)

        if Domino then 
            Domino:GetDirection() 
            self.SelectedArrow.Direction = Domino.Direction 
        end 

        --warn("Selected:", selection)
        self.Selected = selection 
        self.SelectedArrow:Anchor(selection)
        
        self.SelectHighlight:Select(selection) 

        self:Request()
    end)) 

    self.Maid:GiveTask(self._hoverChanged:Connect(function(selection)
        local Domino = DominoController:GetDomino(selection)

        if Domino then 
            Domino:GetDirection() 
            self.HoverArrow.Direction = Domino.Direction 
        end 
        
        self.Hover = selection 
        self.HoverArrow:Anchor(selection) 
        self.Highlight:Select(selection) 
    end))

    self.Maid:GiveTask(Mouse.LeftDown:Connect(function(processed, guis)
        if processed then return end 

        if #guis > 0 then 
            if guiCheck(Inventory.Object, guis) then 
                warn("Guis:", guis) 
                return
            end 
        end 

        self._selectedChanged:Fire(self.Hover) 
    end)) 

    self.HoverArrow:Start()
    self.SelectedArrow:Start() 

    if self.Selected then 
        --warn("Selected:", self.Selected)
        if self.Selected:isDescendantOf(workspace) then 
            self.SelectHighlight:Select(self.Selected)
            self.SelectedArrow:Anchor(self.Selected) 
        else 
            self:ClearSelection() 
        end 
    end 

    game:GetService("RunService"):BindToRenderStep("SetStartSelect", Enum.RenderPriority.Last.Value - 1, function(dt)
        self:UpdateHover() 
    end)
end 

function SetStart:Disable()
    game:GetService("RunService"):UnbindFromRenderStep("SetStartSelect") 

    self.HoverArrow:Stop()
    self.SelectedArrow:Stop() 

    self.SelectHighlight:Select(nil)
    self.Highlight:Select(nil) 

    self.Maid:DoCleaning() 
end 


function SetStart:Destroy()
    
end


return SetStart
