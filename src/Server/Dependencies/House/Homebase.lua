local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService") 

local HttpService = game:GetService("HttpService") 
local Knit = require(ReplicatedStorage.Packages.Knit)

local Signal = require(Knit.Library.Signal)
local Maid = require(Knit.Library.Maid)
local ItemIndexService = Knit.GetService("ItemIndexService") 

local Homebase = {}
Homebase.__index = Homebase

function Homebase.new(object) 
    if not object:isDescendantOf(workspace) then 
        return {_ShellClass = true}
    end 
    
    local self = setmetatable({
        __identifier = "Homebase",

        Data = { -- "interiors:testing"
            Interior = {
                ID = "testing", 
                Config = {}, 
            },

            Exterior = { -- "exteriors:testing" 
                ID = "testing",
                Config = {}, 
            }, 
        },

        Owners = {}, 
        Guests = {}, -- Guest builders that reset after owners leave. 

        Locked = false, -- if locked only Owners are allowed in. 

        Object = object, 
        Loaded = Signal.new(),

        GUID = HttpService:GenerateGUID(), 

        Maid = Maid.new(), 

        _loaded = false, 
    }, Homebase)

    self.Loaded:Connect(function()
        self._loaded = true 
    end)

    return self
end

function Homebase:Load() 
    self._loaded = true 
    self.Loaded:Fire(true) 
end

function Homebase:Package()
    return {
        Object = self.Object, 
        Locked = self.Locked, 
        Loaded = self._loaded, 

        Owners = self.Owners, 
    }
end

function Homebase:Update()
    if self._update then 
        self._update:Fire(self.GUID) 
    else 
        local HouseService = Knit.GetService("HouseService")
        HouseService.UpdateBaseData:Fire(self.GUID) 
    end 
end 

function Homebase:GetOwnerCount()
    local _count = 0 

    for i, v in self.Owners do 
        _count += 1 
    end 
    
    return _count 
end 

function Homebase:AddOwner(player)
    if self.Locked then return end 

    self.Locked = true 
    self:Update() -- make sure no other players request this homebase 

    local PlayerService = Knit.GetService("PlayerService") 
    local PlayerObject = PlayerService:GetPlayer(player) 

    -- if first owner, load homebase data from player.
    if self:GetOwnerCount() == 0 then 
        local Index = PlayerObject.Homes.Index 
        local Data = PlayerObject.Homes.Data[Index]

        self.Data = table.clone(Data)

        self:Load()
        self:Set(PlayerObject)
    end 

    local leavingConn 

    leavingConn = PlayerObject.Leaving:Connect(function()
        self:RemoveOwner(player) 
        leavingConn:Disconnect() 
    end)

    self.Owners[player] = PlayerObject 

    local HouseService = Knit.GetService("HouseService") 
    HouseService.Client.UpdateHomebase:Fire(player, self:Package()) 
    -- 
    self:Update() 

    return true 
end 

function Homebase:RemoveOwner(player)
    self.Owners[player] = nil 

    local HouseService = Knit.GetService("HouseService") 
    HouseService.Client.UpdateHomebase:Fire(player, nil) 

    local BuildService = Knit.GetService("BuildService")
    local Sandbox = BuildService:GetSandbox(self.Sandbox)

    if self.Sandbox then 
        local PlayerService = Knit.GetService("PlayerService")
        local Player = PlayerService:GetPlayer(player) 
        Sandbox:RemoveOwner(Player) 
    end 

    if self:GetOwnerCount() == 0 then 
        Sandbox:Destroy() 
        self:Clean() 
    end 

    self:Update() 
end 

function Homebase:GetEntrance(model)
    for i, v in model:GetDescendants() do 
        if CollectionService:HasTag(v, "Entrance") then 
            return v 
        end 
    end
end 

function Homebase:Find(model: userdata, name: string)
    for i, v in model:GetDescendants() do 
        if v:GetAttribute("is"..name) then 
            return v 
        end
    end 
end 

function Homebase:SetTunnels()
    -- Set Int / Ext
    local Interior = self.Interior 
    local Exterior = self.Exterior 

    local Object = self.Object 
    local Entrance = self:GetEntrance(Interior) 

    Exterior:SetPrimaryPartCFrame(Object.CFrame * CFrame.new(0,-Exterior.PrimaryPart.Size.Y/2,0)) 
    Exterior.PrimaryPart.Transparency = 1 

    -- 
    local InteriorTunnel = self:Find(Interior, "Tunnel") 

    if not InteriorTunnel and Entrance then 
        local extTunnelClone = self.Exterior:Clone() 
        extTunnelClone:SetPrimaryPartCFrame(Entrance.PrimaryPart.CFrame * CFrame.new(0,-InteriorTunnel.PrimaryPart.Size.Y/2,0))

        InteriorTunnel = self:Find(extTunnelClone, "Tunnel")
    end 

    warn("Interior Tunnel:", InteriorTunnel)
    
    -- Set the Tunnels
    local TunnelId = HttpService:GenerateGUID() 
    local ExteriorTunnel = self:Find(Exterior, "Tunnel") 

    if InteriorTunnel and ExteriorTunnel then 
        InteriorTunnel:SetAttribute("TunnelId", TunnelId) 
        ExteriorTunnel:SetAttribute("TunnelId", TunnelId) 

        self.InteriorTunnel = InteriorTunnel 
        self.ExteriorTunnel = ExteriorTunnel 

        InteriorTunnel:SetAttribute("ToggleInventory", true) 

        Exterior.Parent = workspace.game.server.bin 
        InteriorTunnel.Parent = workspace.game.server.bin 
        --CollectionService:AddTag(InteriorTunnel, "Tunnel") 
        --CollectionService:AddTag(Exterior, "Tunnel") 
        local TunnelService = Knit.GetService("TunnelService")

        local Int, Ext = TunnelService:AddTunnelsManual(InteriorTunnel, ExteriorTunnel) 
    end 

    self.Maid:GiveTask(InteriorTunnel) 

    self.InteriorTunnel = InteriorTunnel 
end 

function Homebase:SetSandbox(playerObject)
    local SandboxPart = self:Find(self.Interior, "Sandbox") 
    local Object = require(Knit.Modules.Sandbox).new(SandboxPart) 

    local BuildService = Knit.GetService("BuildService")
    BuildService:AddSandbox(Object) 

    Object:AddOwner(playerObject)

    self.Sandbox = Object.GUID 
end 

function Homebase:CreateSpawns(player)
    -- always spawn inside barnhouse methinks 
    local BarnSpawn = self:Find(self.Interior, "Spawn") 
    CollectionService:AddTag(BarnSpawn, "Spawn") 

    --TODO: attributechanged signal in teleportservice to update any added owners for multi-bases
    local PlayerName = player.Player.DisplayName 

    BarnSpawn:SetAttribute("LocationId", PlayerName.."'s".." barnhouse")
    CollectionService:AddTag(BarnSpawn, "Teleport") 

    local ZoneModel = Instance.new("Model")
    ZoneModel.Parent = self.Interior 
    ZoneModel.Name = "Zone"
    ZoneModel:SetAttribute("Zone", PlayerName.."'s".." barnhouse")
    ZoneModel:SetAttribute("Priority", 1)

    local Zone = Instance.new("Part") 
    local InteriorCF, InteriorSize = self.Interior:GetBoundingBox()

    Zone.Transparency = 1
    Zone.CanTouch = false 
    Zone.CanCollide = false 
    Zone.Anchored = true 
    Zone.Name = "Zone" 
    Zone.Parent = ZoneModel 

    Zone.CFrame = InteriorCF
    Zone.Size = InteriorSize 

    CollectionService:AddTag(ZoneModel, "Zone")

    return {BarnSpawn} 
end 

function Homebase:Set(player)
    if not self._loaded then 
        self.Loaded:Wait() 
    end 

    local HouseService = Knit.GetService("HouseService")

    local InteriorIndex = ItemIndexService:GetHomes("interiors:"..self.Data.Interior.ID:lower())
    local ExteriorIndex = ItemIndexService:GetHomes("exteriors:"..self.Data.Exterior.ID:lower())
 
    assert(InteriorIndex and ExteriorIndex, "Incorrect interior/exterior IDs provided to homebase.") 

    local intObj, extObj = InteriorIndex.Object:Clone(), ExteriorIndex.Object:Clone()

    self.Interior = intObj 
    self.Exterior = extObj 

    self.Maid:GiveTask(extObj)
    self.Maid:GiveTask(intObj) 

    -- Set Interior / Exterior Positions
    -- Start with Interior.
    local Slot = HouseService:SetSlot(player) 

    self.Slot = Slot 

    intObj:SetPrimaryPartCFrame(CFrame.new(Slot.Position))
    intObj.Parent = workspace.game.server.bin 

    self:SetTunnels()
    self:SetSandbox(player) 

    local Spawns = self:CreateSpawns(player) 

    for i, v in Spawns do 
        player:SetSpawn(v) 
        player:Spawn() 
    end 
end

function Homebase:Clean()
    self._loaded = false

    local TunnelService = Knit.GetService("TunnelService") 

    if TunnelService then 
        local a, b = TunnelService.Tunnels[self.InteriorTunnel], TunnelService.Tunnels[self.ExteriorTunnel] 
        
        if a and b then 
            a:Destroy()
            b:Destroy()
        end 
    end 

    self.Slot.Owned = nil 
    self.Slot = nil 
    
    self.Maid:DoCleaning() 

    self.Locked = false 
    self:Update() 
end 

function Homebase:Destroy()
    
end

return Homebase
