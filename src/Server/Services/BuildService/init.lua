-- TODO: Export a lot of the sandbox stuff to a SandboxService 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService") 
local Knit = require(ReplicatedStorage.Packages.Knit)

local Binder = require(ReplicatedStorage.Shared.Binder)
local Signal = require(ReplicatedStorage.Shared.Signal) 

local BuildService = Knit.CreateService {
    Name = "BuildService",
    Floors = {}, 
    Sandboxes = {}, 
    Client = {
        UpdateFloors = Knit.CreateSignal(), -- floors available for use. 
        UpdateSandbox = Knit.CreateSignal(),
        UpdateInventory = Knit.CreateSignal(), 
        UpdateOwnedSandbox = Knit.CreateSignal(), 

        DeleteObject = Knit.CreateSignal(), 
        UpdateConfig = Knit.CreateSignal(), 
        UpdateObject = Knit.CreateSignal(), 

        UpdateInterfaceSandbox = Knit.CreateSignal(), 

        LoadSandbox = Knit.CreateSignal(), 
        LoadPlacedItem = Knit.CreateSignal(), 
        LoadStart = Knit.CreateSignal(), 

        SetStartingDomino = Knit.CreateSignal(), 
        
        ManualUpdateSandbox = Knit.CreateSignal(), 
    },

    Profile = {
        Store = nil, 
        _sandboxSaveKey = "v0.040" 
    },

    _floorObjects = {}, 
    _currentFloor = nil, 
    _busy = false, 
    _busyComplete = Signal.new(),
    _sandboxOwnersChanged = Signal.new(), 
}

-- BuildService Client Methods
--  >   Getting Sandboxes on Client
--  >   Adding players to sandboxes
--  >   Building on sandboxes

-- @Ocula
-- Returns a list of sandboxes indexed on the server.
function BuildService.Client:GetSandboxes(): array 
    return self.Server:GetSandboxes() 
end

-- @Ocula
-- Requests a player be added to a sandbox
function BuildService.Client:RequestClientSandbox(player, sandboxId): boolvalue 
    local PlayerService = Knit.GetService("PlayerService") 

    local sandbox = self.Server.Sandboxes[sandboxId]
    local playerObject = PlayerService:GetPlayer(player) 

    if sandbox then 
        playerObject.Sandbox = sandbox.GUID -- runtime checks
        playerObject._ownedSandbox = sandbox.GUID  -- permanent property

        self.Server.Client.UpdateOwnedSandbox:Fire(player, sandbox:Package()) 

        return true
    else 
        return false 
    end 
end 

-- TODO: Convert the following 3 methods over to a RequestSaveAction(action, player, sandboxId) method to save space.

function BuildService.Client:RequestSaveLoad(player, saveId)
    return self.Server:RequestSaveLoad(player, saveId) 
end 

function BuildService:RequestSaveLoad(player, saveId)
    local PlayerService = Knit.GetService("PlayerService") 
    local PlayerObject = PlayerService:GetPlayer(player)

    local Sandbox = self.Sandboxes[PlayerObject._ownedSandbox]
    
    local SaveData = PlayerObject:GetSaveData(saveId) 

    assert(SaveData, "Could not find save data.")

    warn("Requesting save load on:", player, SaveData, PlayerObject, player.userId) 

    if SaveData.Empty == true or #SaveData.Key == 0 or SaveData.Timestamp == 0 then
        local newSave = {
            Empty = false, 
            Timestamp = DateTime.now().UnixTimestampMillis,
            Key = self:GetUUID(false), 
        }

        warn("GOT NEW UUID:", newSave.Key)

        PlayerObject:ReplaceSave(saveId, newSave) 
        PlayerObject:Save(player)

        local success, message = Sandbox:Load(newSave.Key, true) 

        return success, message  
    elseif SaveData.Empty == false and #SaveData.Key > 0 and SaveData.Timestamp > 0 then 
        warn("Attempting to load:", SaveData.Key) 

        local success, message = Sandbox:Load(SaveData.Key) 

        return success, message 
    else 
        return false, "Error"
    end 
end 


function BuildService.Client:RequestRename(player, saveId, newName) 
    local PlayerService = Knit.GetService("PlayerService") 
    local PlayerObject = PlayerService:GetPlayer(player)
    local SaveData = PlayerObject:GetSaveData(saveId) 

    if SaveData then 
        local success, filter = pcall(function()
            return game:GetService("TextService"):FilterStringAsync(newName, player.userId)
        end)

        local newText 

        if success then 
            newText = filter:GetNonChatStringForUserAsync(player.userId) 
        else 
            newText = "Untitled"
        end 

        local newSave = {
            Name = newText
        }

        PlayerObject:ReplaceSave(saveId, newSave)
        PlayerObject:Save() 

        --warn("Returning:", newText)
        return newText
    end 
end 

-- @Ocula
-- Requests a delete of the specific Save Slot.
function BuildService.Client:RequestDelete(player, saveId)
    local PlayerService = Knit.GetService("PlayerService") 
    local PlayerObject = PlayerService:GetPlayer(player)

    -- check if the currently selected & loaded sandbox is the one we're trying to delete.
    -- if it is, we will unload the sandbox. not clean it. then put the player back into the save menu or something. 

    local SaveData = PlayerObject:GetSaveData(saveId) 

    if SaveData then 
        local key = SaveData.Key
        local playerBox = PlayerObject:GetOwnedSandbox() 

        if playerBox._profileKey == key then 
            warn("Player is deleting the current sandbox!")

            -- compile deleted objects into player inventory 
            
            playerBox:Delete() 

            -- force open Save menu.
        end

        local newSave = {
            Empty = true,
            Timestamp = 0,
            Name = "Untitled",
            Key = "", -- TODO: Choose a UUID that hasn't been used already. 
        }
        
        PlayerObject:ReplaceSave(saveId, newSave) 
        PlayerObject:Save()
    end 
end 

--
function BuildService.Client:SetStartDomino(player, objectId, referenceId)
    local playerService = Knit.GetService("PlayerService")
    local playerObj = playerService:GetPlayer(player)
    local sandboxId = playerObj.Sandbox

    if sandboxId then 
        local sandbox = self.Server.Sandboxes[sandboxId] 

        --warn("Setting Start Domino [191]", player, objectId, referenceId)
        
        sandbox:SetStartDomino(player, objectId, referenceId) 

        return true
    end 

    return false
end

function BuildService.Client:GetStartDomino(player)
    local playerService = Knit.GetService("PlayerService")
    local playerObj = playerService:GetPlayer(player)
    local sandboxId = playerObj.Sandbox

    if sandboxId then 
        local sandbox = self.Server.Sandboxes[sandboxId] 
    
        return sandbox:GetStartDomino()
    end 
end 

-- @Ocula
-- Requests to spawn a player.
function BuildService.Client:SpawnPlayer(player)
    local PlayerService = Knit.GetService("PlayerService") 
    local playerObject = PlayerService:GetPlayer(player) 

    --if playerObject.Sandbox then 
        playerObject:Spawn()
    --end 
end 


-- @Ocula
-- Returns the player's building inventory.
function BuildService.Client:GetInventory(player)
    local PlayerService = Knit.GetService("PlayerService")
    local playerObject = PlayerService:GetPlayer(player) 

    if playerObject then 
        return playerObject:GetInventory()
    else 
        return "No player object"
    end
end 


-- (Done, but keeping this TODO here as a note in case we run into any backlog errors) 
-- TODO: Convert the following methods into a :RequestUpdate() method for saving space. 

-- @Ocula
-- RequestUpdate(player, action: string {"Place", "Delete", "Config", "Move"}, ...: tuple arguments)
-- Requests an update (typically on the sandbox) for certain object data. Replicates all localized changes to other players.
-- TODO: Add in security checks. 
-- AN IMPORTANT NOTE ABOUT REQUESTUPDATE("Place"):
    -- This function *also* handles transforming the given World CFrame into a Relative Sandbox CFrame. 
    --  >   It's important to note if you ever want to use the Server-side CFrames as World CFrames, you
    --      will have to transform it into a WorldCFrame.

function BuildService.Client:RequestUpdate(player, action, ...) -- implement certain security measures. 
    local playerService = Knit.GetService("PlayerService")
    local playerObj = playerService:GetPlayer(player)
    local sandboxId = playerObj.Sandbox

    if sandboxId then
        local sandbox = self.Server.Sandboxes[sandboxId] 

        if action == "Place" then 
            local itemId, cf = ... 
            local relativeCF = sandbox:GetRelativeCF(cf) 

            return sandbox:Place(player, itemId, relativeCF) -- has callback functionality
        elseif action == "Delete" then 
            local objectId = ... 
            local object = sandbox.Objects[objectId] 

            if object then 
                local itemId = object.ItemId 
                sandbox:DeleteObject(player, objectId, itemId) 
            end 
        elseif action == "Config" then 
            local objectId, config = ... 
            local object = sandbox.Objects[objectId] 

            if object then 
                sandbox:UpdateConfig(objectId, config)
            end 
        elseif action == "Move" then 
            local objectId, newCF = ... 
            local object = sandbox.Objects[objectId] 

            if object then 
                local relativeCF = sandbox:GetRelativeCF(newCF) 

                return sandbox:Move(objectId, relativeCF) 
            end 
        end 
    end 
end 


-- Sandbox Server Methods in the following order: 
--  >   Data
--  >   Player Indexing
--  >   Building 

function BuildService:GetSandboxes()
    local newArray = {}
    for i, v in self.Sandboxes do 
        newArray[i] = v:Package()
    end 

    return newArray
end

-- Gets a Unique ID for Sandbox keying.
-- 
function BuildService:GetUUID(_curly)
    -- we're gonna use a good ole' datastore for this one. we don't need a whole profile store. 
    local DataStoreService = game:GetService("DataStoreService")
    local idStore = DataStoreService:GetDataStore("UUID-"..self:GetSandboxKey())

    local _newId
    local _timeout = 0 

    repeat 
        _timeout += 1 
        local currentId = HttpService:GenerateGUID(_curly or false)

        local _getSuccess, isTaken = pcall(function()
            return idStore:GetAsync(currentId)
        end)

        if not isTaken then
            local _setSuccess, errm = pcall(function() 
                idStore:SetAsync(currentId, true)
            end)

            if not _setSuccess then 
                warn("Server could not set data onto the UUID Store:", errm)
            else 
                _newId = currentId 
            end 
        end 

        if _timeout > 3 then -- we will literally never ever get this high. mathematical chances of that happening are so low. 
            task.wait() 
        end
    until _newId 

    return _newId
end 

-- @Ocula
-- Return the sandbox profile key
function BuildService:GetSandboxKey()
    return self.Profile._sandboxSaveKey
end 

-- @Ocula
-- Returns a Sandbox with a given ID
function BuildService:GetSandbox(_id) 
    return self.Sandboxes[_id]
end 

-- @Ocula
-- Get the nearest sandbox to the player
function BuildService:GetNearestSandbox(pos)
    local closestNum, closestBox = math.huge, nil 

    for i, v in pairs(self.Sandboxes) do 
        local magCheck = (v.Object.Position - pos).Magnitude
        if magCheck < closestNum then 
            closestNum = magCheck 
            closestBox = v 
        end 
    end 

    return closestBox 
end

--@Ocula
-- Updates where and what sandbox each player is in at all times.
-- Keeps sandboxes loading and unloading correctly. 
function BuildService:Update()
    local Players = game.Players:GetPlayers() 
    local PlayerService = Knit.GetService("PlayerService") 

    if #Players > 0 then 
        for i, v in pairs(Players) do 
            local playerObject = PlayerService:GetPlayer(v) 

            if playerObject and v.Character then -- make sure the player is loaded into the game. 
                local hrp = v.Character:FindFirstChild("HumanoidRootPart")

                if hrp then 
                    local currentSandbox = playerObject.Sandbox
                    local check = self:GetNearestSandbox(hrp.Position)

                    if check then
                        local areWeHere = check:isPlayerInside(v)

                        if check.GUID == currentSandbox then -- we're in the same sandbox
                            if not areWeHere then
                                playerObject:SetSandbox(nil)
                            end

                            continue
                        end

                        if areWeHere then
                            playerObject:SetSandbox(check.GUID)
                        end 
                    end
                end 
            end
        end
    end
end

--@Ocula
-- For any debounce actions we need. 
function BuildService:SetBusy(bool)
    self._busy = bool 

    if bool == false then 
        self._busyComplete:Fire() 
    end 
end 

--@Ocula
-- Sandbox profiling at startup.
function BuildService:ConnectProfiles()
    local PlayerService = Knit.GetService("PlayerService") 

    local sandboxTemplate = require(Knit.Modules.Sandbox.Profile) 
    local sandboxKey = self:GetSandboxKey()

    local sandboxStore = PlayerService.Profile.Service.GetProfileStore(sandboxKey, sandboxTemplate)
    self.Profile.Store = sandboxStore 
end 

--@Ocula
-- Connect events.
function BuildService:ConnectEvents()
    self._sandboxOwnersChanged:Connect(function(sandboxId)
        local sandbox = self.Sandboxes[sandboxId]

        for i, v in game.Players:GetPlayers() do 
            self.Client.UpdateInterfaceSandbox:Fire(v, sandbox:Package()) 
        end
    end)

    game:GetService("RunService").Heartbeat:Connect(function()
        self:Update() 
    end)
end 

function BuildService:AddSandbox(newSandbox)
    if newSandbox._ShellClass then return end 
    self.Sandboxes[newSandbox.GUID] = newSandbox 
end     

--@Ocula
-- Connects all binders for Sandbox and Floor so we're able to index them on the server.
function BuildService:ConnectBinders()
    local Floor = Binder.new("Floor", require(Knit.Modules.Floor))
    local SandboxBinder = Binder.new("Sandbox", require(Knit.Modules.Sandbox)) 
    
    Floor:GetClassAddedSignal():Connect(function(newFloor)
        if newFloor then 
            self.Floors[newFloor.Object] = newFloor 

            table.insert(self._floorObjects, newFloor.Object) 

            self._currentFloor = newFloor.Object 
        end
    end) 

	SandboxBinder:GetClassAddedSignal():Connect(function(newSandbox)
		self:AddSandbox(newSandbox) 
	end)

	SandboxBinder:Start() 
    Floor:Start()
end 

function BuildService:KnitStart()
    self:ConnectProfiles() -- profiles should be loaded first. 

    self:ConnectBinders() 
    self:ConnectEvents() 
end


function BuildService:KnitInit()
    
end


-- Deprecated Methods

-- @Ocula
-- Deprecated method.
-- Might only have usage for private servers. 
function BuildService:GetOpenSandbox()
    if self._busy then
        self._busyComplete:Wait()
    end 

    self:SetBusy(true) 

    for i, sandbox in pairs(self.Sandboxes) do
        if sandbox:hasOwner() == false then
            self:SetBusy(false) 
            return sandbox 
        end 
    end 

    self:SetBusy(false) 
end

return BuildService
