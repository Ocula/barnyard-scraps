local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Signal = require(Knit.Library.Signal) 
local Maid = require(Knit.Library.Maid)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local DialoguFormat = require(Knit.Library.DialogueFormat)
local Interface = require(Knit.Modules.Interface.get)

local Dialogue = Interface:GetComponent("Game/NPC/Dialogue")

local Talk = {}
Talk.__index = Talk

function Talk.new(Data)
    local self = setmetatable({
        -- input this into talk composition 
        Tree = Data.Dialogue,
        Name = Data.Name, 
        isVendor = Data.isVendor, 

        Visible = Value(false), 

        Index = Value(1),
        GraphemePoint = Value(0), 
        GraphemeTotal = Value(0), 

        Skip = Signal.new(), 
        Next = Signal.new(), 
        Completed = Signal.new(), 

        Maid = Maid.new()
    }, Talk)
    
    local Bin = Knit.GetController("Interface"):GetBin() 

    self.CurrentText = Computed(function(Use)
        local setText = self.Tree[Peek(self.Index)]

        if setText then 
            local formatted = DialoguFormat:Format(setText) 

            return formatted 
        else 
            return '<font color="rgb(255,100,100)">Could not find dialogue asset for NPC: '..self.Name.."</font>"
        end 
    end)

    local function onTextChanged()
        local count = 0 
        local textProp = Peek(self.CurrentText) 

        for first, last in utf8.graphemes(textProp) do 
            --local grapheme = textProp:sub(first, last) 
            count += 1
        end

        self.GraphemeTotal:set(count) 
    end 

    self.Maid:GiveTask(Observer(self.CurrentText):onChange(onTextChanged))

    self.GraphemeSpring = Spring(self.GraphemePoint, 2.5, 1)

    self.Object = Dialogue {
        Name = self.Name, 
        Text = self.CurrentText, 

        Visible = self.Visible, 

        GraphemePoint = self.GraphemePoint, 
        GraphemeSpring = self.GraphemeSpring, 
        GraphemeTotal = self.GraphemeTotal, 

        Parent = Bin, 

        Next = self.Next,
    }

    self.Maid:GiveTask(self.Next:Connect(function()
        if Peek(self.GraphemeSpring) < 0.9 then
            self.GraphemePoint:set(1)
            self.GraphemeSpring:setPosition(1)
        else 
            local Index = Peek(self.Index)

            if self.Tree[Index + 1] then 
                local Add = Index + 1 
                self.GraphemePoint:set(0)
                self.GraphemeSpring:setPosition(0)

                self.Index:set(Add) 

                self.GraphemePoint:set(1) 
            else 
                self:Hide()
            end 
        end
    end))

    self.Maid:GiveTask(self.Completed:Connect(function()

    end)) 

    self.Maid:GiveTask(self.Object) 

    onTextChanged() 

    return self
end

function Talk:Queue(Tree)
    self.Dialogue = table.clone(Tree)
    self.Index:set(0) 

    self.Index:set(1) 
end 

function Talk:Show()
    local InterfaceController = Knit.GetController("Interface") 
    InterfaceController.Game.HUD:Toggle(false) 

    if #self.Tree == 0 then 
        self:Hide() 
    else 
        self.Visible:set(true)

        self.GraphemePoint:set(0)
        self.GraphemeSpring:setPosition(0)
        -- 
        self.GraphemePoint:set(1) 
    end 
end

function Talk:Hide()
    local InterfaceController = Knit.GetController("Interface") 

    local Index = Peek(self.Index) -- how many chats we got through

    for i = 1,Index do
        table.remove(self.Tree, 1) -- remove the first of tree
    end 

    self.Visible:set(false)
    self.Index:set(1) 
    
    self.Completed:Fire()

    InterfaceController.Game.HUD:Toggle(true) 
end 

-- waits for lifetime reached, or player next input
function Talk:Wait()
    self.Completed:Wait() 
end 

function Talk:Destroy()
    self.Maid:DoCleaning() 
end


return Talk
