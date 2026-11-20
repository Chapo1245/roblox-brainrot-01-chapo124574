-- BrainrotSpawner (server): runs the conveyor belt.
-- Spawns brainrots on a timer, walks them down the belt, despawns them
-- at the far gate. Every spawned model gets a ClickDetector so players
-- can buy it by clicking it in the 3D world.

local GameConfig = require(game:GetService("ReplicatedStorage").Shared.GameConfig)
local Catalog = require(game:GetService("ReplicatedStorage").Shared.BrainrotCatalog)
local DataService = require(script.Parent.DataService)
local WorldBuilder = require(script.Parent.WorldBuilder)
local InteractionService = require(script.Parent.InteractionService)

local BrainrotSpawner = {}

local world = nil
local beltFolder = nil

function BrainrotSpawner.setup(worldTable)
	world = worldTable
	beltFolder = Instance.new("Folder")
	beltFolder.Name = "ConveyorBrainrots"
	beltFolder.Parent = world.folder
end

function BrainrotSpawner.spawnBrainrot(forcedMutation)
	local def = Catalog.rollBrainrot()
	local mutation = forcedMutation or Catalog.rollMutation()
	local uid = DataService.newUid()
	local model = WorldBuilder.buildBrainrotModel(def, mutation)
	model:SetAttribute("uid", uid)
	WorldBuilder.setIncomeLabel(model, "$" .. Catalog.incomeFor(def, mutation, 0) .. "/s")

	local startPos = world.conveyor.startPos
	model:PivotTo(CFrame.lookAt(startPos, startPos + Vector3.new(1, 0, 0)))
	model.Parent = beltFolder

	local inst = {
		uid = uid,
		defId = def.id,
		mutation = mutation,
		owner = nil,
		where = "conveyor",
		model = model,
		x = startPos.X,
	}
	table.insert(DataService.Conveyor, inst)
	InteractionService.attach(model, inst)
	return inst
end

function BrainrotSpawner.removeFromConveyor(inst)
	DataService.takeFromConveyor(inst.uid)
	if inst.model and inst.model.Parent then
		inst.model:Destroy()
	end
end

-- One step of the belt: every conveyor brainrot walks forward.
local function stepBelt(dt)
	local startX = world.conveyor.startPos.X
	local endX = world.conveyor.endPos.X
	local i = 1
	while i <= #DataService.Conveyor do
		local inst = DataService.Conveyor[i]
		inst.x = inst.x + GameConfig.CONVEYOR_SPEED * dt
		if inst.x >= endX then
			BrainrotSpawner.removeFromConveyor(inst)
		else
			local pos = Vector3.new(inst.x, world.conveyor.startPos.Y, world.conveyor.startPos.Z)
			if inst.model and inst.model.Parent then
				inst.model:PivotTo(CFrame.lookAt(pos, pos + Vector3.new(1, 0, 0)))
			end
			i = i + 1
		end
	end
end

function BrainrotSpawner.start()
	task.spawn(function()
		while true do
			task.wait(GameConfig.CONVEYOR_INTERVAL)
			if #DataService.Conveyor < GameConfig.CONVEYOR_MAX then
				BrainrotSpawner.spawnBrainrot()
			end
		end
	end)
	task.spawn(function()
		local last = os.clock()
		while true do
			task.wait(0.1)
			local now = os.clock()
			stepBelt(now - last)
			last = now
		end
	end)
end

return BrainrotSpawner
