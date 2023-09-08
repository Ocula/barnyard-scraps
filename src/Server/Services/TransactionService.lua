-- Handles in-game transactions / robux stuff
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)


local TransactionService = Knit.CreateService {
    Name = "TransactionService",
    Client = {},
}

function TransactionService.Client:SetPurchase(_player, ItemId)
    local PlayerService = Knit.GetService("PlayerService")
    local Player = PlayerService:GetPlayer(_player)

    return self.Server:ProcessGameTransaction(Player, ItemId) -- I would send th
end

-- In-game Transactions (ItemId) 
function TransactionService:ProcessGameTransaction(Player: table, ItemId: string)
    return Player:BuyInGameItem(ItemId, 1) 
end 

function TransactionService.Client:RobuxPurchase()

end 

function TransactionService:KnitStart()
    
end


function TransactionService:KnitInit()
    
end


return TransactionService
