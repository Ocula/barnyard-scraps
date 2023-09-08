local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService") 
local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(Knit.Library.Maid) 
local Signal = require(Knit.Library.Signal) 

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Interface = require(Knit.Modules.Interface.get)
local Highlight = require(Knit.Library.Highlight) 
local QuickIndex = require(Knit.Library.QuickIndex) 

local CURR_MAX_RENDER = 20 --> THIS IS THE CURRENT MAXIMUM WE CAN RENDER PARTS BECAUSE OF HIGHLIGHT LIMITATIONS on LOW-END DEVICES 

local RotateClass = Interface:GetClass("Utility/Rotate") 

local Rotate = {}
Rotate.__index = Rotate

function Rotate.new()
    local self = setmetatable({
        Highlights = {}, 

        HoverHighlight = Highlight.new(), 
        SelectedHighlight = Highlight.new(),

        Hover = nil,  
        Selected = nil, 

        CurrentRotate = Value(0), 

        Cache = {}, 

        SelectedHighlightModel = New "Model" {
            Parent = workspace.game.client.bin, 
            Name = "Rotate_Highlight_Model", 
        },

        Signals = {
            
        },

        Maid = Maid.new(), 
        InactiveMaid = Maid.new(),

        Theme = "Rotate", 
    }, Rotate)

    self.Rotate = RotateClass.new(self.CurrentRotate, self.Signals) 

    self.SelectedHighlight:SetTheme(self.Theme) 
    self.HoverHighlight:SetTheme(self.Theme) 

    self.SelectedHighlight.Object.FillTransparency = 0.8
    self.SelectedHighlight:Select(self.SelectedHighlightModel)

    self._rayParams = RaycastParams.new()
    self._rayParams.FilterType = Enum.RaycastFilterType.Include

    return self
end

function Rotate:Request()
    if self.Selected then 
        local object = self.Selected 
        local ReferenceID = object:GetAttribute("_config") 
        local ObjectID = object.Parent:GetAttribute("ID")

        local BuildService = Knit.GetService("BuildService") 

        --local rotate = 
        BuildService:RequestUpdate("Config", ObjectID, {
            Reference = ReferenceID, 
            Rotation = Peek(self.CurrentRotate), 
        }) 
    end 

    --BuildService:RequestObjectRotate(ObjectID, ReferenceID) 
end

function Rotate:CleanSelectedHighlight()
    self.SelectedHighlight:Select(nil) 
    self.SelectedHighlight:Select(self.SelectedHighlightModel) 
end 

function Rotate:GetHighlight(object)
    if not object then return end 

    local index = self.Highlights[object]

    if not index then 
        local _newHighlight = Highlight.new() 
        self.Highlights[object] = _newHighlight 
        
        _newHighlight:SetTheme(self.Theme) 
        _newHighlight.Object.FillTransparency = 0.9
        _newHighlight.Object.OutlineColor = Color3.new(1,1,0) 

        index = _newHighlight
    end 

    return index 
end 

function Rotate:SetHighlight(object)
    object.Parent = self.SelectedHighlightModel

    self:CleanSelectedHighlight()
end 

function Rotate:UpdateHover()
    local UserInput = Knit.GetController("UserInput")
    local Mouse = UserInput:Get("Mouse") 
    -- check under mouse
    local mouseHit = Mouse:Raycast(self._rayParams, 256, .1) 

    if mouseHit then 
        if mouseHit.Instance.Parent:IsA("Model") and mouseHit.Instance.Name == "Domino" then 
            self.HoverHighlight:Select(mouseHit.Instance) 
            self.Hover = mouseHit.Instance 

            return 
        end
    end 

    self.HoverHighlight:Select(nil) 
    self.Hover = nil 
end 

function Rotate:ClearSelected(_object: Instance?)
    if _object then 
        self:GetHighlight(_object):Select(nil) 
        self.Selected = nil 

        return 
    end

    if self.Selected then 
        self:GetHighlight(self.Selected):Select(nil)
    end 

    self.Selected = nil 
end 

function Rotate:ToggleMenu(bool: boolean) 

    if bool then 
        local InterfaceController = Knit.GetController("Interface") 
        self.Rotate.Object.Parent = InterfaceController.Game.Object 
    end 

    self.Rotate:Toggle(bool) 
end

function guiCheck(ancestor, guis) 
    for i, v in pairs(guis) do 
        if v:isDescendantOf(ancestor) then 
            return true 
        end 
    end 
end 


function Rotate:Enable()
    self:ToggleMenu(true) 

    local UserInput = Knit.GetController("UserInput")
    local BuildController = Knit.GetController("BuildController") 
    local InterfaceController = Knit.GetController("Interface") 

    local Inventory = InterfaceController.Game.Menus.Inventory 

    -- Mouse
    local Mouse = UserInput:Get("Mouse") 
    local Keyboard = UserInput:Get("Keyboard") 

    self._rayParams:AddToFilter(workspace.game.client.bin:GetChildren()) 

    local updating = false 
    local lastUpdated = tick() 

    self.InactiveMaid:GiveTask(self.Rotate.Updated:Connect(function(rotateValue)
        if self.Selected then 
            local _cache = self.Cache[self.Selected]
            if not _cache then 
                self.Cache[self.Selected] = {
                    Rotation = self.Selected:GetAttribute("Rotate") or 0,
                    CFrame = self.Selected.CFrame, 
                }

                _cache = self.Cache[self.Selected] 
            end 
            -- update rotation ... 
            -- get proper cf 
            local cf = _cache.CFrame 
            local rot = _cache.Rotation 

            self.Selected.CFrame = cf * CFrame.Angles(0,math.rad(rotateValue - rot),0) 
        end 

        lastUpdated = tick() 

        task.delay(.35, function()
            if tick() - lastUpdated >= .35 and updating == false then 
                updating = true 

                local Sound = Knit.GetController("Sound") 
                Sound:Play("Place")

                self:Request() 
                
                task.delay(.2, function()
                    updating = false 
                end)
            end 
        end)
    end)) 
    
    RunService:BindToRenderStep("Select", Enum.RenderPriority.Last.Value - 1, function(dt)
        self:UpdateHover()
    end)

    self.InactiveMaid:GiveTask(Mouse.LeftDown:Connect(function(processed, guis)
        if processed then return end 
        if #guis > 0 then 
            if guiCheck(Inventory.Object, guis) then 
                return
            end 
        end 
        if not Inventory:isVisible() then return end 

        self:ClearSelected() 
            
        if not self.Hover then 
            self.Rotate:Select(nil) 
            self.Selected = nil 
            return 
        end

        if self.Hover then 
            self.Selected = self.Hover 
            self.CurrentRotate:set(self.Selected:GetAttribute("Rotate") or 0) 
            self:GetHighlight(self.Hover):Select(self.Hover) 

            self.Rotate:Select(self.Selected) 
        end 
    end))

    -- Touch
    local Touch = UserInput:Get("Mobile")

    --[[self.InactiveMaid:GiveTask(Touch.TouchTap:Connect(function()
        self:GetSelected() 
    end))--]]
end 

function Rotate:Disable()
    self:ToggleMenu(false) 
    self.Cache = {} 

    RunService:UnbindFromRenderStep("Select") 

    self:ClearSelected() 
    self.HoverHighlight:Select()
    self.InactiveMaid:DoCleaning() 
end

function Rotate:SetInput()

end 

function Rotate.Init()
    local self = Rotate.new()
    return self 
end 


function Rotate:Destroy()
    
end


return Rotate
