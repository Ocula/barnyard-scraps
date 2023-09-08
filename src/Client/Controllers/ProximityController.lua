local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Dependencies 
local Maid = require(Knit.Library.Maid)
local Signal = require(Knit.Library.Signal) 
local Interface = require(Knit.Modules.Interface.get)
--
local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local ProximityController = Knit.CreateController { 
    Name = "ProximityController", 

    Signals = {
        PromptShown = Signal.new(), 
        PromptHidden = Signal.new(), 
        Triggered = Signal.new(),
        TriggerEnded = Signal.new()
        -- add support for inputholds 
    },

    Enabled = Value(true), 

    Hooks = {},
}

local ProximityPromptService = game:GetService("ProximityPromptService")

function ProximityController:RegisterHook(Name: string, Index: any, Object: table)
    if self.Hooks[Name] == nil then 
        self.Hooks[Name] = {}
    end 

    self.Hooks[Name][Index] = Object 
end 

function ProximityController:GetHook(Name: string, Index: any)
    if self.Hooks[Name] then 
        return self.Hooks[Name][Index]
    end 
end 

function ProximityController:Disable()
    self.Enabled:set(false) 
end 

function ProximityController:KnitStart()
    --onLoad()
    local PromptComponent = Interface:GetComponent("Game/Proximity") 

    local Player = game.Players.LocalPlayer 
    local PlayerGui = Player:WaitForChild("PlayerGui") 

    local ScreenGui = New "ScreenGui" {
        Parent = PlayerGui, 

        Name = "Proximities", 
        IgnoreGuiInset = true, 
        ResetOnSpawn = false, 
    }

    ProximityPromptService.PromptShown:Connect(function(prompt, inputType)
        if prompt.Style == Enum.ProximityPromptStyle.Default then 
            return 
        end

        local PackagedPrompt = prompt:GetAttributes()
        PackagedPrompt.Object = prompt 

        local PromptVariables = {
            Size = Value(0), -- anything else we wanna add here, we can.
        }

        PackagedPrompt.Variables = PromptVariables 

        local Cleaner = Maid.new()

        local PromptObject = PromptComponent {
            Parent = ScreenGui, 

            Enabled = self.Enabled, 

            Adornee = prompt.Parent, 
            Prompt = prompt,
            InputType = inputType, 
            SizeMultiplier = PromptVariables.Size,

            SizeOffset = Value(Vector2.new(prompt.UIOffset.X, prompt.UIOffset.Y)), 

            Cleaner = Cleaner, 
        }

        if PackagedPrompt.MetaObject then 
            local Hook = require(Knit.Modules.Classes.Proximities:FindFirstChild(PackagedPrompt.MetaObject)).new(PackagedPrompt) 
            self:RegisterHook(PackagedPrompt.MetaObject, prompt, Hook) 

            Cleaner:GiveTask(Hook) 
        end 

        Cleaner:GiveTask(PromptObject)

        Cleaner:GiveTask(prompt.Triggered:Connect(function()
            self.Signals.Triggered:Fire(PackagedPrompt) 
        end))

        Cleaner:GiveTask(prompt.TriggerEnded:Connect(function()
            self.Signals.TriggerEnded:Fire(PackagedPrompt) 
        end))

        Cleaner:GiveTask(Observer(self.Enabled):onChange(function()
            prompt.Enabled = Peek(self.Enabled) 
        end))

        self.Signals.PromptShown:Fire(PackagedPrompt) 

        PromptVariables.Size:set(1) -- show 

        prompt.PromptHidden:Wait()

        self.Signals.PromptHidden:Fire(PackagedPrompt) 

        PromptVariables.Size:set(0) -- hide 

        task.delay(0.2, function()
            Cleaner:DoCleaning() 
        end)
    end)
end

function ProximityController:KnitInit()
    local function processPrompt(Prompt: table, Function: string)
        if Prompt.MetaObject then -- connects us to any hooks 
            local Hook = self:GetHook(Prompt.MetaObject, Prompt.Object) 

            if Hook then 
                if Hook[Function] then 
                    Hook[Function](Prompt) 
                end 
            end 
        end 
    end 

    self.Signals.PromptShown:Connect(function(Prompt)
        processPrompt(Prompt, "Show") 
    end)

    self.Signals.PromptHidden:Connect(function(Prompt)
        processPrompt(Prompt, "Hide") 
    end)
    
    self.Signals.Triggered:Connect(function(Prompt)
        processPrompt(Prompt, "Triggered") 
    end)

    self.Signals.TriggerEnded:Connect(function(Prompt)
        processPrompt(Prompt, "TriggerEnded") 
    end)
end


return ProximityController