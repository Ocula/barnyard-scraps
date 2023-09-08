local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

local Interface = require(Knit.Modules.Interface.get)

local Signal = require(Knit.Library.Signal)
local Utility = require(Knit.Library.Utility) 
local Maid = require(Knit.Library.Maid) 

local QuickIndex = require(Knit.Library.QuickIndex) 
local InterfaceUtils = require(Knit.Library.InterfaceUtils) 

local Divider = Interface:GetComponent("Game/Inventory/Build/Divider")
local PageButton = Interface:GetComponent("Game/Inventory/Build/Page")
local Content = Interface:GetComponent("Frames/Content") 
local Scroll = Interface:GetComponent("Frames/Scroll")

local Inventory = {}
Inventory.__index = Inventory

function Inventory.new()
    local self = setmetatable({
        Data = {
            Sections = {}, 
        },

        Build = {
            Sections = Value({}),
            Buttons = Value({}), -- 
            Pages = Value({}), 

            PageLayout = nil, 

            Objects = {}, 
        },

        SelectedObject = Value(""), 
        SelectedTool = Value(""), 

        SectionLayout = 0, 

        Visible = Value(false),

        Request = Signal.new(), -- for when objects are selected in the panel
        Changed = Signal.new(), 
        Page = Signal.new(), 
        Maid = Maid.new(), 
    }, Inventory)

    -- Wait til we're loaded 
    local GameController = Knit.GetController("GameController")
    
    if Peek(GameController.isLoading) then 
        GameController.Loaded:Wait() 
    end

    local BuildService = Knit.GetService("BuildService") 
    local BuildController = Knit.GetController("BuildController")

    BuildService:GetInventory():andThen(function(Data)
        warn("GOT DATA:", Data)
        self.Context = Data 

        self:Process(self.Context)
        self:BuildInterface() 
    end):catch(error)

    -- Observe object selections
    self.Maid:GiveTask(Observer(self.SelectedObject):onChange(function()
        local Last = self.LastSelected 

        if Last ~= "Place" then 
            self.SelectedTool:set("Place") 
        end

        self.LastSelected = Peek(self.SelectedTool)

        --
        if Peek(self.SelectedTool) == "Place" then 
            BuildController:UpdateSelected(Peek(self.SelectedObject)) 
        end 
    end))

    self.Maid:GiveTask(Observer(self.SelectedTool):onChange(function()
        local newTool = Peek(self.SelectedTool)
        BuildController:SwitchTool(newTool) 
    end))

    self.Maid:GiveTask(self.Request:Connect(function(ItemId)
        self.SelectedObject:set(ItemId) 
    end))

    return self
end

function Inventory:BuildInterface()
    local InventoryComponent = Interface:GetComponent("Game/Inventory/Build")

    local Game = Knit.GetController("Interface").Game
    local Bin = Game:GetBin() 

    self.PageLayout = New "UIPageLayout" {
        Name = "UIPageLayout",
        Animated = false,
        Circular = true,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }

    self.Object = InventoryComponent {
        Parent = Bin, 
        Visible = self.Visible, 
        Tool = self.SelectedTool,
        Object = self.SelectedObject, 
        PageLayout = self.PageLayout, 
        Build = self.Build,
    }
end 

function Inventory:BuildSection(SectionIndex)
    self.SectionLayout += 1

    local SectionData = {
        __Object = Divider {
            Name = SectionIndex, 
            LayoutOrder = self.SectionLayout * 100,
        }, 
    } 

    local SectionDividers = Peek(self.Build.Sections)

    SectionDividers[SectionIndex] = SectionData.__Object

    self.Data.Sections[SectionIndex] = SectionData 

    warn("SectionDividers:", SectionDividers)

    self.Build.Sections:set(SectionDividers)

    return SectionData 
end 

function Inventory:BuildPage(Section, PageIndex)
    -- Get layout order from QuickIndex 
    local Folder = QuickIndex:GetFolder(PageIndex)
    local LayoutOrder = Folder:GetAttribute("LayoutOrder") + (self.SectionLayout * 100)
    local Theme = Folder:GetAttributes()

    local Visible = Value(true) 

    local PageObject = Scroll {
        Name = PageIndex, 
        ZIndex = 4, 
        LayoutOrder = LayoutOrder, 
        Visible = Visible, 

        Children = {
            Content {
                Type = "UIListLayout",
                TypeProperties = {
                    Name = "UIListLayout",
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center 
                },

                Children = {
                    New "Frame" {
                        Name = "TopPadding",
                        Size = UDim2.new(1,0,0,24),
                        BackgroundTransparency = 1, 

                        LayoutOrder = 0 
                        --Position = UDim2.new(0.5,0,0,0)
                    },

                    New "Frame" {
                        Name = "BottomPadding", 
                        Size = UDim2.new(1,0,0,12),
                        BackgroundTransparency = 1, 

                        LayoutOrder = 1000, 
                    }
                }
            }--]]
        }
    }

    local Page = {
        __Visible = Visible, -- API access 

        __Page = PageObject,

        __Button = PageButton {
            Name = InterfaceUtils.capitalizeWords(PageIndex), -- will also take strings like BIG OLD BLOCKS and format as Big Old Blocks
            LayoutOrder = LayoutOrder, 
            Visible = Visible, 
            Theme = Theme, 
            Event = self.Page, 
            Size = Value(UDim2.fromScale(1, 0.35)),

            MouseButton1Up = function()
                self.PageLayout:JumpTo(PageObject)
            end, 
        }, 
    } -- Bins for objects 

    local Buttons = Peek(self.Build.Buttons)
    local Pages = Peek(self.Build.Pages)

    -- expose objects to the ui
    Buttons[PageIndex] = Page.__Button 
    Pages[PageIndex] = Page.__Page 

    self.Build.Buttons:set(Buttons)
    self.Build.Pages:set(Pages)

    -- put page into data structure 
    Section[PageIndex] = Page 

    return Page 
end 

-- @Ocula
-- Formats inventory data from:
-- {ItemId = "dominos:basic:basic", Amount = X}
--[[ > {
        Sections = {
            Dominos = {
                Basic = {
                    -- what will change is Amount and whether or not this is still here. 
                    -- so what we should do is just check 
                
                    [ItemId] = { -- Metaobject (script.Object)
                        ItemId = "dominos:basic:basic", 
                        Object = GuiObject, 
                        Instance = Object, 
                        Amount = Value(X), 
                    },

                    ...
                }
            }
        }
    -- 
    {
        {ItemId = "aaa", Amount = 1}
        {
    }
--]]
function Inventory:Format(Data)
    for i, v in Data do 
        local ItemId = v.ItemId

        local ItemSplit = Utility:SplitString(ItemId:upper(), ":")
        local SectionIndex = ItemSplit[1]:upper() 
        local Section = self.Data.Sections[SectionIndex] -- index for major section 

        if not Section then 
            Section = self:BuildSection(SectionIndex) 
        end 

        local PageIndex = ItemSplit[2]:upper() 
        local Page = Section[PageIndex] 

        if not Page then 
            Page = self:BuildPage(Section, PageIndex) 
        end
    end 

    self.Data.Sections.__formatted = true 

    warn("Formatted data:", self)
end 

function Inventory:Get(ItemId)
    if #ItemId < 1 then return nil end 

    local split = Utility:SplitString(ItemId:upper(), ":") -- "dominos:basic:basic" "DOMINOS -> BASIC" [ItemId] 
    local index = self.Data.Sections

    for i = 1, #split - 1 do -- maximum 3 
        --warn(index[split[i]], ItemId, split)
        index = index[split[i]]
    end 

    if not index then 
        warn("No", ItemId, index)
        return nil
    end 
    index = index[ItemId]

    return index 
end

function Inventory:GetPage(ItemId)
    local split = Utility:SplitString(ItemId:upper(), ":") 
    local index = self.Data.Sections

    for i = 1, #split - 1 do 
        index = index[split[i]]
    end 

    return index 
end

-- @Ocula 
-- Processes a new inventory table. 
function Inventory:Process(Data)
    -- check if we've formatted any data already.
    local FormatLoad = false 

    if not self.Data.Sections.__formatted then
        self.Context = Data 
        self:Format(Data) 

        FormatLoad = true 
    end 

    local function findObjectByItemIdIn(Tbl, ItemId)
        for i, v in Tbl do 
            if v.ItemId:lower() == ItemId:lower() then
                return v 
            end
        end 
    end 

    for i, v in Data do 
        -- do a top level check for any differences 
        local ContextObject = findObjectByItemIdIn(self.Context, v.ItemId)
        local Flags = {}
        local PropertyFlags = 0 

        if ContextObject then 
            for index, property in v do 
                if ContextObject[index] ~= property then 
                    Flags[index] = property 
                    PropertyFlags += 1 
                end 
            end 
        else 
            PropertyFlags = 1 
        end 

        if PropertyFlags > 0 or FormatLoad then 
            local Object = self:Get(v.ItemId) 

            if Object then 
                local hasChanged = false 

                for property, data in Flags do 
                    local currentState = Object.Data[property]
                    currentState:set(data)

                end 

                if hasChanged then 
                    self.Changed:Fire(v.ItemId) 
                end 
            else 
                warn("No object found!")
                -- create new object 
                -- check if we have a page and section first. if not, create it.
            
                -- place into page backend
                local SplitString =  Utility:SplitString(v.ItemId:upper(), ":")
                local SectionIndex = SplitString[1]
                local PageIndex = SplitString[2]

                local Section = self.Data.Sections[SectionIndex]    

                if not Section then 
                    warn("Building section", SectionIndex) 
                    Section = self:BuildSection(SectionIndex)
                end 

                local Page = Section[PageIndex] 

                if not Page then
                    warn("Building page", PageIndex) 
                    Page = self:BuildPage(Section, PageIndex)
                end

                Object = require(script.Object).new({
                    ObjectRequest = self.Request, 
                    Object = self.SelectedObject, 
                    Tool = self.SelectedTool, 
                }, v)

                if Page then 
                    Page[v.ItemId] = Object 
                end

                -- place into page physically
                local PageTable = Peek(self.Build.Pages)
                local PageObject = PageTable[PageIndex]

                if PageObject then
                    Object.Object.Parent = PageObject:FindFirstChild("Content")
                else 
                    warn("No page object found:", PageTable, PageObject)
                end 

                self.Changed:Fire(v.ItemId) 
            end
        end 
    end

    -- check if anything was removed. 
    for i, v in self.Context do 
        local checkObject = findObjectByItemIdIn(Data, v.ItemId) 
        local checkOurObject = self:Get(v.ItemId) -- 

        if (checkObject == nil) and (checkOurObject ~= nil) then 
            warn("Removed:", v.ItemId)
            local Page = self:GetPage(v.ItemId)
            Page[v.ItemId] = nil 

            checkOurObject:Destroy() 

            if Peek(self.SelectedObject):lower() == v.ItemId:lower() then 
                self.SelectedObject:set("")
            end 
        end
    end 

    self.Context = Data -- update our context data
end

function Inventory:Load()
    local InterfaceController = Knit.GetController("Interface") 
    local ViewportSignal = InterfaceController:GetViewportRenderSignal()

    game:GetService("RunService"):BindToRenderStep("ViewportRender", Enum.RenderPriority.Last.Value - 1, function(dt)
        ViewportSignal:Fire(dt) 
    end)

    self.Visible:set(true)
end 

function Inventory:Clean()
    self.Visible:set(false) 
    self.SelectedTool:set("")

    game:GetService("RunService"):UnbindFromRenderStep("ViewportRender") 
end 


function Inventory:Toggle(bool: boolean, hide: table?)
    if bool then

        if not self._active then 
            self._active = true 

            self:Load() 
        end

        local InterfaceController = Knit.GetController("Interface")

        for i, v in pairs(InterfaceController.Game.HUD.Visibility) do 
            if v.set then 
                if hide then 
                    if hide[i] then 
                        v:set(false) 
                    end 
                else 
                    if i ~= "Edit" and i ~= "Parent" and i ~= "Rank" and i ~= "Corn" then 
                        v:set(false) 
                    end 
                end 
            end
        end
    else 
        if self._active then 
            self._active = false 

            self:Clean() 
        end 

        local InterfaceController = Knit.GetController("Interface") 

        for i, v in pairs(InterfaceController.Game.HUD.Visibility) do 
            if v.set then 
                if hide then 
                    if hide[i] then 
                        v:set(true) 
                    end 
                else 
                    if i ~= "Edit" and i ~= "Parent" then
                        v:set(true) 
                    end 
                end 
            end 
        end 

        --InterfaceController.Game.HUD.Visibility.PlayPanel.Panel:set(false) 
    end
end 

function Inventory:Init()
    local InterfaceController = Knit.GetController("Interface")

    -- Observe visibility 
    local HUD = InterfaceController.Game.HUD
    local Vis = HUD.Visibility
    local Toggle = HUD.Toggles.Edit  

    local EditObserver = Observer(Toggle):onChange(function()
        self:Toggle(Peek(Toggle))
    end)

    local EditVisibilityObserver = Observer(Vis.Edit):onChange(function()
        if Peek(Vis.Edit) == false then 
            self:Toggle(false)
        end

        Vis.PlayPanel.Panel:set(Peek(Vis.Edit))
    end)

    local HUDObserver = Observer(Vis.Parent):onChange(function()
        if Peek(Vis.Parent) ~= false then return end 
        self:Toggle(false) 
    end)

    self.Maid:GiveTasks({
        EditObserver,
        EditVisibilityObserver,
        HUDObserver
    })
end 

function Inventory:isVisible()
    return Peek(self.Visible) 
end 

function Inventory:Destroy()
    self.Maid:DoCleaning()
end


return Inventory
