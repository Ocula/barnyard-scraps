local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Signal = require(Knit.Library.Signal)
local Maid = require(Knit.Library.Maid)

local QuickIndex = require(Knit.Library.QuickIndex) 

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Interface = require(Knit.Modules.Interface.get)

local ActionMessage = Interface:GetClass("Game/ActionMessage")
local ActionMessageTheme = Interface:GetTheme("Frames/ActionMessage")
local VendorComponent = Interface:GetComponent("Game/NPC/Vendor")

local ExitButton    = Interface:GetClass("Game/Exit") 

local Vendor = {}
Vendor.__index = Vendor


function Vendor.new(Data)
    local Bin = Knit.GetController("Interface"):GetBin() 

    local self = setmetatable({
        Buy = Signal.new(),
        Selected = Value(""), -- itemid: dominos:basic:basic --> QuickIndex:GetBuild(itemId)
        Visible = Value(false), 

        Busy = false, 

        Exited = Signal.new(), 

        Maid = Maid.new(),
    }, Vendor)

    self.Object = VendorComponent {
        Visible = self.Visible, 
        Selected = self.Selected,
        NPC = Data, 
        Buy = self.Buy,

        Parent = Bin, 
    }

    local ExitButtonInstance = ExitButton.new(self.Object, function()
        self:Hide() 
        self.Exited:Fire()
    end) 

    -- Connect to Buy Event here and then use the :Prompt() method 
    self.Maid:GiveTask(self.Buy:Connect(function()
        self:Prompt(Peek(self.Selected)) 
    end))

    return self
end

function Vendor:Prompt(ItemId: string)
    if self.Busy then return end 
    self.Busy = true 

    local Item = QuickIndex:GetBuild(ItemId)
    local Name = Item.Object.Name 
    local Price = Item.Object:GetAttribute("Price") 

    local _Action
    _Action = ActionMessage.new({
        Choose = function(_result)
            -- send data to server
            if _result then
                local TransactionService = Knit.GetService("TransactionService")
                TransactionService:SetPurchase(ItemId):andThen(function(success, reason)
                    if success then 
                        print('yippee')
                    else 
                        local Insuff
                        
                        Insuff = ActionMessage.new({
                            Choose = function(_result)
                                Insuff:Destroy() 
                            end, 

                            Color = ActionMessageTheme.Delete,
                            Body = "You don't have enough corn yet! Topple more sets! 💪",
                            Header = "insufficient kernels 🌽"
                        }) 

                        Insuff:Show() 
                    end
                end):catch(error) 
            end 

            _Action:Destroy()
        end,
       
        Color  = ActionMessageTheme.Green, 
        Body   = "Are you sure you'd like to buy " .. Name .. " for " .. Price .. "🌽?",
        Header = "purchase set",
    })

    _Action:Show()
    _Action:Wait()

    self.Busy = false 
end

function Vendor:Show()
    if Peek(self.Visible) then return end 
    warn("Displaying Vendor plate.") 

    local InterfaceController = Knit.GetController("Interface") 
    local ViewportSignal = InterfaceController:GetViewportRenderSignal()

    game:GetService("RunService"):BindToRenderStep("ViewportRender", Enum.RenderPriority.Last.Value - 1, function(dt)
        ViewportSignal:Fire(dt) 
    end)

    self.Visible:set(true)
end

function Vendor:Hide()
    if not Peek(self.Visible) then return end 
    
    game:GetService("RunService"):UnbindFromRenderStep("ViewportRender")
    
    self.Visible:set(false)
end

function Vendor:Destroy()
    self.Maid:DoCleaning()
end

return Vendor