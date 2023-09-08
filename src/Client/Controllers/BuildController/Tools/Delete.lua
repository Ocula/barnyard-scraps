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

local Delete = {}
Delete.__index = Delete

function Delete.new()
    local self = setmetatable({
        Highlight = Highlight.new(), 
        InactiveMaid = Maid.new(),
        Selected = nil, 

        Maid = Maid.new(), 
    }, Delete)

    self._rayParams = RaycastParams.new()
    self._rayParams.FilterType = Enum.RaycastFilterType.Include

    self.Highlight:SetTheme("Delete") 

    return self
end

function Delete:Request()
    if self.Selected then 
        local ObjectID = self.Selected:GetAttribute("ID") 
        local BuildService = Knit.GetService("BuildService") 

        BuildService:RequestUpdate("Delete", ObjectID)
    end 
end

function Delete:GetSelected()
    local UserInput = Knit.GetController("UserInput")
    local BuildController = Knit.GetController("BuildController") 
    local Mouse = UserInput:Get("Mouse") 
    -- check under mouse
    local mouseHit = Mouse:Raycast(self._rayParams, 256, .2) 

    if mouseHit then 
        if BuildController:isPartParentASet(mouseHit.Instance) then 
            self.Highlight:Select(mouseHit.Instance.Parent)
            self.Selected = mouseHit.Instance.Parent
        else
            self.Highlight:Select(nil)
            self.Selected = nil 
        end 
    else 
        self.Selected = nil 
    end 
end 

function guiCheck(ancestor, guis) 
    for i, v in pairs(guis) do 
        if v:isDescendantOf(ancestor) then 
            return true 
        end 
    end 
end 


function Delete:Enable()
    local UserInput = Knit.GetController("UserInput")
    local BuildController = Knit.GetController("BuildController") 
    local InterfaceController = Knit.GetController("Interface") 

    local Inventory = InterfaceController.Game.Menus.Inventory 

    -- Mouse
    local Mouse = UserInput:Get("Mouse") 

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
        
        if not Inventory:isVisible() then return end 

        self:Request() 
    end))

    -- Touch
    local Touch = UserInput:Get("Mobile")

    --[[self.InactiveMaid:GiveTask(Touch.TouchTap:Connect(function()
        self:GetSelected() 
    end))--]]
end 

function Delete:Disable()
    RunService:UnbindFromRenderStep("Select")

    self.Highlight:Select()
    self.InactiveMaid:DoCleaning() 
end

function Delete:SetInput()

end 

function Delete.Init()
    local self = Delete.new()
    return self 
end 


function Delete:Destroy()
    
end


return Delete
