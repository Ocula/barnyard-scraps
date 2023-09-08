local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService") 
local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(Knit.Library.Maid) 
local Signal = require(Knit.Library.Signal) 

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Interface = require(Knit.Modules.Interface.get)
local Highlight = require(Knit.Library.Highlight) 
local QuickIndex = require(Knit.Library.QuickIndex) 

local CURR_MAX_RENDER = 20 --> THIS IS THE CURRENT MAXIMUM WE CAN RENDER PARTS BECAUSE OF HIGHLIGHT LIMITATIONS on LOW-END DEVICES 

local ColorClass = Interface:GetClass("Utility/Color") 

local Paint = {}
Paint.__index = Paint

function Paint.new()
    local self = setmetatable({
        Highlights = {}, 
        InactiveMaid = Maid.new(),

        SelectedColor = Color3.new(), 
        Hover = nil,  
        HoverHighlight = Highlight.new(), 
        SelectedHighlight = Highlight.new(),
        Selected = {}, 

        Menu = ColorClass.new(), 

        SelectedHighlightModel = New "Model" {
            Parent = workspace.game.client.bin, 
            Name = "Paint_Highlight_Model", 
        },

        Maid = Maid.new(), 
        Theme = "Paint", 

        _renderChecking = false, 
    }, Paint)

    self.SelectedHighlight:SetTheme(self.Theme) 
    self.HoverHighlight:SetTheme(self.Theme) 

    self.SelectedHighlight.Object.FillTransparency = 0.8
    self.SelectedHighlight:Select(self.SelectedHighlightModel)

    self._rayParams = RaycastParams.new()
    self._rayParams.FilterType = Enum.RaycastFilterType.Include

    return self
end

function Paint:Request()
    for object, _ in self.Selected do 
        local ReferenceID = object:GetAttribute("_config") 
        local ObjectID = object.Parent:GetAttribute("ID")
        local Color = object.Color -- color3 
        local Transparency = object.Transparency 

        local BuildService = Knit.GetService("BuildService") 
        
        --warn("Requesting object paint", ObjectID, ReferenceID, Color) -- and color 

        BuildService:RequestUpdate("Config", ObjectID, {Reference = ReferenceID, Transparency = Transparency, Color = Color}) 
    end 

    --BuildService:RequestObjectPaint(ObjectID, ReferenceID) 
end

function Paint:CleanSelectedHighlight()
    self.SelectedHighlight:Select(nil) 
    self.SelectedHighlight:Select(self.SelectedHighlightModel) 
end 

function Paint:GetHighlight(object)
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

function Paint:SetHighlight(object)
    object.Parent = self.SelectedHighlightModel

    self:CleanSelectedHighlight()
end 

function Paint:UpdateHover()
    local UserInput = Knit.GetController("UserInput")
    local Mouse = UserInput:Get("Mouse") 
    local Keyboard = UserInput:Get("Keyboard") 
    -- check under mouse
    local mouseHit = Mouse:Raycast(self._rayParams, 256)

    if mouseHit then 
        if mouseHit.Instance.Parent:IsA("Model") and mouseHit.Instance.Name == "Domino" then 
            if not self.Selected[mouseHit.Instance] then
                self.HoverHighlight:Select(mouseHit.Instance) 
            end 

            self.Hover = mouseHit.Instance 
            -- add touch support for multi-select... idk how to do that yet tho lol
        else
            self.HoverHighlight:Select(nil) 
            self.Hover = nil 
        end
    else 
        self.HoverHighlight:Select(nil) 
        self.Hover = nil 
    end 
end 

function Paint:ClearSelected(_object: Instance?)
    if _object then 
        self:GetHighlight(_object):Select(nil) 
        self.Selected[_object] = nil 

        return 
    end 

    for obj, v in self.Selected do 
        self:GetHighlight(obj):Select(nil) 
    end 

    self.Selected = {} 
    self.Highlights = {} 
end 

function Paint:RenderCheck()
    local _count = 0 

    for i, v in self.Selected do 
        _count += 1 
    end 

    return _count >= CURR_MAX_RENDER
end 

function Paint:ToggleMenu(bool: boolean) 

    if bool then 
        local InterfaceController = Knit.GetController("Interface") 
        self.Menu.Object.Parent = InterfaceController.Game.Object 
    end 

    self.Menu:Toggle(bool) 
end

function guiCheck(ancestor, guis) 
    for i, v in pairs(guis) do 
        if v:isDescendantOf(ancestor) then 
            return true 
        end 
    end 
end 

function Paint:Enable()
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

    self.InactiveMaid:GiveTask(self.Menu.Updated:Connect(function(color)
        _update = true 

        for obj, v in self.Selected do 
            if obj:IsA("BasePart") then 
                obj.Color = color 
            end 
        end 

        lastUpdated = tick() 

        task.delay(.35, function()
            if tick() - lastUpdated >= .35 and updating == false then 
                updating = true 

                local Sound = Knit.GetController("Sound") 
                Sound:Play("Paint")

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

        if not Keyboard:IsDown(Enum.KeyCode.LeftShift) then 
            self:ClearSelected() 
            
            if not self.Hover then
                return 
            end
        else
            if self.Hover == nil then 
                self:ClearSelected() 
                return 
            end 

            if self.Selected[self.Hover] then 
                self:ClearSelected(self.Hover) 
                self.Selected[self.Hover] = nil 
                return 
            end 

            if self:RenderCheck() then
                if self._renderChecking == true then 
                    return 
                end 

                self._renderChecking = true 

                local _action = Interface:GetClass("Game/ActionMessage")
                local _message 

                _message = _action.new({
                    Choose = function(_result)
                        self._renderChecking = false 
                        _message:Destroy()
                    end,
    
                    Header = "paint tool",
                    Body = "You have selected the maximum number of Dominos you can select at one time! ("..tostring(CURR_MAX_RENDER)..")"
                })

                _message:Show() 

                return 
            end 
        end

        if self.Hover then 
            self.Selected[self.Hover] = self.Hover.Parent  
            self:GetHighlight(self.Hover):Select(self.Hover) 
        end 

        --self:Request() we'll request from color wheel 
    end))

    -- Touch
    local Touch = UserInput:Get("Mobile")

    --[[self.InactiveMaid:GiveTask(Touch.TouchTap:Connect(function()
        self:GetSelected() 
    end))--]]
end 

function Paint:Disable()
    self.Menu:Toggle(false) 

    RunService:UnbindFromRenderStep("Select") 

    self:ClearSelected() 
    self.HoverHighlight:Select()
    self.InactiveMaid:DoCleaning() 
end

function Paint:SetInput()

end 

function Paint.Init()
    local self = Paint.new()
    return self 
end 


function Paint:Destroy()
    
end


return Paint
