local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(Knit.Library.Maid) 

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Interface = require(Knit.Modules.Interface.get)

local HighlightTheme = Interface:GetTheme("Highlights/Inventory")

local Highlight = {}
Highlight.__index = Highlight

function Highlight.new(theme)
    local self = setmetatable({
        Adornee = nil,
        Theme = theme, 
        
        _Destroyed = false, 
        _Maid = Maid.new(), 
    }, Highlight)

    self:Create()

    return self
end

function Highlight:Create()
    self.Object = Instance.new("Highlight")

    if not self.Theme then 
        self.Object.FillTransparency = 0.5
        self.Object.FillColor = Color3.fromRGB(0, 239, 255) 
    else 
        for property, value in self.Theme do 
            self.Object[property] = value 
        end 
    end 

    self.Object.Parent = workspace.game.client.bin

    self.Object.Destroying:Connect(function()
        if not self._Destroyed then 
            self:Create() 
        end 
    end)

    self._Maid:GiveTask(self.Object) 
end 

function Highlight:Flash(color, numflashes, time, transparency) 
    if self._flashing then return end 

    self._flashing = true 

    task.spawn(function()
        for i = 0,numflashes,(numflashes/time) do 
            local _lastTransparency = self.Object.FillTransparency 

            self.Object.FillColor = color
            self.Object.FillTransparency = transparency or _lastTransparency

            task.wait(time/(numflashes*2))

            self.Object.FillColor = self.Theme.FillColor or Color3.fromRGB(0, 239, 255) 
            self.Object.FillTransparency = self.Theme.FillTransparency or _lastTransparency 

            task.wait(time/(numflashes*2))
        end 
        self._flashing = false 
    end) 
end 

function Highlight:SetTheme(theme: string)
    local colorData = HighlightTheme[theme] 
    self.Theme = colorData 

    for property, value in colorData do 
        self.Object[property] = value 
    end 
end 

function Highlight:Select(subject: userdata)
    self.Object.Adornee = subject 
    self.Adornee = subject 

    self.Object.Parent = self.Adornee 
end 

function Highlight:Destroy()
    self._Destroyed = true 
    self._Maid:DoCleaning() 
end


return Highlight
