-- EconomyService (server): cash, income ticks, buying, selling, rebirth.
-- All money moves through here so the economy stays consistent.

local GameConfig = require(game:GetService("ReplicatedStorage").Shared.GameConfig)
local Catalog = require(game:GetService("ReplicatedStorage").Shared.BrainrotCatalog)
local DataService = require(script.Parent.DataService)
local BaseService = require(script.Parent.BaseService)
local QuestService = require(script.Parent.QuestService)
local WorldBuilder = require(script.Parent.WorldBuilder)

local EconomyService = {}

local remotes = nil

function EconomyService.setup(remotesFolder)
	remotes = remotesFolder
end

function EconomyService.notify(player, message)
	local remote = remotes:FindFirstChild("Notify")
	if remote then
		remote:FireClient(player, message)
	end
end

-- Buys a conveyor brainrot: pays, then it walks to a free slot.
function EconomyService.buyBrainrot(player, uid)
	local inst = DataService.findOnConveyor(uid)
	if not inst then
		return false, "That brainrot already left the belt"
	end
	local def = Catalog.getById(inst.defId)
	local state = DataService.getState(player)
	if not state then
		return false, "No state"
	end
	if state.cash < def.price then
		return false, "Not enough cash! Need $" .. def.price
	end
	local slotIndex = DataService.freeSlotIndex(player)
	if not slotIndex then
		return false, "Your base is full!"
	end
	DataService.takeFromConveyor(uid)
	DataService.addCash(player, -def.price)
	DataService.markDiscovered(player, def.id)
	BaseService.placeOnSlot(player, inst, slotIndex)
	QuestService.report(player, "buy", 1)
	QuestService.report(player, "discover", 0) -- refresh collector progress below
	EconomyService.refreshCollector(player)
	EconomyService.notify(player, "Bought " .. def.name .. " for $" .. def.price .. "!")
	return true, "Bought " .. def.name
end

-- Collector quest progress is the count of discoveries, not a counter.
function EconomyService.refreshCollector(player)
	local state = DataService.getState(player)
	if not state then
		return
	end
	local count = 0
	for _ in pairs(state.discoveries) do
		count = count + 1
	end
	state.quests["collector"] = math.min(10, count)
end

-- Sells a brainrot off the player's base for half its price.
function EconomyService.sellBrainrot(player, uid)
	local state = DataService.getState(player)
	if not state then
		return false, "No state"
	end
	for slotIndex, inst in ipairs(state.slots) do
		if inst and inst.uid == uid then
			local def = Catalog.getById(inst.defId)
			local refund = math.floor(def.price * GameConfig.SELL_REFUND)
			state.slots[slotIndex] = nil
			if inst.model and inst.model.Parent then
				inst.model:Destroy()
			end
			DataService.addCash(player, refund)
			EconomyService.notify(player, "Sold " .. def.name .. " for $" .. refund)
			return true, "Sold " .. def.name
		end
	end
	return false, "Brainrot not found on your base"
end

-- Rebirth: sacrifice everything for a permanent +25% income per tier.
function EconomyService.rebirth(player)
	local state = DataService.getState(player)
	if not state then
		return false, "No state"
	end
	local cost = GameConfig.REBIRTH_BASE_COST * (2 ^ state.rebirthTier)
	if state.cash < cost then
		return false, "Rebirth costs $" .. cost
	end
	for slotIndex, inst in ipairs(state.slots) do
		if inst and inst.model and inst.model.Parent then
			inst.model:Destroy()
		end
		state.slots[slotIndex] = nil
	end
	state.cash = GameConfig.STARTING_CASH
	state.rebirthTier = state.rebirthTier + 1
	EconomyService.notify(player, "REBIRTH! Tier " .. state.rebirthTier .. " - income +" .. (state.rebirthTier * 25) .. "% forever!")
	return true, "Reborn at tier " .. state.rebirthTier
end

-- Income tick: every base brainrot pays its $/s into the owner's cash.
function EconomyService.startIncomeLoop()
	task.spawn(function()
		while true do
			task.wait(GameConfig.INCOME_TICK)
			for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
				local income = DataService.baseIncomePerSecond(player)
				if income > 0 then
					DataService.addCash(player, income)
					QuestService.report(player, "income", income)
				end
				local state = DataService.getState(player)
				if state then
					local owned = 0
					for _, inst in ipairs(state.slots) do
						if inst then
							owned = owned + 1
						end
					end
					state.quests["tycoon"] = math.max(state.quests["tycoon"] or 0, owned)
				end
			end
		end
	end)
end

-- Builds the per-player snapshot the client HUD renders.
function EconomyService.snapshot(player)
	local state = DataService.getState(player)
	if not state then
		return nil
	end
	local slots = {}
	for i = 1, GameConfig.BASE_SLOTS do
		local inst = state.slots[i]
		if inst then
			local def = Catalog.getById(inst.defId)
			slots[i] = {
				uid = inst.uid,
				defId = inst.defId,
				name = def.name,
				rarity = def.rarity,
				income = Catalog.incomeFor(def, inst.mutation, state.rebirthTier),
				mutation = inst.mutation and inst.mutation.name or nil,
			}
		else
			slots[i] = nil
		end
	end
	local conveyor = {}
	for _, inst in ipairs(DataService.Conveyor) do
		local def = Catalog.getById(inst.defId)
		table.insert(conveyor, {
			uid = inst.uid,
			defId = inst.defId,
			name = def.name,
			rarity = def.rarity,
			price = def.price,
			income = Catalog.incomeFor(def, inst.mutation, 0),
			mutation = inst.mutation and inst.mutation.name or nil,
		})
	end
	local discoveries = 0
	for _ in pairs(state.discoveries) do
		discoveries = discoveries + 1
	end
	return {
		cash = state.cash,
		income = DataService.baseIncomePerSecond(player),
		rebirthTier = state.rebirthTier,
		rebirthCost = GameConfig.REBIRTH_BASE_COST * (2 ^ state.rebirthTier),
		lockUntil = state.lockUntil,
		lockReadyAt = state.lockReadyAt,
		slots = slots,
		conveyor = conveyor,
		discoveries = discoveries,
		totalBrainrots = #Catalog.BRAINROTS,
		quests = QuestService.snapshot(player),
		goldenHour = os.time() < DataService.GoldenHourUntil,
	}
end

function EconomyService.startSyncLoop()
	local sync = remotes:FindFirstChild("StateSync")
	task.spawn(function()
		while true do
			task.wait(1)
			for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
				local snap = EconomyService.snapshot(player)
				if snap then
					sync:FireClient(player, snap)
				end
			end
		end
	end)
end

return EconomyService
