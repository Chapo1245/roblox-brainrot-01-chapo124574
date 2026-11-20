-- init (server): boots Brainrot Bodega.
-- Wires every service, assigns bases, connects the remotes and starts
-- the conveyor, income, sync and event loops.

local Players = game:GetService("Players")

local NetworkService = require(script.Parent.NetworkService)
local DataService = require(script.Parent.DataService)
local WorldBuilder = require(script.Parent.WorldBuilder)
local BrainrotSpawner = require(script.Parent.BrainrotSpawner)
local BaseService = require(script.Parent.BaseService)
local EconomyService = require(script.Parent.EconomyService)
local EventService = require(script.Parent.EventService)
local QuestService = require(script.Parent.QuestService)
local FuseService = require(script.Parent.FuseService)

local remotes = NetworkService.setup()
local world = WorldBuilder.build()

BrainrotSpawner.setup(world)
BaseService.setup(world)
EconomyService.setup(remotes)
EventService.setup(remotes, world)

local function onPlayerAdded(player)
	local baseIndex = BaseService.assignBase(player)
	if not baseIndex then
		player:Kick("The Bodega is full right now. Try again soon!")
		return
	end
	DataService.createPlayerState(player, baseIndex)
	BaseService.setOwnerLabel(player)
end

local function onPlayerRemoving(player)
	local state = DataService.getState(player)
	if state then
		for _, inst in ipairs(state.slots) do
			if inst and inst.model and inst.model.Parent then
				inst.model:Destroy()
			end
		end
	end
	BaseService.clearOwnerLabel(player)
	BaseService.freeBase(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- Remotes: the client HUD talks to the server through these.
remotes.BuyBrainrot.OnServerEvent:Connect(function(player, uid)
	local ok, msg = EconomyService.buyBrainrot(player, uid)
	if not ok then
		EconomyService.notify(player, msg)
	end
end)

remotes.ToggleLock.OnServerEvent:Connect(function(player)
	local ok, msg = BaseService.tryLock(player)
	EconomyService.notify(player, msg)
end)

remotes.FuseBrainrots.OnServerEvent:Connect(function(player, uid1, uid2, uid3)
	local ok, msg = FuseService.fuse(player, uid1, uid2, uid3)
	EconomyService.notify(player, msg)
end)

remotes.ClaimQuest.OnServerEvent:Connect(function(player, questId)
	local ok, msg = QuestService.claimQuest(player, questId)
	EconomyService.notify(player, msg)
end)

remotes.Rebirth.OnServerEvent:Connect(function(player)
	local ok, msg = EconomyService.rebirth(player)
	EconomyService.notify(player, msg)
end)

remotes.SellBrainrot.OnServerEvent:Connect(function(player, uid)
	local ok, msg = EconomyService.sellBrainrot(player, uid)
	if not ok then
		EconomyService.notify(player, msg)
	end
end)

-- Loops: conveyor, income, client sync, events.
BrainrotSpawner.start()
EconomyService.startIncomeLoop()
EconomyService.startSyncLoop()
EventService.start()
