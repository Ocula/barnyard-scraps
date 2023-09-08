local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage") 
local HttpService = game:GetService("HttpService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Shared.Signal) 
local Maid = require(ReplicatedStorage.Shared.Maid)

local Sandbox = {}
Sandbox.__index = Sandbox

local Base64 = require(Knit.Library.Base64)
local Utility = require(Knit.Library.Utility) 

local Fusion = require(Knit.Library.Fusion)
local New = Fusion.New -- she's just easier to use lol 

--[[
    SANDBOX OBJECTS ARE THE BUILDING BASE AS A WHOLE 
        -> Floors are extrapolated so that we can have multiple "building areas"

]]

-- Create a new sandbox object.
-- Sandboxes are created using CollectService. They are blank until a player applies data to them.
-- 
function Sandbox.new(part: BasePart): table
    if not part:isDescendantOf(workspace) then 
        return {_ShellClass = true}
    end 
    
   --[[ local model = Instance.new("Model") -- Sandbox Model
    model.Parent = workspace.game.server.bin
    part.Parent = model 

    local objectBin = Instance.new("Folder") -- Where we'll store sandbox stuff.
    objectBin.Parent = model
    objectBin.Name = "Objects"--]]

    local BuildService = Knit.GetService("BuildService")
    local SandboxKey = BuildService:GetSandboxKey()

    local self = setmetatable({
        __identifier = "Sandbox", 

        GUID = HttpService:GenerateGUID(), 
        Object = part,

        Locked = false, 

        Owners = {},
        Players = {}, 
        Floors = {},
        Objects = {},

        OwnerCount = 0, 

        ToppleData = {},

        Profile = nil, -- Profile.Data will point to profile data for all builds. 
        _maid = Maid.new(),

        _placeUpdate = Signal.new(),
        _deleteUpdate = Signal.new(), 
        _configUpdate = Signal.new(), 
        _objectUpdate = Signal.new(), 

        _startingDominoUpdate = Signal.new(), 
        _lastObjects = {},  
    }, Sandbox)

    part.CustomPhysicalProperties = PhysicalProperties.new(3,3,0,3,0)

    -- Overlap Params
    self.CollisionCheck = OverlapParams.new()
    self.CollisionCheck.CollisionGroup = "CollisionParts" 
    self.CollisionCheck.FilterType = Enum.RaycastFilterType.Exclude 

    for i, v in pairs(part:GetAttributes()) do 
        self[i] = v
    end

    return self
end

-- Functions 

function Sandbox.createCheckPart(cframe: CFrame, size): BasePart
    return New "Part" {
        Parent = workspace.game.server.bin,
        Transparency = 0.5,
        Size = size,
        CFrame = cframe,
        Anchored = true,
        CanCollide = false,
    }
end 

-- Utility

--@Ocula
-- Package the sandbox data up for client transfer.
function Sandbox:Package()
    return {
        ToppleData = self.ToppleData, 

        GUID = self.GUID, 
        Object = self.Object, 
        Objects = self.Objects, 
        Locked = self.Locked, 
        Owners = self.Owners,
    }
end

function Sandbox:CheckForObject(SpecialId)
    for i, v in self.Objects do 
        if v.SpecialId == SpecialId then 
            return true 
        end 
    end 

    return false 
end 

function Sandbox:FormatObjects()
    local formatted = {}

    for _, object in self.Objects do 
        -- CHECK EVERYTHING HERE.  
        local packagedObject = object:Package() 
        table.insert(formatted, packagedObject)
    end 

    return formatted
end 


function Sandbox:Save()
    if self.Profile and self._loadedProfile then 
        -- serializes the sandbox for saving.
        local Serializer = require(Knit.Modules.Serializers.Sandbox) 
        local Formatted = self:FormatObjects() 

        local Version, Data = Serializer.serialize(Formatted) 

        self.Profile.Version = Version 
        self.Profile.Data = Data

        self.Profile.SandboxSize.X = self.Object.Size.X 
        self.Profile.SandboxSize.Z = self.Object.Size.Z 

        self.Profile.Play.ObjectId = self.ToppleData.ObjectId 
        self.Profile.Play.Reference = self.ToppleData.Reference

        for userId, v in self.Owners do 
            self.Profile.Owners[userId] = true 
        end 
        --self.Profile.Data = encoded 
    end 
end

-- @Ocula
-- Not to be confused with :Clean() or :Destroy()
-- This is purely for cleaning out Profile data.
function Sandbox:Delete()
    if self._loadedProfile then 
        self._loadedProfile:Release()

        for i, v in self.Objects do 
            v:Destroy() 
        end 

        self.Objects = {}
        self:ManualUpdate() 
    end
end 

function Sandbox:SetStartDomino(player, objectId, referenceId)
    --TODO: check if this objectId and referenceId exist to be safe. 

    self.ToppleData.ObjectId = objectId 
    self.ToppleData.Reference = referenceId

    --warn("Setting ToppleData", objectId, referenceId, self.ToppleData)

    self._startingDominoUpdate:Fire(objectId, referenceId) 

    self:Save() 
end 

function Sandbox:GetStartDomino()
    return self.ToppleData
end 

-- @Ocula
-- Loads a Sandbox given its profile key.
-- "key" will always be a GUID saved to the owners of the sandbox.
function Sandbox:Load(key: string, firstLoad) 
    if self._loadedProfile then 
        warn("CLEAR OUT") 
        return false, "Not ready"
    end

    assert(
        type(key) ~= "string" or #key > 0, 
        "Sandbox Profile Key must be a valid GUID: '" .. key .."' #key == "..tostring(#key).."; type: "..type(key)
    ) 

    local BuildService = Knit.GetService("BuildService") 
    local SandboxKey = BuildService:GetSandboxKey() 

    local loadedProfile = BuildService.Profile.Store:LoadProfileAsync(SandboxKey .. "_" .. key, "ForceLoad")

    warn("Loading:", loadedProfile) 

	if loadedProfile then
		loadedProfile:Reconcile()

		loadedProfile:ListenToRelease(function()
			--warn("Sandbox cannot be loaded correctly. This is likely because it is loaded elsewhere.")
            self._profileKey = nil 
            self.Profile = nil  
            self._loadedProfile = nil 
		end)

        -- check sizing 
        --[[
        local currentSize = {X = self.Object.Size.X, Z = self.Object.Size.Z}
        local savedSize = loadedProfile.Data.SandboxSize 

        if not firstLoad then 
            if currentSize.X ~= savedSize.X or currentSize.Z ~= savedSize.Z then 
                local _isBigger = false 

                if currentSize.X > savedSize.X or currentSize.Z > savedSize.Z then 
                    _isBigger = true
                end 

                warn("Size") 

                loadedProfile:Release() 

                return false, "The sandbox data you are trying to load was made for a "..(if _isBigger then "bigger" else "smaller").." sandbox size!"
            end 
        else 
            savedSize.X = currentSize.X 
            savedSize.Z = currentSize.Z 
        end--]]

		self.Profile = loadedProfile.Data
        self._loadedProfile = loadedProfile 

        warn("New sandbox loaded profile:", loadedProfile)

        self.ToppleData = self.Profile.Play 

        -- profile loaded, we can continue

        self._profileKey = key 

        local data = self.Profile.Data

        assert(type(data) == "string", "Data for decoding must be an encoded Base91 string.")

        local Serializer = require(Knit.Modules.Serializers.Sandbox) 
        local Version = self.Profile.Version 

        local Data = Serializer.deserialize(Version, data)

        -- compile data 
        local Object = require(script.Object) 

        if Data then 
            for _, loadobject in Data do 

                self.Objects[loadobject.SpecialId] = Object.new({
                    CFrame = loadobject.CFrame,
                    Config = loadobject.Config,
                    ItemId = loadobject.ItemId, 
                    
                    SpecialId = loadobject.SpecialId,
                }, self.Object.CFrame) 

                self._placeUpdate:Fire(loadobject.ItemId, loadobject.CFrame, loadobject.SpecialId, loadobject.Config, true) 
            end
        else 
            warn("Data corrupted:", Data) 

            self._lockProfile = true 
            self:Clean()
            self._lockProfile = false 
            
            return false, "An error has occurred trying to load your save data. Please file a bug report. [Error: 0-254]"
        end 

        return true 
    else 
        warn("Profile not found") 
    end
end

function Sandbox:Update()
    -- update players
    self.Players = self:GetPlayersInSandbox()
end

function Sandbox:GetCorner()
    local size = self.Object.Size 
    return self.Object.CFrame * CFrame.new(-size.X / 2, 0, -size.Z / 2) 
end 

-- Owner functions 

function Sandbox:hasOwner()
    local _owner = false 

    for i,v in pairs(self.Owners) do 
        _owner = true 
        break 
    end 

    return _owner 
end 

function Sandbox:isOwner(player)
    return self.Owners[player.userId] ~= nil 
end 

function Sandbox:countOwners(): number
    local _count = 0 
    for _, _ in self.Owners do 
        _count += 1
    end 

    return _count
end 


-- Player Checks

-- @Ocula
-- Check if a player object is inside of the sandbox
function Sandbox:isPlayerInside(player) -- 20 stud radius around
    if player.Character then 
        local currOverlapParams = OverlapParams.new() 

        currOverlapParams:AddToFilter(player.Character) 
        currOverlapParams.FilterType = Enum.RaycastFilterType.Include

        local playerQuery = workspace:GetPartBoundsInBox(self.Object.CFrame, self.Object.Size + Vector3.new(50,500,50), currOverlapParams)

        if #playerQuery > 0 then 
            return true 
        else
            return false 
        end 
    else 
        return false 
    end 
end 

--@Ocula
-- Gets all of the players inside of the current sandbox
function Sandbox:GetPlayersInSandbox()
    local Players = {}

    for i,v in pairs(game.Players:GetPlayers()) do 
        if self:isPlayerInside(v) then
            Players[v] = v 
        end 
    end

    return Players 
end 

-- Placement Sandboxing

-- @Ocula
-- Utility function for getting the relative space of an object to the baseplate of a sandbox.
function Sandbox:GetRelativeCF(cf)
    return cf:ToObjectSpace(self.Object.CFrame) 
end

-- @Ocula
-- Checks if a CFrame is colliding with any other objects in the sandbox. 
function Sandbox:CheckCollision(cf, size) -- 
    local parts = workspace:GetPartBoundsInBox(cf * CFrame.new(0,2.5,0), size - Vector3.new(0.02,0.02,0.02), self.CollisionCheck) 

    if #parts > 0 then -- this should be the only thing we need to check lol. but. for good measure
        return true 
    end 

    return false 
end

-- @Ocula
-- Each object is given a specialId that is visible to the client as well.
-- Any changes made to the object on the client can then be authorized by the server. 
function Sandbox:GetObject(specialId) 
    for _, object in self.Objects do 
        if object.SpecialId == specialId then 
            return object 
        end 
    end 
end 

-- @Ocula
-- 
function Sandbox:GetConfigReference(object, referenceId)
    for i, v in object.Config do 
        if v.Reference == referenceId then 
            return v, false 
        end 
    end

    return {}, true 
end

-- @Ocula
-- Updates Config table of an Object given the SpecialId of the object and the config array. 
function Sandbox:UpdateConfig(specialId: string, config: array)
    local object = self:GetObject(specialId)
    local configIndex, set = self:GetConfigReference(object, config.Reference)

    -- reconcile configuration table 
    for i, v in config do 
        configIndex[i] = v 
    end

    -- 
    if configIndex.Rotation == nil then 
        configIndex.Rotation = config.Rotation or 0
    end 

    if configIndex.Scale == nil then 
        configIndex.Scale = config.Scale or 1 
    end 

    if configIndex.Color == nil then 
        configIndex.Color = config.Color or Color3.new(1,1,1) 
    end 

    if configIndex.Transparency == nil then 
        configIndex.Transparency = config.Transparency or 0 
    end

    if set then 
        table.insert(object.Config, configIndex) 
    end 

    self._configUpdate:Fire(specialId, config) 

    self:Save() 
end 

--@Ocula
-- Places an abstracted object on the Sandbox metadata.
-- Also handles collision parts so they're server authorized. 
-- 
-- this will place the object on the server, but the client will actually load the object itself.
function Sandbox:Place(player, itemId, relativeCF) -- we always want to use relative CF here for loading / saving
    local worldCF = self.Object.CFrame * relativeCF:Inverse() 
    local DebugService = Knit.GetService("DebugService") 

    -- check relativeCF isn't same as anything else

    local ItemIndexService = Knit.GetService("ItemIndexService") 
    local grabObject = ItemIndexService:GetBuild(itemId) 

    local check = self:CheckCollision(worldCF, grabObject.Object:GetModelSize()) 
    local reason = "" 

    if check then 
        reason = "Collision"
    end 

    -- check inventory
    if check == false and DebugService:isTestingMode() == false then 
        local PlayerService = Knit.GetService("PlayerService") 
        local playerObject = PlayerService:GetPlayer(player) 

        check = not playerObject:HasItem(itemId)

        warn("Player has item:", check)

        if check then 
            -- remove one item
            reason = "Inventory"
        else 
            playerObject:RemoveItem(itemId, 1) 
        end 
    end 

    -- check is owner 
    if check == false then
        check = not self:isOwner(player)
        reason = "Owner Permission"
    end

    if check then -- super high-tech security lol 
        return false, reason 
    end 

    local object = {
        ItemId = itemId, 
        CFrame = relativeCF, 
        Config = {},

        SpecialId = HttpService:GenerateGUID(), 
    } -- "_config" attribute
    -- relative CF will have to be the identifying factor.

    local Object = require(script.Object) 
    self.Objects[object.SpecialId] = Object.new(object, self.Object.CFrame) 

    self:Save()
    self._placeUpdate:Fire(itemId, relativeCF, object.SpecialId, object.Config) 

    return true
end

function Sandbox:Move(objectId, newCF)
    local worldCF = self.Object.CFrame * newCF:Inverse() 
    local object = self.Objects[objectId] 

    local ItemIndexService = Knit.GetService("ItemIndexService") 
    local grabObject = ItemIndexService:GetBuild(object.ItemId) 

    local modelSize = grabObject.Object:GetModelSize() 

    -- avoid self-collision for move [√]
    for obj, _ in pairs(object._collisionParts) do 
        obj.Parent = game.ServerStorage 
    end 

    local check = self:CheckCollision(worldCF, modelSize) 

    if check then   
        for obj, _ in pairs(object._collisionParts) do 
            obj.Parent = workspace.game.server.bin 
        end

        return false, "Collision" 
    end 

    -- now move collision parts

    for obj, relative in pairs(object._collisionParts) do 
        obj.Parent = workspace.game.server.bin
        obj.CFrame = worldCF * relative:Inverse() 
    end 

    object.CFrame = newCF 
    
    self._objectUpdate:Fire(objectId, worldCF) 
    ---TODO: HERE

    return true 
end 

function Sandbox:DeleteObject(player, objectId, itemId) 
    local PlayerService = Knit.GetService("PlayerService") 
    local playerObject = PlayerService:GetPlayer(player) 

    playerObject:AddItem(itemId, 1)

    -- check if it's a topple object 
    if self.ToppleData.ObjectId and self.ToppleData.ObjectId == objectId then 
        warn("We've deleted the starting domino!")
        self:SetStartDomino(player, "", 0)
    end 

    self._deleteUpdate:Fire(objectId)

    if self.Objects[objectId] then 
        self.Objects[objectId]:Destroy()
        self.Objects[objectId] = nil 
    end 
end 

function Sandbox:AddOwner(player)
    -- dependencies
    local ItemIndexService = Knit.GetService("ItemIndexService")
    local BuildService = Knit.GetService("BuildService") 
    local DominoService = Knit.GetService("DominoService") 
    
    local Floor = require(Knit.Modules.Floor)

    player._ownedSandbox = self.GUID 
    player.Sandbox = self.GUID 

    -- Connect Placement Update
    -- Update for visiting users.

    local OwnerCount = self:countOwners()

    if OwnerCount == 0 then 
        local PlayerSave = player:GetSaveIndex() 

        if PlayerSave then 
            BuildService:RequestSaveLoad(player.Player, PlayerSave)
        end

        -- TODO: Make sure this only begins when we're adding the first owner, and it cleans up after the last one leaves. 
        self._maid:GiveTask(self._placeUpdate:Connect(function(itemId, relativeCF, specialId, config, mute) 
            self:Update() 

            local toWorldSpace = self.Object.CFrame * relativeCF:Inverse() 

            for i, v in pairs(self.Players) do 
                BuildService.Client.LoadPlacedItem:Fire(v, self.GUID, itemId, toWorldSpace, specialId, config, mute) 
            end

            -- update profile
            -- self:Save()
        end))

        -- Connect Delete Update
        self._maid:GiveTask(self._deleteUpdate:Connect(function(objectId)
            self:Update()

            for i, v in pairs(self.Players) do 
                BuildService.Client.DeleteObject:Fire(v, self.GUID, objectId) 
            end
        end))

        -- Connect Move update
        self._maid:GiveTask(self._objectUpdate:Connect(function(objectId, newCF) 
            self:Update() 

            for i, v in pairs(self.Players) do 
                BuildService.Client.UpdateObject:Fire(v, self.GUID, objectId, newCF) 
            end
        end))

        -- Connect Config Update
        self._maid:GiveTask(self._configUpdate:Connect(function(objectId, config) 
            self:Update()

            for i, v in pairs(self.Players) do 
                BuildService.Client.UpdateConfig:Fire(v, self.GUID, objectId, config) 
            end
        end))

        self._maid:GiveTask(self._startingDominoUpdate:Connect(function(objectId, reference)
            self:Update() 

            for i, v in pairs(self.Players) do 
                DominoService.Client.SetStartingDomino:Fire(v, self.GUID, objectId, reference) 
            end
        end))
    end 

    --TODO: multi-player building. 
    self.Locked = true 

    -- set owner 
    self.Owners[player.Player.userId] = player 

    -- create floor
    if not self.Floors[self.Object] then 
        local newFloor = Floor.new(self.Object)

        self.Floors[self.Object] = newFloor -- Main floor.
    end

    local sendData = self.Floors[self.Object]:Package() 
    player:SendFloorData(sendData)

    --[[
    if self.Post == nil then 
        -- set post (for now)
        local newPost = ItemIndexService:Get("posts:left").Object:Clone() -- can randomize this if we want.
        newPost.Parent = self.Object.Parent

        local newPostSize = newPost:GetModelSize() 
        newPost:SetPrimaryPartCFrame(self:GetCorner() * CFrame.new(0, newPostSize.Y/2 - 0.5, -3) * CFrame.Angles(0,-math.pi/2,0))
        newPost.Sign.SurfaceGui.Frame.TextLabel.Text = player.Player.Name.." iz here"

        self.Post = newPost 
        self._maid:GiveTask(self.Post) 
    else 
        local ownerCount = self:countOwners()

        if ownerCount > 1 then 
            local names = {}

            for i,v in pairs(self.Owners) do
                table.insert(names, v.Player.Name) 
            end 

            local nameString = table.concat(names, " & ")

            self.Post.Sign.SurfaceGui.Frame.TextLabel.Text = nameString .. " r here"
        end 
    end--]]

    --self._maid:GiveTask(self.Post) 

    BuildService.Client.UpdateSandbox:Fire(player.Player, self.GUID, self:Package())
    BuildService._sandboxOwnersChanged:Fire(self.GUID) 
end 

function Sandbox:RemoveOwner(player)
    local BuildService = Knit.GetService("BuildService")

    self.Owners[player.Player.userId] = nil 

    if self.Post then 
        local names = {}

        for i,v in pairs(self.Owners) do
            table.insert(names, v.Player.Name) 
        end 

        local nameString = table.concat(names, " & ")

        if #names > 1 then 
            self.Post.Sign.SurfaceGui.Frame.TextLabel.Text = nameString .. " r here"
        else
            self.Post.Sign.SurfaceGui.Frame.TextLabel.Text = nameString .. " iz here"
        end 
    end 

    local ownersLeft = self:countOwners()

    if ownersLeft <= 0 then 
        warn("Sandbox has no owners left.")
        self:Clean() 
    end

    BuildService._sandboxOwnersChanged:Fire(self.GUID) 
end

function Sandbox:ManualUpdate()
    local PlayerService = Knit.GetService("PlayerService")
    local BuildService = Knit.GetService("BuildService")

    for i, v in pairs(PlayerService.Players) do
        if v.Sandbox == self.GUID then 
            BuildService.Client.ManualUpdateSandbox:Fire(v.Player, self.GUID, self:Package())
        end 
    end
end 

function Sandbox:Clean()
    -- One last save to the profile just to make sure all Data is cached. --> This will always happen automatically, but its a good idea to be safe whenever the sandbox is cleaned.
    if not self._lockProfile then -- prevent losing corrupted data that can possibly still be fixed
        self:Save() 
    end

    -- Release profile
    if self._loadedProfile then 
        self._loadedProfile:Release() 
        self._loadedProfile = nil 
    end 

    self.Profile = nil
    self._profileKey = ""

    -- Unlock / Reset settings
    self.Locked = false
    self.Post = nil 

    -- Delete all objects on the server
    for i, v in pairs(self.Objects) do
        self._maid:GiveTask(v) 
    end 

    self._maid:DoCleaning() 

    self.Objects = {} -- make sure the table is cleaned out.
    self._placeUpdate = nil -- make sure this is cleaned out as well. 

    -- Reset the base for other players
    self:ManualUpdate() -- for any players on the base, delete the objects.

    local BuildService = Knit.GetService("BuildService") -- update all other players looking to select a base.
    for i, v in game.Players:GetPlayers() do 
        BuildService.Client.UpdateInterfaceSandbox:Fire(v, self:Package()) 
    end
end 

-- This function deep cleans the Sandbox object out of the game.
function Sandbox:Destroy()     
    if self.Model then 
        self._maid:GiveTask(self.Model)
    end 

    self:Clean() -- this will handle the big stuff 
end


return Sandbox
