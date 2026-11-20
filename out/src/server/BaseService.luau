-- BaseService (server): player bases, slots, locks and stealing.
-- A base has 8 slots. Buying places a brainrot on a free slot. Stealing
-- lifts a brainrot off a rival's unlocked base and carries it home.

local Players = game:GetService("Players")
local GameConfig = require(game:GetService("ReplicatedStorage").Shared.GameConfig)
local DataService = require(script.Parent.DataService)
local WorldBuilder = require(script.Parent.WorldBuilder)

local BaseService = {}

local world = nil
local takenBases = {} -- [baseIndex] = player

function BaseService.setup(worldTable)
	world = worldTable
end

function BaseService.assignBase(player)
	for i = 1, GameConfig.MAX_PLAYERS do
		if not takenBases[i] then
			takenBases[i] = player
			return i
		end
	end
	return nil
end

function BaseService.freeBase(player)
	for i, owner in pairs(takenBases) do
		if owner == player then
			takenBases[i] = nil
		end
	end
end

function BaseService.baseOf(player)
	local state = DataService.getState(player)
	if not state then
		return nil
	end
	return world.bases[state.baseIndex]
end

function BaseService.setOwnerLabel(player)
	local base = BaseService.baseOf(player)
	if base and base.ownerLabel then
		base.ownerLabel.Text = player.DisplayName
	end
end

function BaseService.clearOwnerLabel(player)
	local state = DataService.getState(player)
	if not state then
		return
	end
	local base = world.bases[state.baseIndex]
	if base and base.ownerLabel then
		base.ownerLabel.Text = "empty"
	end
end

-- Moves a model to a slot over `duration` seconds, then snaps it in place.
local function moveModelTo(model, targetCFrame, duration)
	local startCFrame = model:GetPivot()
	local steps = 20
	for step = 1, steps do
		local alpha = step / steps
		local pos = startCFrame.Position:Lerp(targetCFrame.Position, alpha)
		local cf = CFrame.new(pos) * targetCFrame.Rotation
		model:PivotTo(cf)
		task.wait(duration / steps)
	end
	model:PivotTo(targetCFrame)
end

function BaseService.placeOnSlot(player, inst, slotIndex)
	local state = DataService.getState(player)
	local base = BaseService.baseOf(player)
	if not state or not base then
		return false
	end
	local slotPos = base.slots[slotIndex]
	if not slotPos then
		return false
	end
	state.slots[slotIndex] = inst
	inst.where = "base"
	inst.slot = slotIndex
	inst.baseIndex = state.baseIndex
	inst.owner = player
	local target = CFrame.lookAt(slotPos, slotPos + base.facing.LookVector)
	task.spawn(function()
		moveModelTo(inst.model, target, 1)
	end)
	return true
end

function BaseService.removeFromSlot(player, slotIndex)
	local state = DataService.getState(player)
	if not state then
		return nil
	end
	local inst = state.slots[slotIndex]
	state.slots[slotIndex] = nil
	if inst then
		inst.where = "carried"
		inst.slot = nil
	end
	return inst
end

-- Locks the caller's base for LOCK_DURATION. Returns true on success.
function BaseService.tryLock(player)
	local state = DataService.getState(player)
	if not state then
		return false, "No state"
	end
	local now = os.time()
	if now < state.lockReadyAt then
		return false, "Lock recharging: " .. (state.lockReadyAt - now) .. "s left"
	end
	state.lockUntil = now + GameConfig.LOCK_DURATION
	state.lockReadyAt = state.lockUntil + GameConfig.LOCK_COOLDOWN
	return true, "Base locked for " .. GameConfig.LOCK_DURATION .. "s!"
end

-- Steal: lift a brainrot off the victim's slot and carry it home.
-- Returns true when the carry starts.
function BaseService.trySteal(thief, victimUserId, slotIndex)
	local victim = Players:GetPlayerByUserId(victimUserId)
	if not victim or victim == thief then
		return false, "Invalid target"
	end
	if DataService.isBaseLocked(victim) then
		return false, "That base is locked!"
	end
	local thiefState = DataService.getState(thief)
	if not thiefState then
		return false, "No state"
	end
	if not DataService.freeSlotIndex(thief) then
		return false, "Your base is full!"
	end
	local inst = BaseService.removeFromSlot(victim, slotIndex)
	if not inst then
		return false, "Nothing there"
	end
	task.spawn(function()
		BaseService.carryHome(thief, victim, inst)
	end)
	return true, "Stole " .. inst.defId .. "! Run home!"
end

-- Carries a stolen brainrot above the thief's head until they reach
-- their own base, then places it. If the thief dies or leaves, the
-- brainrot goes back to the victim's slot.
function BaseService.carryHome(thief, victim, inst)
	local character = thief.Character
	if not character then
		BaseService.returnStolen(victim, inst)
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then
		BaseService.returnStolen(victim, inst)
		return
	end
	local thiefState = DataService.getState(thief)
	local thiefBase = BaseService.baseOf(thief)
	local carried = true
	local diedConn
	diedConn = humanoid.Died:Connect(function()
		carried = false
	end)
	while carried do
		task.wait(0.1)
		if not thief.Parent or not thiefState then
			carried = false
			break
		end
		local char = thief.Character
		local rt = char and char:FindFirstChild("HumanoidRootPart")
		if not rt then
			carried = false
			break
		end
		local pos = rt.Position + Vector3.new(0, 4, 0)
		if inst.model and inst.model.Parent then
			inst.model:PivotTo(CFrame.new(pos))
		end
		-- Reached home? The thief's base center is the home zone.
		if thiefBase and (rt.Position - thiefBase.center).Magnitude < 14 then
			local slotIndex = DataService.freeSlotIndex(thief)
			if slotIndex then
				inst.owner = thief
				BaseService.placeOnSlot(thief, inst, slotIndex)
				local QuestService = require(script.Parent.QuestService)
				QuestService.report(thief, "steal", 1)
				carried = false
			end
		end
	end
	if diedConn then
		diedConn:Disconnect()
	end
	if carried == false and inst.where == "carried" then
		BaseService.returnStolen(victim, inst)
	end
end

function BaseService.returnStolen(victim, inst)
	local victimState = DataService.getState(victim)
	if not victimState then
		if inst.model and inst.model.Parent then
			inst.model:Destroy()
		end
		return
	end
	local slotIndex = DataService.freeSlotIndex(victim)
	if slotIndex then
		BaseService.placeOnSlot(victim, inst, slotIndex)
	else
		if inst.model and inst.model.Parent then
			inst.model:Destroy()
		end
	end
end

return BaseService
