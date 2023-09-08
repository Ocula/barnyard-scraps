local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
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
local Maid = require(Knit.Library.Maid) 

local Point = {}
Point.__index = Point 

local Thickness = 0.1 

function Point.new(cf, Size, Parent)
    local self = setmetatable({
        Position = CFrame, 
        Size = Size, 

        MaxHover = 1,

        Visible = Value(false), 
        Hover = Value(false), 

        Maid = Maid.new(), 
    }, Point)

    local Transparency = Computed(function(Use)
        local hover, visible = Use(self.Hover), Use(self.Visible)

        if hover and visible then 
            return 0.6
        elseif visible and not hover then 
            return 0.6
        else
            return 1 
        end 
    end)

    local HoverAmount = Computed(function(Use)
        if Use(self.Hover) then 
            return 1 --self.MaxHover
        else 
            return 0 
        end 
    end)

    local tSpring = Spring(Transparency, 15, 1)
    local hSpring = Spring(HoverAmount, 18, .3) 

    local Colors = {
        Visible = Color3.new(0.454901, 0.980392, 1),
        Selected = Color3.fromRGB(76,76,76), 
    }

    self.Object = New "Part" {
        Name = "Grid", 
        Anchored = true, 
        Parent = Parent, 
        CastShadow = false, 
        CanCollide = false, 
        Size = Vector3.new(Size.X,1,Size.Z),
        CFrame = Computed(function(Use)
            return cf * CFrame.new(0,-0.48 + Use(hSpring), 0) 
        end), 
        Transparency = Transparency,
        Material = "Neon", 
        Color = Computed(function(Use)
            if Use(self.Hover) then
                return Colors.Visible
            else 
                return Colors.Selected
            end 
        end), 
    }   

    self.Maid:GiveTask(self.Object) 

    return self
end 

function Point:Show()
    self:SetVisible(true) 
end 

function Point:Hide()
    self:SetVisible(false)

    if Peek(self.Hover) then 
        self.Hover:set(false)
    end 
end

function Point:Float()
    self.Hover:set(true) 
end 

function Point:Sink()
    self.Hover:set(false) 
end 

function Point:SetVisible(bool: boolean)
    if Peek(self.Visible) == bool then return end 
    self.Visible:set(bool) 
end 

function Point:Destroy()
    self:Hide()
    self.Maid:DoCleaning() 
end 

return Point 