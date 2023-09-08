local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService") 
local Knit = require(ReplicatedStorage.Packages.Knit)

local Maid = require(Knit.Library.Maid) 

local Fusion = require(Knit.Library.Fusion)
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring

local Interface = require(Knit.Modules.Interface.get)

local SoundObject = {}
SoundObject.__index = SoundObject


function SoundObject.new(_id, props)
    local self = setmetatable({
        Object = SoundObject.Create(_id, props or {}),

        _destroyOnRemove = (props or {}).DestroyOnRemove or true,
        _maid = Maid.new(),
        _isPlaying = false, 
    }, SoundObject)

    self._maid:GiveTask(self.Object) 

    return self
end

function SoundObject.Create(id, props) 
    return New "Sound" {
        SoundId = id, 
        Volume = props.Volume or 0.5, 
        TimePosition = props.Start or 0, 
        Parent = props.Parent or SoundService
    }
end 

function SoundObject:Play()
    local isResume = self._isPlaying  

    if not self._isPlaying then 
        self._isPlaying = true 
    end

    if self.Object then 
        if self._destroyOnRemove then 
            self.Object.Ended:Connect(function()
                self:Destroy() 
            end)
        end 

        if not isResume then 
            self.Object:Play() 
        else 
            self.Object:Resume()
        end 
    end 
end 

function SoundObject:Pause()
    if self.Object then 
        self.Object:Pause() 
    end 
end 

function SoundObject:Stop()
    if self.Object then 
        self._isPlaying = false 
        self.Object:Stop() 

        if self._destroyOnRemove then 
            self:Destroy() 
        end 
    end 
end 

function SoundObject:Destroy()
    self._maid:DoCleaning() 
end


return SoundObject
