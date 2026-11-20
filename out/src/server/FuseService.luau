-- FuseService (server): the Fuse-O-Matic.
-- Feed it 3 brainrots of the same rarity from your base and it spits out
-- 1 brainrot of the next rarity up. The three go in; one better comes out.

local Catalog = require(game:GetService("ReplicatedStorage").Shared.BrainrotCatalog)
local DataService = require(script.Parent.DataService)
local BaseService = require(script.Parent.BaseService)
local WorldBuilder = require(script.Parent.WorldBuilder)
local BrainrotSpawner = require(script.Parent.BrainrotSpawner)

local FuseService = {}

-- Fuses 3 of the player's own slot brainrots (same rarity) into one of
-- the next rarity. Returns true + the new brainrot's name on success.
function FuseService.fuse(player, uid1, uid2, uid3)
	local state = DataService.getState(player)
	if not state then
		return false, "No state"
	end
	local uids = { uid1, uid2, uid3 }
	local picked = {}
	for _, uid in ipairs(uids) do
		local found = nil
		for slotIndex, inst in ipairs(state.slots) do
			if inst and inst.uid == uid then
				found = { inst = inst, slot = slotIndex }
				break
			end
		end
		if not found then
			return false, "One of those brainrots is not on your base"
		end
		table.insert(picked, found)
	end
	local rarity = Catalog.getById(picked[1].inst.defId).rarity
	for _, entry in ipairs(picked) do
		if Catalog.getById(entry.inst.defId).rarity ~= rarity then
			return false, "All three must share a rarity!"
		end
	end
	if rarity == "Prismatic" then
		return false, "Prismatic cannot be fused further!"
	end
	-- Remove the three.
	for _, entry in ipairs(picked) do
		state.slots[entry.slot] = nil
		if entry.inst.model and entry.inst.model.Parent then
			entry.inst.model:Destroy()
		end
	end
	-- Roll one of the next rarity up.
	local nextRarity = Catalog.nextRarity(rarity)
	local pool = Catalog.byRarity[nextRarity]
	local def = pool[math.random(1, #pool)]
	local mutation = Catalog.rollMutation()
	local slotIndex = DataService.freeSlotIndex(player)
	if not slotIndex then
		return false, "No free slot for the result"
	end
	local uid = DataService.newUid()
	local model = WorldBuilder.buildBrainrotModel(def, mutation)
	model:SetAttribute("uid", uid)
	WorldBuilder.setIncomeLabel(model, "$" .. Catalog.incomeFor(def, mutation, state.rebirthTier) .. "/s")
	-- The fused brainrot pops out of the Fuse-O-Matic, then walks home.
	model:PivotTo(CFrame.new(Vector3.new(18, 4, 34)))
	model.Parent = game:GetService("Workspace").BodegaWorld
	local inst = {
		uid = uid,
		defId = def.id,
		mutation = mutation,
		owner = player,
		where = "base",
		model = model,
	}
	local InteractionService = require(script.Parent.InteractionService)
	InteractionService.attach(model, inst)
	BaseService.placeOnSlot(player, inst, slotIndex)
	DataService.markDiscovered(player, def.id)
	return true, "FUSED into " .. def.name .. " (" .. nextRarity .. ")!"
end

return FuseService
