-- DataService (server): the single source of truth for all live game state.
-- Every service reads and writes through here; nothing else keeps its own
-- copy of player cash, bases, conveyor or discoveries.

local Players = game:GetService("Players")
local GameConfig = require(game:GetService("ReplicatedStorage").Shared.GameConfig)

local DataService = {}

-- state[player] = {
--   cash, rebirthTier, baseIndex, lockUntil, lockReadyAt,
--   slots = { [1..8] = brainrotInstance or nil },
--   discoveries = { [brainrotId] = true },
--   quests = { [questId] = progress },
--   questsClaimed = { [questId] = true },
-- }
-- brainrotInstance = { uid, defId, mutation, owner (Player or nil),
--   where = "conveyor" | "base" | "carried" | "fused", slot, baseIndex, model }
DataService.Players = {}
DataService.Conveyor = {} -- list of brainrot instances currently on the belt
DataService.GoldenHourUntil = 0
DataService.NextUid = 1

function DataService.newUid()
	local uid = DataService.NextUid
	DataService.NextUid = DataService.NextUid + 1
	return uid
end

function DataService.getState(player)
	return DataService.Players[player.UserId]
end

function DataService.createPlayerState(player, baseIndex)
	local state = {
		cash = GameConfig.STARTING_CASH,
		rebirthTier = 0,
		baseIndex = baseIndex,
		lockUntil = 0,
		lockReadyAt = 0,
		slots = {},
		discoveries = {},
		quests = {},
		questsClaimed = {},
	}
	for i = 1, GameConfig.BASE_SLOTS do
		state.slots[i] = nil
	end
	DataService.Players[player.UserId] = state
	return state
end

function DataService.removePlayerState(player)
	DataService.Players[player.UserId] = nil
end

function DataService.addCash(player, amount)
	local state = DataService.getState(player)
	if not state then
		return
	end
	state.cash = math.max(0, state.cash + amount)
end

function DataService.ownsSlot(player, slotIndex)
	local state = DataService.getState(player)
	return state and state.slots[slotIndex] or nil
end

function DataService.freeSlotIndex(player)
	local state = DataService.getState(player)
	if not state then
		return nil
	end
	for i = 1, GameConfig.BASE_SLOTS do
		if state.slots[i] == nil then
			return i
		end
	end
	return nil
end

function DataService.baseIncomePerSecond(player)
	local state = DataService.getState(player)
	if not state then
		return 0
	end
	local Catalog = require(game:GetService("ReplicatedStorage").Shared.BrainrotCatalog)
	local total = 0
	for _, inst in ipairs(state.slots) do
		if inst then
			local def = Catalog.getById(inst.defId)
			total = total + Catalog.incomeFor(def, inst.mutation, state.rebirthTier)
		end
	end
	if os.time() < DataService.GoldenHourUntil then
		total = total * GameConfig.GOLDEN_HOUR_MULT
	end
	return total
end

function DataService.isBaseLocked(player)
	local state = DataService.getState(player)
	return state and os.time() < state.lockUntil
end

function DataService.markDiscovered(player, defId)
	local state = DataService.getState(player)
	if state then
		state.discoveries[defId] = true
	end
end

-- Removes a conveyor instance by uid; returns it or nil.
function DataService.takeFromConveyor(uid)
	for i, inst in ipairs(DataService.Conveyor) do
		if inst.uid == uid then
			table.remove(DataService.Conveyor, i)
			return inst
		end
	end
	return nil
end

function DataService.findOnConveyor(uid)
	for _, inst in ipairs(DataService.Conveyor) do
		if inst.uid == uid then
			return inst
		end
	end
	return nil
end

Players.PlayerRemoving:Connect(function(player)
	DataService.removePlayerState(player)
end)

return DataService
