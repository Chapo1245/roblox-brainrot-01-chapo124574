-- GameConfig (shared): every tuning number in one place.

local GameConfig = {}

GameConfig.STARTING_CASH = 150
GameConfig.MAX_PLAYERS = 8
GameConfig.BASE_SLOTS = 8 -- brainrot slots on each player's base

GameConfig.CONVEYOR_INTERVAL = 2.5 -- seconds between conveyor spawns
GameConfig.CONVEYOR_MAX = 10 -- brainrots on the belt at once
GameConfig.CONVEYOR_SPEED = 6 -- studs per second along the belt

GameConfig.INCOME_TICK = 1 -- seconds between income payouts
GameConfig.SELL_REFUND = 0.5 -- selling a brainrot returns half its price

GameConfig.LOCK_DURATION = 60 -- seconds a base lock lasts
GameConfig.LOCK_COOLDOWN = 90 -- seconds before the lock can be used again

GameConfig.REBIRTH_BASE_COST = 25000 -- cash for rebirth 1; doubles each tier
GameConfig.REBIRTH_BONUS = 0.25 -- +25% income per rebirth tier

GameConfig.FUSE_COUNT = 3 -- brainrots fused into one of the next rarity

GameConfig.EVENT_INTERVAL_MIN = 75
GameConfig.EVENT_INTERVAL_MAX = 150
GameConfig.GOLDEN_HOUR_DURATION = 60
GameConfig.GOLDEN_HOUR_MULT = 2

GameConfig.QUEST_REWARD_MULT = 1 -- quest cash rewards scale with progress

-- World layout (studs). Bases sit in a ring around the market square.
GameConfig.MARKET_RADIUS = 60 -- distance from center to each base front
GameConfig.CONVEYOR_LENGTH = 90
GameConfig.CONVEYOR_Y = 3

return GameConfig
