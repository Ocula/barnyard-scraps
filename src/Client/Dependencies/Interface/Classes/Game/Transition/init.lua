local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Interface = require(Knit.Modules.Interface.get)

local Transition = {}
Transition.__index = Transition


function Transition.new(transitionType: string)
    local self = setmetatable({
        __kind = transitionType, 

        Active = false, 
    }, Transition)

    self:Create() 

    return self
end

function Transition:_indexKind()
    return self.__kind 
end 

function Transition:Create()
    local kind = self:_indexKind()
    self.Transition = require(script[kind]).new() 
end 

function Transition:In()
    if self.Active then return end 
    self.Active = true 

    self.Transition:In()

    game:GetService("RunService"):BindToRenderStep("Transition Render", Enum.RenderPriority.Camera.Value - 1, function(dt)
        self.Transition:Render(dt)
    end)
end

function Transition:Out()
    if not self.Active then return end 
    self.Active = false 
    
    self.Transition:Out()
    
    game:GetService("RunService"):UnbindFromRenderStep("Transition Render")
end 

function Transition:Destroy()
    
end


return Transition
