-- CLIENT-SIDE NPC OBJECT
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService") 

local Knit = require(ReplicatedStorage.Packages.Knit)
local QuickIndex = require(Knit.Library.QuickIndex)

local Maid = require(Knit.Library.Maid)
local Signal = require(Knit.Library.Signal) 

local Interface = require(Knit.Modules.Interface.get)

local TalkProximity = Interface:GetComponent("Game/TalkPrompt")
local TalkClass = require(script:WaitForChild("Talk")) 
local Vendor = require(script:WaitForChild("Vendor"))

local NPCBin = workspace.game.client:WaitForChild("npcs")
local SharedBin = Instance.new("Folder")
SharedBin.Parent = game.Lighting 
SharedBin.Name = "npc-client" 

local NPClient = {}
NPClient.__index = NPClient

function NPClient.new(Data)
    local self = setmetatable({
        Data        = Data, 
        Maid        = Maid.new(), 

        State       = "Idle", 

        Update      = Signal.new(), 

        Focused = false, 
    }, NPClient)

    self:Set() 

    --self.Animate = require(script.Animate).new(self:Package()) 
    --self.Dialogue = require(script.Dialogue).new(self:Package()) 

    self.Talk = TalkClass.new({
        Name = self.Data.Name, 
        IsVendor = self.Data.IsVendor, 
        Dialogue = {
            self.Data.Dialogue["en-us"].Greet, -- localize
        }
    })

    -- Handle vendor stuff
    self.Maid:GiveTask(self.Talk.Completed:Connect(function()
        if self.Focused and self.Data.IsVendor then 
            self.Vendor:Show() 
        else 
            self:LoseFocus() 
        end 
    end))


    if self.Data.IsVendor then
        self.Vendor = Vendor.new(self.Data)
        -- Connect
        self.Maid:GiveTask(self.Vendor.Exited:Connect(function()
            if self.Focused then 
                self:LoseFocus()
            end 
        end))
    end 

    return self
end

-- / Utility Methods

-- @Ocula 
-- Setup NPClient.
function NPClient:Set()
    if not self.Object then 
        local CharacterId = self.Data.Character 
        local Character = QuickIndex:GetVendor(CharacterId)

        if Character then 
            self.Object = Character.Object:Clone()

            -- create proximity prompt
            local Proximity = TalkProximity({
                Parent = self.Object.PrimaryPart, 
                Name = self.Data.Name, 
                Keycode = Enum.KeyCode.E, 
                GamepadCode = Enum.KeyCode.ButtonA
            }) 

            Proximity.TriggerEnded:Connect(function() 
                if not self.Focused then 
                    self:Focus()
                end 
            end)

            Proximity.PromptHidden:Connect(function()
                self:LoseFocus() 

                if self.Data.IsVendor then 
                    self.Vendor:Hide()
                end 
            end)
        end
    end 

    if not self.Stage then 
        local StageId = self.Data.Stage

        if StageId then 
            local Stage = QuickIndex:GetVendor(StageId)

            if Stage then 
                self.Stage = Stage.Object:Clone()

                -- find npc anchor 
                for i, v in self.Stage:GetDescendants() do 
                    if CollectionService:HasTag(v, "Anchor") then 
                        self.Anchor = v 
                    end 
                end 

                if self.Anchor then 
                    self.Object:SetPrimaryPartCFrame(self.Anchor.CFrame) 
                end 
            end 
        end 
    end 
end 

--
function NPClient:Package()
    return {
        Name = self.Data.Name, 
        Object = self.Object, 
        Stage = self.Stage, 
        Dialogue = self.Data.Dialogue,
        State = self.State, 
    }
end 

-- @Ocula
-- Show the NPC to the player.
function NPClient:Show()
    -- check with server if we have permission to do this.
    self.Object.Parent = NPCBin 
    self.Stage.Parent = NPCBin 
end 


-- @Ocula
-- Hide the NPC from the player. 
function NPClient:Hide()
    self.Object.Parent = SharedBin
    self.Stage.Parent = SharedBin 
end 


function NPClient:Next()
    if self.Talk then 
        self.Talk.Next:Fire() 
    end 
end 

-- @Ocula
function NPClient:Focus()
    if self.Focused then return end 
    self.Focused = true 

    local Talk = self.Talk 

    Talk:Queue({
        self.Data.Dialogue["en-us"].Greet, --TODO: localize
    })

    Talk:Show() 

    --[[
    self.CompletedConnection = Talk.Completed:Connect(function()
        self.Focused = false 
        self.CompletedConnection:Disconnect() 
    end)--]]
end 

-- @Ocula
function NPClient:LoseFocus()
    if not self.Focused then return end 

    self.Focused = false 

    if self.CompletedConnection then 
        self.CompletedConnection:Disconnect() 
    end 

    self.Talk:Hide()
end 

-- / Activity Methods 

-- @Ocula
-- 
function NPClient:Speak()

end 

function NPClient:Move(_to)

end 

function NPClient:Destroy()
    
end


return NPClient
