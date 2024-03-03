-- AnalyticsService.lua for all Barnyard Games' studio games.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

--local GameAnalytics = require(Knit.Library.GameAnalytics)

local AnalyticsService = Knit.CreateService({
	Name = "AnalyticsService",
	Client = {},
})

--[[
local Build = "0.1.0"
local GameKey = "0f81b49bc5e1137863dde32232636895"
local SecretKey = "9579a41c35f921b2ee7fec64a12927d99ad03742"

-- @Ocula
-- Streamlined event registration for GameAnalytics SDK 
-- > Event types: Source (add $), Sink (lose $), RankUp 
function AnalyticsService:Register(userId: number, event: string, data: table) 
    assert(userId and event and data, "Bad parameters given to analytics service.")

    -- Resource Events
    if event == "Source" then -- use this for buying corn in-game 
        GameAnalytics:addResourceEvent(userId, {
            flowType = GameAnalytics.EGAResourceFlowType.Source,
            currency = data.Currency, 
            amount = data.Amount, 

            itemType = "IAP", -- in-app purchase 
            itemId = data.ItemId, 
        })

    -- Progression Events
    elseif event == "Sink" then 
        GameAnalytics:addResourceEvent(userId, {
            flowType = GameAnalytics.EGAResourceFlowType.Sink,
            currency = data.Currency, 
            amount = data.Amount, 

            itemType = "Gameplay", -- in-app purchase 
            itemId = data.ItemId, -- domino object that player bought
        })
    elseif event == "RankUp" then 
        GameAnalytics:addDesignEvent(userId, {
            eventId = "Player:Gained:Rank", 
            value = data.Rank 
        })
    end 
end --]]

function AnalyticsService:KnitStart() end

function AnalyticsService:KnitInit()
	--[[GameAnalytics:configureBuild(Build) 
    GameAnalytics:initialize({
        gameKey = GameKey, 
        secretKey = SecretKey,

        automaticSendBusinessEvents = true, 
    })--]]
end --]]

return AnalyticsService
