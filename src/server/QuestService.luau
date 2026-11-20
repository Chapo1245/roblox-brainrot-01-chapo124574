-- QuestService (server): daily quests with cash rewards.
-- Progress is reported by the other services (buy, income, steal,
-- discover, slots) and claimed through the ClaimQuest remote.

local DataService = require(script.Parent.DataService)

local QuestService = {}

QuestService.QUESTS = {
	{ id = "first_stock", name = "First Stock", desc = "Buy 1 brainrot", target = 1, reward = 500, kind = "buy" },
	{ id = "big_earner", name = "Big Earner", desc = "Earn $10,000 from your bases", target = 10000, reward = 2000, kind = "income" },
	{ id = "sticky_fingers", name = "Sticky Fingers", desc = "Steal 1 brainrot", target = 1, reward = 1500, kind = "steal" },
	{ id = "collector", name = "Collector", desc = "Discover 10 different brainrots", target = 10, reward = 3000, kind = "discover" },
	{ id = "tycoon", name = "Tycoon", desc = "Own 8 brainrots at once", target = 8, reward = 5000, kind = "slots" },
}

function QuestService.report(player, kind, amount)
	local state = DataService.getState(player)
	if not state then
		return
	end
	for _, quest in ipairs(QuestService.QUESTS) do
		if quest.kind == kind then
			local current = state.quests[quest.id] or 0
			if current < quest.target then
				state.quests[quest.id] = math.min(quest.target, current + amount)
			end
		end
	end
end

function QuestService.claimQuest(player, questId)
	local state = DataService.getState(player)
	if not state then
		return false, "No state"
	end
	local quest = nil
	for _, q in ipairs(QuestService.QUESTS) do
		if q.id == questId then
			quest = q
			break
		end
	end
	if not quest then
		return false, "Unknown quest"
	end
	if state.questsClaimed[questId] then
		return false, "Already claimed"
	end
	local progress = state.quests[questId] or 0
	if progress < quest.target then
		return false, "Not complete yet"
	end
	state.questsClaimed[questId] = true
	DataService.addCash(player, quest.reward)
	return true, "Quest complete! +$" .. quest.reward
end

-- Snapshot of all quests for the client sync.
function QuestService.snapshot(player)
	local state = DataService.getState(player)
	local out = {}
	for _, quest in ipairs(QuestService.QUESTS) do
		local progress = state and (state.quests[quest.id] or 0) or 0
		table.insert(out, {
			id = quest.id,
			name = quest.name,
			desc = quest.desc,
			progress = progress,
			target = quest.target,
			reward = quest.reward,
			claimed = state and state.questsClaimed[quest.id] or false,
		})
	end
	return out
end

return QuestService
