--[[

Gameplan: 7/29/2023 @ 11:31PM 

I can already tell this is going to change a lot as we go through it. But here's the sitch.

Problem: 
    - The current Map Layout with sandbox bases on it mapped out in 4x4 on separate islands presents
      a few problems:
        > Players won't be able to see other people's bases because of client-side loading/unloading
          unless they're on the base. So having all of those empty paddocks will feel weird. And seem
          incomplete to the player and the world we're trying to build.
        > We can create preview models so as to fill up the space, but it's an extra source of part lag
          at scale. 
        > In order to accomodate for larger base sizes, the islands themselves become much bigger than
          we want them to be. 
        > Traveling from base to base should be fun, easy, and intuitive. 

The solution:
    - Introducing HouseService.
        > Players will choose a place to set down a Barnhouse. 
        > Inside this barnhouse is a plot of land for building their domino sets.
        
        > This way, players can customize barnhouses, upgrade base sizes, & more
          without us having to subsidize space on the main map.
        > On top of that, we will have a more compressed main map - all housing will be in or near the plaza
          giving players easier access to the shop for Domino restocks. 
        > With the minigames money aspect (secondary income) 
            - Farmer Joe's Needle In A Haystack Game
            - Farmer Joe's Paddock Wrangler Game
            - Farmer Joe's Wheelbarrow On A Whim Game 

            - Multiplayer Team vs Team Domino Building Competition Game 
                - Topple It All

          Having houses makes this much more accessible. 

How it will work:
    - Using the current Base Selection system, player will join, choose a base. 
        -> Migrate Sandboxing over to non-ownership. *
        -> Migrate Homebase over to Ownership control. *
    - The base they choose will determine their Barnhouse. They'll spawn in front of it. 
    - When they head inside, their last opened save will have already been loaded onto the baseplate.
    - Inside their base they have access to the save menu as well as inventory menu.
    - TODO: Start tracking amounts in inventory. Use Testing Inventory for time being, though. 
    - They can load different saves onto their base using the save menu.

Questions:
    - Should we have them manually collect cash via a wheelbarrow?

--> Sandbox will be indexed when the sandbox is created. 

We can save it on the player as

    Player.Homes = {
        {
            Exterior = {
                ItemId = "blah:blah", 
                Config = {
                    Name = "ASD", 
                }
            },

            Interior = {
                ItemId = "blah:blah"
                Config = {
                    Size = "Upgrade-1 - N/A", 

                }
            }
        }
    }
]]

local PackageIdentifiers = {
    Homebase = true,
}

-- Middleware Functions
--[[function Package(player: Player, args: { any }) 
    warn(player, args) 

    for i, v in args do 
        if type(v) == "table" then 
            if PackageIdentifiers[v.__identifier] then 
                args[i] = v:Package() 
            end 
        end 
    end 
end--]]

-- HouseService.lua 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService") 

local Knit = require(ReplicatedStorage.Packages.Knit)

local Signal = require(Knit.Library.Signal) 

local HouseService = Knit.CreateService {
    Name = "HouseService",

    Homebases = {}, 
    Requests = {}, 

    Slots = {
        Amount = 16, 
        Positions = {}, 
    },

    --[[Middleware = {
        Inbound = {
            Package, 
        }
    },--]]

    Client = {
        UpdateBaseOwnership = Knit.CreateSignal(), 
        UpdateHomebase = Knit.CreateSignal(), 
    },

    UpdateBaseData = Signal.new(), 
}

function HouseService.Client:GetBases()
    return self.Server.Homebases  
end

function HouseService:GetHomebase(guid)
    return self.Homebases[guid] 
end 

function HouseService:GetAvailableHomebase()
    for i, v in self.Homebases do 
        if v:GetOwnerCount() == 0 and v._loaded == false then 
            return v 
        end 
    end 
end 

function HouseService:RequestOwnershipOnRandomBase(player)
    if self.Requests[player] then return false end 
    self.Requests[player] = true 

    local Base = self:GetAvailableHomebase() 
    local isOwnerAlready = self:isOwnerOfBase(player) 

    if isOwnerAlready then 
        return false, "Ownership"
    end

    if Base then
        --warn("Requesting ownership of homebase:", guid, Base) 

        local success = Base:AddOwner(player)
 
        self.Requests[player] = nil 

        if success then 
            --warn("Owner added") 
            return true
        else 
            return false 
        end 
    else

        self.Requests[player] = nil 

        return false, "Base" 
    end 
end 

function HouseService:isOwnerOfBase(player) 
    for i, v in self.Homebases do 
        if v.Owners[player] then 
            return true 
        end 
    end 

    return false 
end 

function HouseService.Client:RequestOwnership(player, guid) 
    if self.Server.Requests[player] then return false end
    self.Server.Requests[player] = true 
    -- check if player owns a base
    local isOwnerAlready = self.Server:isOwnerOfBase(player) 

    if isOwnerAlready then 
        return false, "Ownership"
    end 

    local Base = self.Server:GetHomebase(guid)

    if Base then
        --warn("Requesting ownership of homebase:", guid, Base) 

        local success = Base:AddOwner(player)

        self.Server.Requests[player] = nil 

        if success then 
            --warn("Owner added") 
            return true
        else 
            return false 
        end 
    else

        self.Server.Requests[player] = nil 

        return false, "Base" 
    end 
end 

function HouseService:GetPoint(pointNumber)
    if pointNumber < 1 or pointNumber > self.Slots.Amount then
        return Vector3.new(0, 0, 0)  -- Return origin if input is out of range
    end

    local radius = 2500 -- enough for 500 x 500 bases 
    local angle = math.rad((pointNumber - 1) * (360 / self.Slots.Amount))  -- Calculate angle in radians
    
    local x = radius * math.cos(angle)
    local z = radius * math.sin(angle)
    
    return Vector3.new(x, 0, z)
end

function HouseService:SetSlot(player) 
    -- check that player doesn't have a slot already 
    local slot

    for i, v in self.Slots.Positions do 
        if v.Owned == nil and not slot then 
            v.Owned = player 
            slot = v 
        end 

        if v.Owned == player then 
            return v -- we've already set a slot. 
        end 
    end 

    if not slot then 
        return false 
    end

    return slot 
end 

-- Manages loading / unloading home bases. 

function HouseService:KnitStart()
    -- Create slots
    for i = 1, self.Slots.Amount do 
        self.Slots.Positions[i] = {
            Owned = nil, 
            Position = self:GetPoint(i),  
        } 
    end 
    -- 
    local Binder = require(Knit.Library.Binder) 
    local HomebaseBinder = Binder.new("Homebase", require(Knit.Modules.House.Homebase)) 

    HomebaseBinder:GetClassAddedSignal():Connect(function(newBase)
        if newBase._ShellClass then return end 
        newBase._update = self.UpdateBaseData
        
        self.Homebases[newBase.GUID] = newBase
    end)

    -- we might not need this binder lol 
    HomebaseBinder:Start()
    
    self.UpdateBaseData:Connect(function(guid)
        for i, v in pairs(game.Players:GetPlayers()) do 
            self.Client.UpdateBaseOwnership:Fire(v, guid) 
        end 
    end)
end


function HouseService:KnitInit()
    
end


return HouseService
